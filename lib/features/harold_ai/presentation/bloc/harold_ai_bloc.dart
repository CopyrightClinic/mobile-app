import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/services/harold_navigation_service.dart';
import '../../domain/usecases/evaluate_query_usecase.dart';
import 'harold_ai_event.dart';
import 'harold_ai_state.dart';

class HaroldAiBloc extends Bloc<HaroldAiEvent, HaroldAiState> {
  final EvaluateQueryUseCase evaluateQueryUseCase;

  HaroldAiBloc({required this.evaluateQueryUseCase}) : super(const HaroldAiInitial()) {
    on<SubmitHaroldQuery>(_onSubmitHaroldQuery);
    on<ResetHaroldState>(_onResetHaroldState);
  }

  Future<void> _onSubmitHaroldQuery(SubmitHaroldQuery event, Emitter<HaroldAiState> emit) async {
    try {
      emit(const HaroldAiLoading());

      final bool isUserAuthenticated = await HaroldNavigationService.isUserAuthenticated();

      final result = await evaluateQueryUseCase(EvaluateQueryParams(query: event.query));

      result.fold(
        (failure) {
          emit(HaroldAiError(message: failure.message ?? AppStrings.failedToEvaluateQuery));
        },
        (evaluationResult) {
          if (evaluationResult.success) {
            if (evaluationResult.isLegitimate) {
              emit(HaroldAiSuccess(isUserAuthenticated: isUserAuthenticated, query: event.query, fee: evaluationResult.fee));
            } else {
              emit(HaroldAiFailure(isUserAuthenticated: isUserAuthenticated, query: event.query));
            }
          } else {
            emit(const HaroldAiError(message: AppStrings.haroldAiEvaluationNotSuccessful));
          }
        },
      );
    } catch (e) {
      emit(HaroldAiError(message: '${AppStrings.unexpectedErrorOccurred}: $e'));
    }
  }

  void _onResetHaroldState(ResetHaroldState event, Emitter<HaroldAiState> emit) {
    emit(const HaroldAiInitial());
  }
}
