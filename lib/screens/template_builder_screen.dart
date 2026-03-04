import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';

/// Lets the user build a custom inspection template with sections and questions.
class TemplateBuilderScreen extends StatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  State<TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends State<TemplateBuilderScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedIndustry = 'General';
  final List<_SectionDraft> _sections = [];

  static const List<String> _industries = [
    'General',
    'Construction',
    'Manufacturing',
    'Healthcare',
    'Hospitality',
    'Retail',
    'Office',
    'Warehouse',
    'Oil & Gas',
    'Education',
    'Agriculture',
    'Mining',
    'Transportation',
  ];

  void _addSection() {
    setState(() {
      _sections.add(_SectionDraft(
        title: 'Section ${_sections.length + 1}',
        questions: [],
      ));
    });
  }

  void _addQuestion(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].questions.add(_QuestionDraft(
        text: '',
        type: _QType.yesNo,
      ));
    });
  }

  void _removeSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  void _removeQuestion(int sIndex, int qIndex) {
    setState(() => _sections[sIndex].questions.removeAt(qIndex));
  }

  void _moveSection(int from, int to) {
    setState(() {
      final item = _sections.removeAt(from);
      _sections.insert(to, item);
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      AppToast.show(context, 'Enter a template name', isError: true);
      return;
    }
    if (_sections.isEmpty) {
      AppToast.show(context, 'Add at least one section', isError: true);
      return;
    }
    // TODO: Persist to Firestore via InspectionStore or a dedicated template store
    Navigator.pop(context, {
      'name': _nameCtrl.text.trim(),
      'industry': _selectedIndustry,
      'sections': _sections
          .map((s) => {
                'title': s.title,
                'questions': s.questions
                    .map((q) => {
                          'text': q.text,
                          'type': q.type.name,
                        })
                    .toList(),
              })
          .toList(),
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Build Template',
              showBackButton: true,
              actions: [
                PrimaryButton(
                  text: 'Save',
                  height: 40,
                  onPressed: _save,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AppViewport(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3,
                    AppSpacing.x2,
                    AppSpacing.x3,
                    AppSpacing.x4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      InputField(
                        label: 'Template name',
                        hintText: 'e.g. Monthly fire safety audit',
                        controller: _nameCtrl,
                      ),
                      const SizedBox(height: 14),

                      // Industry
                      Text(
                        'Industry',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.borderColor(context)),
                          color: AppColors.surfaceColor(context),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedIndustry,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: _industries
                              .map((i) =>
                                  DropdownMenuItem(value: i, child: Text(i)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedIndustry = v!),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sections
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sections',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          SecondaryButton(
                            text: 'Add section',
                            height: 36,
                            onPressed: _addSection,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_sections.isEmpty)
                        EmptyState(
                          icon: Icons.list_alt,
                          title: 'No sections yet',
                          description: 'Tap "Add section" to start building',
                        ),

                      ...List.generate(_sections.length, (si) {
                        final section = _sections[si];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section header
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InlineEdit(
                                        initialValue: section.title,
                                        onChanged: (v) =>
                                            section.title = v,
                                      ),
                                    ),
                                    if (si > 0)
                                      Tappable(
                                        onTap: () => _moveSection(si, si - 1),
                                        child: Icon(Icons.arrow_upward,
                                            size: 18,
                                            color: AppColors.textSecondary(
                                                context)),
                                      ),
                                    if (si < _sections.length - 1) ...[
                                      const SizedBox(width: 4),
                                      Tappable(
                                        onTap: () => _moveSection(si, si + 1),
                                        child: Icon(Icons.arrow_downward,
                                            size: 18,
                                            color: AppColors.textSecondary(
                                                context)),
                                      ),
                                    ],
                                    const SizedBox(width: 4),
                                    Tappable(
                                      onTap: () => _removeSection(si),
                                      child: Icon(Icons.delete_outline,
                                          size: 18, color: AppColors.error),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Questions
                                ...List.generate(section.questions.length,
                                    (qi) {
                                  final q = section.questions[qi];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        color: AppColors.backgroundColor(
                                            context),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 22,
                                                height: 22,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                ),
                                                child: Text(
                                                  '${qi + 1}',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: _InlineEdit(
                                                  initialValue: q.text,
                                                  hint: 'Question text…',
                                                  onChanged: (v) =>
                                                      q.text = v,
                                                ),
                                              ),
                                              Tappable(
                                                onTap: () =>
                                                    _removeQuestion(si, qi),
                                                child: Icon(Icons.close,
                                                    size: 16,
                                                    color:
                                                        AppColors.error),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          _QuestionTypePicker(
                                            value: q.type,
                                            onChanged: (v) =>
                                                setState(() => q.type = v),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                Tappable(
                                  onTap: () => _addQuestion(si),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle_outline,
                                          size: 16,
                                          color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add question',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
    );
  }
}

// ─── Internal helpers ─────────────────────────────────────────

enum _QType { yesNo, multiChoice, text, numeric, photo }

class _SectionDraft {
  String title;
  final List<_QuestionDraft> questions;
  _SectionDraft({required this.title, required this.questions});
}

class _QuestionDraft {
  String text;
  _QType type;
  _QuestionDraft({required this.text, required this.type});
}

class _InlineEdit extends StatefulWidget {
  final String initialValue;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const _InlineEdit({
    required this.initialValue,
    this.hint,
    this.onChanged,
  });

  @override
  State<_InlineEdit> createState() => _InlineEditState();
}

class _InlineEditState extends State<_InlineEdit> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => widget.onChanged?.call(_ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      label: '',
      hintText: widget.hint,
      controller: _ctrl,
    );
  }
}

class _QuestionTypePicker extends StatelessWidget {
  final _QType value;
  final ValueChanged<_QType> onChanged;

  const _QuestionTypePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: _QType.values.map((t) {
        final selected = t == value;
        return Tappable(
          onTap: () => onChanged(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.borderColor(context),
              ),
            ),
            child: Text(
              _typeLabel(t),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _typeLabel(_QType t) {
    switch (t) {
      case _QType.yesNo:
        return 'Yes / No';
      case _QType.multiChoice:
        return 'Multi-choice';
      case _QType.text:
        return 'Text';
      case _QType.numeric:
        return 'Numeric';
      case _QType.photo:
        return 'Photo';
    }
  }
}
