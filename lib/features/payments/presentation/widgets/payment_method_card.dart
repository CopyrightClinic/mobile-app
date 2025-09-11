import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../domain/entities/payment_method_entity.dart';

/// Flexible payment method card that supports different action types
/// Following Open/Closed Principle - open for extension, closed for modification
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodEntity paymentMethod;
  final PaymentMethodCardAction action;
  final bool isSelected;

  const PaymentMethodCard({super.key, required this.paymentMethod, required this.action, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DimensionConstants.gap16Px.h),
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: context.filledBgDark,
        borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
        border: isSelected ? Border.all(color: context.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          // Card Brand Icon
          _buildCardIcon(context),

          SizedBox(width: DimensionConstants.gap16Px.w),

          // Card Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  _getCardDisplayName(),
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: DimensionConstants.gap4Px.h),
                TranslatedText(
                  'ending in ${paymentMethod.card.last4}',
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: DimensionConstants.gap2Px.h),
                TranslatedText(
                  'Expires ${paymentMethod.card.expMonth.toString().padLeft(2, '0')}/${paymentMethod.card.expYear.toString().substring(2)}',
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),

          // Action Widget (Delete button, Radio button, etc.)
          action.buildActionWidget(context, paymentMethod, isSelected),
        ],
      ),
    );
  }

  Widget _buildCardIcon(BuildContext context) {
    final brandColor = _getCardBrandColor();

    return Container(
      width: 48.w,
      height: 32.h,
      decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r)),
      child: Center(
        child: TranslatedText(
          _getCardBrandText(),
          style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _getCardDisplayName() {
    switch (paymentMethod.card.brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return paymentMethod.card.brand;
    }
  }

  String _getCardBrandText() {
    switch (paymentMethod.card.brand.toLowerCase()) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'amex':
        return 'AMEX';
      case 'discover':
        return 'DISC';
      default:
        return paymentMethod.card.brand.substring(0, 4).toUpperCase();
    }
  }

  Color _getCardBrandColor() {
    switch (paymentMethod.card.brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      case 'discover':
        return const Color(0xFFFF6000);
      default:
        return const Color(0xFF666666);
    }
  }
}

/// Abstract base class for payment method card actions
/// This follows the Strategy Pattern for different action behaviors
abstract class PaymentMethodCardAction {
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected);
}

/// Delete action for profile payment methods screen
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

/// Selection action for checkout payment methods screen
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
          border: Border.all(color: isSelected ? context.primary : context.darkTextSecondary, width: 2),
          color: isSelected ? context.primary : Colors.transparent,
        ),
        child:
            isSelected
                ? Center(child: Container(width: 8.w, height: 8.h, decoration: BoxDecoration(shape: BoxShape.circle, color: context.white)))
                : null,
      ),
    );
  }
}

/// Tap action for simple card selection (entire card is tappable)
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
