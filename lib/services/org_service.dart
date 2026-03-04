import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/organization.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/audit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages the current user's organization and team members.
class OrgService extends ChangeNotifier {
  OrgService._();
  static final OrgService instance = OrgService._();

  Organization? _org;
  Organization? get org => _org;
  bool get hasOrg => _org != null;

  UnmodifiableListView<OrgMember> get members =>
      UnmodifiableListView(_org?.members ?? []);

  /// The current user's role within the organization.
  /// Returns null when there is no org or the user isn't a member.
  OrgRole? get currentUserRole {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null || _org == null) return null;
    final match = _org!.members.where((m) => m.userId == uid);
    if (match.isEmpty) return null;
    return match.first.role;
  }

  /// Convenience role checks.
  bool get isAdmin => currentUserRole == OrgRole.admin;
  bool get isManager =>
      currentUserRole == OrgRole.admin || currentUserRole == OrgRole.manager;
  bool get isInspector => currentUserRole != null;

  /// Load the user's organization from Firestore.
  Future<void> loadForCurrentUser() async {
    _org = null;
    final auth = AuthService.instance;
    if (!auth.isAvailable || auth.currentUser == null) {
      notifyListeners();
      return;
    }
    final uid = auth.currentUser!.uid;

    try {
      // Check if user belongs to an org
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final orgId = userDoc.data()?['orgId'] as String?;
      if (orgId == null || orgId.isEmpty) {
        notifyListeners();
        return;
      }

      final orgDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .get();
      if (!orgDoc.exists) {
        notifyListeners();
        return;
      }

      // Load members
      final membersSnap = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('members')
          .get();
      final membersList = membersSnap.docs
          .map((d) => OrgMember.fromJson(d.data()))
          .toList();

      _org = Organization.fromJson(orgDoc.data()!, members: membersList);
    } catch (_) {}
    notifyListeners();
  }

  /// Create a new organization and make current user the admin.
  Future<Organization?> createOrg(String name) async {
    final auth = AuthService.instance;
    if (!auth.isAvailable || auth.currentUser == null) return null;
    final uid = auth.currentUser!.uid;

    final orgId = 'org-${DateTime.now().millisecondsSinceEpoch}';
    final org = Organization(
      id: orgId,
      name: name,
      ownerId: uid,
    );

    final member = OrgMember(
      userId: uid,
      email: auth.email,
      displayName: auth.displayName,
      role: OrgRole.admin,
    );

    try {
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .set(org.toJson());
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('members')
          .doc(uid)
          .set(member.toJson());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'orgId': orgId}, SetOptions(merge: true));

      _org = Organization(
        id: orgId,
        name: name,
        ownerId: uid,
        members: [member],
      );
      notifyListeners();
      return _org;
    } catch (_) {
      return null;
    }
  }

  /// Invite a member by email. Requires admin role.
  Future<bool> inviteMember({
    required String email,
    OrgRole role = OrgRole.inspector,
  }) async {
    if (_org == null) return false;
    if (!isAdmin) return false; // RBAC guard
    final orgId = _org!.id;

    final memberId = 'pending-${DateTime.now().millisecondsSinceEpoch}';
    final member = OrgMember(
      userId: memberId,
      email: email,
      role: role,
    );

    try {
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('members')
          .doc(memberId)
          .set(member.toJson());

      final updatedMembers = [..._org!.members, member];
      _org = Organization(
        id: _org!.id,
        name: _org!.name,
        ownerId: _org!.ownerId,
        members: updatedMembers,
        createdAt: _org!.createdAt,
      );
      notifyListeners();
      AuditService.instance.log(
        action: AuditAction.memberInvited,
        targetId: memberId,
        description: 'Invited $email as ${role.name}',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check all orgs for a pending invite matching the current user's email.
  /// Returns a map with {orgId, orgName, pendingMemberId, role} or null.
  Future<Map<String, String>?> checkPendingInvites() async {
    final auth = AuthService.instance;
    if (!auth.isAvailable || auth.currentUser == null) return null;
    final email = auth.email.toLowerCase().trim();
    if (email.isEmpty) return null;

    try {
      // Query all orgs for pending members matching this email.
      // Firestore doesn't support cross-collection queries, so we use a
      // collectionGroup query on the 'members' subcollection.
      final snap = await FirebaseFirestore.instance
          .collectionGroup('members')
          .where('email', isEqualTo: email)
          .where('userId', isGreaterThanOrEqualTo: 'pending-')
          .where('userId', isLessThan: 'pending.')
          .get();

      if (snap.docs.isEmpty) return null;

      final pendingDoc = snap.docs.first;
      final data = pendingDoc.data();
      final pendingMemberId = data['userId'] as String? ?? pendingDoc.id;
      final role = data['role'] as String? ?? 'inspector';

      // Walk up the path to get the org ID: members/{id} → organizations/{orgId}
      final orgRef = pendingDoc.reference.parent.parent;
      if (orgRef == null) return null;
      final orgId = orgRef.id;

      // Fetch org name
      final orgDoc = await orgRef.get();
      final orgName = orgDoc.data()?['name'] as String? ?? 'Unknown';

      return {
        'orgId': orgId,
        'orgName': orgName,
        'pendingMemberId': pendingMemberId,
        'role': role,
      };
    } catch (e) {
      debugPrint('[OrgService] checkPendingInvites failed: $e');
      return null;
    }
  }

  /// Accept an org invite: replace the pending member doc with the real user,
  /// and write `orgId` to the user's profile so data resolves org-scoped.
  /// Preserves the role assigned by the admin who created the invite.
  Future<bool> acceptInvite({
    required String orgId,
    required String pendingMemberId,
  }) async {
    final auth = AuthService.instance;
    if (!auth.isAvailable || auth.currentUser == null) return false;
    final uid = auth.currentUser!.uid;

    try {
      final orgMembersRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('members');

      // Read the pending doc to preserve the invited role
      final pendingDoc = await orgMembersRef.doc(pendingMemberId).get();
      final invitedRole = pendingDoc.data()?['role'] as String? ?? 'inspector';
      final role = OrgRole.values.firstWhere(
        (e) => e.name == invitedRole,
        orElse: () => OrgRole.inspector,
      );

      // Remove the pending placeholder
      await orgMembersRef.doc(pendingMemberId).delete();

      // Add real user member doc with the originally invited role
      final member = OrgMember(
        userId: uid,
        email: auth.email,
        displayName: auth.displayName,
        role: role,
      );
      await orgMembersRef.doc(uid).set(member.toJson());

      // Write orgId to the user's profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'orgId': orgId}, SetOptions(merge: true));

      // Refresh in-memory _orgId so all collection refs switch to org-scoped.
      await auth.reloadProfile();

      AuditService.instance.log(
        action: AuditAction.memberInvited,
        targetId: uid,
        description: 'Accepted invite to org $orgId as ${role.name}',
      );

      await loadForCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Join an org by its code (which is the org's Firestore doc ID).
  /// Checks if the org exists and if there's a pending invite for this email.
  /// If no pending invite, adds the user directly as inspector (open join).
  Future<bool> joinByCode(String orgCode) async {
    final auth = AuthService.instance;
    if (!auth.isAvailable || auth.currentUser == null) return false;
    final uid = auth.currentUser!.uid;
    final email = auth.email.toLowerCase().trim();

    try {
      // Verify org exists
      final orgDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgCode)
          .get();
      if (!orgDoc.exists) return false;

      final membersRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgCode)
          .collection('members');

      // Check for a pending invite matching this email
      final pendingSnap = await membersRef
          .where('email', isEqualTo: email)
          .get();

      String? pendingId;
      OrgRole invitedRole = OrgRole.inspector;
      for (final doc in pendingSnap.docs) {
        final userId = doc.data()['userId'] as String? ?? '';
        if (userId.startsWith('pending-')) {
          pendingId = userId;
          final roleStr = doc.data()['role'] as String? ?? 'inspector';
          invitedRole = OrgRole.values.firstWhere(
            (e) => e.name == roleStr,
            orElse: () => OrgRole.inspector,
          );
          break;
        }
      }

      if (pendingId != null) {
        // Accept the existing invite (preserving role)
        return await acceptInvite(
          orgId: orgCode,
          pendingMemberId: pendingId,
        );
      }

      // No pending invite — join as inspector directly
      final member = OrgMember(
        userId: uid,
        email: email,
        displayName: auth.displayName,
        role: invitedRole,
      );
      await membersRef.doc(uid).set(member.toJson());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'orgId': orgCode}, SetOptions(merge: true));

      // Refresh in-memory _orgId so all collection refs switch to org-scoped.
      await auth.reloadProfile();

      AuditService.instance.log(
        action: AuditAction.memberInvited,
        targetId: uid,
        description: 'Joined org $orgCode via code as ${invitedRole.name}',
      );

      await loadForCurrentUser();
      return true;
    } catch (e) {
      debugPrint('[OrgService] joinByCode failed: $e');
      return false;
    }
  }

  /// Update a member's role. Requires admin role.
  Future<void> updateMemberRole(String memberId, OrgRole role) async {
    if (_org == null || !isAdmin) return;
    try {
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(_org!.id)
          .collection('members')
          .doc(memberId)
          .update({'role': role.name});
      AuditService.instance.log(
        action: AuditAction.memberRoleChanged,
        targetId: memberId,
        description: 'Changed member $memberId role to ${role.name}',
      );
      await loadForCurrentUser();
    } catch (e) {
      debugPrint('[OrgService] updateMemberRole failed: $e');
    }
  }

  /// Remove a member. Requires admin role.
  Future<void> removeMember(String memberId) async {
    if (_org == null || !isAdmin) return;
    try {
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(_org!.id)
          .collection('members')
          .doc(memberId)
          .delete();
      AuditService.instance.log(
        action: AuditAction.memberRemoved,
        targetId: memberId,
        description: 'Removed member $memberId from organization',
      );
      await loadForCurrentUser();
    } catch (e) {
      debugPrint('[OrgService] removeMember failed: $e');
    }
  }
}
