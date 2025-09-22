import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_method_card.dart';
import 'payment_methods_list_config.dart';

class PaymentMethodsList extends StatelessWidget {
  final List<PaymentMethodEntity> paymentMethods;
  final PaymentMethodsListConfig config;
  final String? selectedPaymentMethodId;
  final bool isLoading;

  const PaymentMethodsList({super.key, required this.paymentMethods, required this.config, this.selectedPaymentMethodId, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (config.subtitle != null) ...[
          SizedBox(height: DimensionConstants.gap8Px.h),
          TranslatedText(
            config.subtitle!,
            style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
          ),
        ],
        SizedBox(height: DimensionConstants.gap24Px.h),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (paymentMethods.isEmpty)
          _buildEmptyState(context)
        else
          Expanded(
            child: ListView.builder(
              itemCount: paymentMethods.length + (config.showAddButton ? 1 : 0),
              itemBuilder: (context, index) {
                if (config.showAddButton && index == paymentMethods.length) {
                  return _buildAddPaymentMethodButton(context);
                }

                final paymentMethod = paymentMethods[index];
                final isSelected = selectedPaymentMethodId == paymentMethod.id;

                return config.wrapWithGestureDetector
                    ? GestureDetector(
                      onTap: () => config.onPaymentMethodTap?.call(paymentMethod),
                      child: PaymentMethodCard(
                        paymentMethod: paymentMethod,
                        action: config.getActionForPaymentMethod(paymentMethod),
                        isSelected: isSelected,
                      ),
                    )
                    : PaymentMethodCard(
                      paymentMethod: paymentMethod,
                      action: config.getActionForPaymentMethod(paymentMethod),
                      isSelected: isSelected,
                    );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off, size: 64.w, color: context.darkTextSecondary),
            SizedBox(height: DimensionConstants.gap16Px.h),
            TranslatedText(
              config.emptyStateMessage ?? AppStrings.noPaymentMethods,
              style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
            ),
            if (config.showAddButton) ...[SizedBox(height: DimensionConstants.gap24Px.h), _buildAddPaymentMethodButton(context)],
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodButton(BuildContext context) {
    return GestureDetector(
      onTap: config.onAddPaymentMethod,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
              child: Icon(Icons.add, color: context.white, size: DimensionConstants.icon24Px.f),
            ),
            SizedBox(width: DimensionConstants.gap16Px.w),
            TranslatedText(
              AppStrings.addAnotherPaymentMethod,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
