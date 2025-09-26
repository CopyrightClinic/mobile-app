import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/enumns/ui/payment_method.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_bottomsheet.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/payment_methods_list.dart';
import '../widgets/payment_methods_list_config.dart';

/// Payment Methods Screen for Profile Section
/// Allows users to view, add, and delete their saved payment methods
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late PaymentBloc _paymentBloc;

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
        if (state is PaymentMethodDeleted) {
          SnackBarUtils.showSuccess(context, state.message);
          _paymentBloc.add(const LoadPaymentMethods());
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
            AppStrings.paymentMethods,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                final isLoading = state is PaymentLoading;
                final paymentMethods = state is PaymentMethodsLoaded ? state.paymentMethods : <PaymentMethodEntity>[];

                return PaymentMethodsList(
                  paymentMethods: paymentMethods,
                  isLoading: isLoading,
                  config: PaymentMethodsListConfig.forProfile(onDelete: _onDeletePaymentMethod, onAddPaymentMethod: _onAddPaymentMethod),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onDeletePaymentMethod(PaymentMethodEntity paymentMethod) {
    CustomBottomSheet.show(
      context: context,
      iconPath: ImageConstants.delete,
      title: AppStrings.deletePaymentMethod,
      subtitle: AppStrings.confirmDelete,
      primaryButtonText: AppStrings.delete,
      secondaryButtonText: AppStrings.cancel,
      onPrimaryPressed: () {
        context.pop();
        _paymentBloc.add(DeletePaymentMethodRequested(paymentMethodId: paymentMethod.stripePaymentMethodId));
      },
      onSecondaryPressed: () {
        context.pop();
      },
    );
  }

  void _onAddPaymentMethod() {
    context.push(AppRoutes.addPaymentMethodRouteName, extra: {'from': PaymentMethodFrom.home}).then((value) {
      if (value != null) {
        _paymentBloc.add(const LoadPaymentMethods());
      }
    });
  }
}
