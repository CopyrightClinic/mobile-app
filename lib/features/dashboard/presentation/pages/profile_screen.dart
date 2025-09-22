import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.welcomeRouteName);
        } else if (state is AuthError) {
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        appBar: CustomAppBar(
          titleText: AppStrings.profile.tr(),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: DimensionConstants.gap16Px.w),
              child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: DimensionConstants.gap24Px.w),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap8Px.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TranslatedText(
                      'Personal Information',
                      style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    Spacer(),
                    GlobalImage(assetPath: ImageConstants.edit, width: DimensionConstants.gap20Px.w, height: DimensionConstants.gap20Px.w),
                  ],
                ),
                SizedBox(height: DimensionConstants.gap16Px.h),
                _buildPersonalInfoCard(context),
                SizedBox(height: DimensionConstants.gap32Px.h),

                TranslatedText(
                  AppStrings.other,
                  style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                ),
                SizedBox(height: DimensionConstants.gap16Px.h),
                _buildOtherOptionsCard(context),
                SizedBox(height: DimensionConstants.gap40Px.h),

                _buildLogoutButton(context),

                _buildDeleteAccountButton(context),
                SizedBox(height: DimensionConstants.gap40Px.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.filledBgDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
          title: TranslatedText(
            AppStrings.confirmLogout,
            style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
          ),
          content: TranslatedText(
            AppStrings.areYouSureLogout,
            style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap8Px.h),
              ),
              child: TranslatedText(
                AppStrings.cancel,
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _authBloc.add(LogoutRequested());
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap8Px.h),
              ),
              child: TranslatedText(
                AppStrings.logout,
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.filledBgDark,
        borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
        border: Border.all(color: context.border.withAlpha(10)),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = '-';
          String userEmail = '-';
          String userPhone = '-';
          String userAddress = '-';

          if (state is AuthAuthenticated) {
            userName = state.user.name ?? state.user.email.split('@').first;
            userEmail = state.user.email;
          }

          return Column(
            children: [
              _buildInfoRow(context, iconPath: ImageConstants.name, label: 'Full Name', value: userName),
              _buildInfoRow(context, iconPath: ImageConstants.email, label: 'Email', value: userEmail),
              _buildInfoRow(context, iconPath: ImageConstants.phone, label: 'Phone Number', value: userPhone),
              _buildInfoRow(context, iconPath: ImageConstants.address, label: 'Address', value: userAddress, isLast: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOtherOptionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
      child: Column(
        children: [
          SizedBox(height: DimensionConstants.gap8Px.h),
          _buildOptionRow(context, iconPath: ImageConstants.changePassword, title: AppStrings.changePassword, onTap: () {}),
          _buildOptionRow(
            context,
            iconPath: ImageConstants.paymentMethods,
            title: AppStrings.paymentMethods,
            onTap: () {
              context.push(AppRoutes.addPaymentMethodRouteName);
            },
          ),
          _buildOptionRow(context, iconPath: ImageConstants.privacyPolicy, title: AppStrings.privacyPolicy, onTap: () {}),
          _buildOptionRow(context, iconPath: ImageConstants.termsAndConditions, title: AppStrings.termsAndConditions, onTap: () {}, isLast: true),
          SizedBox(height: DimensionConstants.gap8Px.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String iconPath, required String label, required String value, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap20Px.w, vertical: DimensionConstants.gap16Px.h),
      child: Row(
        children: [
          GlobalImage(assetPath: iconPath, width: DimensionConstants.gap20Px.w, height: DimensionConstants.gap20Px.w),
          SizedBox(width: DimensionConstants.gap8Px.w),
          Expanded(
            flex: 1,
            child: TranslatedText(
              label,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, color: context.darkTextSecondary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: DimensionConstants.gap8Px.w),
          Expanded(
            flex: 2,
            child: TranslatedText(
              value,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, color: context.darkTextPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, {required String iconPath, required String title, required VoidCallback onTap, bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap20Px.w, vertical: DimensionConstants.gap16Px.h),
        child: Row(
          children: [
            GlobalImage(assetPath: iconPath, width: DimensionConstants.gap20Px.w, height: DimensionConstants.gap20Px.w),
            SizedBox(width: DimensionConstants.gap10Px.w),
            Expanded(
              child: TranslatedText(
                title,
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, color: context.darkTextPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: DimensionConstants.gap16Px.w, color: context.darkTextPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
          elevation: 0,
        ),
        child: TranslatedText(
          AppStrings.logout,
          style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: context.red,
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap8Px.h),
        ),
        child: TranslatedText(
          AppStrings.deleteAccount,
          style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500, color: context.red),
        ),
      ),
    );
  }
}
