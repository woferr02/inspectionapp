import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/data/question_bank.dart';
import 'package:health_safety_inspection/models/corrective_action.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/form_radio_group.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/photo_grid.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class SectionDetailScreen extends StatefulWidget {
  final InspectionSection section;
  final String inspectionName;
  final Inspection? inspection;

  const SectionDetailScreen({
    super.key,
    required this.section,
    required this.inspectionName,
    this.inspection,
  });

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  final Map<String, String> _answers = {};
  final Map<String, String> _notes = {};
  final Map<String, TextEditingController> _noteControllers = {};
  final Map<String, List<String>> _photoFiles = {};
  final Set<String> _expandedIds = {};
  final Map<String, GlobalKey> _questionKeys = {};
  final ScrollController _scrollController = ScrollController();
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    final inspection = widget.inspection;
    if (inspection == null) return;
    final store = InspectionStore.instance;
    _answers.addAll(
      store.sectionAnswers(
        inspectionId: inspection.id,
        sectionId: widget.section.id,
      ),
    );
    _notes.addAll(
      store.sectionNotes(
        inspectionId: inspection.id,
        sectionId: widget.section.id,
      ),
    );
    // Restore persisted photos
    final storedPhotos = store.sectionPhotos(
      inspectionId: inspection.id,
      sectionId: widget.section.id,
    );
    for (final entry in storedPhotos.entries) {
      _photoFiles[entry.key] = List<String>.from(entry.value);
    }

    for (final entry in _notes.entries) {
      _noteControllers[entry.key] = TextEditingController(text: entry.value);
    }

    // Auto-expand first unanswered question
    _expandFirstUnanswered();
  }

  void _expandFirstUnanswered() {
    final questions = QuestionBank.forSection(
      widget.section.name,
      widget.section.questionCount,
    );
    for (final q in questions) {
      final qId = q['id']!;
      if (!_answers.containsKey(qId)) {
        _expandedIds.add(qId);
        return;
      }
    }
    // All answered — expand first
    if (questions.isNotEmpty) {
      _expandedIds.add(questions.first['id']!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerForNote(String questionId) {
    return _noteControllers.putIfAbsent(
      questionId,
      () => TextEditingController(text: _notes[questionId] ?? ''),
    );
  }

  final Set<String> _createdActions = {};

  void _createAction(String questionId, String questionTitle) {
    final inspection = widget.inspection;
    if (inspection == null) return;
    if (_createdActions.contains(questionId)) {
      AppToast.show(context, 'Action already created for this question');
      return;
    }
    final note = _notes[questionId] ?? '';
    ActionStore.instance.addAction(
      inspectionId: inspection.id,
      sectionId: widget.section.id,
      questionId: questionId,
      title: 'Failed: $questionTitle',
      description: note.isNotEmpty ? note : 'Requires corrective action.',
      severity: ActionSeverity.medium,
      dueDate: DateTime.now().add(const Duration(days: 14)),
    );
    _createdActions.add(questionId);
    if (mounted) {
      setState(() {});
      AppToast.show(context, 'Corrective action created');
    }
  }

  List<Map<String, String>> get _questions {
    return QuestionBank.forSection(
      widget.section.name,
      widget.section.questionCount,
    );
  }

  void _scrollToFirstUnanswered(List<Map<String, String>> questions) {
    for (final q in questions) {
      final id = q['id']!;
      if (!_answers.containsKey(id)) {
        // Expand it and scroll into view
        _expandedIds.add(id);
        final key = _questionKeys[id];
        if (key?.currentContext != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    final completed = _answers.length;
    final progress = questions.isEmpty ? 0.0 : completed / questions.length;
    final isComplete = completed == questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: widget.section.name,
              subtitle: widget.inspectionName,
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: AppViewport(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3,
                    AppSpacing.x2,
                    AppSpacing.x3,
                    96,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progress,
                          backgroundColor: AppColors.borderColor(context),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$completed of ${questions.length} checks completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary(context),
                            ),
                      ),
                      // ── Quick actions ──
                      if (!isComplete) ...[
                        const SizedBox(height: AppSpacing.x1),
                        Row(
                          children: [
                            Tappable(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  for (final q in questions) {
                                    final qId = q['id']!;
                                    if (!_answers.containsKey(qId)) {
                                      _answers[qId] = 'pass';
                                      final inspection = widget.inspection;
                                      if (inspection != null) {
                                        InspectionStore.instance.setSectionAnswer(
                                          inspectionId: inspection.id,
                                          sectionId: widget.section.id,
                                          questionId: qId,
                                          answer: 'pass',
                                        );
                                      }
                                    }
                                  }
                                });
                                AppToast.show(context, 'All unanswered items marked as Pass');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  color: AppColors.success.withValues(alpha: 0.08),
                                  border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 14, color: AppColors.success),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Mark all pass',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.x2),
                      ...questions.map((question) {
                        final id = question['id']!;
                        final answer = _answers[id];
                        final expanded = _expandedIds.contains(id);
                        final isFail = answer == 'fail';
                        final hasAnswer = answer != null;
                        _questionKeys.putIfAbsent(id, () => GlobalKey());

                        return Padding(
                          key: _questionKeys[id],
                          padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(AppSpacing.x2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tappable(
                                  onTap: () => setState(() {
                                    if (expanded) {
                                      _expandedIds.remove(id);
                                    } else {
                                      _expandedIds.add(id);
                                    }
                                  }),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question['title']!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              question['desc']!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textSecondary(
                                                            context),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.x1),
                                      Icon(
                                        answer == null
                                            ? Icons.radio_button_unchecked
                                            : Icons.check_circle,
                                        size: 18,
                                        color: answer == null
                                            ? AppColors.textTertiary(context)
                                            : AppColors.success,
                                      ),
                                      const SizedBox(width: AppSpacing.x1),
                                      Icon(
                                        expanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: AppColors.textSecondary(context),
                                      ),
                                    ],
                                  ),
                                ),
                                if (expanded) ...[
                                  const SizedBox(height: AppSpacing.x2),
                                  FormRadioGroup<String>(
                                    label: 'Response',
                                    value: answer,
                                    items: const ['pass', 'fail', 'na'],
                                    itemLabel: (v) {
                                      switch (v) {
                                        case 'pass':
                                          return 'Pass';
                                        case 'fail':
                                          return 'Fail';
                                        case 'na':
                                          return 'N/A';
                                        default:
                                          return v;
                                      }
                                    },
                                    onChanged: (value) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _answers[id] = value;
                                        final inspection = widget.inspection;
                                        if (inspection != null) {
                                          InspectionStore.instance
                                              .setSectionAnswer(
                                            inspectionId: inspection.id,
                                            sectionId: widget.section.id,
                                            questionId: id,
                                            answer: value,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  if (_showValidation && answer == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Select a response to continue.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.error,
                                            ),
                                      ),
                                    ),
                                  if (hasAnswer) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppSpacing.x2),
                                      child: InputField(
                                        label: isFail ? 'Observation note' : 'Note (optional)',
                                        hintText: isFail
                                            ? 'Describe issue, action taken, and evidence.'
                                            : 'Add any observations or comments.',
                                        controller: _controllerForNote(id),
                                        maxLines: 4,
                                        minLines: isFail ? 3 : 2,
                                        onChanged: (value) {
                                          _notes[id] = value;
                                          final inspection = widget.inspection;
                                          if (inspection != null) {
                                            InspectionStore.instance
                                                .setSectionNote(
                                              inspectionId: inspection.id,
                                              sectionId: widget.section.id,
                                              questionId: id,
                                              note: value,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    // Photo evidence
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: PhotoGrid(
                                        photoPaths: _photoFiles[id] ?? [],
                                        onPhotoAdded: (path) {
                                          setState(() {
                                            _photoFiles[id] = [...(_photoFiles[id] ?? []), path];
                                          });
                                          final inspection = widget.inspection;
                                          if (inspection != null) {
                                            InspectionStore.instance.setSectionPhotos(
                                              inspectionId: inspection.id,
                                              sectionId: widget.section.id,
                                              questionId: id,
                                              paths: _photoFiles[id]!,
                                            );
                                          }
                                        },
                                        onPhotoRemoved: (index) {
                                          setState(() {
                                            final list = List<String>.from(_photoFiles[id] ?? []);
                                            list.removeAt(index);
                                            _photoFiles[id] = list;
                                          });
                                          final inspection = widget.inspection;
                                          if (inspection != null) {
                                            InspectionStore.instance.setSectionPhotos(
                                              inspectionId: inspection.id,
                                              sectionId: widget.section.id,
                                              questionId: id,
                                              paths: _photoFiles[id] ?? [],
                                            );
                                          }
                                        },
                                        maxPhotos: 4,
                                      ),
                                    ),
                                    // Create corrective action (fail only)
                                    if (isFail && widget.inspection != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: AnimatedOpacity(
                                          opacity: _createdActions.contains(id) ? 0.4 : 1.0,
                                          duration: const Duration(milliseconds: 200),
                                          child: Tappable(
                                            onTap: () => _createAction(id, question['title']!),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(AppRadius.md),
                                                border: Border.all(
                                                    color: _createdActions.contains(id)
                                                        ? AppColors.success.withValues(alpha: 0.3)
                                                        : AppColors.error.withValues(alpha: 0.3)),
                                                color: _createdActions.contains(id)
                                                    ? AppColors.success.withValues(alpha: 0.06)
                                                    : AppColors.error.withValues(alpha: 0.06),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      _createdActions.contains(id)
                                                          ? Icons.check_circle_outline
                                                          : Icons.add_task,
                                                      size: 16,
                                                      color: _createdActions.contains(id)
                                                          ? AppColors.success
                                                          : AppColors.error),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _createdActions.contains(id)
                                                        ? 'Action created'
                                                        : 'Create corrective action',
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: _createdActions.contains(id)
                                                          ? AppColors.success
                                                          : AppColors.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          border:
              Border(top: BorderSide(color: AppColors.borderColor(context))),
        ),
        child: SafeArea(
          top: false,
          child: AppViewport(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x3,
              AppSpacing.x2,
              AppSpacing.x3,
              AppSpacing.x2,
            ),
            child: PrimaryButton(
              text: isComplete ? 'Complete section' : 'Continue',
              width: double.infinity,
              onPressed: () {
                if (!isComplete) {
                  setState(() => _showValidation = true);
                  // Scroll to first unanswered question
                  _scrollToFirstUnanswered(questions);
                  return;
                }
                final inspection = widget.inspection;
                if (inspection != null) {
                  final sectionScore =
                      InspectionStore.calculateSectionScore(_answers);

                  final updatedInspection =
                      InspectionStore.instance.updateSectionCompletion(
                    inspectionId: inspection.id,
                    sectionId: widget.section.id,
                    completedCount: widget.section.questionCount,
                    score: sectionScore,
                  );

                  if (updatedInspection.status == InspectionStatus.completed ||
                      updatedInspection.status == InspectionStatus.submitted) {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.inspectionComplete,
                      arguments: updatedInspection,
                    );
                    return;
                  }
                }
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
