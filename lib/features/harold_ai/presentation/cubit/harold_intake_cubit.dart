import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/enumns/api/harold_enums.dart';
import '../constants/harold_intake_constants.dart';
import 'harold_intake_state.dart';

class HaroldIntakeCubit extends Cubit<HaroldIntakeState> {
  final HaroldUserType _userType;

  HaroldIntakeCubit({String? userType}) : _userType = HaroldUserTypeParsing.fromApi(userType), super(HaroldIntakeState.initial()) {
    _rebuildStepsAndEmit(initial: true);
  }

  void selectCurrentAnswer(String value) {
    final step = state.currentStep;
    if (step == null) return;

    final nextAnswers = Map<String, String>.from(state.answersById)..[step.id] = value;
    final steps = _buildSteps(nextAnswers);
    emit(state.copyWith(answersById: nextAnswers, steps: steps));
  }

  void clearTextStepNotSureIfTyping() {
    final step = state.currentStep;
    if (step == null || step.type != HaroldIntakeQuestionType.text || !step.allowNotSure) return;
    if (state.answerFor(step.id) != HaroldIntakeOptionIds.notSure) return;
    final nextAnswers = Map<String, String>.from(state.answersById)..remove(step.id);
    emit(state.copyWith(answersById: nextAnswers));
  }

  void next({String? textAnswer, bool forReview = false}) {
    final step = state.currentStep;
    if (step == null) return;

    String resolved;
    if (step.type == HaroldIntakeQuestionType.text && step.allowNotSure) {
      final fromState = state.answersById[step.id];
      if (fromState == HaroldIntakeOptionIds.notSure) {
        resolved = HaroldIntakeOptionIds.notSure;
      } else {
        final t = textAnswer?.trim() ?? '';
        if (t.isEmpty) return;
        resolved = t;
      }
    } else {
      final v = textAnswer ?? state.answersById[step.id];
      if (v == null || v.trim().isEmpty) return;
      resolved = v.trim();
    }

    final nextAnswers = Map<String, String>.from(state.answersById)..[step.id] = resolved;

    final terminationMessageKey = _terminationMessageKeyFor(nextAnswers);
    if (terminationMessageKey != null) {
      emit(
        state.copyWith(answersById: nextAnswers, isTerminated: true, terminationMessageKey: terminationMessageKey),
      );
      return;
    }

    final steps = _buildSteps(nextAnswers);
    final nextIndex = (state.currentIndex + 1).clamp(0, steps.isEmpty ? 0 : steps.length - 1);
    final wouldComplete = state.currentIndex + 1 >= steps.length;

    if (wouldComplete && forReview) {
      emit(
        state.copyWith(
          answersById: nextAnswers,
          steps: steps,
          currentIndex: state.currentIndex,
          isTerminated: false,
          terminationMessageKey: null,
        ),
      );
      return;
    }

    if (wouldComplete && !forReview) {
      return;
    }

    emit(
      state.copyWith(
        answersById: nextAnswers,
        steps: steps,
        currentIndex: nextIndex,
        isTerminated: false,
        terminationMessageKey: null,
      ),
    );
  }

  void goBack() {
    if (state.isTerminated) return;
    if (state.currentIndex <= 0) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  void goToFirstQuestion() {
    if (state.isTerminated) return;
    if (state.steps.isEmpty) return;
    emit(state.copyWith(currentIndex: 0));
  }

  void _rebuildStepsAndEmit({required bool initial}) {
    final steps = _buildSteps(state.answersById);
    emit(state.copyWith(steps: steps, currentIndex: initial ? 0 : state.currentIndex.clamp(0, steps.isEmpty ? 0 : steps.length - 1)));
  }

  String? _terminationMessageKeyFor(Map<String, String> answersById) {
    final q1 = answersById[HaroldIntakeQuestionIds.q1CreativeExpression];
    if (q1 == HaroldIntakeOptionIds.no) return AppStrings.haroldIntakeTerminationNotCopyright;

    final q3Invention = answersById[HaroldIntakeQuestionIds.q3InventionBoundary];
    if (q3Invention == HaroldIntakeOptionIds.yes) return AppStrings.haroldIntakeTerminationNotCopyright;

    final q3Trademark = answersById[HaroldIntakeQuestionIds.q3TrademarkBoundary];
    if (q3Trademark == HaroldIntakeOptionIds.yes) return AppStrings.haroldIntakeTerminationNotCopyright;

    return null;
  }

  List<HaroldIntakeStep> _buildSteps(Map<String, String> answersById) {
    final steps = <HaroldIntakeStep>[
      HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q1CreativeExpression,
        promptKey: AppStrings.haroldIntakeQ1Prompt,
        type: HaroldIntakeQuestionType.singleChoice,
        options: const [
          HaroldIntakeOption(id: HaroldIntakeOptionIds.yes, labelKey: AppStrings.yes),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.no, labelKey: AppStrings.no),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
        ],
      ),
      HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q2Situation,
        promptKey: AppStrings.haroldIntakeQ2Prompt,
        type: HaroldIntakeQuestionType.singleChoice,
        options: const [
          HaroldIntakeOption(id: HaroldIntakeOptionIds.situationCreator, labelKey: AppStrings.haroldIntakeQ2OptionCreator),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.situationAccused, labelKey: AppStrings.haroldIntakeQ2OptionAccused),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.situationUnsure, labelKey: AppStrings.haroldIntakeQ2OptionUnsure),
        ],
      ),
      HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q3InventionBoundary,
        promptKey: AppStrings.haroldIntakeQ3InventionPrompt,
        type: HaroldIntakeQuestionType.singleChoice,
        options: const [
          HaroldIntakeOption(id: HaroldIntakeOptionIds.yes, labelKey: AppStrings.yes),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.no, labelKey: AppStrings.no),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
        ],
      ),
      HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q3TrademarkBoundary,
        promptKey: AppStrings.haroldIntakeQ3TrademarkPrompt,
        type: HaroldIntakeQuestionType.singleChoice,
        options: const [
          HaroldIntakeOption(id: HaroldIntakeOptionIds.yes, labelKey: AppStrings.yes),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.no, labelKey: AppStrings.no),
          HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
        ],
      ),
      _conditionalQ4(),
      const HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q4OthersInvolved,
        promptKey: AppStrings.haroldIntakeQ4Prompt,
        type: HaroldIntakeQuestionType.text,
        allowNotSure: true,
      ),
      const HaroldIntakeStep(
        id: HaroldIntakeQuestionIds.q6Impact,
        promptKey: AppStrings.haroldIntakeQ6Prompt,
        type: HaroldIntakeQuestionType.text,
        allowNotSure: true,
      ),
    ];

    return steps;
  }

  HaroldIntakeStep _conditionalQ4() {
    switch (_userType) {
      case HaroldUserType.creator:
        return const HaroldIntakeStep(
          id: HaroldIntakeQuestionIds.q4Conditional,
          promptKey: AppStrings.haroldIntakeQ4CreatorPrompt,
          type: HaroldIntakeQuestionType.singleChoice,
          options: [
            HaroldIntakeOption(id: HaroldIntakeOptionIds.yes, labelKey: AppStrings.yes),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.no, labelKey: AppStrings.no),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
          ],
        );
      case HaroldUserType.accused:
        return const HaroldIntakeStep(
          id: HaroldIntakeQuestionIds.q4Conditional,
          promptKey: AppStrings.haroldIntakeQ4AccusedPrompt,
          type: HaroldIntakeQuestionType.singleChoice,
          options: [
            HaroldIntakeOption(id: HaroldIntakeOptionIds.yes, labelKey: AppStrings.yes),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.no, labelKey: AppStrings.no),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
          ],
        );
      case HaroldUserType.unsure:
      case HaroldUserType.unknown:
        return const HaroldIntakeStep(
          id: HaroldIntakeQuestionIds.q4Conditional,
          promptKey: AppStrings.haroldIntakeQ4UnsurePrompt,
          type: HaroldIntakeQuestionType.singleChoice,
          options: [
            HaroldIntakeOption(id: HaroldIntakeOptionIds.concernUsedMyWork, labelKey: AppStrings.haroldIntakeQ4UnsureOptionUsedMyWork),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.concernRaisedAboutMyUse, labelKey: AppStrings.haroldIntakeQ4UnsureOptionRaisedConcern),
            HaroldIntakeOption(id: HaroldIntakeOptionIds.notSure, labelKey: AppStrings.notSure),
          ],
        );
    }
  }
}
