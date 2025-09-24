import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_method_card_action.dart';

/// Configuration class for PaymentMethodsList widget
/// Provides different configurations for various use cases like profile management and checkout
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

  /// Factory constructor for profile screen configuration
  /// Shows payment methods with delete functionality and add button
  factory PaymentMethodsListConfig.forProfile({required Function(PaymentMethodEntity) onDelete, required VoidCallback onAddPaymentMethod}) {
    return PaymentMethodsListConfig(
      title: AppStrings.paymentMethods,
      subtitle: AppStrings.savedPaymentMethods,
      emptyStateMessage: AppStrings.noPaymentMethodsYet,
      showAddButton: true,
      wrapWithGestureDetector: false,
      onAddPaymentMethod: onAddPaymentMethod,
      onPaymentMethodDelete: onDelete,
    );
  }

  /// Factory constructor for checkout screen configuration
  /// Shows payment methods with selection functionality and add button
  factory PaymentMethodsListConfig.forCheckout({required Function(PaymentMethodEntity) onSelect, required VoidCallback onAddPaymentMethod}) {
    return PaymentMethodsListConfig(
      title: AppStrings.paymentMethod,
      subtitle: AppStrings.selectPreferredPaymentCard,
      emptyStateMessage: AppStrings.noPaymentMethodsAddOne,
      showAddButton: true,
      wrapWithGestureDetector: true,
      onAddPaymentMethod: onAddPaymentMethod,
      onPaymentMethodTap: onSelect,
      onPaymentMethodSelect: onSelect,
    );
  }

  /// Returns the appropriate action for a payment method based on the configuration
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
