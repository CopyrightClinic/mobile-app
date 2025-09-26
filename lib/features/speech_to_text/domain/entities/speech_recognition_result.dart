import 'package:equatable/equatable.dart';

class SpeechRecognitionResult extends Equatable {
  final String recognizedText;
  final bool isFinal;
  final double confidence;
  final DateTime timestamp;

  const SpeechRecognitionResult({required this.recognizedText, required this.isFinal, required this.confidence, required this.timestamp});

  @override
  List<Object?> get props => [recognizedText, isFinal, confidence, timestamp];

  SpeechRecognitionResult copyWith({String? recognizedText, bool? isFinal, double? confidence, DateTime? timestamp}) {
    return SpeechRecognitionResult(
      recognizedText: recognizedText ?? this.recognizedText,
      isFinal: isFinal ?? this.isFinal,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
