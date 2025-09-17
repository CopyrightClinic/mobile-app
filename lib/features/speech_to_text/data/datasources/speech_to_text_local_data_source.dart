import 'dart:async';
import 'dart:developer';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import '../models/speech_recognition_result_model.dart';
import '../../domain/entities/speech_recognition_state.dart';

abstract class SpeechToTextLocalDataSource {
  Future<bool> initialize();
  Future<void> startListening({String? localeId, bool enableHapticFeedback});
  Future<void> stopListening();
  Future<void> pauseListening();
  Future<void> resumeListening();
  Future<bool> isAvailable();
  SpeechRecognitionState getCurrentState();
  Stream<SpeechRecognitionResultModel> get recognitionResults;
  Stream<SpeechRecognitionState> get stateChanges;
  Stream<double> get soundLevelChanges;
  Future<void> dispose();
}

class SpeechToTextLocalDataSourceImpl implements SpeechToTextLocalDataSource {
  ManualSttController? _controller;

  final StreamController<SpeechRecognitionResultModel> _recognitionResultsController = StreamController<SpeechRecognitionResultModel>.broadcast();
  final StreamController<SpeechRecognitionState> _stateChangesController = StreamController<SpeechRecognitionState>.broadcast();
  final StreamController<double> _soundLevelController = StreamController<double>.broadcast();

  SpeechRecognitionState _currentState = SpeechRecognitionState.stopped;
  bool _isInitialized = false;

  @override
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  void _initializeController(dynamic context) {
    if (_controller != null) return;

    _controller = ManualSttController(context);
    _controller!.clearTextOnStart = false;
    _controller!.enableHapticFeedback = true;

    _controller!.listen(
      onListeningStateChanged: (ManualSttState state) {
        log('Speech state changed to: ${state.name}');
        final mappedState = _mapManualSttState(state);
        _currentState = mappedState;
        _stateChangesController.add(mappedState);
      },
      onListeningTextChanged: (String text) {
        log('Recognized text: $text');
        final result = SpeechRecognitionResultModel(recognizedText: text, isFinal: false, confidence: 1.0, timestamp: DateTime.now());
        _recognitionResultsController.add(result);
      },
      onSoundLevelChanged: (double level) {
        _soundLevelController.add(level);
      },
    );
  }

  SpeechRecognitionState _mapManualSttState(ManualSttState state) {
    switch (state) {
      case ManualSttState.listening:
        return SpeechRecognitionState.listening;
      case ManualSttState.paused:
        return SpeechRecognitionState.paused;
      case ManualSttState.stopped:
        return SpeechRecognitionState.stopped;
    }
  }

  @override
  Future<void> startListening({String? localeId, bool enableHapticFeedback = true}) async {
    if (_controller == null) {
      throw Exception('Controller not initialized. Call initializeWithContext first.');
    }

    try {
      _controller!.localId = localeId ?? 'en-US';
      _controller!.enableHapticFeedback = enableHapticFeedback;
      _controller!.startStt();
    } catch (e) {
      log('Error starting speech recognition: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      _controller?.stopStt();
    } catch (e) {
      log('Error stopping speech recognition: $e');
      rethrow;
    }
  }

  @override
  Future<void> pauseListening() async {
    try {
      _controller?.pauseStt();
    } catch (e) {
      log('Error pausing speech recognition: $e');
      rethrow;
    }
  }

  @override
  Future<void> resumeListening() async {
    try {
      _controller?.resumeStt();
    } catch (e) {
      log('Error resuming speech recognition: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isAvailable() async {
    return _isInitialized;
  }

  @override
  SpeechRecognitionState getCurrentState() {
    return _currentState;
  }

  @override
  Stream<SpeechRecognitionResultModel> get recognitionResults => _recognitionResultsController.stream;

  @override
  Stream<SpeechRecognitionState> get stateChanges => _stateChangesController.stream;

  @override
  Stream<double> get soundLevelChanges => _soundLevelController.stream;

  void initializeWithContext(dynamic context) {
    _initializeController(context);
  }

  @override
  Future<void> dispose() async {
    _controller?.dispose();
    _controller = null;
    await _recognitionResultsController.close();
    await _stateChangesController.close();
    await _soundLevelController.close();
    _isInitialized = false;
  }
}
