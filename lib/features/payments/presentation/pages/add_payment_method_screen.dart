import 'package:copyright_clinic_flutter/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/utils/mixin/validator.dart';
import '../../../../core/utils/logger/logger.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final ValueNotifier<bool> _cardCompleteNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _formValidNotifier = ValueNotifier<bool>(false);

  final CardFormEditController _cardFormController = CardFormEditController();

  final _nameFocusNode = FocusNode();

  late PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _addListeners();
    _paymentBloc = sl<PaymentBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      bloc: _paymentBloc,
      listener: (context, state) {
        if (state is PaymentMethodAdded) {
          Log.d('AddPaymentMethodScreen', 'Payment method added successfully - ID: ${state.paymentMethod.id}');
          SnackBarUtils.showSuccess(context, AppStrings.paymentMethodAdded.tr());
          context.pop();
        } else if (state is PaymentError) {
          Log.e('AddPaymentMethodScreen', 'Payment method addition failed: ${state.message}');
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          title: TranslatedText(
            AppStrings.addPaymentMethod,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w600),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: DimensionConstants.gap16Px.w),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.white,
                  foregroundColor: context.darkTextPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap20Px.w, vertical: DimensionConstants.gap12Px.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                  minimumSize: Size.zero,
                ),
                child: TranslatedText(
                  AppStrings.skip,
                  style: TextStyle(color: context.textPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: DimensionConstants.gap20Px.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: DimensionConstants.gap20Px.h),
                          CustomTextField(
                            label: AppStrings.nameOnCard,
                            placeholder: AppStrings.enterFullNameAsShownOnCard,
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            keyboardType: TextInputType.name,
                            validator: _validateName,
                            onEditingComplete: () {
                              _cardFormController.focus();
                            },
                            onChanged: (value) => _validateForm(),
                          ),

                          SizedBox(height: DimensionConstants.gap24Px.h),

                          TranslatedText(
                            AppStrings.cardDetails,
                            style: TextStyle(fontSize: DimensionConstants.font13Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
                          ),
                          SizedBox(height: DimensionConstants.gap8Px.h),
                          SizedBox(
                            height: 200.h,
                            child: CardFormField(
                              key: const ValueKey('stripe_card_form'),
                              controller: _cardFormController,
                              style: CardFormStyle(
                                backgroundColor: context.filledBgDark,
                                borderColor: context.primary,
                                borderRadius: DimensionConstants.radius12Px.r.toInt(),
                                cursorColor: context.primaryColor,
                                fontSize: DimensionConstants.font16Px.f.toInt(),
                                placeholderColor: context.darkTextSecondary,
                                textColor: context.darkTextPrimary,
                              ),
                              onCardChanged: (details) {
                                Log.d('AddPaymentMethodScreen', 'Card form changed: complete=${details?.complete}');
                                final complete = details?.complete ?? false;
                                if (complete != _cardCompleteNotifier.value) {
                                  _cardCompleteNotifier.value = complete;
                                  _validateForm();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  BlocBuilder<PaymentBloc, PaymentState>(
                    bloc: _paymentBloc,
                    builder: (context, state) {
                      final isLoading = state is PaymentLoading;

                      return ValueListenableBuilder<bool>(
                        valueListenable: _formValidNotifier,
                        builder: (context, isFormValid, child) {
                          return AuthButton(
                            text: AppStrings.addPaymentMethod,
                            onPressed: _onAddPaymentMethod,
                            isLoading: isLoading,
                            isEnabled: isFormValid,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addListeners() {
    _nameController.addListener(_validateForm);
  }

  void _validateForm() {
    final isNameValid = _nameController.text.isNotEmpty;
    final isCardValid = _cardCompleteNotifier.value;
    final newFormValid = isNameValid && isCardValid;

    Log.d('AddPaymentMethodScreen', 'Validation: name=$isNameValid, card=$isCardValid, form=$newFormValid');

    if (_formValidNotifier.value != newFormValid) {
      _formValidNotifier.value = newFormValid;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.cardholderNameIsRequired.tr();
    }
    return null;
  }

  void _onAddPaymentMethod() {
    Log.d('AddPaymentMethodScreen', 'Add payment method button pressed');
    if (_formKey.currentState?.validate() == true && _formValidNotifier.value && _cardCompleteNotifier.value) {
      Log.d('AddPaymentMethodScreen', 'Form validation passed - submitting payment method for ${_nameController.text}');

      _paymentBloc.add(AddPaymentMethodRequested(cardholderName: _nameController.text));
    } else {
      Log.w('AddPaymentMethodScreen', 'Form validation failed or card details incomplete - cannot submit payment method');
      if (!_cardCompleteNotifier.value) {
        Log.w('AddPaymentMethodScreen', 'Card form is not complete');
      }
    }
  }

  @override
  void dispose() {
    Log.d('AddPaymentMethodScreen', 'Screen disposed');
    _nameController.dispose();
    _cardFormController.dispose();
    _cardCompleteNotifier.dispose();
    _formValidNotifier.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
