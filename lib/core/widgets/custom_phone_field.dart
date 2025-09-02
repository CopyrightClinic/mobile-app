import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';

import 'translated_text.dart';

class CustomPhoneField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final AutovalidateMode autovalidateMode;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<PhoneNumber>? onChanged;
  final String? initialValue;
  final String? initialCountryCode;

  const CustomPhoneField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofocus = false,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.initialValue,
    this.initialCountryCode = 'US',
  });

  @override
  State<CustomPhoneField> createState() => CustomPhoneFieldState();
}

class CustomPhoneFieldState extends State<CustomPhoneField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(widget.label, style: TextStyle(color: context.darkTextPrimary, fontSize: 13.f, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            _phoneNumber = number;
            widget.onChanged?.call(number);
          },
          onInputValidated: (bool value) {
            _isPhoneValid = value;
            if (mounted) {
              setState(() {});
            }
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            useBottomSheetSafeArea: true,
            setSelectorButtonAsPrefixIcon: true,
            leadingPadding: 16,
            trailingSpace: false,
          ),
          ignoreBlank: false,
          autoValidateMode: widget.autovalidateMode,
          selectorTextStyle: TextStyle(color: context.textColor, fontSize: 16.f, fontWeight: FontWeight.w400),
          initialValue: PhoneNumber(isoCode: widget.initialCountryCode),
          textFieldController: _controller,
          focusNode: _focusNode,
          formatInput: true,
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
          inputBorder: InputBorder.none,
          onSaved: (PhoneNumber number) {
            _phoneNumber = number;
          },
          onFieldSubmitted: (value) {
            widget.onEditingComplete?.call();
          },
          validator: widget.validator,
          textStyle: TextStyle(color: context.textColor, fontSize: 16.f, fontWeight: FontWeight.w400),
          inputDecoration: InputDecoration(
            hintText: widget.placeholder.tr(),
            hintStyle: TextStyle(color: context.darkTextSecondary, fontSize: 16.f, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: context.surfaceColor.withValues(alpha: 0.8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.radiusMedium), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.radiusMedium), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusMedium),
              borderSide: BorderSide(color: context.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusMedium),
              borderSide: BorderSide(color: context.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusMedium),
              borderSide: BorderSide(color: context.red, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: context.spacingMedium, vertical: context.spacingMedium),
          ),
          searchBoxDecoration: InputDecoration(
            hintText: 'Search country',
            hintStyle: TextStyle(color: context.darkTextSecondary, fontSize: 16.f, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: context.surfaceColor.withValues(alpha: 0.8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.radiusMedium), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.radiusMedium), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusMedium),
              borderSide: BorderSide(color: context.primaryColor, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: context.spacingMedium, vertical: context.spacingMedium),
            prefixIcon: Icon(Icons.search, color: context.darkTextSecondary, size: 20.f),
          ),
        ),
      ],
    );
  }

  PhoneNumber? get phoneNumber => _phoneNumber;

  String? get formattedPhoneNumber => _phoneNumber?.phoneNumber;

  String? get parsedPhoneNumber => _phoneNumber?.parseNumber();

  bool isValid() {
    return _isPhoneValid && _phoneNumber != null && _phoneNumber!.phoneNumber != null && _phoneNumber!.phoneNumber!.isNotEmpty;
  }

  bool get isPhoneValid => _isPhoneValid;
}
