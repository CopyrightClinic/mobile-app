import 'package:equatable/equatable.dart';
import '../../domain/entities/session_details_entity.dart';

class SessionDetailsState extends Equatable {
  final SessionDetailsEntity? sessionDetails;
  final bool isLoadingDetails;
  final bool isProcessingCancel;
  final bool isProcessingFeedback;
  final bool isProcessingUnlockSummary;
  final String? errorMessage;
  final String? successMessage;
  final SessionDetailsOperation? lastOperation;

  const SessionDetailsState({
    this.sessionDetails,
    this.isLoadingDetails = false,
    this.isProcessingCancel = false,
    this.isProcessingFeedback = false,
    this.isProcessingUnlockSummary = false,
    this.errorMessage,
    this.successMessage,
    this.lastOperation,
  });

  bool get hasData => sessionDetails != null;
  bool get hasError => errorMessage != null;
  bool get isProcessing => isProcessingCancel || isProcessingFeedback || isProcessingUnlockSummary;

  SessionDetailsState copyWith({
    SessionDetailsEntity? sessionDetails,
    bool? isLoadingDetails,
    bool? isProcessingCancel,
    bool? isProcessingFeedback,
    bool? isProcessingUnlockSummary,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    SessionDetailsOperation? lastOperation,
  }) {
    return SessionDetailsState(
      sessionDetails: sessionDetails ?? this.sessionDetails,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isProcessingCancel: isProcessingCancel ?? this.isProcessingCancel,
      isProcessingFeedback: isProcessingFeedback ?? this.isProcessingFeedback,
      isProcessingUnlockSummary: isProcessingUnlockSummary ?? this.isProcessingUnlockSummary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastOperation: lastOperation ?? this.lastOperation,
    );
  }

  @override
  List<Object?> get props => [
    sessionDetails,
    isLoadingDetails,
    isProcessingCancel,
    isProcessingFeedback,
    isProcessingUnlockSummary,
    errorMessage,
    successMessage,
    lastOperation,
  ];
}

enum SessionDetailsOperation { loadDetails, cancel, submitFeedback, unlockSummary }
