import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../../payments/presentation/widgets/payment_method_card.dart';
import '../../../payments/presentation/widgets/payment_methods_list_config.dart';

class UnlockSummaryPaymentBottomSheet extends StatefulWidget {
  final String sessionId;
  final VoidCallback? onPaymentSuccess;

  const UnlockSummaryPaymentBottomSheet({super.key, required this.sessionId, this.onPaymentSuccess});

  @override
  State<UnlockSummaryPaymentBottomSheet> createState() => _UnlockSummaryPaymentBottomSheetState();
}

class _UnlockSummaryPaymentBottomSheetState extends State<UnlockSummaryPaymentBottomSheet> {
  String? _selectedPaymentMethodId;
  PaymentMethodEntity? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadPaymentMethods());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF16181E),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.customBackgroundGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DimensionConstants.radius20Px.r),
            topRight: Radius.circular(DimensionConstants.radius20Px.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 4.h,
              margin: EdgeInsets.only(top: DimensionConstants.gap12Px.h),
              decoration: BoxDecoration(color: context.white, borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: DimensionConstants.gap24Px.h),
            GlobalImage(
              assetPath: ImageConstants.unlockSummaryPayment,
              width: DimensionConstants.gap64Px.w,
              height: DimensionConstants.gap64Px.h,
              fit: BoxFit.contain,
              showLoading: false,
              showError: false,
              fadeIn: false,
            ),
            SizedBox(height: DimensionConstants.gap20Px.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
              child: Column(
                children: [
                  TranslatedText(
                    AppStrings.confirmPurchase,
                    style: TextStyle(
                      color: context.darkTextPrimary,
                      fontSize: DimensionConstants.font22Px.f,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DimensionConstants.gap12Px.h),
                  TranslatedText(
                    AppStrings.professionallyReviewedSummaryDescription,
                    style: TextStyle(
                      color: context.darkTextSecondary,
                      fontSize: DimensionConstants.font14Px.f,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: DimensionConstants.gap20Px.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$25', style: TextStyle(color: context.neonBlue, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700)),
                SizedBox(width: DimensionConstants.gap8Px.w),
                TranslatedText(
                  AppStrings.forSessionSummary,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            SizedBox(height: DimensionConstants.gap24Px.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
              child: TranslatedText(
                AppStrings.selectPaymentMethod,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: DimensionConstants.gap16Px.h),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap32Px.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (state is PaymentError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w, vertical: DimensionConstants.gap32Px.h),
                    child: Center(
                      child: TranslatedText(
                        AppStrings.failedToLoadPaymentMethods,
                        style: TextStyle(color: context.red, fontSize: DimensionConstants.font14Px.f),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (state is PaymentMethodsLoaded) {
                  final paymentMethods = state.paymentMethods;
                  return _buildPaymentMethodsList(paymentMethods);
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: DimensionConstants.gap24Px.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => context.pop(),
                      backgroundColor: context.buttonSecondary,
                      textColor: context.darkTextPrimary,
                      borderColor: context.buttonSecondary,
                      borderWidth: 1,
                      borderRadius: 50.r,
                      height: 48.h,
                      padding: 0,
                      child: TranslatedText(
                        AppStrings.cancel,
                        style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: DimensionConstants.gap12Px.w),
                  Expanded(
                    child: CustomButton(
                      onPressed: _selectedPaymentMethodId != null ? _onConfirmAndPay : null,
                      backgroundColor: context.primary,
                      disabledBackgroundColor: context.buttonDisabled,
                      textColor: Colors.white,
                      borderRadius: 50.r,
                      height: 48.h,
                      padding: 0,
                      child: TranslatedText(
                        AppStrings.confirmAndPay,
                        style: TextStyle(
                          fontSize: DimensionConstants.font16Px.f,
                          fontWeight: FontWeight.w600,
                          color: _selectedPaymentMethodId != null ? Colors.white : context.darkTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DimensionConstants.gap24Px.h),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(List<PaymentMethodEntity> paymentMethods) {
    if (paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 300.h),
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: paymentMethods.length + 1,
        itemBuilder: (context, index) {
          if (index == paymentMethods.length) {
            return _buildAddPaymentMethodButton();
          }

          final paymentMethod = paymentMethods[index];
          final isSelected = _selectedPaymentMethodId == paymentMethod.id;
          final config = PaymentMethodsListConfig.forUnlockSummary(onSelect: _onSelectPaymentMethod, onAddPaymentMethod: _onAddPaymentMethod);

          return GestureDetector(
            onTap: () => _onSelectPaymentMethod(paymentMethod),
            child: PaymentMethodCard(paymentMethod: paymentMethod, action: config.getActionForPaymentMethod(paymentMethod), isSelected: isSelected),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w, vertical: DimensionConstants.gap32Px.h),
      child: Column(
        children: [
          GlobalImage(
            assetPath: ImageConstants.noPaymentMethods,
            width: 60.w,
            height: 60.h,
            fit: BoxFit.contain,
            showLoading: false,
            showError: false,
            fadeIn: false,
          ),
          SizedBox(height: DimensionConstants.gap12Px.h),
          TranslatedText(
            AppStrings.noPaymentMethodsAddOne,
            style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          _buildAddPaymentMethodButton(),
        ],
      ),
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return GestureDetector(
      onTap: _onAddPaymentMethod,
      child: Container(
        margin: EdgeInsets.only(top: DimensionConstants.gap8Px.h, bottom: DimensionConstants.gap8Px.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
              child: Icon(Icons.add, color: context.white, size: DimensionConstants.icon24Px.f),
            ),
            SizedBox(width: DimensionConstants.gap12Px.w),
            TranslatedText(
              AppStrings.addAnotherPaymentMethod,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectPaymentMethod(PaymentMethodEntity paymentMethod) {
    setState(() {
      _selectedPaymentMethodId = paymentMethod.id;
      _selectedPaymentMethod = paymentMethod;
    });
  }

  void _onAddPaymentMethod() {
    context.push(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.home}).then((value) {
      if (value != null) {
        context.read<PaymentBloc>().add(const LoadPaymentMethods());
      }
    });
  }

  void _onConfirmAndPay() {
    if (_selectedPaymentMethod != null) {
      widget.onPaymentSuccess?.call();
      context.pop(_selectedPaymentMethod);
    }
  }
}
