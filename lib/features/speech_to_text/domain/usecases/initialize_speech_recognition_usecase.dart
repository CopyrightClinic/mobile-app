import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_to_text_repository.dart';

class InitializeSpeechRecognitionUseCase extends UseCase<bool, NoParams> {
  final SpeechToTextRepository repository;

  InitializeSpeechRecognitionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.initialize();
  }
}
