import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../domain/services/harold_navigation_service.dart';
import '../bloc/harold_ai_bloc.dart';
import '../bloc/harold_ai_event.dart';
import '../bloc/harold_ai_state.dart';
import '../../../speech_to_text/presentation/bloc/speech_to_text_bloc.dart';
import '../../../speech_to_text/presentation/bloc/speech_to_text_event.dart';
import '../../../speech_to_text/presentation/bloc/speech_to_text_state.dart';

class AskHaroldAiScreen extends StatefulWidget {
  const AskHaroldAiScreen({super.key});

  @override
  State<AskHaroldAiScreen> createState() => _AskHaroldAiScreenState();
}

class _AskHaroldAiScreenState extends State<AskHaroldAiScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<SpeechToTextBloc>().add(InitializeSpeechRecognition(context: context));
  }

  void _setupAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    return _textController.text.trim().length > 1;
  }

  void _toggleVoiceInput() {
    context.read<SpeechToTextBloc>().add(const ToggleSpeechRecognition(localeId: 'en-US', enableHapticFeedback: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HaroldAiBloc, HaroldAiState>(
      bloc: sl<HaroldAiBloc>(),
      listener: (context, state) {
        if (state is HaroldAiSuccess) {
          HaroldNavigationService.handleHaroldResult(context: context, isSuccess: true, isUserAuthenticated: state.isUserAuthenticated);
        } else if (state is HaroldAiFailure) {
          HaroldNavigationService.handleHaroldResult(context: context, isSuccess: false, isUserAuthenticated: state.isUserAuthenticated);
        } else if (state is HaroldAiError) {
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w), leading: const CustomBackButton()),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                      TranslatedText(
                        AppStrings.describeYourCopyrightIssue,
                        style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: DimensionConstants.gap16Px.h),
                      Expanded(child: _buildTextInputField()),
                    ],
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputField() {
    return BlocListener<SpeechToTextBloc, SpeechToTextState>(
      listener: (context, state) {
        if (state is SpeechToTextListening && state.currentText.isNotEmpty) {
          _textController.text = state.currentText;
          _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
        } else if (state is SpeechToTextStopped && state.finalText.isNotEmpty) {
          _textController.text = state.finalText;
          _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
        } else if (state is SpeechToTextError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Speech recognition error: ${state.message}'), backgroundColor: Colors.red));
        }
      },
      child: Container(
        padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: AppStrings.describe,
                  hintStyle: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildVoiceButton()]),
          SizedBox(height: DimensionConstants.gap16Px.h),
          BlocBuilder<HaroldAiBloc, HaroldAiState>(
            builder: (context, state) {
              final isLoading = state is HaroldAiLoading;
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, child) {
                  final isValid = _isValidInput();
                  return AuthButton(
                    text: AppStrings.submit,
                    onPressed: isValid && !isLoading ? _onSubmit : null,
                    isLoading: isLoading,
                    isEnabled: isValid && !isLoading,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return BlocBuilder<SpeechToTextBloc, SpeechToTextState>(
      builder: (context, state) {
        final isListening = state is SpeechToTextListening;
        final isInitialized = state is! SpeechToTextInitial && state is! SpeechToTextInitializing;

        return GestureDetector(
          onTap: isInitialized ? _toggleVoiceInput : null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: isListening ? context.primary : context.filledBgDark,
                    shape: BoxShape.circle,
                    boxShadow: isListening ? [BoxShadow(color: context.primary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isListening)
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                        ),
                      Icon(_getIconForState(state), color: isListening ? Colors.white : context.darkTextPrimary, size: 24.w),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIconForState(SpeechToTextState state) {
    if (state is SpeechToTextListening) {
      return Icons.stop;
    } else if (state is SpeechToTextPaused) {
      return Icons.play_arrow;
    } else if (state is SpeechToTextInitializing) {
      return Icons.hourglass_empty;
    } else {
      return Icons.mic;
    }
  }

  void _onSubmit() {
    if (_isValidInput()) {
      final currentState = context.read<SpeechToTextBloc>().state;
      if (currentState is SpeechToTextListening) {
        context.read<SpeechToTextBloc>().add(StopSpeechRecognition());
      }

      // Submit query to Harold AI BLoC
      context.read<HaroldAiBloc>().add(
        SubmitHaroldQuery(
          query: _textController.text.trim(),
          isUserAuthenticated: false, // This will be determined in the BLoC
        ),
      );
    }
  }
}
