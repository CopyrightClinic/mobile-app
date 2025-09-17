import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_to_text_repository.dart';

class StartSpeechRecognitionUseCase extends UseCase<void, StartSpeechRecognitionParams> {
  final SpeechToTextRepository repository;

  StartSpeechRecognitionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(StartSpeechRecognitionParams params) async {
    return await repository.startListening(localeId: params.localeId, enableHapticFeedback: params.enableHapticFeedback);
  }
}

class StartSpeechRecognitionParams {
  final String? localeId;
  final bool enableHapticFeedback;

  StartSpeechRecognitionParams({this.localeId, this.enableHapticFeedback = true});
}
