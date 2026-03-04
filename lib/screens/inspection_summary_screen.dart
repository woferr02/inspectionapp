import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/services/ai_service.dart';
import 'package:health_safety_inspection/services/export_service.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/services/pdf_service.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/pro_lock.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';
import 'package:health_safety_inspection/widgets/signature_pad.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class InspectionSummaryScreen extends StatefulWidget {
  final Inspection inspection;

  const InspectionSummaryScreen({super.key, required this.inspection});

  @override
  State<InspectionSummaryScreen> createState() =>
      _InspectionSummaryScreenState();
}

class _InspectionSummaryScreenState extends State<InspectionSummaryScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? _inspectorSig;
  Uint8List? _managerSig;
  RiskAssessment? _risk;
  bool _loadingAi = false;
  late TabController _tabController;

  static const _tabs = ['Overview', 'Scores', 'Sign', 'Export'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runAiAssessment(Inspection current) async {
    setState(() => _loadingAi = true);
    try {
      final store = InspectionStore.instance;
      final Map<String, String> answers = {};
      final Map<String, String> notes = {};
      for (final section in current.sections) {
        answers.addAll(store.sectionAnswers(
          inspectionId: current.id,
          sectionId: section.id,
        ));
        notes.addAll(store.sectionNotes(
          inspectionId: current.id,
          sectionId: section.id,
        ));
      }
      final result = await AiService.instance.analyseInspection(
        inspectionName: current.name,
        siteName: current.siteName,
        answers: answers,
        notes: notes,
        sectionNames: current.sections.map((s) => s.name).toList(),
      );
      if (mounted) setState(() => _risk = result);
    } catch (_) {
      if (mounted) {
        AppToast.show(context, 'AI analysis failed – using local fallback');
      }
    }
    if (mounted) setState(() => _loadingAi = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final current = store.findById(widget.inspection.id) ??
            store.ensureInspection(widget.inspection);
        final isReported = current.status == InspectionStatus.submitted;
        final actions = ActionStore.instance.forInspection(current.id);

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                const PageHeader(
                  title: 'Inspection Summary',
                  showBackButton: true,
                ),
                // ── Tab bar ──
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.borderColor(context), width: 1),
                    ),
                  ),
                  child: AppViewport(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary(context),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          Theme.of(context).textTheme.labelMedium,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2.5,
                      dividerColor: Colors.transparent,
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ),
                ),
                // ── Tab content ──
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(
                        current: current,
                        isReported: isReported,
                        actions: actions,
                        risk: _risk,
                        loadingAi: _loadingAi,
                        onRunAi: () => _runAiAssessment(current),
                      ),
                      _ScoresTab(inspection: current),
                      _SignTab(
                        inspectorSig: _inspectorSig,
                        managerSig: _managerSig,
                        onInspectorSig: (b) =>
                            setState(() => _inspectorSig = b),
                        onManagerSig: (b) => setState(() => _managerSig = b),
                      ),
                      _ExportTab(
                        current: current,
                        isReported: isReported,
                        actions: actions,
                        inspectorSig: _inspectorSig,
                        managerSig: _managerSig,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TAB 1: Overview – status, meta, AI risk
// ═══════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final Inspection current;
  final bool isReported;
  final List actions;
  final RiskAssessment? risk;
  final bool loadingAi;
  final VoidCallback onRunAi;

  const _OverviewTab({
    required this.current,
    required this.isReported,
    required this.actions,
    required this.risk,
    required this.loadingAi,
    required this.onRunAi,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${current.date.day}/${current.date.month}/${current.date.year}';
    final openCount =
        actions.where((a) => a.status.name == 'open').length;

    return SingleChildScrollView(
      child: AppViewport(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3, AppSpacing.x3, AppSpacing.x3, AppSpacing.x4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            SurfaceCard(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isReported
                              ? AppColors.success
                              : current.statusColor)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isReported
                          ? Icons.check_circle_outline
                          : Icons.assignment_outlined,
                      color: isReported
                          ? AppColors.success
                          : current.statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.statusText,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isReported
                              ? 'Report generated and ready to share.'
                              : 'Inspection finished. Review and generate a report.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2),

            // Meta card
            SurfaceCard(
              child: Column(
                children: [
                  _MetaRow(label: 'Inspection', value: current.name),
                  const SizedBox(height: 10),
                  _MetaRow(label: 'Site', value: current.siteName),
                  const SizedBox(height: 10),
                  _MetaRow(label: 'Date', value: date),
                  const SizedBox(height: 10),
                  _MetaRow(
                      label: 'Inspector', value: current.inspectorName),
                  const SizedBox(height: 10),
                  _MetaRow(
                    label: 'Score',
                    value: current.score == null
                        ? 'Pending'
                        : '${current.score}%',
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _MetaRow(
                      label: 'Actions',
                      value: '${actions.length} ($openCount open)',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2),

            // AI Risk
            ProLock(
              feature: Feature.aiAnalysis,
              child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'AI Risk Assessment',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (risk == null && !loadingAi)
                    Tappable(
                      onTap: onRunAi,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.borderColor(context)),
                        ),
                        child: Center(
                          child: Text(
                            'Run AI analysis',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                  if (loadingAi)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  if (risk != null) ...[
                    _RiskBadge(risk: risk!),
                    const SizedBox(height: 8),
                    Text(
                      risk!.summary,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.textSecondary(context),
                            height: 1.5,
                          ),
                    ),
                    if (risk!.keyFindings.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Key findings',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              )),
                      const SizedBox(height: 4),
                      ...risk!.keyFindings.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('•  ',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(f,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color:
                                                AppColors.textSecondary(
                                                    context),
                                          )),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ],
              ),
            ),
            ), // ProLock
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TAB 2: Scores – MOT-style grade card
// ═══════════════════════════════════════════════════════════════════
class _ScoresTab extends StatelessWidget {
  final Inspection inspection;
  const _ScoresTab({required this.inspection});

  static String _grade(int score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  static String _gradeLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Satisfactory';
    if (score >= 60) return 'Below Standard';
    return 'Fail';
  }

  static Color _gradeColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  static Color _sectionColor(int? score, BuildContext context) {
    if (score == null) return AppColors.textTertiary(context);
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  static String _sectionVerdict(int? score) {
    if (score == null) return 'N/A';
    if (score >= 80) return 'PASS';
    if (score >= 60) return 'ADVISORY';
    return 'FAIL';
  }

  static IconData _sectionIcon(int? score) {
    if (score == null) return Icons.remove_circle_outline;
    if (score >= 80) return Icons.check_circle;
    if (score >= 60) return Icons.warning_amber_rounded;
    return Icons.cancel;
  }

  @override
  Widget build(BuildContext context) {
    final overall = inspection.score;
    final scored =
        inspection.sections.where((s) => s.score != null).toList();
    final advisory =
        scored.where((s) => s.score! >= 60 && s.score! < 80).toList();
    final failed = scored.where((s) => s.score! < 60).toList();

    return SingleChildScrollView(
      child: AppViewport(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3, AppSpacing.x3, AppSpacing.x3, AppSpacing.x4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall grade
            SurfaceCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Inspection Grade',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (overall != null) ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _gradeColor(overall)
                                  .withValues(alpha: 0.12),
                              border: Border.all(
                                color: _gradeColor(overall),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _grade(overall),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _gradeColor(overall),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$overall% — ${_gradeLabel(overall)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _gradeColor(overall),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Complete all sections to see your grade',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.textSecondary(context)),
                        ),
                      ),
                    ),

                  // Summary counts
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: AppColors.backgroundColor(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CountPill(
                          label: 'Pass',
                          count: scored
                              .where((s) => s.score! >= 80)
                              .length,
                          color: AppColors.success,
                        ),
                        _CountPill(
                          label: 'Advisory',
                          count: advisory.length,
                          color: AppColors.warning,
                        ),
                        _CountPill(
                          label: 'Fail',
                          count: failed.length,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2),

            // Section breakdown table
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: AppColors.borderColor(context)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Section',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.textSecondary(context),
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            'Score',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.textSecondary(context),
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: Text(
                            'Result',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.textSecondary(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table rows
                  ...inspection.sections.asMap().entries.map((entry) {
                    final section = entry.value;
                    final isLast =
                        entry.key == inspection.sections.length - 1;
                    final sColor =
                        _sectionColor(section.score, context);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  color: AppColors.borderColor(context),
                                  width: 0.5,
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          Icon(_sectionIcon(section.score),
                              size: 16, color: sColor),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              section.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              section.score != null
                                  ? '${section.score}%'
                                  : '—',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: sColor,
                                  ),
                            ),
                          ),
                          Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              color: sColor.withValues(alpha: 0.12),
                            ),
                            child: Text(
                              _sectionVerdict(section.score),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: sColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2),

            // Advisories & failures
            if (advisory.isNotEmpty || failed.isNotEmpty)
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (advisory.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'Needs Attention (${advisory.length})',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...advisory.map((s) => Padding(
                            padding: const EdgeInsets.only(
                                left: 22, bottom: 3),
                            child: Text(
                              '${s.name}  —  ${s.score}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary(
                                        context),
                                  ),
                            ),
                          )),
                    ],
                    if (advisory.isNotEmpty && failed.isNotEmpty)
                      const SizedBox(height: 12),
                    if (failed.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.cancel,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 6),
                          Text(
                            'Failed (${failed.length})',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...failed.map((s) => Padding(
                            padding: const EdgeInsets.only(
                                left: 22, bottom: 3),
                            child: Text(
                              '${s.name}  —  ${s.score}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary(
                                        context),
                                  ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TAB 3: Signatures
// ═══════════════════════════════════════════════════════════════════
class _SignTab extends StatelessWidget {
  final Uint8List? inspectorSig;
  final Uint8List? managerSig;
  final ValueChanged<Uint8List?> onInspectorSig;
  final ValueChanged<Uint8List?> onManagerSig;

  const _SignTab({
    required this.inspectorSig,
    required this.managerSig,
    required this.onInspectorSig,
    required this.onManagerSig,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AppViewport(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3, AppSpacing.x3, AppSpacing.x3, AppSpacing.x4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspector Signature',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign to confirm that you conducted this inspection.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (inspectorSig == null)
                    SignaturePad(onSigned: onInspectorSig)
                  else
                    _SignaturePreview(bytes: inspectorSig!),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site Manager Signature',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Counter-signature from the site manager or supervisor.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (managerSig == null)
                    SignaturePad(onSigned: onManagerSig)
                  else
                    _SignaturePreview(bytes: managerSig!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TAB 4: Export & Actions
// ═══════════════════════════════════════════════════════════════════
class _ExportTab extends StatelessWidget {
  final Inspection current;
  final bool isReported;
  final List actions;
  final Uint8List? inspectorSig;
  final Uint8List? managerSig;

  const _ExportTab({
    required this.current,
    required this.isReported,
    required this.actions,
    this.inspectorSig,
    this.managerSig,
  });

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;

    return SingleChildScrollView(
      child: AppViewport(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3, AppSpacing.x3, AppSpacing.x3, AppSpacing.x4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF generation
            Text(
              'Report',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.x1),
            PrimaryButton(
              text: isReported ? 'Download PDF' : 'Generate PDF Report',
              width: double.infinity,
              onPressed: () async {
                if (!isReported) {
                  try {
                    store.generateReport(current.id);
                  } catch (e) {
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        'Complete at least 50 % of the inspection before submitting.',
                        isError: true,
                      );
                    }
                    return;
                  }
                }
                await PdfService.instance.shareReport(
                  inspection: current,
                  inspectorSignature: inspectorSig,
                  siteManagerSignature: managerSig,
                );
                if (context.mounted) {
                  AppToast.show(
                      context, 'PDF generated for ${current.name}');
                }
              },
            ),
            const SizedBox(height: AppSpacing.x3),

            // Export formats
            Text(
              'Export Data',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.x1),
            ProLock(
              feature: Feature.exportData,
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Export CSV',
                      onPressed: () async {
                        await ExportService.instance.shareCsv(current);
                        if (context.mounted) {
                          AppToast.show(context, 'CSV exported');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x1),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Export JSON',
                      onPressed: () async {
                        await ExportService.instance.shareJson(current);
                        if (context.mounted) {
                          AppToast.show(context, 'JSON exported');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x1),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Print',
                      onPressed: () async {
                        await PdfService.instance.printReport(
                          inspection: current,
                          inspectorSignature: inspectorSig,
                          siteManagerSignature: managerSig,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3),

            // Quick actions
            Text(
              'Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.x1),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit Inspection',
                    subtitle: 'Go back and modify answers',
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      Routes.inspectionDetail,
                      arguments: current,
                    ),
                  ),
                  Divider(height: 1, color: AppColors.borderColor(context)),
                  _ActionTile(
                    icon: Icons.copy_outlined,
                    label: 'Duplicate',
                    subtitle: 'Create a blank copy of this inspection',
                    onTap: () {
                      final copy =
                          store.duplicateInspection(current.id);
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.inspectionDetail,
                        arguments: copy,
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColors.borderColor(context)),
                  _ActionTile(
                    icon: Icons.task_alt_outlined,
                    label: 'Corrective Actions (${actions.length})',
                    subtitle: 'View and manage actions for this inspection',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.correctiveActions,
                      arguments: current.id,
                    ),
                  ),
                  if (current.status != InspectionStatus.archived) ...[
                    Divider(
                        height: 1,
                        color: AppColors.borderColor(context)),
                    _ActionTile(
                      icon: Icons.archive_outlined,
                      label: 'Archive Inspection',
                      subtitle: 'Move to archived records',
                      color: AppColors.warning,
                      onTap: () {
                        _confirmArchive(context, store);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmArchive(BuildContext context, InspectionStore store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text('Archive Inspection',
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600)),
        content: Text(
            'This inspection will be moved to the archived section.',
            style: TextStyle(color: AppColors.textSecondary(context))),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Cancel',
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500)),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Archive',
                  style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      store.archiveInspection(current.id);
      if (context.mounted) {
        AppToast.show(context, 'Inspection archived');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Shared helper widgets
// ═══════════════════════════════════════════════════════════════════

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final RiskAssessment risk;
  const _RiskBadge({required this.risk});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (risk.riskLevel) {
      case RiskLevel.low:
        color = AppColors.success;
        break;
      case RiskLevel.medium:
        color = AppColors.warning;
        break;
      case RiskLevel.high:
        color = AppColors.warning;
        break;
      case RiskLevel.critical:
        color = AppColors.error;
        break;
    }
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: color.withValues(alpha: 0.12),
          ),
          child: Text(
            risk.riskLevel.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Score: ${risk.score}/100',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
        ),
      ],
    );
  }
}

class _SignaturePreview extends StatelessWidget {
  final Uint8List bytes;
  const _SignaturePreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        color: AppColors.success.withValues(alpha: 0.04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.memory(bytes, fit: BoxFit.contain),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountPill({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context),
              ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary(context);
    return Tappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x2, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: c,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: AppColors.textTertiary(context)),
          ],
        ),
      ),
    );
  }
}
