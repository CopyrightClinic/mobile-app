import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';

class AskHaroldAiScreen extends StatefulWidget {
  const AskHaroldAiScreen({super.key});

  @override
  State<AskHaroldAiScreen> createState() => _AskHaroldAiScreenState();
}

class _AskHaroldAiScreenState extends State<AskHaroldAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<bool> _isListening = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _textController.dispose();
    _isListening.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    return _textController.text.trim().length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
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
    );
  }

  Widget _buildTextInputField() {
    return Container(
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
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildVoiceButton()]),
          SizedBox(height: DimensionConstants.gap16Px.h),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, value, child) {
              final isValid = _isValidInput();
              return AuthButton(text: AppStrings.submit, onPressed: isValid ? _onSubmit : null, isLoading: false, isEnabled: isValid);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isListening,
      builder: (context, isListening, child) {
        return GestureDetector(
          onTap: _toggleVoiceInput,
          child: Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(color: isListening ? context.primary : context.filledBgDark, shape: BoxShape.circle),
            child: Icon(Icons.mic, color: isListening ? Colors.white : context.darkTextPrimary, size: 24.w),
          ),
        );
      },
    );
  }

  void _toggleVoiceInput() {
    _isListening.value = !_isListening.value;

    // TODO: Implement voice input functionality
    if (_isListening.value) {
      // Start voice recording
    } else {
      // Stop voice recording
    }
  }

  void _onSubmit() {
    if (_isValidInput()) {
      // TODO: Implement Harold AI submission logic
      print('Submitted: ${_textController.text}');
      context.pop();
    }
  }
}
