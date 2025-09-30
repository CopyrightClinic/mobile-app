import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_phone_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_app_bar.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/utils/phone_number_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:copyright_clinic_flutter/core/utils/ui/snackbar_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final GlobalKey<CustomPhoneFieldState> _phoneFieldKey = GlobalKey<CustomPhoneFieldState>();

  void Function(void Function())? _buttonSetState;
  PhoneNumber? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _prepopulateFields();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is UpdateProfileSuccess) {
          SnackBarUtils.showSuccess(context, state.message);
          context.pop();
        } else if (state is UpdateProfileError) {
          SnackBarUtils.showError(context, state.message);
        }
      },

      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          leading: const CustomBackButton(),
          title: TranslatedText(
            AppStrings.editPersonalInformation,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
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

                          CustomTextField(
                            label: AppStrings.email,
                            placeholder: AppStrings.enterYourEmail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            validator: null,
                          ),
                          SizedBox(height: DimensionConstants.gap20Px.h),

                          CustomPhoneField(
                            key: _phoneFieldKey,
                            label: AppStrings.phoneNumber,
                            placeholder: AppStrings.enterYourPhoneNumber,
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            validator: (value) {
                              if (_phoneNumber == null || _phoneNumber!.phoneNumber == null || _phoneNumber!.phoneNumber!.isEmpty) {
                                return tr(AppStrings.phoneNumberRequired);
                              }
                              final isValid = _phoneFieldKey.currentState?.isPhoneValid ?? false;
                              if (!isValid) {
                                return tr(AppStrings.invalidPhoneNumber);
                              }
                              return null;
                            },
                            onEditingComplete: () => _addressFocusNode.requestFocus(),
                            onChanged: (PhoneNumber phoneNumber) {
                              _phoneNumber = phoneNumber;
                              _onFieldChanged();
                            },
                            initialValue: PhoneNumberUtils.getLocalPhoneNumber(widget.user.phoneNumber),
                            initialCountryCode: PhoneNumberUtils.getCountryCodeFromPhoneNumber(widget.user.phoneNumber),
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
                            onEditingComplete: _handleSave,
                            onChanged: (value) => _onFieldChanged(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isLoading = state is UpdateProfileLoading;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          _buttonSetState = setState;
                          return AuthButton(text: AppStrings.saveChanges, onPressed: _handleSave, isLoading: isLoading, isEnabled: _isFormValid);
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

  void _prepopulateFields() {
    _fullNameController.text = widget.user.name ?? '';
    _emailController.text = widget.user.email;
    _addressController.text = widget.user.address ?? '';

    if (widget.user.phoneNumber != null && widget.user.phoneNumber!.isNotEmpty) {
      _phoneNumber = PhoneNumberUtils.createPhoneNumberFromInternational(widget.user.phoneNumber);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _phoneFieldKey.currentState?.triggerValidation();
          }
        });
      });
    }
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
    if (_formKey.currentState!.validate() && _phoneNumber != null) {
      final isPhoneValid = _phoneFieldKey.currentState?.isValid() ?? false;

      if (!isPhoneValid) {
        SnackBarUtils.showError(context, tr(AppStrings.invalidPhoneNumber));
        return;
      }

      final name = _fullNameController.text.trim();
      final phoneNumber = _phoneNumber!.phoneNumber ?? '';
      final address = _addressController.text.trim();

      context.read<ProfileBloc>().add(UpdateProfileRequested(name: name, phoneNumber: phoneNumber, address: address));

      _fullNameFocusNode.unfocus();
      _phoneFocusNode.unfocus();
      _addressFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fullNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }
}
