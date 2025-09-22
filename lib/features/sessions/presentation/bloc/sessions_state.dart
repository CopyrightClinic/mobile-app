import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_availability_entity.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<SessionEntity> upcomingSessions;
  final List<SessionEntity> completedSessions;
  final SessionsTab currentTab;

  const SessionsLoaded({required this.upcomingSessions, required this.completedSessions, required this.currentTab});

  @override
  List<Object> get props => [upcomingSessions, completedSessions, currentTab];

  List<SessionEntity> get currentSessions {
    return currentTab == SessionsTab.upcoming ? upcomingSessions : completedSessions;
  }

  SessionsLoaded copyWith({List<SessionEntity>? upcomingSessions, List<SessionEntity>? completedSessions, SessionsTab? currentTab}) {
    return SessionsLoaded(
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class SessionsError extends SessionsState {
  final String message;

  const SessionsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionCancelLoading extends SessionsState {
  final String sessionId;

  const SessionCancelLoading({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SessionCancelled extends SessionsState {
  final String message;

  const SessionCancelled({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionJoinLoading extends SessionsState {
  final String sessionId;

  const SessionJoinLoading({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SessionJoined extends SessionsState {
  final SessionEntity session;

  const SessionJoined({required this.session});

  @override
  List<Object> get props => [session];
}

class SessionScheduleLoading extends SessionsState {
  const SessionScheduleLoading();
}

class SessionScheduled extends SessionsState {
  final SessionEntity session;

  const SessionScheduled({required this.session});

  @override
  List<Object> get props => [session];
}

class SessionScheduleError extends SessionsState {
  final String message;

  const SessionScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class ScheduleSessionState extends SessionsState {
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final SessionAvailabilityEntity? availability;
  final bool isLoadingAvailability;
  final String? errorMessage;

  const ScheduleSessionState({
    required this.selectedDate,
    this.selectedTimeSlot,
    this.availability,
    this.isLoadingAvailability = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [selectedDate, selectedTimeSlot, availability, isLoadingAvailability, errorMessage];

  ScheduleSessionState copyWith({
    DateTime? selectedDate,
    String? selectedTimeSlot,
    SessionAvailabilityEntity? availability,
    bool? isLoadingAvailability,
    String? errorMessage,
    bool clearTimeSlot = false,
    bool clearError = false,
  }) {
    return ScheduleSessionState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: clearTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      availability: availability ?? this.availability,
      isLoadingAvailability: isLoadingAvailability ?? this.isLoadingAvailability,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get canContinueToPayment => selectedTimeSlot != null;

  List<AvailabilityDayEntity> get availableDays => availability?.days ?? [];

  List<TimeSlotEntity> get availableTimeSlotsForSelectedDate {
    if (availability == null) return [];

    final selectedDay =
        availability!.days
            .where((day) => day.date.year == selectedDate.year && day.date.month == selectedDate.month && day.date.day == selectedDate.day)
            .firstOrNull;

    return selectedDay?.slots ?? [];
  }
}
