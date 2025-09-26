import '../../domain/entities/speech_recognition_result.dart';

class SpeechRecognitionResultModel extends SpeechRecognitionResult {
  const SpeechRecognitionResultModel({required super.recognizedText, required super.isFinal, required super.confidence, required super.timestamp});

  factory SpeechRecognitionResultModel.fromEntity(SpeechRecognitionResult entity) {
    return SpeechRecognitionResultModel(
      recognizedText: entity.recognizedText,
      isFinal: entity.isFinal,
      confidence: entity.confidence,
      timestamp: entity.timestamp,
    );
  }

  SpeechRecognitionResult toEntity() {
    return SpeechRecognitionResult(recognizedText: recognizedText, isFinal: isFinal, confidence: confidence, timestamp: timestamp);
  }

  @override
  SpeechRecognitionResultModel copyWith({String? recognizedText, bool? isFinal, double? confidence, DateTime? timestamp}) {
    return SpeechRecognitionResultModel(
      recognizedText: recognizedText ?? this.recognizedText,
      isFinal: isFinal ?? this.isFinal,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
