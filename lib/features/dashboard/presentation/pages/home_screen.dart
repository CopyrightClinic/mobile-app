import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/services/bottom_sheet_service.dart';
import '../../../../di.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/widgets/session_card.dart';
import '../../../sessions/presentation/widgets/cancel_session_bottom_sheet.dart';
import '../../../sessions/presentation/bloc/sessions_bloc.dart';
import '../../../sessions/presentation/bloc/sessions_event.dart';
import '../../../sessions/presentation/bloc/sessions_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../zoom/presentation/bloc/zoom_bloc.dart';
import '../../../zoom/presentation/widgets/zoom_connection_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SessionsBloc _sessionsBloc;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    _profileBloc = context.read<ProfileBloc>();
    _sessionsBloc.add(const LoadUserSessions());
    _profileBloc.add(const GetProfileRequested());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: context.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _sessionsBloc.add(const RefreshSessions());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatedText(
                              AppStrings.welcome,
                              style: TextStyle(
                                fontSize: DimensionConstants.font16Px.f,
                                color: context.darkTextSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: DimensionConstants.gap2Px.h),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              bloc: _profileBloc,
                              builder: (context, state) {
                                String userName = '-';
                                if (state is ProfileLoaded) {
                                  userName = state.profile.name != null ? '${state.profile.name}!' : '-';
                                }
                                return Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: DimensionConstants.font20Px.f,
                                    fontWeight: FontWeight.w700,
                                    color: context.darkTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: DimensionConstants.gap8Px.w),
                      Container(
                        width: DimensionConstants.gap40Px.w,
                        height: DimensionConstants.gap40Px.w,
                        decoration: BoxDecoration(color: context.bgDark.withValues(alpha: 0.7), shape: BoxShape.circle),
                        child: InkWell(
                          onTap: () {
                            context.push(AppRoutes.notificationsRouteName);
                          },
                          borderRadius: BorderRadius.circular((DimensionConstants.gap40Px.w / 2).w),
                          child: Center(
                            child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: (DimensionConstants.gap40Px * 0.5).w),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DimensionConstants.gap32Px.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBlock(
                          context,
                          icon: ImageConstants.aboutUs,
                          title: AppStrings.aboutUs,
                          onTap: () {
                            context.push(AppRoutes.aboutUsRouteName);
                          },
                        ),
                      ),
                      SizedBox(width: DimensionConstants.gap16Px.w),
                      Expanded(
                        child: _buildActionBlock(
                          context,
                          icon: ImageConstants.whatWeDo,
                          title: AppStrings.whatWeDo,
                          onTap: () {
                            context.push(AppRoutes.whatWeDoRouteName);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DimensionConstants.gap24Px.h),

                  _buildHaroldAIBlock(context),

                  SizedBox(height: DimensionConstants.gap32Px.h),

                  TranslatedText(
                    AppStrings.upcomingSessions,
                    style: TextStyle(fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                  ),

                  SizedBox(height: DimensionConstants.gap16Px.h),

                  BlocBuilder<SessionsBloc, SessionsState>(
                    builder: (context, state) {
                      if (state.isLoadingSessions) {
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: context.filledBgDark,
                            borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state.hasUpcomingData) {
                        final upcomingSessions = state.upcomingSessions!;
                        if (upcomingSessions.isEmpty) {
                          return _buildNoUpcomingSessionsCard(context);
                        }

                        final sessionsToShow = upcomingSessions.take(5).toList();
                        return Column(
                          children: List.generate(sessionsToShow.length, (index) {
                            final session = sessionsToShow[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < sessionsToShow.length - 1 ? DimensionConstants.gap16Px.h : 0),
                              child: SessionCard(
                                session: session,
                                onCancel: session.canCancel ? () => _showCancelDialog(context, session) : null,
                                onJoin: session.canJoin ? () => _joinSessionDirectly(context, session.id) : null,
                              ),
                            );
                          }),
                        );
                      }

                      if (state.hasError) {
                        return _buildErrorSessionCard(context, state.errorMessage!);
                      }

                      return _buildNoUpcomingSessionsCard(context);
                    },
                  ),

                  SizedBox(height: DimensionConstants.gap24Px.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBlock(BuildContext context, {required String icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DimensionConstants.gap20Px.w),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
        child: Column(
          children: [
            Container(
              width: DimensionConstants.gap48Px.w,
              height: DimensionConstants.gap48Px.h,
              decoration: BoxDecoration(color: context.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: GlobalImage(
                  assetPath: icon,
                  width: DimensionConstants.icon24Px.w,
                  height: DimensionConstants.icon24Px.h,
                  fit: BoxFit.contain,
                  showLoading: false,
                  showError: false,
                  fadeIn: false,
                ),
              ),
            ),
            SizedBox(height: DimensionConstants.gap12Px.h),
            TranslatedText(
              title,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHaroldAIBlock(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.askHaroldAiRouteName),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap20Px.h),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
        child: Row(
          children: [
            Container(
              width: DimensionConstants.gap48Px.w,
              height: DimensionConstants.gap48Px.h,
              decoration: BoxDecoration(color: context.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: GlobalImage(
                  assetPath: ImageConstants.askHaroldAi,
                  width: DimensionConstants.icon24Px.w,
                  height: DimensionConstants.icon24Px.h,
                  fit: BoxFit.contain,
                  showLoading: false,
                  showError: false,
                  fadeIn: false,
                ),
              ),
            ),
            SizedBox(width: DimensionConstants.gap12Px.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    AppStrings.askHaroldAI,
                    style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  TranslatedText(
                    AppStrings.haroldWillHelpYou,
                    style: TextStyle(fontSize: DimensionConstants.font12Px.f, color: context.darkTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUpcomingSessionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
      child: Column(
        children: [
          Icon(Icons.event_note_outlined, size: DimensionConstants.gap48Px.w, color: context.darkTextSecondary),
          SizedBox(height: DimensionConstants.gap12Px.h),
          TranslatedText(
            AppStrings.noUpcomingSessions,
            style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap4Px.h),
          TranslatedText(
            AppStrings.noSessionsYet,
            style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSessionCard(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: DimensionConstants.gap48Px.w, color: context.red),
          SizedBox(height: DimensionConstants.gap12Px.h),
          TranslatedText(
            AppStrings.somethingWentWrong,
            style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap4Px.h),
          Text(message, style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, SessionEntity session) {
    BottomSheetService.show(
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: _sessionsBloc,
            child: CancelSessionBottomSheet(sessionId: session.id, reason: AppStrings.userRequestedCancellation),
          ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  void _joinSessionDirectly(BuildContext context, String sessionId) {
    final zoomBloc = sl<ZoomBloc>();
    ZoomConnectionDialog.show(context, sessionId, zoomBloc);
  }
}
