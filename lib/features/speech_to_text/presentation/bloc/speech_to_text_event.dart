import 'package:equatable/equatable.dart';

abstract class SpeechToTextEvent extends Equatable {
  const SpeechToTextEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSpeechRecognition extends SpeechToTextEvent {
  final dynamic context;

  const InitializeSpeechRecognition({required this.context});

  @override
  List<Object?> get props => [context];
}

class StartSpeechRecognition extends SpeechToTextEvent {
  final String? localeId;
  final bool enableHapticFeedback;

  const StartSpeechRecognition({this.localeId, this.enableHapticFeedback = true});

  @override
  List<Object?> get props => [localeId, enableHapticFeedback];
}

class StopSpeechRecognition extends SpeechToTextEvent {}

class PauseSpeechRecognition extends SpeechToTextEvent {}

class ResumeSpeechRecognition extends SpeechToTextEvent {}

class ToggleSpeechRecognition extends SpeechToTextEvent {
  final String? localeId;
  final bool enableHapticFeedback;

  const ToggleSpeechRecognition({this.localeId, this.enableHapticFeedback = true});

  @override
  List<Object?> get props => [localeId, enableHapticFeedback];
}

class ClearRecognizedText extends SpeechToTextEvent {}

class SpeechRecognitionResultReceived extends SpeechToTextEvent {
  final String recognizedText;
  final bool isFinal;
  final double confidence;

  const SpeechRecognitionResultReceived({required this.recognizedText, required this.isFinal, required this.confidence});

  @override
  List<Object?> get props => [recognizedText, isFinal, confidence];
}

class SpeechRecognitionStateChanged extends SpeechToTextEvent {
  final String state;

  const SpeechRecognitionStateChanged({required this.state});

  @override
  List<Object?> get props => [state];
}

class SpeechRecognitionSoundLevelChanged extends SpeechToTextEvent {
  final double soundLevel;

  const SpeechRecognitionSoundLevelChanged({required this.soundLevel});

  @override
  List<Object?> get props => [soundLevel];
}
