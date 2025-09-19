import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_method_card.dart';

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
            GlobalImage(assetPath: ImageConstants.noPaymentMethods, width: 80.w, height: 80.h),
            SizedBox(height: DimensionConstants.gap16Px.h),
            TranslatedText(
              config.emptyStateMessage ?? AppStrings.noPaymentMethods,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w700),
            ),
            TranslatedText(
              AppStrings.tapToAdd,
              style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
            ),
            if (config.showAddButton) ...[SizedBox(height: DimensionConstants.gap18Px.h), _buildAddPaymentMethodButton(context)],
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodButton(BuildContext context) {
    return GestureDetector(
      onTap: config.onAddPaymentMethod,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
        child: Icon(Icons.add, color: context.white, size: DimensionConstants.icon24Px.f),
      ),
    );
  }
}

class PaymentMethodsListConfig {
  final String? title;
  final String? subtitle;
  final String? emptyStateMessage;
  final bool showAddButton;
  final bool wrapWithGestureDetector;
  final VoidCallback? onAddPaymentMethod;
  final Function(PaymentMethodEntity)? onPaymentMethodTap;
  final Function(PaymentMethodEntity)? onPaymentMethodDelete;
  final Function(PaymentMethodEntity)? onPaymentMethodSelect;

  const PaymentMethodsListConfig({
    this.title,
    this.subtitle,
    this.emptyStateMessage,
    this.showAddButton = false,
    this.wrapWithGestureDetector = false,
    this.onAddPaymentMethod,
    this.onPaymentMethodTap,
    this.onPaymentMethodDelete,
    this.onPaymentMethodSelect,
  });

  factory PaymentMethodsListConfig.forProfile({required Function(PaymentMethodEntity) onDelete, required VoidCallback onAddPaymentMethod}) {
    return PaymentMethodsListConfig(
      title: AppStrings.paymentMethods,
      subtitle: AppStrings.savedPaymentMethods,
      emptyStateMessage: AppStrings.noPaymentMethods,
      showAddButton: true,
      wrapWithGestureDetector: false,
      onAddPaymentMethod: onAddPaymentMethod,
      onPaymentMethodDelete: onDelete,
    );
  }

  factory PaymentMethodsListConfig.forCheckout({required Function(PaymentMethodEntity) onSelect, required VoidCallback onAddPaymentMethod}) {
    return PaymentMethodsListConfig(
      title: AppStrings.paymentMethod,
      subtitle: AppStrings.selectPreferredPaymentCard,
      emptyStateMessage: AppStrings.noPaymentMethods,
      showAddButton: true,
      wrapWithGestureDetector: true,
      onAddPaymentMethod: onAddPaymentMethod,
      onPaymentMethodTap: onSelect,
      onPaymentMethodSelect: onSelect,
    );
  }

  PaymentMethodCardAction getActionForPaymentMethod(PaymentMethodEntity paymentMethod) {
    if (onPaymentMethodDelete != null) {
      return DeletePaymentMethodAction(onDelete: () => onPaymentMethodDelete!(paymentMethod));
    }

    if (onPaymentMethodSelect != null) {
      return SelectPaymentMethodAction(onSelect: () => onPaymentMethodSelect!(paymentMethod));
    }

    if (onPaymentMethodTap != null) {
      return TapPaymentMethodAction(onTap: () => onPaymentMethodTap!(paymentMethod));
    }

    return TapPaymentMethodAction(onTap: () {});
  }
}
