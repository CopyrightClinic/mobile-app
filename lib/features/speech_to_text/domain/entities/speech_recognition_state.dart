enum SpeechRecognitionState { stopped, listening, paused, processing, error }

extension SpeechRecognitionStateX on SpeechRecognitionState {
  bool get isListening => this == SpeechRecognitionState.listening;
  bool get isStopped => this == SpeechRecognitionState.stopped;
  bool get isPaused => this == SpeechRecognitionState.paused;
  bool get isProcessing => this == SpeechRecognitionState.processing;
  bool get hasError => this == SpeechRecognitionState.error;
}
