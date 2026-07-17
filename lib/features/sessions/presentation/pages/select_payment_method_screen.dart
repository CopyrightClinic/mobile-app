import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_bottomsheet.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../di.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../../payments/presentation/widgets/payment_methods_list.dart';
import '../../../payments/presentation/widgets/payment_methods_list_config.dart';
import '../../domain/entities/session_availability_entity.dart';
import 'params/select_payment_method_screen_params.dart';
import 'params/confirm_booking_screen_params.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  final SelectPaymentMethodScreenParams params;

  const SelectPaymentMethodScreen({super.key, required this.params});

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  late PaymentBloc _paymentBloc;
  String? _selectedPaymentMethodId;
  PaymentMethodEntity? _selectedPaymentMethod;
  late SessionFeeEntity _baseSessionFee;
  late SessionFeeEntity _sessionFee;
  String? _appliedCouponCode;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
    _baseSessionFee = widget.params.fee;
    _sessionFee = _baseSessionFee;
    _paymentBloc.add(const LoadPaymentMethods());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logAnalytics(
        AnalyticsEvents.addToCart,
        parameters: {
          'session_date': widget.params.sessionDate.toIso8601String(),
          'time_slot': widget.params.timeSlot,
          'currency': _sessionFee.currency,
          'value': _sessionFee.totalFee.toDouble(),
          'content_type': 'consultation',
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentProcessed) {
          SnackBarUtils.showSuccess(context, AppStrings.paymentSuccessful.tr());
          context.go(AppRoutes.homeRouteName);
        } else if (state is PaymentError) {
          logAnalytics(
            AnalyticsEvents.paymentFailed,
            parameters: {'source': 'select_payment_method'},
          );
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          leading: const CustomBackButton(),
          centerTitle: true,
          title: TranslatedText(
            AppStrings.paymentMethod,
            style: TextStyle(
              color: context.darkTextPrimary,
              fontSize: DimensionConstants.font18Px.f,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: DimensionConstants.gap16Px.w,
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      final isLoading = state is PaymentLoading;
                      final paymentMethods =
                          state is PaymentMethodsLoaded
                              ? state.paymentMethods
                              : <PaymentMethodEntity>[];

                      return PaymentMethodsList(
                        paymentMethods: paymentMethods,
                        isLoading: isLoading,
                        selectedPaymentMethodId: _selectedPaymentMethodId,
                        config: PaymentMethodsListConfig.forCheckout(
                          onSelect: _onSelectPaymentMethod,
                          onAddPaymentMethod: _onAddPaymentMethod,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DimensionConstants.gap16Px.w,
                ),
                child: _buildCouponSection(),
              ),

              SizedBox(height: DimensionConstants.gap8Px.h),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DimensionConstants.gap16Px.w,
                ),
                child: BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    final isProcessing = state is PaymentProcessing;
                    final canProceed =
                        _selectedPaymentMethodId != null ||
                        _appliedCouponCode != null;

                    return AuthButton(
                      text: AppStrings.continueText,
                      onPressed: canProceed ? _onContinue : null,
                      isLoading: isProcessing,
                      isEnabled: canProceed,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectPaymentMethod(PaymentMethodEntity paymentMethod) {
    setState(() {
      _selectedPaymentMethodId = paymentMethod.id;
      _selectedPaymentMethod = paymentMethod;
    });
    logAnalytics(
      AnalyticsEvents.addPaymentInfo,
      parameters: {
        'payment_type': paymentMethod.card.brand,
        'payment_method_id': paymentMethod.id,
      },
    );
  }

  void _onAddPaymentMethod() {
    context
        .push(
          AppRoutes.addPaymentMethodRouteName,
          extra: {'from': PaymentMethodFrom.home},
        )
        .then((value) {
          if (value != null) {
            _paymentBloc.add(const LoadPaymentMethods());
          }
        });
  }

  void _onContinue() {
    final hasCoupon = _appliedCouponCode != null;

    context.push(
      AppRoutes.confirmBookingRouteName,
      extra: ConfirmBookingScreenParams(
        sessionDate: widget.params.sessionDate,
        timeSlot: widget.params.timeSlot,
        paymentMethod: _selectedPaymentMethod,
        stripePaymentMethodId:
            hasCoupon ? '' : (_selectedPaymentMethod?.id ?? ''),
        couponCode: _appliedCouponCode,
        query: widget.params.query,
        fee: _sessionFee,
        eligibilitySummary: widget.params.eligibilitySummary,
      ),
    );
  }

  Widget _buildCouponSection() {
    final hasCoupon = _appliedCouponCode != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _showCouponBottomSheet,
            icon: Icon(
              Icons.local_offer_outlined,
              size: DimensionConstants.icon16Px.w,
              color: context.darkTextPrimary,
            ),
            label: TranslatedText(
              hasCoupon ? AppStrings.changeCoupon : AppStrings.addCoupon,
              style: TextStyle(
                color: context.darkTextPrimary,
                fontSize: DimensionConstants.font14Px.f,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: DimensionConstants.gap10Px.w,
                vertical: DimensionConstants.gap8Px.h,
              ),
              backgroundColor: context.filledBgDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  DimensionConstants.radius20Px.r,
                ),
              ),
            ),
          ),
        ),
        if (hasCoupon) ...[
          SizedBox(height: DimensionConstants.gap8Px.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: DimensionConstants.gap12Px.w,
              vertical: DimensionConstants.gap8Px.h,
            ),
            decoration: BoxDecoration(
              color: context.filledBgDark,
              borderRadius: BorderRadius.circular(
                DimensionConstants.radius12Px.r,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.couponAppliedCode.tr(
                      namedArgs: {'code': _appliedCouponCode!},
                    ),
                    style: TextStyle(
                      color: context.darkTextSecondary,
                      fontSize: DimensionConstants.font12Px.f,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _removeCoupon,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(
                      horizontal: DimensionConstants.gap8Px.w,
                      vertical: DimensionConstants.gap2Px.h,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: TranslatedText(
                    AppStrings.removeCoupon,
                    style: TextStyle(
                      color: context.red,
                      fontSize: DimensionConstants.font12Px.f,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showCouponBottomSheet() async {
    final couponCodeNotifier = ValueNotifier<String>('');
    final isApplyingNotifier = ValueNotifier<bool>(false);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (bottomSheetContext) {
        return ValueListenableBuilder<bool>(
          valueListenable: isApplyingNotifier,
          builder: (context, isApplying, _) {
            return ValueListenableBuilder<String>(
              valueListenable: couponCodeNotifier,
              builder: (context, couponCode, __) {
                final normalizedCouponCode = couponCode.trim().toUpperCase();
                final hasCouponValue = normalizedCouponCode.isNotEmpty;
                final hasValidFormat = _isCouponFormatValid(
                  normalizedCouponCode,
                );

                return CustomBottomSheet(
                  customIcon: Icon(
                    Icons.local_offer_outlined,
                    color: context.darkTextPrimary,
                    size: DimensionConstants.gap48Px.w,
                  ),
                  title: AppStrings.addCoupon,
                  primaryButtonText: AppStrings.applyCoupon,
                  secondaryButtonText: AppStrings.cancel,
                  isPrimaryLoading: isApplying,
                  isPrimaryEnabled: hasCouponValue && hasValidFormat,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: AppStrings.couponCode,
                        placeholder: AppStrings.enterCouponCode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                          LengthLimitingTextInputFormatter(20),
                          _UpperCaseTextFormatter(),
                        ],
                        onChanged: (value) {
                          couponCodeNotifier.value = value;
                        },
                      ),
                      if (hasCouponValue && !hasValidFormat) ...[
                        SizedBox(height: DimensionConstants.gap8Px.h),
                        TranslatedText(
                          AppStrings.invalidCouponCodeFormat,
                          style: TextStyle(
                            color: context.red,
                            fontSize: DimensionConstants.font12Px.f,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onSecondaryPressed: () {
                    Navigator.of(bottomSheetContext).pop();
                  },
                  onPrimaryPressed: () async {
                    if (normalizedCouponCode.isEmpty) {
                      SnackBarUtils.showError(
                        context,
                        AppStrings.enterCouponCode.tr(),
                      );
                      return;
                    }

                    if (!hasValidFormat) {
                      SnackBarUtils.showError(
                        context,
                        AppStrings.invalidCouponCodeFormat.tr(),
                      );
                      return;
                    }

                    if (_appliedCouponCode == normalizedCouponCode) {
                      SnackBarUtils.showError(
                        context,
                        AppStrings.couponAlreadyApplied.tr(),
                      );
                      return;
                    }

                    isApplyingNotifier.value = true;
                    final isValid = await _validateAndApplyCoupon(
                      normalizedCouponCode,
                    );
                    if (!mounted) return;
                    isApplyingNotifier.value = false;
                    if (isValid && bottomSheetContext.mounted) {
                      Navigator.of(bottomSheetContext).pop();
                    }
                  },
                );
              },
            );
          },
        );
      },
    );

    couponCodeNotifier.dispose();
    isApplyingNotifier.dispose();
  }

  Future<bool> _validateAndApplyCoupon(String couponCode) async {
    try {
      final response = await sl<ApiService>().postData<Map<String, dynamic>>(
        endpoint: '/coupons/validate',
        data: {'code': couponCode},
        converter: (result) => result.data,
      );

      if (response['valid'] != true ||
          response['fees'] is! Map<String, dynamic>) {
        final responseMessage = response['message']?.toString();
        logAnalytics(
          AnalyticsEvents.couponFailed,
          parameters: {
            'coupon_code': couponCode,
            if (responseMessage != null) 'reason': responseMessage,
          },
        );
        SnackBarUtils.showError(
          context,
          responseMessage ?? AppStrings.invalidCouponCode.tr(),
        );
        return false;
      }

      final updatedFee = _parseCouponFee(
        response['fees'] as Map<String, dynamic>,
      );

      setState(() {
        _sessionFee = updatedFee;
        _appliedCouponCode = couponCode;
      });

      logAnalytics(
        AnalyticsEvents.couponApplied,
        parameters: {
          'coupon_code': couponCode,
          'currency': updatedFee.currency,
          'value': updatedFee.totalFee.toDouble(),
        },
      );
      SnackBarUtils.showSuccess(
        context,
        AppStrings.couponAppliedSuccessfully.tr(),
      );
      return true;
    } on CustomException catch (e) {
      logAnalytics(
        AnalyticsEvents.couponFailed,
        parameters: {
          'coupon_code': couponCode,
          'reason': e.message,
        },
      );
      SnackBarUtils.showError(context, e.message);
      return false;
    } catch (e) {
      logAnalytics(
        AnalyticsEvents.couponFailed,
        parameters: {
          'coupon_code': couponCode,
          'reason': e.toString(),
        },
      );
      SnackBarUtils.showError(context, AppStrings.invalidCouponCode.tr());
      return false;
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _sessionFee = _baseSessionFee;
    });
    SnackBarUtils.showSuccess(
      context,
      AppStrings.couponRemovedSuccessfully.tr(),
    );
  }

  bool _isCouponFormatValid(String couponCode) {
    return RegExp(r'^[A-Z0-9]{6,20}$').hasMatch(couponCode);
  }

  SessionFeeEntity _parseCouponFee(Map<String, dynamic> fees) {
    return SessionFeeEntity(
      sessionFee: _toNum(fees['sessionFee']),
      processingFee: _toNum(fees['processingFee']),
      totalFee: _toNum(fees['totalAmount']),
      currency: fees['currency']?.toString() ?? _sessionFee.currency,
    );
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
