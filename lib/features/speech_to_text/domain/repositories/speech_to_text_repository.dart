import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/speech_recognition_result.dart';
import '../entities/speech_recognition_state.dart';

abstract class SpeechToTextRepository {
  /// Initialize speech recognition service
  Future<Either<Failure, bool>> initialize();

  /// Start listening for speech
  Future<Either<Failure, void>> startListening({String? localeId, bool enableHapticFeedback});

  /// Stop listening for speech
  Future<Either<Failure, void>> stopListening();

  /// Pause speech recognition
  Future<Either<Failure, void>> pauseListening();

  /// Resume speech recognition
  Future<Either<Failure, void>> resumeListening();

  /// Check if speech recognition is available
  Future<Either<Failure, bool>> isAvailable();

  /// Get current recognition state
  SpeechRecognitionState getCurrentState();

  /// Stream of recognition results
  Stream<SpeechRecognitionResult> get recognitionResults;

  /// Stream of recognition state changes
  Stream<SpeechRecognitionState> get stateChanges;

  /// Stream of sound level changes
  Stream<double> get soundLevelChanges;

  /// Dispose resources
  Future<void> dispose();
}
