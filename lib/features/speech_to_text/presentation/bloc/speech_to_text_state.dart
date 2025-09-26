import 'package:equatable/equatable.dart';
import '../../domain/entities/speech_recognition_result.dart';
import '../../domain/entities/speech_recognition_state.dart';

abstract class SpeechToTextState extends Equatable {
  const SpeechToTextState();

  @override
  List<Object?> get props => [];
}

class SpeechToTextInitial extends SpeechToTextState {}

class SpeechToTextInitializing extends SpeechToTextState {}

class SpeechToTextInitialized extends SpeechToTextState {
  final bool isAvailable;

  const SpeechToTextInitialized({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

class SpeechToTextError extends SpeechToTextState {
  final String message;

  const SpeechToTextError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SpeechToTextListening extends SpeechToTextState {
  final String currentText;
  final double soundLevel;
  final SpeechRecognitionState recognitionState;
  final List<SpeechRecognitionResult> results;

  const SpeechToTextListening({required this.currentText, required this.soundLevel, required this.recognitionState, required this.results});

  @override
  List<Object?> get props => [currentText, soundLevel, recognitionState, results];

  SpeechToTextListening copyWith({
    String? currentText,
    double? soundLevel,
    SpeechRecognitionState? recognitionState,
    List<SpeechRecognitionResult>? results,
  }) {
    return SpeechToTextListening(
      currentText: currentText ?? this.currentText,
      soundLevel: soundLevel ?? this.soundLevel,
      recognitionState: recognitionState ?? this.recognitionState,
      results: results ?? this.results,
    );
  }
}

class SpeechToTextStopped extends SpeechToTextState {
  final String finalText;
  final List<SpeechRecognitionResult> results;

  const SpeechToTextStopped({required this.finalText, required this.results});

  @override
  List<Object?> get props => [finalText, results];
}

class SpeechToTextPaused extends SpeechToTextState {
  final String currentText;
  final List<SpeechRecognitionResult> results;

  const SpeechToTextPaused({required this.currentText, required this.results});

  @override
  List<Object?> get props => [currentText, results];
}

class SpeechToTextProcessing extends SpeechToTextState {
  final String currentText;
  final List<SpeechRecognitionResult> results;

  const SpeechToTextProcessing({required this.currentText, required this.results});

  @override
  List<Object?> get props => [currentText, results];
}
