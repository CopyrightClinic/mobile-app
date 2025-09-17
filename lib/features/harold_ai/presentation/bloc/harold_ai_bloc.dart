import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/harold_navigation_service.dart';
import 'harold_ai_event.dart';
import 'harold_ai_state.dart';

class HaroldAiBloc extends Bloc<HaroldAiEvent, HaroldAiState> {
  HaroldAiBloc() : super(const HaroldAiInitial()) {
    on<SubmitHaroldQuery>(_onSubmitHaroldQuery);
    on<ResetHaroldState>(_onResetHaroldState);
  }

  Future<void> _onSubmitHaroldQuery(SubmitHaroldQuery event, Emitter<HaroldAiState> emit) async {
    try {
      emit(const HaroldAiLoading());

      await Future.delayed(const Duration(seconds: 1));

      final bool isQuerySuccessful = event.query.toLowerCase().contains('success');

      final bool isUserAuthenticated = await HaroldNavigationService.isUserAuthenticated();

      if (isQuerySuccessful) {
        emit(HaroldAiSuccess(isUserAuthenticated: isUserAuthenticated));
      } else {
        emit(HaroldAiFailure(isUserAuthenticated: isUserAuthenticated));
      }
    } catch (e) {
      emit(HaroldAiError(message: e.toString()));
    }
  }

  void _onResetHaroldState(ResetHaroldState event, Emitter<HaroldAiState> emit) {
    emit(const HaroldAiInitial());
  }
}
