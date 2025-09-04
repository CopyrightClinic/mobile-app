import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/card_input_formatters.dart';
import '../widgets/custom_text_field.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    _nameController.addListener(_validateForm);
    _cardNumberController.addListener(_validateForm);
    _expiryController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        _nameController.text.isNotEmpty &&
        _cardNumberController.text.replaceAll(' ', '').length >= 13 &&
        _expiryController.text.length == 5 &&
        _cvvController.text.length >= 3;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.cardNumberIsRequired.tr();
    }
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return AppStrings.invalidCardNumber.tr();
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.expirationDateIsRequired.tr();
    }
    if (value.length != 5) {
      return AppStrings.invalidExpirationDate.tr();
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return AppStrings.invalidExpirationDate.tr();
    }

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return AppStrings.invalidExpirationDate.tr();
    }

    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month);
    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return AppStrings.invalidExpirationDate.tr();
    }

    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.cvvIsRequired.tr();
    }
    if (value.length < 3 || value.length > 4) {
      return AppStrings.invalidCvv.tr();
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.cardholderNameIsRequired.tr();
    }
    return null;
  }

  void _onAddPaymentMethod() {
    if (_formKey.currentState?.validate() == true && _isFormValid) {
      final expiry = _expiryController.text.split('/');
      context.read<PaymentBloc>().add(
        AddPaymentMethodRequested(
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          expiryMonth: expiry[0],
          expiryYear: '20${expiry[1]}',
          cvv: _cvvController.text,
          cardholderName: _nameController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.greyLight,
      body: GradientBackground(
        child: SafeArea(
          child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentMethodAdded) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(AppStrings.paymentMethodAdded.tr()), backgroundColor: AppTheme.green));
                context.pop();
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.red));
              }
            },
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context, isDark),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DimensionConstants.gap24Px),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: DimensionConstants.gap32Px),

                          // Name on Card
                          CustomTextField(
                            label: AppStrings.nameOnCard,
                            hint: AppStrings.enterFullNameAsShownOnCard,
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            validator: _validateName,
                          ),

                          SizedBox(height: DimensionConstants.gap24Px),

                          // Card Number
                          CustomTextField(
                            label: AppStrings.cardNumber,
                            hint: AppStrings.enterCardNumber,
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberInputFormatter()],
                            validator: _validateCardNumber,
                          ),

                          SizedBox(height: DimensionConstants.gap24Px),

                          // Expiry Date and CVV Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: AppStrings.expirationDate,
                                  hint: AppStrings.mmYy,
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateInputFormatter()],
                                  validator: _validateExpiryDate,
                                ),
                              ),

                              SizedBox(width: DimensionConstants.gap16Px),

                              Expanded(
                                child: CustomTextField(
                                  label: AppStrings.cvv,
                                  hint: AppStrings.enterCvv,
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CVVInputFormatter()],
                                  validator: _validateCVV,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Button
                _buildBottomButton(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px, vertical: DimensionConstants.gap8Px),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),

          Expanded(
            child: Text(
              AppStrings.addPaymentMethod.tr(),
              style: TextStyle(
                fontSize: DimensionConstants.font18Px,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),

          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              AppStrings.skip.tr(),
              style: TextStyle(
                fontSize: DimensionConstants.font16Px,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textBodyLight,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DimensionConstants.gap24Px),
      child: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          final isLoading = state is PaymentLoading;

          return SizedBox(
            width: double.infinity,
            height: DimensionConstants.gap56Px,
            child: ElevatedButton(
              onPressed: _isFormValid && !isLoading ? _onAddPaymentMethod : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: isDark ? AppTheme.buttonDiabled : AppTheme.placeholder,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DimensionConstants.radius12Px)),
              ),
              child:
                  isLoading
                      ? SizedBox(
                        height: DimensionConstants.gap24Px,
                        width: DimensionConstants.gap24Px,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppTheme.darkTextPrimary : AppTheme.white),
                        ),
                      )
                      : Text(
                        AppStrings.addPaymentMethod.tr(),
                        style: TextStyle(
                          fontSize: DimensionConstants.font16Px,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}
