import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/api/harold_enums.dart';
import 'package:copyright_clinic_flutter/features/harold_ai/presentation/constants/harold_intake_constants.dart';
import 'package:copyright_clinic_flutter/features/harold_ai/presentation/cubit/harold_intake_cubit.dart';
import 'package:copyright_clinic_flutter/features/harold_ai/presentation/cubit/harold_intake_state.dart';

void main() {
  group('HaroldIntakeCubit - Q3 invention/trademark boundary', () {
    late HaroldIntakeCubit cubit;

    setUp(() {
      cubit = HaroldIntakeCubit(userType: HaroldUserType.creator.name);
    });

    tearDown(() => cubit.close());

    test('initial steps contain separate invention and trademark boundary questions', () {
      final ids = cubit.state.steps.map((s) => s.id).toList();

      expect(ids, contains(HaroldIntakeQuestionIds.q3InventionBoundary));
      expect(ids, contains(HaroldIntakeQuestionIds.q3TrademarkBoundary));
      expect(ids.contains('q3_ip_boundary'), isFalse);
    });

    test('invention boundary question uses the invention prompt key', () {
      final step = cubit.state.steps.firstWhere((s) => s.id == HaroldIntakeQuestionIds.q3InventionBoundary);
      expect(step.promptKey, AppStrings.haroldIntakeQ3InventionPrompt);
    });

    test('trademark boundary question uses the trademark prompt key', () {
      final step = cubit.state.steps.firstWhere((s) => s.id == HaroldIntakeQuestionIds.q3TrademarkBoundary);
      expect(step.promptKey, AppStrings.haroldIntakeQ3TrademarkPrompt);
    });

    void answerQ1Yes() {
      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.yes);
      cubit.next();
    }

    void answerQ2() {
      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.situationCreator);
      cubit.next();
    }

    test('answering yes to invention boundary terminates the flow', () {
      answerQ1Yes();
      answerQ2();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.yes);
      cubit.next();

      expect(cubit.state.isTerminated, isTrue);
      expect(cubit.state.terminationMessageKey, AppStrings.haroldIntakeTerminationNotCopyright);
    });

    test('answering no to invention boundary does not terminate and advances to trademark boundary', () {
      answerQ1Yes();
      answerQ2();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.no);
      cubit.next();

      expect(cubit.state.isTerminated, isFalse);
      expect(cubit.state.currentStep?.id, HaroldIntakeQuestionIds.q3TrademarkBoundary);
    });

    test('answering yes to trademark boundary terminates the flow', () {
      answerQ1Yes();
      answerQ2();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.no);
      cubit.next();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.yes);
      cubit.next();

      expect(cubit.state.isTerminated, isTrue);
      expect(cubit.state.terminationMessageKey, AppStrings.haroldIntakeTerminationNotCopyright);
    });

    test('answering no to both invention and trademark boundaries continues the flow', () {
      answerQ1Yes();
      answerQ2();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.no);
      cubit.next();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.no);
      cubit.next();

      expect(cubit.state.isTerminated, isFalse);
      expect(cubit.state.currentStep?.id, HaroldIntakeQuestionIds.q4Conditional);
    });

    test('not-sure on invention and trademark boundaries does not terminate', () {
      answerQ1Yes();
      answerQ2();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.notSure);
      cubit.next();

      cubit.selectCurrentAnswer(HaroldIntakeOptionIds.notSure);
      cubit.next();

      expect(cubit.state.isTerminated, isFalse);
      expect(cubit.state.currentStep?.id, HaroldIntakeQuestionIds.q4Conditional);
    });
  });
}
