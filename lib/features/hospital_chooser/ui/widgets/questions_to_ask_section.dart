import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Displays suggested questions to ask during a maternity unit tour.
///
/// Shows a mix of standard NHS maternity questions plus context-aware
/// questions based on the unit's data (ratings, PLACE scores, facilities).
class QuestionsToAskSection extends StatelessWidget {
  /// The maternity unit to generate questions for.
  final MaternityUnit unit;

  const QuestionsToAskSection({
    super.key,
    required this.unit,
  });

  /// Generate the list of questions based on unit data.
  List<String> _generateQuestions() {
    final questions = <String>[];

    // Standard NHS maternity questions (always shown)
    questions.addAll([
      'What birthing positions are supported?',
      'What pain relief options do you offer?',
      'Can my partner stay overnight?',
      'What support is available for breastfeeding?',
    ]);

    // Conditional questions based on unit data

    // If Safe rating is poor, ask about improvements
    final safeRating = CqcRating.fromString(unit.ratingSafe);
    if (safeRating == CqcRating.requiresImprovement ||
        safeRating == CqcRating.inadequate) {
      questions.add(
        'What improvements have been made since the last CQC inspection?',
      );
    }

    // If maternity rating is lower than overall, ask about specific changes
    if (unit.maternityRating != null &&
        unit.overallRating != null &&
        unit.maternityRatingEnum.sortValue < unit.overallRatingEnum.sortValue) {
      questions.add(
        'What specific changes are planned for the maternity unit?',
      );
    }

    // If PLACE food score is low, ask about bringing food
    if (unit.hasPlaceData && unit.placeFood != null && unit.placeFood! < 80) {
      questions.add('Can I bring my own food during my stay?');
    }

    // If PLACE cleanliness score is lower than ideal
    if (unit.hasPlaceData &&
        unit.placeCleanliness != null &&
        unit.placeCleanliness! < 90) {
      questions.add('How often are the maternity rooms cleaned?');
    }

    // If no birthing options listed, ask about water births
    if (unit.birthingOptions == null || unit.birthingOptions!.isEmpty) {
      questions.add('Are water births available?');
    }

    // Check facilities for NICU/SCBU
    if (unit.facilities != null) {
      final facilitiesStr = unit.facilities.toString().toLowerCase();
      if (facilitiesStr.contains('nicu') || facilitiesStr.contains('scbu')) {
        questions.add(
          'What level of special care is available for my baby?',
        );
      }
    }

    // Additional standard NHS questions
    questions.addAll([
      'What happens if I need a caesarean section?',
      'Can I have a tour of the labour ward?',
    ]);

    // Remove duplicates while preserving order
    return questions.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final questions = _generateQuestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Questions to Ask on Your Tour',
          style: AppTypography.headlineExtraSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),

        // Question list
        ...questions.map((question) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.gapSM),
              child: _QuestionRow(question: question),
            )),
      ],
    );
  }
}

/// A row displaying a single question with an icon.
class _QuestionRow extends StatelessWidget {
  final String question;

  const _QuestionRow({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMD,
        vertical: AppSpacing.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question mark icon in a circle
          Container(
            width: AppSpacing.iconSM,
            height: AppSpacing.iconSM,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.help_outline,
                size: AppSpacing.iconXXS,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.gapMD),

          // Question text
          Expanded(
            child: Text(
              question,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
