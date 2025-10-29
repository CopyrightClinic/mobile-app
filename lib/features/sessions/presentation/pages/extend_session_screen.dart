import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../../payments/presentation/widgets/payment_method_card.dart';
import '../../../payments/presentation/widgets/payment_method_card_action.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import 'params/extend_session_screen_params.dart';

class ExtendSessionScreen extends StatelessWidget {
  final ExtendSessionScreenParams params;

  const ExtendSessionScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return ExtendSessionView(sessionId: params.sessionId, totalFee: params.totalFee);
  }
}

class ExtendSessionView extends StatefulWidget {
  final String sessionId;
  final double totalFee;

  const ExtendSessionView({super.key, required this.sessionId, required this.totalFee});

  @override
  State<ExtendSessionView> createState() => _ExtendSessionViewState();
}

class _ExtendSessionViewState extends State<ExtendSessionView> {
  String? _selectedPaymentMethodId;
  PaymentMethodEntity? _selectedPaymentMethod;
  late PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    Log.i(runtimeType, '🚀 ExtendSessionScreen: initState started');
    Log.i(runtimeType, '📋 ExtendSessionScreen: Session ID from params: ${widget.sessionId}');
    Log.i(runtimeType, '💰 ExtendSessionScreen: Total Fee from params: \$${widget.totalFee.toStringAsFixed(2)}');

    _paymentBloc = context.read<PaymentBloc>();
    Log.i(runtimeType, '📦 ExtendSessionScreen: PaymentBloc obtained');

    _paymentBloc.add(const LoadPaymentMethods());
    Log.i(runtimeType, '📋 ExtendSessionScreen: LoadPaymentMethods event dispatched');

    Log.i(runtimeType, '✅ ExtendSessionScreen: initState completed');
  }

  @override
  Widget build(BuildContext context) {
    Log.d(runtimeType, '🎨 ExtendSessionScreen: build() called, sessionId: ${widget.sessionId}');

    return BlocListener<SessionsBloc, SessionsState>(
      bloc: context.read<SessionsBloc>(),
      listener: (context, state) {
        Log.d(runtimeType, '👂 ExtendSessionScreen: BlocListener triggered');
        Log.d(runtimeType, '   - hasSuccess: ${state.hasSuccess}');
        Log.d(runtimeType, '   - hasError: ${state.hasError}');
        Log.d(runtimeType, '   - lastOperation: ${state.lastOperation}');
        Log.d(runtimeType, '   - isProcessingExtension: ${state.isProcessingExtension}');

        if (state.hasSuccess && state.lastOperation == SessionsOperation.extendSession) {
          Log.i(runtimeType, '✅ ExtendSessionScreen: Session extended successfully!');
          Log.i(runtimeType, '   - Success message: ${state.successMessage}');

          SnackBarUtils.showSuccess(context, state.successMessage ?? AppStrings.sessionExtendedSuccess);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Log.i(runtimeType, '🔙 ExtendSessionScreen: Navigating back after success');
              context.pop();
            }
          });
        } else if (state.hasError && state.lastOperation == SessionsOperation.extendSession) {
          Log.e(runtimeType, '❌ ExtendSessionScreen: Session extension failed!');
          Log.e(runtimeType, '   - Error message: ${state.errorMessage}');

          SnackBarUtils.showError(context, state.errorMessage ?? AppStrings.sessionExtendError);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          leading: const CustomBackButton(),
          centerTitle: true,
          title: TranslatedText(
            AppStrings.extendSession,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DimensionConstants.gap24Px.h),

                    _buildExtensionInfoSection(),

                    SizedBox(height: DimensionConstants.gap24Px.h),

                    TranslatedText(
                      AppStrings.selectPaymentMethod,
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: DimensionConstants.gap16Px.h),
                  ],
                ),
              ),
              Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w), child: _buildPaymentMethodsList())),
              _buildAddPaymentMethodButton(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionInfoSection() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
      child: Column(
        children: [
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionTime,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      AppStrings.extensionDuration,
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap2Px.h),
                    TranslatedText(
                      AppStrings.extensionDurationValue,
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionPrice,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    AppStrings.extensionFee,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  Text(
                    '\$${widget.totalFee.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: context.orange, size: DimensionConstants.gap20Px.w),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: TranslatedText(
                  AppStrings.extensionNote,
                  style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      bloc: _paymentBloc,
      builder: (context, state) {
        final isLoading = state is PaymentLoading;
        final paymentMethods = state is PaymentMethodsLoaded ? state.paymentMethods : <PaymentMethodEntity>[];

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlobalImage(assetPath: ImageConstants.noPaymentMethods, width: 80.w, height: 80.h, fit: BoxFit.contain),
                SizedBox(height: DimensionConstants.gap16Px.h),
                TranslatedText(
                  AppStrings.noPaymentMethodsAddOne,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                TranslatedText(
                  AppStrings.tapToAdd,
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final paymentMethod = paymentMethods[index];
            final isSelected = _selectedPaymentMethodId == paymentMethod.id;

            return GestureDetector(
              onTap: () => _onSelectPaymentMethod(paymentMethod),
              child: PaymentMethodCard(
                paymentMethod: paymentMethod,
                action: SelectPaymentMethodAction(onSelect: () => _onSelectPaymentMethod(paymentMethod)),
                isSelected: isSelected,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap16Px.h),
      child: GestureDetector(
        onTap: _onAddPaymentMethod,
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

  Widget _buildActionButtons() {
    return BlocBuilder<SessionsBloc, SessionsState>(
      builder: (context, state) {
        final isProcessing = state.isLoading && state.lastOperation == SessionsOperation.extendSession;
        final canPay = _selectedPaymentMethodId != null;

        return Container(
          padding: EdgeInsets.only(
            left: DimensionConstants.gap16Px.w,
            right: DimensionConstants.gap16Px.w,
            top: DimensionConstants.gap16Px.h,
            bottom: DimensionConstants.gap16Px.h + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(color: context.bottomNavBarBG),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: isProcessing ? null : () => context.pop(),
                  backgroundColor: context.buttonSecondary,
                  disabledBackgroundColor: context.buttonDisabled,
                  textColor: context.darkTextPrimary,
                  borderRadius: DimensionConstants.radius52Px.r,
                  padding: 12.0,
                  child: TranslatedText(
                    AppStrings.cancel,
                    style: TextStyle(
                      fontSize: DimensionConstants.font16Px.f,
                      fontWeight: FontWeight.w600,
                      color: isProcessing ? context.darkTextSecondary : context.darkTextPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: DimensionConstants.gap12Px.w),
              Expanded(
                child: CustomButton(
                  onPressed: (isProcessing || !canPay) ? null : _onPayNow,
                  backgroundColor: context.primary,
                  disabledBackgroundColor: context.buttonDisabled,
                  textColor: Colors.white,
                  borderRadius: DimensionConstants.radius52Px.r,
                  padding: 12.0,
                  child:
                      isProcessing
                          ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : TranslatedText(
                            AppStrings.payNow,
                            style: TextStyle(
                              fontSize: DimensionConstants.font16Px.f,
                              fontWeight: FontWeight.w600,
                              color: canPay ? Colors.white : context.darkTextSecondary,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSelectPaymentMethod(PaymentMethodEntity paymentMethod) {
    Log.i(runtimeType, '💳 ExtendSessionScreen: Payment method selected');
    Log.i(runtimeType, '   - Payment Method ID: ${paymentMethod.id}');
    Log.i(runtimeType, '   - Stripe Payment Method ID: ${paymentMethod.stripePaymentMethodId}');

    setState(() {
      _selectedPaymentMethodId = paymentMethod.id;
      _selectedPaymentMethod = paymentMethod;
    });

    Log.i(runtimeType, '✅ ExtendSessionScreen: Payment method state updated');
  }

  void _onAddPaymentMethod() {
    Log.i(runtimeType, '➕ ExtendSessionScreen: Add payment method button tapped');
    Log.i(runtimeType, '🧭 ExtendSessionScreen: Navigating to add payment method screen');

    context.push(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.home}).then((value) {
      if (value != null) {
        Log.i(runtimeType, '✅ ExtendSessionScreen: Returned from add payment method screen with result');
        Log.i(runtimeType, '📋 ExtendSessionScreen: Reloading payment methods');
        _paymentBloc.add(const LoadPaymentMethods());
      } else {
        Log.i(runtimeType, '↩️ ExtendSessionScreen: Returned from add payment method screen without result');
      }
    });
  }

  void _onPayNow() {
    Log.i(runtimeType, '💰 ExtendSessionScreen: Pay Now button tapped');
    Log.i(runtimeType, '📋 ExtendSessionScreen: Validating data...');
    Log.i(runtimeType, '   - Session ID: ${widget.sessionId}');
    Log.i(runtimeType, '   - Selected Payment Method ID: $_selectedPaymentMethodId');
    Log.i(runtimeType, '   - Selected Payment Method: ${_selectedPaymentMethod?.stripePaymentMethodId}');

    if (_selectedPaymentMethod != null) {
      Log.i(runtimeType, '✅ ExtendSessionScreen: Validation passed, dispatching ExtendSession event');
      Log.i(runtimeType, '📤 ExtendSessionScreen: Event details:');
      Log.i(runtimeType, '   - sessionId: ${widget.sessionId}');
      Log.i(runtimeType, '   - paymentMethodId: ${_selectedPaymentMethod!.stripePaymentMethodId}');

      context.read<SessionsBloc>().add(ExtendSession(sessionId: widget.sessionId, paymentMethodId: _selectedPaymentMethod!.stripePaymentMethodId));

      Log.i(runtimeType, '✅ ExtendSessionScreen: ExtendSession event dispatched to SessionsBloc');
    } else {
      Log.w(runtimeType, '⚠️ ExtendSessionScreen: Validation failed - No payment method selected');
    }
  }
}
