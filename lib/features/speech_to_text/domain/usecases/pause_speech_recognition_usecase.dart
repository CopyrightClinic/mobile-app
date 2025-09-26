import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_to_text_repository.dart';

class PauseSpeechRecognitionUseCase extends UseCase<void, NoParams> {
  final SpeechToTextRepository repository;

  PauseSpeechRecognitionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.pauseListening();
  }
}
