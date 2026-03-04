import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';

/// Tracks the last Firestore write timestamp and shows real sync status.
class SyncService extends ChangeNotifier {
  SyncService._();
  static final SyncService instance = SyncService._();

  DateTime? _lastSyncTime;
  bool _syncing = false;

  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _syncing;

  /// Call this from any store after a successful Firestore write.
  void markSynced() {
    _lastSyncTime = DateTime.now();
    _syncing = false;
    notifyListeners();
  }

  /// Call before starting a Firestore write batch.
  void markSyncing() {
    _syncing = true;
    notifyListeners();
  }

  String get statusText {
    if (_syncing) return 'Syncing...';
    if (_lastSyncTime == null) return 'Not synced';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inSeconds < 30) return 'Just synced';
    if (diff.inMinutes < 1) return 'Synced ${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return 'Synced ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Synced ${diff.inHours}h ago';
    return 'Synced ${diff.inDays}d ago';
  }
}

class SyncIndicator extends StatefulWidget {
  /// Legacy parameter kept for backward compatibility; ignored when
  /// [useLive] is true (the default).
  final String lastSynced;
  final bool isSyncing;
  final bool useLive;

  const SyncIndicator({
    super.key,
    this.lastSynced = '',
    this.isSyncing = false,
    this.useLive = true,
  });

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh every 30 seconds to update "Synced Xm ago" text.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.useLive) {
      return _buildRow(context, widget.isSyncing, widget.lastSynced);
    }

    return AnimatedBuilder(
      animation: SyncService.instance,
      builder: (context, _) {
        final svc = SyncService.instance;
        return _buildRow(context, svc.isSyncing, svc.statusText);
      },
    );
  }

  Widget _buildRow(BuildContext context, bool syncing, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (syncing)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SyncService.instance.lastSyncTime != null
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
        ),
      ],
    );
  }
}
