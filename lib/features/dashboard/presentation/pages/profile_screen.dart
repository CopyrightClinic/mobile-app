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
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: TranslatedText(AppStrings.cancel, style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
              },
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // User has been logged out, navigate to welcome screen
          context.go(AppRoutes.welcomeRouteName);
        } else if (state is AuthError) {
          // Show error message
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        appBar: CustomAppBar(titleText: AppStrings.profile.tr(), automaticallyImplyLeading: false),
        body: Padding(
          padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
                decoration: BoxDecoration(
                  color: context.filledBgDark,
                  borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: DimensionConstants.gap40Px.w,
                      backgroundColor: context.primary,
                      child: Icon(Icons.person, size: DimensionConstants.gap40Px.w, color: Colors.white),
                    ),
                    SizedBox(height: DimensionConstants.gap16Px.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String userName = 'User';
                        String userEmail = 'user@example.com';
                        if (state is AuthAuthenticated) {
                          userName = state.user.name ?? state.user.email.split('@').first;
                          userEmail = state.user.email;
                        }
                        return Column(
                          children: [
                            TranslatedText(
                              userName,
                              style: TextStyle(fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                            ),
                            SizedBox(height: DimensionConstants.gap4Px.h),
                            TranslatedText(userEmail, style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: DimensionConstants.gap32Px.h),

              _buildProfileOption(context, icon: Icons.person_outline, title: AppStrings.editProfile, onTap: () {}),
              SizedBox(height: DimensionConstants.gap16Px.h),
              _buildProfileOption(context, icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () {}),
              SizedBox(height: DimensionConstants.gap16Px.h),
              _buildProfileOption(context, icon: Icons.settings_outlined, title: AppStrings.settings, onTap: () {}),
              SizedBox(height: DimensionConstants.gap32Px.h),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.red,
                    side: BorderSide(color: context.red),
                    padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                  ),
                  child: TranslatedText(
                    AppStrings.logout,
                    style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
        decoration: BoxDecoration(
          color: context.filledBgDark,
          borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: DimensionConstants.gap24Px.w, color: context.darkTextPrimary),
            SizedBox(width: DimensionConstants.gap16Px.w),
            Expanded(
              child: TranslatedText(
                title,
                style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: DimensionConstants.gap16Px.w, color: context.darkTextSecondary),
          ],
        ),
      ),
    );
  }
}
