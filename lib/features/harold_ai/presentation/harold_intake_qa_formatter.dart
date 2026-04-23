import '../../../../core/constants/app_strings.dart';
import 'cubit/harold_intake_cubit.dart' show HaroldIntakeOptionIds;
import 'cubit/harold_intake_state.dart';
import 'pages/params/harold_intake_review_screen_params.dart';

class HaroldIntakeQaFormatter {
  HaroldIntakeQaFormatter._();

  static List<HaroldIntakeReviewRow> buildReviewRows(HaroldIntakeState state, String Function(String key) tr) {
    final list = <HaroldIntakeReviewRow>[];
    for (final step in state.steps) {
      final raw = state.answersById[step.id] ?? '';
      list.add(HaroldIntakeReviewRow(question: tr(step.promptKey), answer: formatAnswer(step, raw, tr)));
    }
    return list;
  }

  static Map<String, dynamic> buildEligibilityPayload(HaroldIntakeState state, String Function(String key) tr) {
    final out = <String, dynamic>{};
    for (var i = 0; i < state.steps.length; i++) {
      final step = state.steps[i];
      final answerRaw = state.answersById[step.id] ?? '';
      out['q${i + 1}'] = {'question': tr(step.promptKey), 'answer': formatAnswer(step, answerRaw, tr)};
    }
    return out;
  }

  static String formatAnswer(HaroldIntakeStep step, String raw, String Function(String key) tr) {
    if (step.type == HaroldIntakeQuestionType.singleChoice) {
      if (raw == HaroldIntakeOptionIds.notSure) return tr(AppStrings.notSure);
      for (final option in step.options) {
        if (option.id == raw) return tr(option.labelKey);
      }
      return raw;
    }
    if (raw == HaroldIntakeOptionIds.notSure) return tr(AppStrings.notSure);
    return raw;
  }
}
