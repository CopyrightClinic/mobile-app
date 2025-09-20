import 'package:copyright_clinic_flutter/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../config/routes/app_routes.dart';
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
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../harold_ai/domain/services/harold_navigation_service.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  final PaymentMethodFrom from;
  const AddPaymentMethodScreen({super.key, required this.from});

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

  void _handleAuthFlowCompletion(BuildContext context) {
    final data = HaroldNavigationService().getPendingResultAndQuery();
    if (!mounted) return;

    final pendingResult = data['result'];
    final pendingQuery = data['query'];

    if (pendingResult != null) {
      if (pendingResult == 'success') {
        context.go(AppRoutes.haroldSuccessRouteName, extra: {'fromAuthFlow': true, 'query': pendingQuery});
      } else {
        context.go(AppRoutes.haroldFailedRouteName, extra: {'fromAuthFlow': true, 'query': pendingQuery});
      }
    } else {
      context.go(AppRoutes.homeRouteName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      bloc: _paymentBloc,
      listener: (context, state) {
        if (state is PaymentMethodAdded) {
          SnackBarUtils.showSuccess(context, AppStrings.paymentMethodAdded.tr());
          if (widget.from == PaymentMethodFrom.auth) {
            _handleAuthFlowCompletion(context);
          } else {
            context.pop(true);
          }
        } else if (state is PaymentError) {
          SnackBarUtils.showError(context, state.message.tr());
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          title: TranslatedText(
            AppStrings.addPaymentMethod,
            style: TextStyle(
              color: context.darkTextPrimary,
              fontSize: widget.from == PaymentMethodFrom.home ? DimensionConstants.font18Px.f : DimensionConstants.font24Px.f,
              fontWeight: FontWeight.w600,
            ),
          ),
          automaticallyImplyLeading: widget.from == PaymentMethodFrom.home,
          centerTitle: widget.from == PaymentMethodFrom.home,
          actions: [
            if (widget.from == PaymentMethodFrom.auth) ...[
              Padding(
                padding: EdgeInsets.only(right: DimensionConstants.gap16Px.w),
                child: ElevatedButton(
                  onPressed: () {
                    _handleAuthFlowCompletion(context);
                  },
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
                            height: 300.h,
                            child: CardFormField(
                              key: const ValueKey('stripe_card_form'),
                              controller: _cardFormController,
                              style: CardFormStyle(
                                backgroundColor: context.surfaceColor.withValues(alpha: 0.8),
                                borderColor: Colors.white,
                                borderRadius: DimensionConstants.radius12Px.r.toInt(),
                                cursorColor: context.primaryColor,
                                fontSize: DimensionConstants.font16Px.f.toInt(),
                                placeholderColor: context.white,
                                textColor: context.white,
                              ),
                              onCardChanged: (details) {
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

    if (_formValidNotifier.value != newFormValid) {
      _formValidNotifier.value = newFormValid;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.cardholderNameIsRequired.tr();
    } else if (value.trim().length > 100) {
      return AppStrings.cardholderNameCannotExceed100Characters.tr();
    }
    return null;
  }

  void _onAddPaymentMethod() {
    if (_formKey.currentState?.validate() == true && _formValidNotifier.value && _cardCompleteNotifier.value) {
      _paymentBloc.add(AddPaymentMethodRequested(cardholderName: _nameController.text));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardFormController.dispose();
    _cardCompleteNotifier.dispose();
    _formValidNotifier.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
