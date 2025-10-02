import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/get_session_details_usecase.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import 'session_details_event.dart';
import 'session_details_state.dart';

class SessionDetailsBloc extends Bloc<SessionDetailsEvent, SessionDetailsState> {
  final GetSessionDetailsUseCase getSessionDetailsUseCase;
  final CancelSessionUseCase cancelSessionUseCase;

  SessionDetailsBloc({required this.getSessionDetailsUseCase, required this.cancelSessionUseCase}) : super(const SessionDetailsInitial()) {
    on<LoadSessionDetails>(_onLoadSessionDetails);
    on<CancelSessionFromDetails>(_onCancelSessionFromDetails);
  }

  Future<void> _onLoadSessionDetails(LoadSessionDetails event, Emitter<SessionDetailsState> emit) async {
    emit(const SessionDetailsLoading());

    try {
      final timezone = await TimezoneHelper.getUserTimezone();
      final result = await getSessionDetailsUseCase(GetSessionDetailsParams(sessionId: event.sessionId, timezone: timezone));

      result.fold(
        (failure) => emit(SessionDetailsError(message: failure.message ?? AppStrings.failedToFetchSession)),
        (sessionDetails) => emit(SessionDetailsLoaded(sessionDetails: sessionDetails)),
      );
    } catch (e) {
      emit(SessionDetailsError(message: '${AppStrings.failedToFetchSession}: $e'));
    }
  }

  Future<void> _onCancelSessionFromDetails(CancelSessionFromDetails event, Emitter<SessionDetailsState> emit) async {
    if (state is SessionDetailsLoaded) {
      final currentState = state as SessionDetailsLoaded;
      emit(SessionDetailsCancelLoading(sessionDetails: currentState.sessionDetails));

      final result = await cancelSessionUseCase(CancelSessionParams(sessionId: event.sessionId, reason: event.reason));

      result.fold(
        (failure) => emit(SessionDetailsError(message: failure.message ?? AppStrings.failedToCancelSession)),
        (message) => emit(SessionDetailsCancelled(message: message)),
      );
    }
  }
}
