import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/cancel_session_request_usecase.dart';
import '../../domain/usecases/get_user_sessions_usecase.dart';
import '../../domain/usecases/get_user_session_requests_usecase.dart';
import '../../domain/usecases/get_session_availability_usecase.dart';
import '../../domain/usecases/book_session_usecase.dart';
import '../../domain/usecases/extend_session_usecase.dart';
import 'sessions_event.dart';
import 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetUserSessionsUseCase getUserSessionsUseCase;
  final GetUserSessionRequestsUseCase getUserSessionRequestsUseCase;
  final CancelSessionUseCase cancelSessionUseCase;
  final CancelSessionRequestUseCase cancelSessionRequestUseCase;
  final GetSessionAvailabilityUseCase getSessionAvailabilityUseCase;
  final BookSessionUseCase bookSessionUseCase;
  final ExtendSessionUseCase extendSessionUseCase;

  SessionsBloc({
    required this.getUserSessionsUseCase,
    required this.getUserSessionRequestsUseCase,
    required this.cancelSessionUseCase,
    required this.cancelSessionRequestUseCase,
    required this.getSessionAvailabilityUseCase,
    required this.bookSessionUseCase,
    required this.extendSessionUseCase,
  }) : super(const SessionsState()) {
    on<LoadUserSessions>(_onLoadUserSessions);
    on<RefreshSessions>(_onRefreshSessions);
    on<LoadMoreSessions>(_onLoadMoreSessions);
    on<SwitchToUpcoming>(_onSwitchToUpcoming);
    on<SwitchToCompleted>(_onSwitchToCompleted);
    on<SwitchToPending>(_onSwitchToPending);
    on<SwitchToCancelled>(_onSwitchToCancelled);
    on<CancelSessionRequested>(_onCancelSessionRequested);
    on<CancelSessionRequestSubmitted>(_onCancelSessionRequestSubmitted);
    on<ScheduleSessionRequested>(_onScheduleSessionRequested);
    on<InitializeScheduleSession>(_onInitializeScheduleSession);
    on<DateSelected>(_onDateSelected);
    on<TimeSlotSelected>(_onTimeSlotSelected);
    on<LoadSessionAvailability>(_onLoadSessionAvailability);
    on<BookSessionRequested>(_onBookSessionRequested);
    on<ExtendSession>(_onExtendSession);
  }

  Future<void> _onLoadUserSessions(
    LoadUserSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingSessions: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final String timezone = await TimezoneHelper.getUserTimezone();
    final upcomingResult = await getUserSessionsUseCase(
      GetUserSessionsParams(
        timezone: timezone,
        status: 'upcoming',
        page: 1,
        limit: 10,
      ),
    );
    final completedResult = await getUserSessionsUseCase(
      GetUserSessionsParams(
        timezone: timezone,
        status: 'completed',
        page: 1,
        limit: 10,
      ),
    );

    await upcomingResult.fold(
      (failure) async => emit(
        state.copyWith(
          isLoadingSessions: false,
          errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
          lastOperation: SessionsOperation.loadSessions,
        ),
      ),
      (upcomingPaginated) async {
        await completedResult.fold(
          (failure) async => emit(
            state.copyWith(
              isLoadingSessions: false,
              errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
              lastOperation: SessionsOperation.loadSessions,
            ),
          ),
          (completedPaginated) async {
            emit(
              state.copyWith(
                upcomingSessions: upcomingPaginated.sessions,
                completedSessions: completedPaginated.sessions,
                currentUpcomingPage: upcomingPaginated.page,
                currentCompletedPage: completedPaginated.page,
                hasMoreUpcoming: upcomingPaginated.hasMore,
                hasMoreCompleted: completedPaginated.hasMore,
                isLoadingSessions: false,
                currentTab: SessionsTab.upcoming,
                clearError: true,
                lastOperation: SessionsOperation.loadSessions,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshSessions(
    RefreshSessions event,
    Emitter<SessionsState> emit,
  ) async {
    if (!state.hasData) {
      await _onLoadUserSessions(const LoadUserSessions(), emit);
      return;
    }

    if (state.currentTab == SessionsTab.pending || state.currentTab == SessionsTab.cancelled) {
      final String timezone = await TimezoneHelper.getUserTimezone();
      final isPendingTab = state.currentTab == SessionsTab.pending;
      final result = await getUserSessionRequestsUseCase(
        GetUserSessionRequestsParams(timezone: timezone, status: isPendingTab ? 'pending' : 'canceled'),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            errorMessage: failure.message ?? AppStrings.failedToRefreshSessions,
            lastOperation: SessionsOperation.loadSessions,
          ),
        ),
        (requests) {
          emit(
            isPendingTab
                ? state.copyWith(pendingRequests: requests, clearError: true, clearSuccess: true)
                : state.copyWith(cancelledRequests: requests, clearError: true, clearSuccess: true),
          );
        },
      );
      return;
    }

    final String timezone = await TimezoneHelper.getUserTimezone();
    final upcomingResult = await getUserSessionsUseCase(
      GetUserSessionsParams(
        timezone: timezone,
        status: 'upcoming',
        page: 1,
        limit: 10,
      ),
    );
    final completedResult = await getUserSessionsUseCase(
      GetUserSessionsParams(
        timezone: timezone,
        status: 'completed',
        page: 1,
        limit: 10,
      ),
    );

    await upcomingResult.fold(
      (failure) async => emit(
        state.copyWith(
          errorMessage: failure.message ?? AppStrings.failedToRefreshSessions,
          lastOperation: SessionsOperation.loadSessions,
        ),
      ),
      (upcomingPaginated) async {
        await completedResult.fold(
          (failure) async => emit(
            state.copyWith(
              errorMessage:
                  failure.message ?? AppStrings.failedToRefreshSessions,
              lastOperation: SessionsOperation.loadSessions,
            ),
          ),
          (completedPaginated) async {
            emit(
              state.copyWith(
                upcomingSessions: upcomingPaginated.sessions,
                completedSessions: completedPaginated.sessions,
                currentUpcomingPage: upcomingPaginated.page,
                currentCompletedPage: completedPaginated.page,
                hasMoreUpcoming: upcomingPaginated.hasMore,
                hasMoreCompleted: completedPaginated.hasMore,
                clearError: true,
                clearSuccess: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onLoadMoreSessions(
    LoadMoreSessions event,
    Emitter<SessionsState> emit,
  ) async {
    if (!state.hasData) return;

    final currentTab = state.currentTab;
    if (currentTab != SessionsTab.upcoming && currentTab != SessionsTab.completed) {
      return;
    }

    final isUpcomingTab = currentTab == SessionsTab.upcoming;
    final hasMore = isUpcomingTab ? state.hasMoreUpcoming : state.hasMoreCompleted;
    final isAlreadyLoading = isUpcomingTab ? state.isLoadingMoreUpcoming : state.isLoadingMoreCompleted;

    if (!hasMore || isAlreadyLoading) return;

    final nextPage = (isUpcomingTab ? state.currentUpcomingPage : state.currentCompletedPage) + 1;

    if (isUpcomingTab) {
      emit(state.copyWith(isLoadingMoreUpcoming: true, clearError: true));
    } else {
      emit(state.copyWith(isLoadingMoreCompleted: true, clearError: true));
    }

    final String timezone = await TimezoneHelper.getUserTimezone();
    final result = await getUserSessionsUseCase(
      GetUserSessionsParams(
        timezone: timezone,
        status: currentTab.apiValue,
        page: nextPage,
        limit: 10,
      ),
    );

    result.fold(
      (failure) {
        if (isUpcomingTab) {
          emit(
            state.copyWith(
              isLoadingMoreUpcoming: false,
              errorMessage: failure.message ?? AppStrings.failedToLoadMoreSessions,
              lastOperation: SessionsOperation.loadSessions,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoadingMoreCompleted: false,
              errorMessage: failure.message ?? AppStrings.failedToLoadMoreSessions,
              lastOperation: SessionsOperation.loadSessions,
            ),
          );
        }
      },
      (paginatedSessions) {
        if (isUpcomingTab) {
          emit(
            state.copyWith(
              upcomingSessions: [...state.upcomingSessions!, ...paginatedSessions.sessions],
              currentUpcomingPage: paginatedSessions.page,
              hasMoreUpcoming: paginatedSessions.hasMore,
              isLoadingMoreUpcoming: false,
              clearError: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              completedSessions: [...state.completedSessions!, ...paginatedSessions.sessions],
              currentCompletedPage: paginatedSessions.page,
              hasMoreCompleted: paginatedSessions.hasMore,
              isLoadingMoreCompleted: false,
              clearError: true,
            ),
          );
        }
      },
    );
  }

  void _onSwitchToUpcoming(
    SwitchToUpcoming event,
    Emitter<SessionsState> emit,
  ) {
    emit(state.copyWith(currentTab: SessionsTab.upcoming, clearSuccess: true, clearError: true));
  }

  Future<void> _onSwitchToCompleted(
    SwitchToCompleted event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(currentTab: SessionsTab.completed, clearSuccess: true, clearError: true));

    if (!state.hasCompletedData) {
      emit(state.copyWith(isLoadingSessions: true, clearError: true));

      final String timezone = await TimezoneHelper.getUserTimezone();
      final result = await getUserSessionsUseCase(
        GetUserSessionsParams(
          timezone: timezone,
          status: 'completed',
          page: 1,
          limit: 10,
        ),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoadingSessions: false,
            errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
            lastOperation: SessionsOperation.loadSessions,
          ),
        ),
        (paginatedSessions) {
          emit(
            state.copyWith(
              completedSessions: paginatedSessions.sessions,
              currentCompletedPage: paginatedSessions.page,
              hasMoreCompleted: paginatedSessions.hasMore,
              isLoadingSessions: false,
              clearError: true,
              lastOperation: SessionsOperation.loadSessions,
            ),
          );
        },
      );
    }
  }

  Future<void> _onSwitchToPending(
    SwitchToPending event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(currentTab: SessionsTab.pending, clearSuccess: true, clearError: true));

    if (!state.hasPendingData) {
      emit(state.copyWith(isLoadingSessions: true, clearError: true));

      final String timezone = await TimezoneHelper.getUserTimezone();
      final result = await getUserSessionRequestsUseCase(
        GetUserSessionRequestsParams(timezone: timezone, status: 'pending'),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoadingSessions: false,
            errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
            lastOperation: SessionsOperation.loadSessions,
          ),
        ),
        (requests) {
          emit(
            state.copyWith(
              pendingRequests: requests,
              isLoadingSessions: false,
              clearError: true,
              lastOperation: SessionsOperation.loadSessions,
            ),
          );
        },
      );
    }
  }

  Future<void> _onSwitchToCancelled(
    SwitchToCancelled event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(currentTab: SessionsTab.cancelled, clearSuccess: true, clearError: true));

    if (!state.hasCancelledData) {
      emit(state.copyWith(isLoadingSessions: true, clearError: true));

      final String timezone = await TimezoneHelper.getUserTimezone();
      final result = await getUserSessionRequestsUseCase(
        GetUserSessionRequestsParams(timezone: timezone, status: 'canceled'),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoadingSessions: false,
            errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
            lastOperation: SessionsOperation.loadSessions,
          ),
        ),
        (requests) {
          emit(
            state.copyWith(
              cancelledRequests: requests,
              isLoadingSessions: false,
              clearError: true,
              lastOperation: SessionsOperation.loadSessions,
            ),
          );
        },
      );
    }
  }

  Future<void> _onCancelSessionRequested(
    CancelSessionRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isProcessingCancel: true,
        cancellingSessionId: event.sessionId,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await cancelSessionUseCase(
      CancelSessionParams(sessionId: event.sessionId, reason: event.reason),
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isProcessingCancel: false,
          errorMessage: failure.message ?? AppStrings.failedToCancelSession,
          lastOperation: SessionsOperation.cancelSession,
          clearCancellingSessionId: true,
        ),
      ),
      (response) async {
        emit(
          state.copyWith(
            isProcessingCancel: false,
            successMessage: response.message,
            lastOperation: SessionsOperation.cancelSession,
            clearCancellingSessionId: true,
          ),
        );
        await _onRefreshSessions(const RefreshSessions(), emit);
      },
    );
  }

  Future<void> _onCancelSessionRequestSubmitted(
    CancelSessionRequestSubmitted event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isProcessingCancel: true,
        cancellingSessionId: event.requestId,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await cancelSessionRequestUseCase(
      CancelSessionRequestParams(requestId: event.requestId, reason: event.reason),
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isProcessingCancel: false,
          errorMessage: failure.message ?? AppStrings.failedToCancelSession,
          lastOperation: SessionsOperation.cancelSessionRequest,
          clearCancellingSessionId: true,
        ),
      ),
      (response) async {
        emit(
          state.copyWith(
            isProcessingCancel: false,
            successMessage: response.message ?? AppStrings.sessionCancelledSuccessfully,
            lastOperation: SessionsOperation.cancelSessionRequest,
            clearCancellingSessionId: true,
          ),
        );

        final String timezone = await TimezoneHelper.getUserTimezone();
        final pendingResult = await getUserSessionRequestsUseCase(
          GetUserSessionRequestsParams(timezone: timezone, status: 'pending'),
        );
        pendingResult.fold((_) {}, (requests) {
          emit(state.copyWith(pendingRequests: requests));
        });

        if (state.hasCancelledData) {
          final cancelledResult = await getUserSessionRequestsUseCase(
            GetUserSessionRequestsParams(timezone: timezone, status: 'canceled'),
          );
          cancelledResult.fold((_) {}, (requests) {
            emit(state.copyWith(cancelledRequests: requests));
          });
        }
      },
    );
  }

  Future<void> _onScheduleSessionRequested(
    ScheduleSessionRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isProcessingSchedule: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          isProcessingSchedule: false,
          successMessage: AppStrings.sessionScheduledSuccessfully,
          lastOperation: SessionsOperation.scheduleSession,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProcessingSchedule: false,
          errorMessage:
              '${AppStrings.failedToScheduleSessionGeneric}: ${e.toString()}',
          lastOperation: SessionsOperation.scheduleSession,
        ),
      );
    }
  }

  Future<void> _onInitializeScheduleSession(
    InitializeScheduleSession event,
    Emitter<SessionsState> emit,
  ) async {
    final now = DateTime.now();
    emit(
      state.copyWith(
        selectedDate: now,
        isLoadingAvailability: true,
        clearError: true,
        clearSuccess: true,
        clearTimeSlot: true,
      ),
    );

    final String currentTimeZone = await TimezoneHelper.getUserTimezone();
    await _onLoadSessionAvailability(
      LoadSessionAvailability(timezone: currentTimeZone),
      emit,
    );
  }

  void _onDateSelected(DateSelected event, Emitter<SessionsState> emit) {
    if (state.isScheduling) {
      emit(
        state.copyWith(selectedDate: event.selectedDate, clearTimeSlot: true),
      );
    }
  }

  void _onTimeSlotSelected(
    TimeSlotSelected event,
    Emitter<SessionsState> emit,
  ) {
    if (state.isScheduling) {
      emit(state.copyWith(selectedTimeSlot: event.selectedTimeSlot));
    }
  }

  Future<void> _onLoadSessionAvailability(
    LoadSessionAvailability event,
    Emitter<SessionsState> emit,
  ) async {
    if (!state.isScheduling) return;

    emit(state.copyWith(isLoadingAvailability: true));

    final result = await getSessionAvailabilityUseCase(event.timezone);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingAvailability: false,
            errorMessage:
                failure.message ?? AppStrings.failedToLoadSessionAvailability,
            lastOperation: SessionsOperation.loadAvailability,
          ),
        );
      },
      (availability) {
        DateTime selectedDate = state.selectedDate!;
        if (availability.days.isNotEmpty) {
          final availableDate = availability.days.firstWhere(
            (day) => day.slots.isNotEmpty,
            orElse: () => availability.days.first,
          );
          selectedDate = availableDate.date;
        }

        emit(
          state.copyWith(
            availability: availability,
            selectedDate: selectedDate,
            isLoadingAvailability: false,
            clearTimeSlot: true,
            clearError: true,
            lastOperation: SessionsOperation.loadAvailability,
          ),
        );
      },
    );
  }

  Future<void> _onBookSessionRequested(
    BookSessionRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isProcessingBook: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await bookSessionUseCase(
      BookSessionParams(
        stripePaymentMethodId: event.stripePaymentMethodId,
        couponCode: event.couponCode,
        date: event.date,
        startTime: event.startTime,
        endTime: event.endTime,
        summary: event.summary,
        timezone: event.timezone,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isProcessingBook: false,
            errorMessage: failure.message ?? AppStrings.failedToBookSession,
            lastOperation: SessionsOperation.bookSession,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            isProcessingBook: false,
            bookSessionResponse: response,
            successMessage: response.message,
            lastOperation: SessionsOperation.bookSession,
          ),
        );
      },
    );
  }

  Future<void> _onExtendSession(
    ExtendSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isProcessingExtension: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await extendSessionUseCase(
      ExtendSessionParams(
        sessionId: event.sessionId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isProcessingExtension: false,
            errorMessage: failure.message ?? AppStrings.sessionExtendError,
            lastOperation: SessionsOperation.extendSession,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            isProcessingExtension: false,
            successMessage:
                response.message ?? AppStrings.sessionExtendedSuccess,
            lastOperation: SessionsOperation.extendSession,
          ),
        );
      },
    );
  }
}
