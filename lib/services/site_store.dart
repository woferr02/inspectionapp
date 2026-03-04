import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/audit_service.dart';
import 'package:health_safety_inspection/widgets/sync_indicator.dart';

/// Manages sites with Firestore persistence (org-scoped when applicable).
/// Uses a real-time snapshot listener so sites created on the dashboard
/// appear in the mobile app immediately.
class SiteStore extends ChangeNotifier {
  SiteStore._();
  static final SiteStore instance = SiteStore._();

  final List<Site> _sites = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  UnmodifiableListView<Site> get sites => UnmodifiableListView(_sites);

  /// Start a real-time listener on the sites collection.
  /// Sites added/updated/deleted on the dashboard appear instantly.
  Future<void> loadForCurrentUser() async {
    // Cancel any previous listener.
    await _subscription?.cancel();
    _subscription = null;
    _sites.clear();

    final ref = AuthService.instance.sitesRef;
    if (ref != null) {
      // Do an initial one-time fetch so the UI has data immediately...
      try {
        final snapshot = await ref.orderBy('name').get();
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              // Use Firestore doc id as fallback when 'id' field is missing
              // (e.g. sites created from the web dashboard via addDoc).
              if (!data.containsKey('id') || (data['id'] as String?) == null || (data['id'] as String).isEmpty) {
                data['id'] = doc.id;
              }
              _sites.add(Site.fromJson(data));
            }
          } catch (_) {}
        }
      } catch (_) {}

      // ...then subscribe to real-time updates.
      _subscription = ref.orderBy('name').snapshots().listen((snapshot) {
        _sites.clear();
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              if (!data.containsKey('id') || (data['id'] as String?) == null || (data['id'] as String).isEmpty) {
                data['id'] = doc.id;
              }
              _sites.add(Site.fromJson(data));
            }
          } catch (_) {}
        }
        notifyListeners();
      }, onError: (_) {});
    }

    // Demo mode: seed mock data when not authenticated.
    if (_sites.isEmpty && AuthService.instance.currentUser == null) {
      _sites.addAll(List<Site>.from(MockData.sites));
    }

    notifyListeners();
  }

  /// Cancel the real-time listener (call on sign-out).
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Site? findById(String id) {
    for (final site in _sites) {
      if (site.id == id) return site;
    }
    return null;
  }

  Site? findByName(String name) {
    for (final site in _sites) {
      if (site.name == name) return site;
    }
    return null;
  }

  /// Create a new site and persist to Firestore.
  Site addSite({
    required String name,
    required String address,
    String? contactName,
    String? contactPhone,
    String notes = '',
  }) {
    final site = Site(
      id: 'site-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      contactName: contactName,
      contactPhone: contactPhone,
      notes: notes,
    );
    _sites.insert(0, site);
    notifyListeners();
    _persist(site);
    AuditService.instance.log(
      action: AuditAction.siteCreated,
      targetId: site.id,
      description: 'Created site "${site.name}"',
    );
    return site;
  }

  /// Update an existing site.
  void updateSite(Site updated) {
    final idx = _sites.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _sites[idx] = updated;
      notifyListeners();
      _persist(updated);
      AuditService.instance.log(
        action: AuditAction.siteUpdated,
        targetId: updated.id,
        description: 'Updated site "${updated.name}"',
      );
    }
  }

  /// Delete a site.
  Future<void> deleteSite(String siteId) async {
    _sites.removeWhere((s) => s.id == siteId);
    notifyListeners();

    AuditService.instance.log(
      action: AuditAction.siteDeleted,
      targetId: siteId,
      description: 'Deleted site $siteId',
    );

    final ref = AuthService.instance.sitesRef;
    if (ref == null) return;
    try {
      await ref.doc(siteId).delete();
    } catch (e) {
      debugPrint('[SiteStore] deleteSite failed: $e');
    }
  }

  Future<void> _persist(Site site) async {
    final ref = AuthService.instance.sitesRef;
    if (ref == null) return;
    try {
      await ref.doc(site.id).set(site.toJson());
      SyncService.instance.markSynced();
    } catch (e) {
      debugPrint('[SiteStore] persist failed: $e');
    }
  }
}
