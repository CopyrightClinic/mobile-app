import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/enumns/ui/card_brand.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_method_card_action.dart';

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
    final cardBrand = CardBrand.fromString(paymentMethod.card.brand);
    final cardImagePath = cardBrand.imagePath;

    return Container(
      width: 48.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: cardImagePath == null ? cardBrand.brandColor : Colors.transparent,
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
                  cardBrand.abbreviatedText,
                  style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w700),
                ),
              ),
    );
  }

  String _getCardDisplayName() {
    final cardBrand = CardBrand.fromString(paymentMethod.card.brand);
    return cardBrand.displayName;
  }
}
