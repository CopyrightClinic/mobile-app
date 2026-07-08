import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/analytics/analytics.dart';
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
import '../../../../core/services/bottom_sheet_service.dart';
import '../../../../di.dart';
import '../../../sessions/presentation/bloc/sessions_bloc.dart';
import '../../../sessions/presentation/bloc/sessions_event.dart';
import '../../../sessions/presentation/bloc/sessions_state.dart';
import '../../../sessions/presentation/widgets/sessions_tab_selector.dart';
import '../../../sessions/presentation/widgets/session_card.dart';
import '../../../sessions/presentation/widgets/session_request_card.dart';
import '../../../sessions/presentation/widgets/cancel_session_bottom_sheet.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../zoom/presentation/bloc/zoom_bloc.dart';
import '../../../zoom/presentation/widgets/zoom_connection_dialog.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late SessionsBloc _sessionsBloc;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _sessionsBloc.add(const LoadUserSessions());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = _sessionsBloc.state;
      if (state.currentTab != SessionsTab.upcoming && state.currentTab != SessionsTab.completed) {
        return;
      }

      final isUpcomingTab = state.currentTab == SessionsTab.upcoming;
      final isLoadingMore = isUpcomingTab ? state.isLoadingMoreUpcoming : state.isLoadingMoreCompleted;
      final hasMore = isUpcomingTab ? state.hasMoreUpcoming : state.hasMoreCompleted;

      if (!isLoadingMore && hasMore) {
        _sessionsBloc.add(const LoadMoreSessions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleText: AppStrings.mySessions.tr(),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            width: DimensionConstants.gap40Px.d,
            height: DimensionConstants.gap40Px.d,
            decoration: BoxDecoration(color: context.bgDark.withValues(alpha: 0.7), shape: BoxShape.circle),
            child: InkWell(
              onTap: () {
                context.pushNamed(AppRoutes.notificationsRouteName);
              },
              borderRadius: BorderRadius.circular((DimensionConstants.gap40Px.d / 2).d),
              child: Center(child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: (DimensionConstants.gap40Px * 0.5).d)),
            ),
          ),
          SizedBox(width: DimensionConstants.gap16Px),
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
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px, vertical: DimensionConstants.gap12Px.h),
            child: Column(
              children: [
                if (state.hasUpcomingData) ...[
                  SessionsTabSelector(
                    currentTab: state.currentTab,
                    onTabSelected: (tab) {
                      switch (tab) {
                        case SessionsTab.upcoming:
                          _sessionsBloc.add(const SwitchToUpcoming());
                        case SessionsTab.completed:
                          _sessionsBloc.add(const SwitchToCompleted());
                        case SessionsTab.pending:
                          _sessionsBloc.add(const SwitchToPending());
                        case SessionsTab.cancelled:
                          _sessionsBloc.add(const SwitchToCancelled());
                      }
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
    final isRequestsTab = state.currentTab == SessionsTab.pending || state.currentTab == SessionsTab.cancelled;
    final hasData = switch (state.currentTab) {
      SessionsTab.upcoming => state.hasUpcomingData,
      SessionsTab.completed => state.hasCompletedData,
      SessionsTab.pending => state.hasPendingData,
      SessionsTab.cancelled => state.hasCancelledData,
    };

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
            return isRequestsTab ? _buildRequestsList(context, state) : _buildSessionsList(context, state);
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(context, SessionsTab.upcoming))],
          );
        },
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, SessionsState state) {
    final sessions = state.currentSessions;

    if (sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(context, state.currentTab))],
      );
    }

    final isUpcomingTab = state.currentTab == SessionsTab.upcoming;
    final isLoadingMore = isUpcomingTab ? state.isLoadingMoreUpcoming : state.isLoadingMoreCompleted;
    final hasMore = isUpcomingTab ? state.hasMoreUpcoming : state.hasMoreCompleted;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sessions.length + (hasMore ? 1 : 0),
      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap20Px.h),
      itemBuilder: (context, index) {
        if (index == sessions.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
              child: isLoadingMore ? CircularProgressIndicator(color: context.primary) : const SizedBox.shrink(),
            ),
          );
        }

        final session = sessions[index];
        return SessionCard(
          session: session,
          onCancel: session.canCancel ? () => _showCancelDialog(context, session) : null,
          onJoin: session.isUpcoming ? () => _joinSessionDirectly(context, session.id) : null,
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, SessionsState state) {
    final requests = state.currentRequests;

    if (requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(context, state.currentTab))],
      );
    }

    final isPendingTab = state.currentTab == SessionsTab.pending;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: requests.length,
      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap20Px.h),
      itemBuilder: (context, index) {
        final request = requests[index];
        return SessionRequestCard(request: request, onCancel: isPendingTab ? () {} : null);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, SessionsTab tab) {
    final title = switch (tab) {
      SessionsTab.upcoming => AppStrings.noUpcomingSessions,
      SessionsTab.completed => AppStrings.noCompletedSessions,
      SessionsTab.pending => AppStrings.noPendingSessions,
      SessionsTab.cancelled => AppStrings.noCancelledSessions,
    };
    final description = switch (tab) {
      SessionsTab.upcoming => AppStrings.noSessionsYet,
      SessionsTab.completed => AppStrings.completedSessionsDescription,
      SessionsTab.pending => AppStrings.pendingSessionsDescription,
      SessionsTab.cancelled => AppStrings.cancelledSessionsDescription,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note_outlined, size: DimensionConstants.gap64Px.w, color: context.darkTextSecondary),
        SizedBox(height: DimensionConstants.gap24Px.h),
        TranslatedText(
          title,
          style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
        ),
        SizedBox(height: DimensionConstants.gap8Px.h),
        TranslatedText(
          description,
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
    BottomSheetService.show(
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: _sessionsBloc,
            child: CancelSessionBottomSheet(sessionId: session.id, reason: AppStrings.userRequestedCancellation.tr()),
          ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  void _joinSessionDirectly(BuildContext context, String sessionId) {
    logAnalytics(
      AnalyticsEvents.sessionJoinClick,
      parameters: {'session_id': sessionId, 'source': 'sessions_tab'},
    );
    final zoomBloc = sl<ZoomBloc>();
    ZoomConnectionDialog.show(context, sessionId, zoomBloc);
  }
}
