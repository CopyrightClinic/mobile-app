import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_to_text_repository.dart';

class ResumeSpeechRecognitionUseCase extends UseCase<void, NoParams> {
  final SpeechToTextRepository repository;

  ResumeSpeechRecognitionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.resumeListening();
  }
}
