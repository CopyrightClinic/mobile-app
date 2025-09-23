import 'package:flutter/foundation.dart';
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
import '../../../../system_speech.dart';

class AskHaroldAiScreen extends StatefulWidget {
  const AskHaroldAiScreen({super.key});

  @override
  State<AskHaroldAiScreen> createState() => _AskHaroldAiScreenState();
}

class _AskHaroldAiScreenState extends State<AskHaroldAiScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final ValueNotifier<bool> _isListeningNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
    _isListeningNotifier.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    return _textController.text.trim().length > 1;
  }

  void _toggleVoiceInput() async {
    if (_isListeningNotifier.value) {
      _stopVoiceInput();
    } else {
      _startVoiceInput();
    }
  }

  void _startVoiceInput() async {
    _isListeningNotifier.value = true;

    try {
      final result = await SystemSpeech.startSpeech(prompt: 'Describe your copyright issue', locale: 'en-US', maxSeconds: 120);

      if (result != null && result.isNotEmpty) {
        final existingText = _textController.text;
        final separator = existingText.isNotEmpty ? ' ' : '';
        final combinedText = existingText + separator + result;
        _textController.text = combinedText;
        _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
      }
    } catch (e) {
      String errorMessage = 'Speech recognition error: ${e.toString()}';

      final errorString = e.toString();
      if (errorString.contains('network') ||
          errorString.contains('internet') ||
          errorString.contains('connection') ||
          errorString.contains('speech_not_available')) {
        errorMessage = 'Speech recognition requires internet connection on iOS 16 and earlier. Please check your connection and try again.';
      } else if (errorString.contains('Siri and Dictation are disabled') || errorString.contains('enable Dictation in Settings')) {
        errorMessage = 'Speech recognition is disabled. Please enable Dictation in Settings → General → Keyboard → Enable Dictation.';
      }

      SnackBarUtils.showError(context, errorMessage);
    } finally {
      _isListeningNotifier.value = false;
    }
  }

  void _stopVoiceInput() async {
    try {
      final result = await SystemSpeech.stopSpeech();

      if (result != null && result.isNotEmpty) {
        final existingText = _textController.text;
        final separator = existingText.isNotEmpty ? ' ' : '';
        final combinedText = existingText + separator + result;
        _textController.text = combinedText;
        _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
      }
    } catch (e) {
    } finally {
      _isListeningNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HaroldAiBloc, HaroldAiState>(
      bloc: sl<HaroldAiBloc>(),
      listener: (context, state) {
        if (state is HaroldAiSuccess) {
          HaroldNavigationService.handleHaroldResult(
            context: context,
            isSuccess: true,
            isUserAuthenticated: state.isUserAuthenticated,
            query: state.query,
          );
        } else if (state is HaroldAiFailure) {
          HaroldNavigationService.handleHaroldResult(
            context: context,
            isSuccess: false,
            isUserAuthenticated: state.isUserAuthenticated,
            query: state.query,
          );
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
    return BlocBuilder<HaroldAiBloc, HaroldAiState>(
      builder: (context, haroldState) {
        final isLoading = haroldState is HaroldAiLoading;

        return Container(
          padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
          decoration: BoxDecoration(
            color: isLoading ? context.filledBgDark.withValues(alpha: 0.5) : context.filledBgDark,
            borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
          ),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !isLoading,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color: isLoading ? context.darkTextPrimary.withValues(alpha: 0.5) : context.darkTextPrimary,
                    fontSize: DimensionConstants.font16Px.f,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.describe,
                    hintStyle: TextStyle(
                      color: isLoading ? context.darkTextSecondary.withValues(alpha: 0.5) : context.darkTextSecondary,
                      fontSize: DimensionConstants.font16Px.f,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return BlocBuilder<HaroldAiBloc, HaroldAiState>(
      builder: (context, haroldState) {
        final isHaroldLoading = haroldState is HaroldAiLoading;
        final isEnabled = !isHaroldLoading;

        return ValueListenableBuilder<bool>(
          valueListenable: _isListeningNotifier,
          builder: (context, isListening, child) {
            return GestureDetector(
              onTap: isEnabled ? _toggleVoiceInput : null,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isListening ? _scaleAnimation.value : 1.0,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isListening ? context.primary : (isEnabled ? context.filledBgDark : context.filledBgDark.withValues(alpha: 0.5)),
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
                          Icon(
                            isListening ? Icons.stop : Icons.mic,
                            color:
                                isListening ? Colors.white : (isEnabled ? context.darkTextPrimary : context.darkTextPrimary.withValues(alpha: 0.5)),
                            size: 24.w,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onSubmit() {
    if (_isValidInput()) {
      FocusScope.of(context).unfocus();
      context.read<HaroldAiBloc>().add(SubmitHaroldQuery(query: _textController.text.trim(), isUserAuthenticated: false));
    }
  }
}
