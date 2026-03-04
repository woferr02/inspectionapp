import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (_) {
      _available = false;
    }

    _initialized = true;
  }

  User? get currentUser {
    if (!_available) return null;
    return FirebaseAuth.instance.currentUser;
  }

  /// Display name pulled from Firebase user (Google name or profile update).
  String get displayName {
    final user = currentUser;
    if (user == null) return 'User';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null) return user.email!.split('@').first;
    return 'User';
  }

  String get email => currentUser?.email ?? '';

  /// Cached profile fields loaded from Firestore after login.
  String _jobTitle = '';
  String _industry = '';
  String _country = '';
  String _orgId = '';
  bool _onboardingComplete = false;

  String get jobTitle => _jobTitle;
  String get industry => _industry;
  String get country => _country;
  String get orgId => _orgId;
  bool get onboardingComplete => _onboardingComplete;

  String get initials {
    final name = displayName;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  // ── Email / Password ──

  /// Create a new account with email + password, then write a Firestore profile.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await initialize();
    if (!_available) throw Exception('Firebase is not configured yet.');

    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Set display name on the Firebase Auth user
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
    }

    // Write initial Firestore profile
    await _writeUserProfile(credential.user);

    return credential;
  }

  /// Sign in with email + password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await initialize();
    if (!_available) throw Exception('Firebase is not configured yet.');

    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Touch profile with latest login timestamp
    await _writeUserProfile(credential.user);

    return credential;
  }

  /// Send password-reset email.
  Future<void> sendPasswordReset(String email) async {
    await initialize();
    if (!_available) throw Exception('Firebase is not configured yet.');
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  // ── Google Sign-In ──

  Future<UserCredential> signInWithGoogle() async {
    await initialize();
    if (!_available) {
      throw Exception('Firebase is not configured yet.');
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Write / merge Firestore profile
    await _writeUserProfile(result.user);

    return result;
  }

  // ── Sign-Out ──

  Future<void> signOut() async {
    await initialize();
    if (!_available) return;
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  // ── Firestore helpers ──

  /// Writes or merges the authenticated user's profile to Firestore.
  Future<void> _writeUserProfile(User? user) async {
    if (user == null || !_available) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Load cached profile fields
      await _loadProfile(user.uid);
    } catch (_) {
      // Firestore write failure should not block auth
    }
  }

  /// Load profile fields (jobTitle, industry, onboardingComplete) from Firestore.
  Future<void> _loadProfile(String uid) async {
    if (!_available) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _jobTitle = data['jobTitle'] as String? ?? '';
        _industry = data['industry'] as String? ?? '';
        _country = data['country'] as String? ?? '';
        _company = data['company'] as String? ?? '';
        _orgId = data['orgId'] as String? ?? '';
        _onboardingComplete = data['onboardingComplete'] as bool? ?? false;
      }
    } catch (_) {}
  }

  /// Reload cached profile fields from Firestore.
  /// Call after the user joins an org so [_orgId] updates in-memory and
  /// all collection refs ([inspectionsRef], [actionsRef], etc.) switch to
  /// the org-scoped path.
  Future<void> reloadProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _loadProfile(uid);
  }

  /// Save onboarding data (job title + industry + country) to Firestore.
  Future<void> completeOnboarding({
    required String jobTitle,
    required String industry,
    String country = '',
  }) async {
    _jobTitle = jobTitle;
    _industry = industry;
    _country = country;
    _onboardingComplete = true;

    final ref = userDoc;
    if (ref == null) return;
    try {
      await ref.set({
        'jobTitle': jobTitle,
        'industry': industry,
        'country': country,
        'onboardingComplete': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AuthService] completeOnboarding failed: $e');
    }
  }

  /// Update editable profile fields and sync to Firestore.
  Future<void> updateProfile({
    String? displayName,
    String? company,
    String? jobTitle,
    String? industry,
  }) async {
    // Update Firebase Auth display name
    if (displayName != null && displayName != this.displayName) {
      try {
        await currentUser?.updateDisplayName(displayName);
        await currentUser?.reload();
      } catch (e) {
        debugPrint('[AuthService] updateDisplayName failed: $e');
      }
    }

    if (jobTitle != null) _jobTitle = jobTitle;
    if (industry != null) _industry = industry;

    final ref = userDoc;
    if (ref == null) return;
    try {
      final updates = <String, dynamic>{};
      if (company != null) updates['company'] = company;
      if (jobTitle != null) updates['jobTitle'] = jobTitle;
      if (industry != null) updates['industry'] = industry;
      if (updates.isNotEmpty) {
        await ref.set(updates, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[AuthService] updateProfile failed: $e');
    }
  }

  /// Cached company name.
  String _company = '';
  String get company => _company;

  /// Convenience: reference to the current user's document.
  DocumentReference? get userDoc {
    final user = currentUser;
    if (user == null || !_available) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  /// The org-level document when the user belongs to an organization.
  DocumentReference? get _orgDoc {
    if (_orgId.isEmpty || !_available) return null;
    return FirebaseFirestore.instance.collection('organizations').doc(_orgId);
  }

  /// Root reference for shared data — org-scoped when possible, else per-user.
  DocumentReference? get _dataRoot => _orgDoc ?? userDoc;

  /// Convenience: reference to the inspections collection (org-scoped or user-scoped).
  CollectionReference? get inspectionsRef {
    return _dataRoot?.collection('inspections');
  }

  /// Convenience: reference to the corrective actions collection.
  CollectionReference? get actionsRef {
    return _dataRoot?.collection('corrective_actions');
  }

  /// Convenience: reference to the schedules collection.
  CollectionReference? get schedulesRef {
    return _dataRoot?.collection('schedules');
  }

  /// Convenience: reference to the sites collection.
  CollectionReference? get sitesRef {
    return _dataRoot?.collection('sites');
  }
}
