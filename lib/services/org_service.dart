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

  /// Accept an org invite: replace the pending member doc with the real user,
  /// and write `orgId` to the user's profile so data resolves org-scoped.
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

      // Remove the pending placeholder
      await orgMembersRef.doc(pendingMemberId).delete();

      // Add real user member doc
      final member = OrgMember(
        userId: uid,
        email: auth.email,
        displayName: auth.displayName,
        role: OrgRole.inspector,
      );
      await orgMembersRef.doc(uid).set(member.toJson());

      // Write orgId to the user's profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'orgId': orgId}, SetOptions(merge: true));

      await loadForCurrentUser();
      return true;
    } catch (_) {
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
