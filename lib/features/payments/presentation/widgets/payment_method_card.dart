import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodEntity paymentMethod;
  final PaymentMethodCardAction action;
  final bool isSelected;

  const PaymentMethodCard({super.key, required this.paymentMethod, required this.action, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DimensionConstants.gap16Px.h),
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap12Px.h),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
      child: Row(
        children: [
          _buildCardIcon(context),

          SizedBox(width: DimensionConstants.gap16Px.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCardDisplayName(),
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: DimensionConstants.gap4Px.h),
                Text(
                  'ending in ${paymentMethod.card.last4}',
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: DimensionConstants.gap2Px.h),
                Text(
                  'Expires ${paymentMethod.card.expMonth.toString().padLeft(2, '0')}/${paymentMethod.card.expYear.toString().substring(2)}',
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),

          action.buildActionWidget(context, paymentMethod, isSelected),
        ],
      ),
    );
  }

  Widget _buildCardIcon(BuildContext context) {
    final cardImagePath = _getCardImagePath();

    return Container(
      width: 48.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: cardImagePath == null ? _getCardBrandColor() : Colors.transparent,
        borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r),
      ),
      child:
          cardImagePath != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r),
                child: GlobalImage(
                  assetPath: cardImagePath,
                  width: 48.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                  showLoading: false,
                  showError: false,
                  fadeIn: false,
                ),
              )
              : Center(
                child: Text(
                  _getCardBrandText(),
                  style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w700),
                ),
              ),
    );
  }

  String? _getCardImagePath() {
    switch (paymentMethod.card.brand.toLowerCase()) {
      case 'visa':
        return ImageConstants.visa;
      case 'mastercard':
        return ImageConstants.mastercard;
      default:
        return null;
    }
  }

  String _getCardDisplayName() {
    return paymentMethod.card.brand;
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

abstract class PaymentMethodCardAction {
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected);
}

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

  @override
  Widget buildActionWidget(BuildContext context, PaymentMethodEntity paymentMethod, bool isSelected) {
    return const SizedBox.shrink();
  }
}
