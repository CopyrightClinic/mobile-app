import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_bottomsheet.dart';
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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthBloc _authBloc;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
    _profileBloc = context.read<ProfileBloc>();
    _profileBloc.add(const GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go(AppRoutes.welcomeRouteName);
            } else if (state is AuthError) {
              SnackBarUtils.showError(context, state.message);
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          listener: (context, state) {
            if (state is DeleteAccountSuccess) {
              SnackBarUtils.showSuccess(context, state.message);
              context.go(AppRoutes.welcomeRouteName);
            } else if (state is DeleteAccountError) {
              SnackBarUtils.showError(context, state.message);
            } else if (state is UpdateProfileSuccess) {
              _profileBloc.add(const GetProfileRequested());
              _authBloc.add(CheckAuthStatus());
            }
          },
        ),
      ],
      child: CustomScaffold(
        appBar: CustomAppBar(
          titleText: AppStrings.profile.tr(),
          automaticallyImplyLeading: false,
          actions: [
            Container(
              width: DimensionConstants.gap40Px.w,
              height: DimensionConstants.gap40Px.w,
              decoration: BoxDecoration(color: context.bgDark.withValues(alpha: 0.7), shape: BoxShape.circle),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular((DimensionConstants.gap40Px.w / 2).w),
                child: Center(child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: (DimensionConstants.gap40Px * 0.5).w)),
              ),
            ),
            SizedBox(width: DimensionConstants.gap16Px.w),
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
                      AppStrings.personalInformation,
                      style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    Spacer(),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return InkWell(
                          onTap: () async {
                            if (state is AuthAuthenticated) {
                              await context.push(AppRoutes.editProfileRouteName, extra: state.user);
                            }
                          },
                          child: GlobalImage(
                            assetPath: ImageConstants.edit,
                            width: DimensionConstants.gap20Px.w,
                            height: DimensionConstants.gap20Px.w,
                            loadingSize: DimensionConstants.gap20Px.w,
                          ),
                        );
                      },
                    ),
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

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.filledBgDark,
        borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
        border: Border.all(color: context.border.withAlpha(10)),
      ),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        builder: (context, state) {
          String userName = '-';
          String userEmail = '-';
          String userPhone = '-';
          String userAddress = '-';

          if (state is ProfileLoaded) {
            userName = state.profile.name ?? '-';
            userEmail = state.profile.email;
            userPhone = state.profile.phoneNumber ?? '-';
            userAddress = state.profile.address ?? '-';
          }

          return Column(
            children: [
              _buildInfoRow(context, iconPath: ImageConstants.name, label: AppStrings.fullName, value: userName),
              _buildInfoRow(context, iconPath: ImageConstants.email, label: AppStrings.email, value: userEmail),
              _buildInfoRow(context, iconPath: ImageConstants.phone, label: AppStrings.phoneNumber, value: userPhone),
              _buildInfoRow(context, iconPath: ImageConstants.address, label: AppStrings.address, value: userAddress, isLast: true),
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
          _buildOptionRow(
            context,
            iconPath: ImageConstants.changePassword,
            title: AppStrings.changePassword,
            onTap: () {
              context.push(AppRoutes.changePasswordRouteName);
            },
          ),
          _buildOptionRow(
            context,
            iconPath: ImageConstants.paymentMethods,
            title: AppStrings.paymentMethods,
            onTap: () {
              context.push(AppRoutes.paymentMethodsRouteName);
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
          GlobalImage(
            assetPath: iconPath,
            width: DimensionConstants.gap20Px.w,
            height: DimensionConstants.gap20Px.w,
            loadingSize: DimensionConstants.gap20Px.w,
          ),
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
            GlobalImage(
              assetPath: iconPath,
              width: DimensionConstants.gap20Px.w,
              height: DimensionConstants.gap20Px.w,
              loadingSize: DimensionConstants.gap20Px.w,
            ),
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
        onPressed: () {
          CustomBottomSheet.show(
            context: context,
            iconPath: ImageConstants.warning,
            title: AppStrings.deleteAccountTitle,
            subtitle: AppStrings.deleteAccountSubtitle,
            primaryButtonText: AppStrings.deleteAccountConfirm,
            secondaryButtonText: AppStrings.cancel,
            onPrimaryPressed: () {
              context.pop();
              _profileBloc.add(const DeleteAccountRequested());
            },
            onSecondaryPressed: () {
              context.pop();
            },
          );
        },
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

  void _handleLogout() {
    CustomBottomSheet.show(
      context: context,
      iconPath: ImageConstants.logout,
      title: AppStrings.confirmLogout,
      subtitle: AppStrings.areYouSureLogout,
      primaryButtonText: AppStrings.logout,
      secondaryButtonText: AppStrings.cancel,
      onPrimaryPressed: () {
        context.pop();
        _authBloc.add(LogoutRequested());
      },
      onSecondaryPressed: () {
        context.pop();
      },
    );
  }
}
