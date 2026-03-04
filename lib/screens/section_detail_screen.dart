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
  final Map<String, TextEditingController> _numericControllers = {};
  final Map<String, TextEditingController> _textControllers = {};
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
    for (final controller in _numericControllers.values) {
      controller.dispose();
    }
    for (final controller in _textControllers.values) {
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

  void _setAnswer(String questionId, String value) {
    HapticFeedback.selectionClick();
    setState(() {
      _answers[questionId] = value;
      final inspection = widget.inspection;
      if (inspection != null) {
        InspectionStore.instance.setSectionAnswer(
          inspectionId: inspection.id,
          sectionId: widget.section.id,
          questionId: questionId,
          answer: value,
        );
      }
    });
  }

  /// Builds the appropriate input widget based on question type.
  Widget _buildQuestionInput(
    BuildContext context,
    Map<String, String> question,
    String questionId,
    String? currentAnswer,
  ) {
    final type = question['type'] ?? 'pass_fail';

    switch (type) {
      case 'yes_no':
        return FormRadioGroup<String>(
          label: 'Response',
          value: currentAnswer,
          items: const ['yes', 'no', 'na'],
          itemLabel: (v) {
            switch (v) {
              case 'yes': return 'Yes';
              case 'no': return 'No';
              case 'na': return 'N/A';
              default: return v;
            }
          },
          onChanged: (value) => _setAnswer(questionId, value),
        );

      case 'numeric':
        final unit = question['unit'] ?? '';
        final controller = _numericControllers.putIfAbsent(
          questionId,
          () => TextEditingController(text: currentAnswer ?? ''),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Measured value${unit.isNotEmpty ? ' ($unit)' : ''}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderColor(context)),
                      color: AppColors.backgroundColor(context),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter value',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary(context),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                        border: InputBorder.none,
                        suffixText: unit,
                        suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          _setAnswer(questionId, val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case 'text':
        final controller = _textControllers.putIfAbsent(
          questionId,
          () => TextEditingController(text: currentAnswer ?? ''),
        );
        return InputField(
          label: 'Response',
          hintText: 'Enter your observation or finding',
          controller: controller,
          maxLines: 4,
          minLines: 2,
          onChanged: (val) {
            if (val.isNotEmpty) {
              _setAnswer(questionId, val);
            }
          },
        );

      case 'scale':
        final selectedValue = int.tryParse(currentAnswer ?? '');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating (1 = Poor, 5 = Excellent)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final val = i + 1;
                final isSelected = selectedValue == val;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _setAnswer(questionId, val.toString()),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderColor(context),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.backgroundColor(context),
                      ),
                      child: Center(
                        child: Text(
                          '$val',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case 'multi':
        final options = (question['options'] ?? '').split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
        final selected = (currentAnswer ?? '').split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toSet();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select all that apply',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...options.map((option) {
              final isChecked = selected.contains(option);
              return GestureDetector(
                onTap: () {
                  final updated = Set<String>.from(selected);
                  if (isChecked) {
                    updated.remove(option);
                  } else {
                    updated.add(option);
                  }
                  _setAnswer(questionId, updated.join(', '));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isChecked ? AppColors.primary : AppColors.borderColor(context),
                    ),
                    color: isChecked
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : AppColors.backgroundColor(context),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 20,
                        color: isChecked ? AppColors.primary : AppColors.textTertiary(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                            color: isChecked
                                ? AppColors.primary
                                : AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      case 'pass_fail':
      default:
        return FormRadioGroup<String>(
          label: 'Response',
          value: currentAnswer,
          items: const ['pass', 'fail', 'na'],
          itemLabel: (v) {
            switch (v) {
              case 'pass': return 'Pass';
              case 'fail': return 'Fail';
              case 'na': return 'N/A';
              default: return v;
            }
          },
          onChanged: (value) => _setAnswer(questionId, value),
        );
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
                        borderRadius: BorderRadius.circular(AppRadius.sm),
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
                                    final qType = q['type'] ?? 'pass_fail';
                                    // Only auto-fill pass/fail and yes/no types
                                    if (!_answers.containsKey(qId) &&
                                        (qType == 'pass_fail' || qType == 'yes_no')) {
                                      final answer = qType == 'yes_no' ? 'yes' : 'pass';
                                      _answers[qId] = answer;
                                      final inspection = widget.inspection;
                                      if (inspection != null) {
                                        InspectionStore.instance.setSectionAnswer(
                                          inspectionId: inspection.id,
                                          sectionId: widget.section.id,
                                          questionId: qId,
                                          answer: answer,
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
                        final isFail = answer == 'fail' || answer == 'no';
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
                                  _buildQuestionInput(context, question, id, answer),
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
