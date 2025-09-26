import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/payment_method.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_phone_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:copyright_clinic_flutter/core/utils/ui/snackbar_utils.dart';
import 'package:copyright_clinic_flutter/di.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/routes/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final GlobalKey<CustomPhoneFieldState> _phoneFieldKey = GlobalKey<CustomPhoneFieldState>();

  void Function(void Function())? _buttonSetState;
  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fullNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final fullNameValidation = validateFullName(_fullNameController.text.trim(), tr);
    final addressValidation = validateAddress(_addressController.text.trim(), tr);
    final isPhoneValid = _phoneFieldKey.currentState?.isValid() ?? false;
    return fullNameValidation == null && addressValidation == null && isPhoneValid;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      final name = _fullNameController.text.trim();
      final phoneNumber = _phoneNumber?.phoneNumber ?? '';
      final address = _addressController.text.trim();

      context.read<AuthBloc>().add(CompleteProfileRequested(name: name, phoneNumber: phoneNumber, address: address));

      _fullNameFocusNode.unfocus();
      _phoneFocusNode.unfocus();
      _addressFocusNode.unfocus();
    }
  }

  void _handleSkip() {
    context.go(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.auth});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CompleteProfileSuccess) {
            SnackBarUtils.showSuccess(context, state.message);
            context.go(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.auth});
          } else if (state is CompleteProfileError) {
            SnackBarUtils.showError(context, state.message);
          }
        },
        child: CustomScaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            showBackButton: false,
            title: TranslatedText(
              AppStrings.completeYourProfile,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: DimensionConstants.gap16Px.w),
                child: ElevatedButton(
                  onPressed: _handleSkip,
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
                    SizedBox(height: DimensionConstants.gap20Px.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: DimensionConstants.gap20Px.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              label: AppStrings.fullName,
                              placeholder: AppStrings.enterYourFullName,
                              controller: _fullNameController,
                              focusNode: _fullNameFocusNode,
                              keyboardType: TextInputType.name,
                              validator: (value) => validateFullName(value, tr),
                              onEditingComplete: () => _phoneFocusNode.requestFocus(),
                              onChanged: (value) => _onFieldChanged(),
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),

                            CustomPhoneField(
                              key: _phoneFieldKey,
                              label: AppStrings.phoneNumber,
                              placeholder: AppStrings.enterYourPhoneNumber,
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              onEditingComplete: () => _addressFocusNode.requestFocus(),
                              onChanged: (PhoneNumber phoneNumber) {
                                _phoneNumber = phoneNumber;
                                _onFieldChanged();
                              },
                              onValidationChanged: (bool isValid) {
                                _onFieldChanged();
                              },
                              initialCountryCode: 'US',
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),

                            CustomTextField(
                              label: AppStrings.address,
                              placeholder: AppStrings.enterYourAddress,
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              keyboardType: TextInputType.streetAddress,
                              maxLines: 3,
                              validator: (value) => validateAddress(value, tr),
                              onEditingComplete: () => _addressFocusNode.unfocus(),
                              onChanged: (value) => _onFieldChanged(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    BlocBuilder<AuthBloc, AuthState>(
                      bloc: sl<AuthBloc>(),
                      builder: (context, state) {
                        final isLoading = state is CompleteProfileLoading;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return AuthButton(text: AppStrings.save, onPressed: _handleSave, isLoading: isLoading, isEnabled: _isFormValid);
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
      ),
    );
  }
}
