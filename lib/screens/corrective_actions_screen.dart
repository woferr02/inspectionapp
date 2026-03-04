import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_safety_inspection/models/corrective_action.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class CorrectiveActionsScreen extends StatefulWidget {
  final String? inspectionId;

  const CorrectiveActionsScreen({super.key, this.inspectionId});

  @override
  State<CorrectiveActionsScreen> createState() =>
      _CorrectiveActionsScreenState();
}

class _CorrectiveActionsScreenState extends State<CorrectiveActionsScreen> {
  String _filter = 'all'; // all, open, overdue, resolved

  @override
  Widget build(BuildContext context) {
    final store = ActionStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        var actions = widget.inspectionId != null
            ? store.forInspection(widget.inspectionId!)
            : store.actions.toList();

        switch (_filter) {
          case 'open':
            actions = actions
                .where((a) => a.status == ActionStatus.open || a.status == ActionStatus.inProgress)
                .toList();
            break;
          case 'overdue':
            actions = actions.where((a) => a.isOverdue).toList();
            break;
          case 'resolved':
            actions = actions
                .where((a) => a.status == ActionStatus.resolved || a.status == ActionStatus.closed)
                .toList();
            break;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: AppViewport(
              padding: EdgeInsets.zero,
              child: Column(
              children: [
                PageHeader(
                  title: 'Corrective Actions',
                  subtitle: widget.inspectionId != null ? 'Inspection actions' : null,
                  showBackButton: widget.inspectionId != null,
                  showMenuButton: widget.inspectionId == null,
                ),
                // Filter row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: widget.inspectionId != null
                            ? store.forInspection(widget.inspectionId!).length
                            : store.actions.length,
                        isActive: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Open',
                        count: store.openActions.length,
                        isActive: _filter == 'open',
                        onTap: () => setState(() => _filter = 'open'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Overdue',
                        count: store.overdueActions.length,
                        isActive: _filter == 'overdue',
                        color: AppColors.error,
                        onTap: () => setState(() => _filter = 'overdue'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Resolved',
                        isActive: _filter == 'resolved',
                        onTap: () => setState(() => _filter = 'resolved'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: actions.isEmpty
                      ? EmptyState(
                          icon: Icons.check_circle_outline,
                          title: _filter == 'all'
                              ? 'No corrective actions yet'
                              : 'No $_filter actions',
                          description: _filter == 'all'
                              ? 'Actions will appear here when created'
                              : 'No actions match this filter',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                          itemCount: actions.length,
                          itemBuilder: (context, index) {
                            final action = actions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ActionCard(
                                action: action,
                                onResolve: () => store.resolveAction(action.id),
                                onClose: () => store.closeAction(action.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isActive,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive
              ? activeColor.withValues(alpha: 0.12)
              : AppColors.surfaceColor(context),
          border: Border.all(
            color: isActive ? activeColor : AppColors.borderColor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : AppColors.textSecondary(context),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : AppColors.textTertiary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final CorrectiveAction action;
  final VoidCallback onResolve;
  final VoidCallback onClose;

  const _ActionCard({
    required this.action,
    required this.onResolve,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final dueDateStr = action.dueDate != null
        ? DateFormat('d MMM yyyy').format(action.dueDate!)
        : null;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: severity + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: action.severityColor.withValues(alpha: 0.12),
                ),
                child: Text(
                  action.severityLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: action.severityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: action.statusColor.withValues(alpha: 0.12),
                ),
                child: Text(
                  action.statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: action.statusColor,
                  ),
                ),
              ),
              if (action.isOverdue) ...[
                const SizedBox(width: 8),
                Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
              ],
              const Spacer(),
              if (dueDateStr != null)
                Text(
                  dueDateStr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: action.isOverdue
                        ? AppColors.error
                        : AppColors.textTertiary(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            action.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),

          if (action.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              action.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],

          if (action.assignee.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: AppColors.textTertiary(context)),
                const SizedBox(width: 4),
                Text(
                  action.assignee,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (action.status == ActionStatus.open ||
              action.status == ActionStatus.inProgress) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tappable(
                  onTap: onResolve,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.success.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      'Mark Resolved',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (action.status == ActionStatus.resolved) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tappable(
                  onTap: onClose,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.borderColor(context),
                    ),
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
