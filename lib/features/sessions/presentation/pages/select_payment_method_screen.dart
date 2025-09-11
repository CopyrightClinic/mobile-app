import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../../payments/presentation/widgets/payment_methods_list.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  State<SelectPaymentMethodScreen> createState() => _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  late PaymentBloc _paymentBloc;
  String? _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
    _paymentBloc.add(const LoadPaymentMethods());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentProcessed) {
          SnackBarUtils.showSuccess(context, 'Payment successful!');
          context.go(AppRoutes.homeRouteName);
        } else if (state is PaymentError) {
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
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      final isLoading = state is PaymentLoading;
                      final paymentMethods = state is PaymentMethodsLoaded ? state.paymentMethods : <PaymentMethodEntity>[];

                      return PaymentMethodsList(
                        paymentMethods: paymentMethods,
                        isLoading: isLoading,
                        selectedPaymentMethodId: _selectedPaymentMethodId,
                        config: PaymentMethodsListConfig.forCheckout(onSelect: _onSelectPaymentMethod, onAddPaymentMethod: _onAddPaymentMethod),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                child: BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    final isProcessing = state is PaymentProcessing;

                    return AuthButton(
                      text: AppStrings.continueText,
                      onPressed: _selectedPaymentMethodId != null ? _onContinue : null,
                      isLoading: isProcessing,
                      isEnabled: _selectedPaymentMethodId != null,
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
    });
  }

  void _onAddPaymentMethod() {
    context.push(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.home});
  }

  void _onContinue() {
    if (_selectedPaymentMethodId != null) {}
  }
}
