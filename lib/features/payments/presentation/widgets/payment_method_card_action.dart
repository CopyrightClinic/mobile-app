import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../domain/entities/payment_method_entity.dart';

/// Abstract base class for payment method card actions
abstract class PaymentMethodCardAction {
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected);
}

/// Action for deleting a payment method
class DeletePaymentMethodAction extends PaymentMethodCardAction {
  final VoidCallback onDelete;

  DeletePaymentMethodAction({required this.onDelete});

  @override
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected) {
    return IconButton(
      onPressed: onDelete,
      icon: Icon(Icons.delete_outline, color: context.red, size: DimensionConstants.icon24Px.f),
      padding: EdgeInsets.all(DimensionConstants.gap8Px.w),
      constraints: const BoxConstraints(),
    );
  }
}

/// Action for selecting a payment method (used in payment selection screens)
class SelectPaymentMethodAction extends PaymentMethodCardAction {
  final VoidCallback onSelect;

  SelectPaymentMethodAction({required this.onSelect});

  @override
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? context.white : context.white, width: 2),
          color: Colors.transparent,
        ),
        child:
            isSelected
                ? Center(child: Container(width: 10.w, height: 10.h, decoration: BoxDecoration(shape: BoxShape.circle, color: context.white)))
                : null,
      ),
    );
  }
}

/// Action for tapping a payment method (general tap action)
class TapPaymentMethodAction extends PaymentMethodCardAction {
  final VoidCallback onTap;

  TapPaymentMethodAction({required this.onTap});

  @override
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? context.primary : context.darkTextSecondary, width: 2),
        color: isSelected ? context.primary : Colors.transparent,
      ),
      child:
          isSelected
              ? Center(child: Container(width: 8.w, height: 8.h, decoration: BoxDecoration(shape: BoxShape.circle, color: context.white)))
              : null,
    );
  }
}

/// Action for when no action is needed (displays nothing)
class NoPaymentMethodAction extends PaymentMethodCardAction {
  @override
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected) {
    return const SizedBox.shrink();
  }
}
