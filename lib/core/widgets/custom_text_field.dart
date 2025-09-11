import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/dimensions.dart';
import '../utils/mixin/validator.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';
import 'translated_text.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool readOnly;
  final AutovalidateMode autovalidateMode;
  final Widget? suffixIcon;
  final int maxLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.suffixIcon,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with Validator {
  bool _obscureText = true;
  late TextEditingController _controller;
  late FocusNode _focusNode;

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
        TranslatedText(
          widget.label,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font13Px.f, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: DimensionConstants.gap8Px.h),
        TextFormField(
          autovalidateMode: widget.autovalidateMode,
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscureText,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: TextStyle(color: context.textColor, fontSize: 16.f, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
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
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: context.darkTextPrimary,
                        size: 20.f,
                      ),
                    )
                    : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
