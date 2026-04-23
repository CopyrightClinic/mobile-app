import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/translated_text.dart';
import '../constants/harold_intake_constants.dart';
import '../cubit/harold_intake_cubit.dart' show HaroldIntakeCubit;
import '../cubit/harold_intake_state.dart';
import '../harold_intake_qa_formatter.dart';
import 'params/harold_failed_screen_params.dart';
import 'params/harold_intake_questions_screen_params.dart';
import 'params/harold_intake_review_screen_params.dart';

class HaroldIntakeQuestionsScreen extends StatefulWidget {
  final HaroldIntakeQuestionsScreenParams params;

  const HaroldIntakeQuestionsScreen({super.key, required this.params});

  @override
  State<HaroldIntakeQuestionsScreen> createState() => _HaroldIntakeQuestionsScreenState();
}

class _HaroldIntakeQuestionsScreenState extends State<HaroldIntakeQuestionsScreen> {
  late final HaroldIntakeCubit _cubit;
  final TextEditingController _textController = TextEditingController();
  int _previousIndexForAnimation = -1;
  bool _stepAnimationForward = true;

  @override
  void initState() {
    super.initState();
    _cubit = HaroldIntakeCubit(userType: widget.params.userType);
  }

  @override
  void dispose() {
    _textController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<HaroldIntakeCubit, HaroldIntakeState>(
        listener: (context, state) {
          if (state.isTerminated && state.terminationMessageKey != null) {
            context.go(
              AppRoutes.haroldFailedRouteName,
              extra: HaroldFailedScreenParams(
                fromAuthFlow: widget.params.fromAuthFlow,
                query: widget.params.query,
                overrideMessageKey: state.terminationMessageKey,
              ),
            );
            return;
          }
        },
        builder: (context, state) {
          final currentStep = state.currentStep;
          if (currentStep != null && state.currentIndex != _previousIndexForAnimation) {
            _stepAnimationForward = state.currentIndex > _previousIndexForAnimation;
            _previousIndexForAnimation = state.currentIndex;
          }

          return CustomScaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
              leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
              leading: CustomBackButton(
                onPressed: () {
                  if (state.currentIndex > 0) {
                    context.read<HaroldIntakeCubit>().goBack();
                  } else {
                    if (widget.params.fromAuthFlow) {
                      context.go(AppRoutes.homeRouteName);
                    } else {
                      context.pop();
                    }
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DimensionConstants.gap16Px.h),
                    TranslatedText(
                      AppStrings.askHaroldAI,
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: DimensionConstants.gap12Px.h),
                    if (currentStep == null)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else
                      Expanded(child: _buildAnimatedStepBody(context: context, step: currentStep, state: state)),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (context, value, child) {
                        return _buildBottomButton(context: context, step: currentStep, state: state);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStepBody({required BuildContext context, required HaroldIntakeStep step, required HaroldIntakeState state}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: Offset(_stepAnimationForward ? 0.07 : -0.07, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.92, curve: Curves.easeOut)),
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>('${state.currentIndex}_${step.id}'),
        child: SizedBox.expand(child: _buildStepBody(context: context, step: step, state: state)),
      ),
    );
  }

  Widget _buildStepBody({required BuildContext context, required HaroldIntakeStep step, required HaroldIntakeState state}) {
    _syncTextController(step: step, state: state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(step.promptKey),
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: DimensionConstants.gap16Px.h),
        if (step.type == HaroldIntakeQuestionType.singleChoice)
          _buildOptions(step: step, state: state)
        else
          _buildTextField(context: context, step: step, state: state),
      ],
    );
  }

  Widget _buildOptions({required HaroldIntakeStep step, required HaroldIntakeState state}) {
    final selected = state.answerFor(step.id);
    return Expanded(
      child: ListView.separated(
        itemCount: step.options.length,
        separatorBuilder: (_, __) => SizedBox(height: DimensionConstants.gap10Px.h),
        itemBuilder: (context, index) {
          final option = step.options[index];
          final isSelected = selected == option.id;
          return InkWell(
            onTap: () => context.read<HaroldIntakeCubit>().selectCurrentAnswer(option.id),
            borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
            child: Container(
              padding: EdgeInsets.all(DimensionConstants.gap14Px.w),
              decoration: BoxDecoration(
                color: isSelected ? context.primary.withValues(alpha: 0.18) : context.filledBgDark,
                borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
                border: Border.all(color: isSelected ? context.primary : context.darkTextPrimary.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(option.labelKey),
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: DimensionConstants.gap12Px.w),
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? context.primary : context.darkTextSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({required BuildContext context, required HaroldIntakeStep step, required HaroldIntakeState state}) {
    final isNotSureSelected = state.answerFor(step.id) == HaroldIntakeOptionIds.notSure;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
              decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
              child: TextField(
                controller: _textController,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<HaroldIntakeCubit>().clearTextStepNotSureIfTyping();
                  }
                },
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: AppStrings.describe.tr(),
                  hintStyle: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (step.allowNotSure) ...[
            SizedBox(height: DimensionConstants.gap10Px.h),
            InkWell(
              onTap: () {
                _textController.clear();
                context.read<HaroldIntakeCubit>().selectCurrentAnswer(HaroldIntakeOptionIds.notSure);
              },
              borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
              child: Container(
                padding: EdgeInsets.all(DimensionConstants.gap14Px.w),
                decoration: BoxDecoration(
                  color: isNotSureSelected ? context.primary.withValues(alpha: 0.18) : context.filledBgDark,
                  borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
                  border: Border.all(color: isNotSureSelected ? context.primary : context.darkTextPrimary.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.notSure.tr(),
                        style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      isNotSureSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isNotSureSelected ? context.primary : context.darkTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton({required BuildContext context, required HaroldIntakeStep? step, required HaroldIntakeState state}) {
    final bool isTextStep = step?.type == HaroldIntakeQuestionType.text;
    final bool canContinue =
        step == null
            ? false
            : (!isTextStep
                ? state.answerFor(step.id) != null
                : (state.answerFor(step.id) == HaroldIntakeOptionIds.notSure || _textController.text.trim().isNotEmpty));
    final bool isLastStep = step == null ? false : (state.currentIndex == state.steps.length - 1);
    final String buttonTextKey = isLastStep ? AppStrings.haroldIntakeReview : AppStrings.next;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
      child: AuthButton(
        text: buttonTextKey,
        onPressed:
            !canContinue
                ? null
                : () async {
                  final cubit = context.read<HaroldIntakeCubit>();
                  if (isLastStep) {
                    if (isTextStep) {
                      cubit.next(textAnswer: _textController.text.trim(), forReview: true);
                    } else {
                      cubit.next(forReview: true);
                    }
                    if (!cubit.state.isTerminated) {
                      await _openReview(context, cubit.state);
                    }
                  } else {
                    if (isTextStep) {
                      cubit.next(textAnswer: _textController.text.trim());
                    } else {
                      cubit.next();
                    }
                  }
                },
        isLoading: false,
        isEnabled: canContinue,
      ),
    );
  }

  Future<void> _openReview(BuildContext context, HaroldIntakeState state) async {
    final rows = HaroldIntakeQaFormatter.buildReviewRows(state, tr);
    final payload = HaroldIntakeQaFormatter.buildEligibilityPayload(state, tr);
    final result = await context.push<String?>(
      AppRoutes.haroldIntakeReviewRouteName,
      extra: HaroldIntakeReviewScreenParams(
        fromAuthFlow: widget.params.fromAuthFlow,
        query: widget.params.query,
        fee: widget.params.fee,
        evaluationId: widget.params.evaluationId,
        rows: rows,
        eligibilityPayload: payload,
      ),
    );
    if (!context.mounted) return;
    if (result == kHaroldIntakeReviewPopEditFromStart) {
      _cubit.goToFirstQuestion();
    }
  }

  void _syncTextController({required HaroldIntakeStep step, required HaroldIntakeState state}) {
    if (step.type != HaroldIntakeQuestionType.text) {
      if (_textController.text.isNotEmpty) _textController.clear();
      return;
    }

    final existing = state.answerFor(step.id) ?? '';
    if (existing == HaroldIntakeOptionIds.notSure) {
      if (_textController.text.isNotEmpty) _textController.clear();
      return;
    }
    if (_textController.text != existing) {
      _textController.text = existing;
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
    }
  }
}

