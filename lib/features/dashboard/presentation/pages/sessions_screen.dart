import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../sessions/presentation/bloc/sessions_bloc.dart';
import '../../../sessions/presentation/bloc/sessions_event.dart';
import '../../../sessions/presentation/bloc/sessions_state.dart';
import '../../../sessions/presentation/widgets/sessions_tab_selector.dart';
import '../../../sessions/presentation/widgets/session_card.dart';
import '../../../sessions/presentation/widgets/cancel_session_bottom_sheet.dart';
import '../../../sessions/domain/entities/session_entity.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late SessionsBloc _sessionsBloc;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    _sessionsBloc.add(const LoadUserSessions());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleText: AppStrings.mySessions.tr(),
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
      body: BlocConsumer<SessionsBloc, SessionsState>(
        listener: (context, state) {
          if (state.hasError) {
            SnackBarUtils.showError(context, state.errorMessage!);
          } else if (state.hasSuccess && state.lastOperation == SessionsOperation.cancelSession) {
            SnackBarUtils.showSuccess(context, state.successMessage!);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap12Px.h),
            child: Column(
              children: [
                if (state.hasUpcomingData) ...[
                  SessionsTabSelector(
                    isUpcomingSelected: state.currentTab == SessionsTab.upcoming,
                    onUpcomingTap: () {
                      _sessionsBloc.add(const SwitchToUpcoming());
                    },
                    onCompletedTap: () {
                      _sessionsBloc.add(const SwitchToCompleted());
                    },
                  ),
                ],
                SizedBox(height: DimensionConstants.gap4Px.h),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SessionsState state) {
    final isUpcomingTab = state.currentTab == SessionsTab.upcoming;
    final hasData = isUpcomingTab ? state.hasUpcomingData : state.hasCompletedData;

    return RefreshIndicator(
      onRefresh: () async {
        _sessionsBloc.add(const RefreshSessions());
      },
      child: Builder(
        builder: (context) {
          if (state.isLoadingSessions && !hasData) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const Center(child: CircularProgressIndicator()))],
            );
          }

          if (state.hasError && !hasData) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildErrorState(context, state.errorMessage!))],
            );
          }

          if (hasData) {
            final sessions = state.currentSessions;

            if (sessions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildEmptyState(context, state.currentTab == SessionsTab.upcoming),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sessions.length,
              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap20Px.h),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionCard(
                  session: session,
                  onCancel: session.canCancel ? () => _showCancelDialog(context, session) : null,
                  onJoin: session.isUpcoming ? () => _joinSession(context, session.id) : null,
                );
              },
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(context, true))],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isUpcoming) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note_outlined, size: DimensionConstants.gap64Px.w, color: context.darkTextSecondary),
        SizedBox(height: DimensionConstants.gap24Px.h),
        TranslatedText(
          isUpcoming ? AppStrings.noUpcomingSessions : AppStrings.noCompletedSessions,
          style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
        ),
        SizedBox(height: DimensionConstants.gap8Px.h),
        TranslatedText(
          isUpcoming ? AppStrings.noSessionsYet : AppStrings.completedSessionsDescription,
          style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: DimensionConstants.gap64Px.w, color: context.red),
        SizedBox(height: DimensionConstants.gap24Px.h),
        TranslatedText(
          AppStrings.somethingWentWrong,
          style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
        ),
        SizedBox(height: DimensionConstants.gap8Px.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
          child: Text(
            message,
            style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: DimensionConstants.gap24Px.h),
        ElevatedButton(
          onPressed: () {
            _sessionsBloc.add(const LoadUserSessions());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.darkSecondary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w, vertical: DimensionConstants.gap12Px.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
          ),
          child: TranslatedText(AppStrings.retry, style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, SessionEntity session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: _sessionsBloc,
            child: CancelSessionBottomSheet(sessionId: session.id, reason: AppStrings.userRequestedCancellation.tr()),
          ),
    );
  }

  void _joinSession(BuildContext context, String sessionId) {
    context.pushNamed(AppRoutes.joinMeetingRouteName, extra: {'meetingId': sessionId});
  }
}
