import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/speech_recognition_result.dart';
import '../../domain/entities/speech_recognition_state.dart';
import '../../domain/repositories/speech_to_text_repository.dart';
import '../datasources/speech_to_text_local_data_source.dart';

class SpeechToTextRepositoryImpl implements SpeechToTextRepository {
  final SpeechToTextLocalDataSource localDataSource;

  SpeechToTextRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      final result = await localDataSource.initialize();
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to initialize speech recognition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startListening({String? localeId, bool enableHapticFeedback = true}) async {
    try {
      await localDataSource.startListening(localeId: localeId, enableHapticFeedback: enableHapticFeedback);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure('Failed to start speech recognition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await localDataSource.stopListening();
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure('Failed to stop speech recognition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> pauseListening() async {
    try {
      await localDataSource.pauseListening();
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure('Failed to pause speech recognition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resumeListening() async {
    try {
      await localDataSource.resumeListening();
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure('Failed to resume speech recognition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAvailable() async {
    try {
      final result = await localDataSource.isAvailable();
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to check speech recognition availability: ${e.toString()}'));
    }
  }

  @override
  SpeechRecognitionState getCurrentState() {
    return localDataSource.getCurrentState();
  }

  @override
  Stream<SpeechRecognitionResult> get recognitionResults => localDataSource.recognitionResults.map((model) => model.toEntity());

  @override
  Stream<SpeechRecognitionState> get stateChanges => localDataSource.stateChanges;

  @override
  Stream<double> get soundLevelChanges => localDataSource.soundLevelChanges;

  @override
  Future<void> dispose() async {
    await localDataSource.dispose();
  }

  void initializeWithContext(dynamic context) {
    if (localDataSource is SpeechToTextLocalDataSourceImpl) {
      (localDataSource as SpeechToTextLocalDataSourceImpl).initializeWithContext(context);
    }
  }

  void clearControllerText() {
    if (localDataSource is SpeechToTextLocalDataSourceImpl) {
      (localDataSource as SpeechToTextLocalDataSourceImpl).clearControllerText();
    }
  }
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}
