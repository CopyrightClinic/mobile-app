import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/user_session_request_entity.dart';
import '../../domain/entities/session_availability_entity.dart';
import '../../domain/entities/book_session_response_entity.dart';

enum SessionsOperation { loadSessions, cancelSession, joinSession, scheduleSession, bookSession, loadAvailability, extendSession }

class SessionsState extends Equatable {
  final List<SessionEntity>? upcomingSessions;
  final List<SessionEntity>? completedSessions;
  final List<UserSessionRequestEntity>? pendingRequests;
  final List<UserSessionRequestEntity>? cancelledRequests;
  final SessionsTab currentTab;
  final bool isLoadingSessions;
  final bool isLoadingMoreUpcoming;
  final bool isLoadingMoreCompleted;
  final int currentUpcomingPage;
  final int currentCompletedPage;
  final bool hasMoreUpcoming;
  final bool hasMoreCompleted;
  final bool isProcessingCancel;
  final String? cancellingSessionId;
  final bool isProcessingJoin;
  final String? joiningSessionId;
  final bool isProcessingSchedule;
  final bool isProcessingBook;
  final bool isProcessingExtension;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final SessionAvailabilityEntity? availability;
  final bool isLoadingAvailability;
  final String? errorMessage;
  final String? successMessage;
  final SessionsOperation? lastOperation;
  final BookSessionResponseEntity? bookSessionResponse;

  const SessionsState({
    this.upcomingSessions,
    this.completedSessions,
    this.pendingRequests,
    this.cancelledRequests,
    this.currentTab = SessionsTab.upcoming,
    this.isLoadingSessions = false,
    this.isLoadingMoreUpcoming = false,
    this.isLoadingMoreCompleted = false,
    this.currentUpcomingPage = 1,
    this.currentCompletedPage = 1,
    this.hasMoreUpcoming = false,
    this.hasMoreCompleted = false,
    this.isProcessingCancel = false,
    this.cancellingSessionId,
    this.isProcessingJoin = false,
    this.joiningSessionId,
    this.isProcessingSchedule = false,
    this.isProcessingBook = false,
    this.isProcessingExtension = false,
    this.selectedDate,
    this.selectedTimeSlot,
    this.availability,
    this.isLoadingAvailability = false,
    this.errorMessage,
    this.successMessage,
    this.lastOperation,
    this.bookSessionResponse,
  });

  bool get hasUpcomingData => upcomingSessions != null;
  bool get hasCompletedData => completedSessions != null;
  bool get hasPendingData => pendingRequests != null;
  bool get hasCancelledData => cancelledRequests != null;
  bool get hasData => upcomingSessions != null && completedSessions != null;
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isScheduling => selectedDate != null;
  bool get canContinueToPayment => selectedTimeSlot != null;
  bool get isLoading =>
      isLoadingSessions ||
      isProcessingCancel ||
      isProcessingJoin ||
      isProcessingSchedule ||
      isProcessingBook ||
      isLoadingAvailability ||
      isProcessingExtension;

  List<SessionEntity> get currentSessions {
    switch (currentTab) {
      case SessionsTab.upcoming:
        return upcomingSessions ?? [];
      case SessionsTab.completed:
        return completedSessions ?? [];
      case SessionsTab.pending:
      case SessionsTab.cancelled:
        return [];
    }
  }

  List<UserSessionRequestEntity> get currentRequests {
    switch (currentTab) {
      case SessionsTab.pending:
        return pendingRequests ?? [];
      case SessionsTab.cancelled:
        return cancelledRequests ?? [];
      case SessionsTab.upcoming:
      case SessionsTab.completed:
        return [];
    }
  }

  List<AvailabilityDayEntity> get availableDays => availability?.days ?? [];

  List<TimeSlotEntity> get availableTimeSlotsForSelectedDate {
    if (availability == null || selectedDate == null) return [];

    final selectedDay =
        availability!.days
            .where((day) => day.date.year == selectedDate!.year && day.date.month == selectedDate!.month && day.date.day == selectedDate!.day)
            .firstOrNull;

    return selectedDay?.slots ?? [];
  }

  SessionsState copyWith({
    List<SessionEntity>? upcomingSessions,
    List<SessionEntity>? completedSessions,
    List<UserSessionRequestEntity>? pendingRequests,
    List<UserSessionRequestEntity>? cancelledRequests,
    SessionsTab? currentTab,
    bool? isLoadingSessions,
    bool? isLoadingMoreUpcoming,
    bool? isLoadingMoreCompleted,
    int? currentUpcomingPage,
    int? currentCompletedPage,
    bool? hasMoreUpcoming,
    bool? hasMoreCompleted,
    bool? isProcessingCancel,
    String? cancellingSessionId,
    bool? isProcessingJoin,
    String? joiningSessionId,
    bool? isProcessingSchedule,
    bool? isProcessingBook,
    bool? isProcessingExtension,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    SessionAvailabilityEntity? availability,
    bool? isLoadingAvailability,
    String? errorMessage,
    String? successMessage,
    SessionsOperation? lastOperation,
    BookSessionResponseEntity? bookSessionResponse,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearTimeSlot = false,
    bool clearCancellingSessionId = false,
    bool clearJoiningSessionId = false,
    bool clearBookSessionResponse = false,
  }) {
    return SessionsState(
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      cancelledRequests: cancelledRequests ?? this.cancelledRequests,
      currentTab: currentTab ?? this.currentTab,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      isLoadingMoreUpcoming: isLoadingMoreUpcoming ?? this.isLoadingMoreUpcoming,
      isLoadingMoreCompleted: isLoadingMoreCompleted ?? this.isLoadingMoreCompleted,
      currentUpcomingPage: currentUpcomingPage ?? this.currentUpcomingPage,
      currentCompletedPage: currentCompletedPage ?? this.currentCompletedPage,
      hasMoreUpcoming: hasMoreUpcoming ?? this.hasMoreUpcoming,
      hasMoreCompleted: hasMoreCompleted ?? this.hasMoreCompleted,
      isProcessingCancel: isProcessingCancel ?? this.isProcessingCancel,
      cancellingSessionId: clearCancellingSessionId ? null : (cancellingSessionId ?? this.cancellingSessionId),
      isProcessingJoin: isProcessingJoin ?? this.isProcessingJoin,
      joiningSessionId: clearJoiningSessionId ? null : (joiningSessionId ?? this.joiningSessionId),
      isProcessingSchedule: isProcessingSchedule ?? this.isProcessingSchedule,
      isProcessingBook: isProcessingBook ?? this.isProcessingBook,
      isProcessingExtension: isProcessingExtension ?? this.isProcessingExtension,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: clearTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      availability: availability ?? this.availability,
      isLoadingAvailability: isLoadingAvailability ?? this.isLoadingAvailability,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastOperation: lastOperation ?? this.lastOperation,
      bookSessionResponse: clearBookSessionResponse ? null : (bookSessionResponse ?? this.bookSessionResponse),
    );
  }

  @override
  List<Object?> get props => [
    upcomingSessions,
    completedSessions,
    pendingRequests,
    cancelledRequests,
    currentTab,
    isLoadingSessions,
    isLoadingMoreUpcoming,
    isLoadingMoreCompleted,
    currentUpcomingPage,
    currentCompletedPage,
    hasMoreUpcoming,
    hasMoreCompleted,
    isProcessingCancel,
    cancellingSessionId,
    isProcessingJoin,
    joiningSessionId,
    isProcessingSchedule,
    isProcessingBook,
    isProcessingExtension,
    selectedDate,
    selectedTimeSlot,
    availability,
    isLoadingAvailability,
    errorMessage,
    successMessage,
    lastOperation,
    bookSessionResponse,
  ];
}
