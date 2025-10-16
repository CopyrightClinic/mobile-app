import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/get_session_details_usecase.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/submit_session_feedback_usecase.dart';
import '../../domain/usecases/unlock_session_summary_usecase.dart';
import 'session_details_event.dart';
import 'session_details_state.dart';

class SessionDetailsBloc extends Bloc<SessionDetailsEvent, SessionDetailsState> {
  final GetSessionDetailsUseCase getSessionDetailsUseCase;
  final CancelSessionUseCase cancelSessionUseCase;
  final SubmitSessionFeedbackUseCase submitSessionFeedbackUseCase;
  final UnlockSessionSummaryUseCase unlockSessionSummaryUseCase;

  SessionDetailsBloc({
    required this.getSessionDetailsUseCase,
    required this.cancelSessionUseCase,
    required this.submitSessionFeedbackUseCase,
    required this.unlockSessionSummaryUseCase,
  }) : super(const SessionDetailsState()) {
    on<LoadSessionDetails>(_onLoadSessionDetails);
    on<CancelSessionFromDetails>(_onCancelSessionFromDetails);
    on<SubmitSessionFeedback>(_onSubmitSessionFeedback);
    on<UnlockSessionSummary>(_onUnlockSessionSummary);
  }

  Future<void> _onLoadSessionDetails(LoadSessionDetails event, Emitter<SessionDetailsState> emit) async {
    emit(state.copyWith(isLoadingDetails: true, clearError: true, clearSuccess: true));

    try {
      final timezone = await TimezoneHelper.getUserTimezone();
      final result = await getSessionDetailsUseCase(GetSessionDetailsParams(sessionId: event.sessionId, timezone: timezone));

      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoadingDetails: false,
            errorMessage: failure.message ?? AppStrings.failedToFetchSession,
            lastOperation: SessionDetailsOperation.loadDetails,
          ),
        ),
        (sessionDetails) => emit(
          state.copyWith(
            sessionDetails: sessionDetails,
            isLoadingDetails: false,
            clearError: true,
            lastOperation: SessionDetailsOperation.loadDetails,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDetails: false,
          errorMessage: '${AppStrings.failedToFetchSession}: $e',
          lastOperation: SessionDetailsOperation.loadDetails,
        ),
      );
    }
  }

  Future<void> _onCancelSessionFromDetails(CancelSessionFromDetails event, Emitter<SessionDetailsState> emit) async {
    if (!state.hasData) return;

    emit(state.copyWith(isProcessingCancel: true, clearError: true, clearSuccess: true));

    final result = await cancelSessionUseCase(CancelSessionParams(sessionId: event.sessionId, reason: event.reason));

    result.fold(
      (failure) => emit(
        state.copyWith(
          isProcessingCancel: false,
          errorMessage: failure.message ?? AppStrings.failedToCancelSession,
          lastOperation: SessionDetailsOperation.cancel,
        ),
      ),
      (message) => emit(state.copyWith(isProcessingCancel: false, successMessage: message, lastOperation: SessionDetailsOperation.cancel)),
    );
  }

  Future<void> _onSubmitSessionFeedback(SubmitSessionFeedback event, Emitter<SessionDetailsState> emit) async {
    if (!state.hasData) return;

    emit(state.copyWith(isProcessingFeedback: true, clearError: true, clearSuccess: true));

    final result = await submitSessionFeedbackUseCase(
      SubmitSessionFeedbackParams(sessionId: event.sessionId, rating: event.rating, review: event.review),
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isProcessingFeedback: false,
          errorMessage: failure.message ?? AppStrings.failedToSubmitFeedback,
          lastOperation: SessionDetailsOperation.submitFeedback,
        ),
      ),
      (response) async {
        emit(state.copyWith(isProcessingFeedback: false, successMessage: response.message, lastOperation: SessionDetailsOperation.submitFeedback));
        add(LoadSessionDetails(sessionId: event.sessionId));
      },
    );
  }

  Future<void> _onUnlockSessionSummary(UnlockSessionSummary event, Emitter<SessionDetailsState> emit) async {
    if (!state.hasData) return;

    emit(state.copyWith(isProcessingUnlockSummary: true, clearError: true, clearSuccess: true));

    final result = await unlockSessionSummaryUseCase(
      UnlockSessionSummaryParams(sessionId: event.sessionId, paymentMethodId: event.paymentMethodId, summaryFee: event.summaryFee),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isProcessingUnlockSummary: false,
            errorMessage: failure.message ?? AppStrings.failedToUnlockSessionSummary,
            lastOperation: SessionDetailsOperation.unlockSummary,
          ),
        );
      },
      (response) async {
        emit(
          state.copyWith(isProcessingUnlockSummary: false, successMessage: response.message, lastOperation: SessionDetailsOperation.unlockSummary),
        );
        add(LoadSessionDetails(sessionId: event.sessionId));
      },
    );
  }
}
