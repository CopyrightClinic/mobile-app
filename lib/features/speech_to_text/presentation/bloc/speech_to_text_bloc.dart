import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/speech_recognition_result.dart';
import '../../domain/entities/speech_recognition_state.dart';
import '../../domain/repositories/speech_to_text_repository.dart';
import '../../domain/usecases/initialize_speech_recognition_usecase.dart';
import '../../domain/usecases/start_speech_recognition_usecase.dart';
import '../../domain/usecases/stop_speech_recognition_usecase.dart';
import '../../domain/usecases/pause_speech_recognition_usecase.dart';
import '../../domain/usecases/resume_speech_recognition_usecase.dart';
import '../../data/repositories/speech_to_text_repository_impl.dart';
import 'speech_to_text_event.dart';
import 'speech_to_text_state.dart';

class SpeechToTextBloc extends Bloc<SpeechToTextEvent, SpeechToTextState> {
  final InitializeSpeechRecognitionUseCase initializeUseCase;
  final StartSpeechRecognitionUseCase startUseCase;
  final StopSpeechRecognitionUseCase stopUseCase;
  final PauseSpeechRecognitionUseCase pauseUseCase;
  final ResumeSpeechRecognitionUseCase resumeUseCase;
  final SpeechToTextRepository repository;

  StreamSubscription<SpeechRecognitionResult>? _recognitionResultsSubscription;
  StreamSubscription<SpeechRecognitionState>? _stateChangesSubscription;
  StreamSubscription<double>? _soundLevelSubscription;

  final List<SpeechRecognitionResult> _results = [];
  String _currentText = '';
  double _soundLevel = 0.0;
  SpeechRecognitionState _currentRecognitionState = SpeechRecognitionState.stopped;

  SpeechToTextBloc({
    required this.initializeUseCase,
    required this.startUseCase,
    required this.stopUseCase,
    required this.pauseUseCase,
    required this.resumeUseCase,
    required this.repository,
  }) : super(SpeechToTextInitial()) {
    on<InitializeSpeechRecognition>(_onInitializeSpeechRecognition);
    on<StartSpeechRecognition>(_onStartSpeechRecognition);
    on<StopSpeechRecognition>(_onStopSpeechRecognition);
    on<PauseSpeechRecognition>(_onPauseSpeechRecognition);
    on<ResumeSpeechRecognition>(_onResumeSpeechRecognition);
    on<ToggleSpeechRecognition>(_onToggleSpeechRecognition);
    on<ClearRecognizedText>(_onClearRecognizedText);
    on<SpeechRecognitionResultReceived>(_onSpeechRecognitionResultReceived);
    on<SpeechRecognitionStateChanged>(_onSpeechRecognitionStateChanged);
    on<SpeechRecognitionSoundLevelChanged>(_onSpeechRecognitionSoundLevelChanged);

    _setupStreamListeners();
  }

  void _setupStreamListeners() {
    _recognitionResultsSubscription = repository.recognitionResults.listen(
      (result) {
        add(SpeechRecognitionResultReceived(recognizedText: result.recognizedText, isFinal: result.isFinal, confidence: result.confidence));
      },
      onError: (error) {
        log('Speech recognition result stream error: $error');
        add(SpeechRecognitionStateChanged(state: 'error'));
      },
    );

    _stateChangesSubscription = repository.stateChanges.listen(
      (state) {
        add(SpeechRecognitionStateChanged(state: state.name));
      },
      onError: (error) {
        log('Speech recognition state stream error: $error');
      },
    );

    _soundLevelSubscription = repository.soundLevelChanges.listen(
      (level) {
        add(SpeechRecognitionSoundLevelChanged(soundLevel: level));
      },
      onError: (error) {
        log('Sound level stream error: $error');
      },
    );
  }

  Future<void> _onInitializeSpeechRecognition(InitializeSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    emit(SpeechToTextInitializing());

    // Initialize with context if repository supports it
    if (repository is SpeechToTextRepositoryImpl) {
      (repository as SpeechToTextRepositoryImpl).initializeWithContext(event.context);
    }

    final result = await initializeUseCase(NoParams());

    result.fold(
      (failure) => emit(SpeechToTextError(message: failure.message ?? 'Failed to initialize speech recognition')),
      (isAvailable) => emit(SpeechToTextInitialized(isAvailable: isAvailable)),
    );
  }

  Future<void> _onStartSpeechRecognition(StartSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    final result = await startUseCase(StartSpeechRecognitionParams(localeId: event.localeId, enableHapticFeedback: event.enableHapticFeedback));

    result.fold((failure) => emit(SpeechToTextError(message: failure.message ?? 'Failed to start speech recognition')), (_) {
      _currentRecognitionState = SpeechRecognitionState.listening;
      emit(SpeechToTextListening(currentText: _currentText, soundLevel: _soundLevel, recognitionState: _currentRecognitionState, results: _results));
    });
  }

  Future<void> _onStopSpeechRecognition(StopSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    final result = await stopUseCase(NoParams());

    result.fold((failure) => emit(SpeechToTextError(message: failure.message ?? 'Failed to stop speech recognition')), (_) {
      _currentRecognitionState = SpeechRecognitionState.stopped;
      emit(SpeechToTextStopped(finalText: _currentText, results: _results));
    });
  }

  Future<void> _onPauseSpeechRecognition(PauseSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    final result = await pauseUseCase(NoParams());

    result.fold((failure) => emit(SpeechToTextError(message: failure.message ?? 'Failed to pause speech recognition')), (_) {
      _currentRecognitionState = SpeechRecognitionState.paused;
      emit(SpeechToTextPaused(currentText: _currentText, results: _results));
    });
  }

  Future<void> _onResumeSpeechRecognition(ResumeSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    final result = await resumeUseCase(NoParams());

    result.fold((failure) => emit(SpeechToTextError(message: failure.message ?? 'Failed to resume speech recognition')), (_) {
      _currentRecognitionState = SpeechRecognitionState.listening;
      emit(SpeechToTextListening(currentText: _currentText, soundLevel: _soundLevel, recognitionState: _currentRecognitionState, results: _results));
    });
  }

  Future<void> _onToggleSpeechRecognition(ToggleSpeechRecognition event, Emitter<SpeechToTextState> emit) async {
    switch (_currentRecognitionState) {
      case SpeechRecognitionState.stopped:
        add(StartSpeechRecognition(localeId: event.localeId, enableHapticFeedback: event.enableHapticFeedback));
        break;
      case SpeechRecognitionState.listening:
        add(StopSpeechRecognition());
        break;
      case SpeechRecognitionState.paused:
        add(ResumeSpeechRecognition());
        break;
      case SpeechRecognitionState.processing:
      case SpeechRecognitionState.error:
        // Do nothing in these states
        break;
    }
  }

  void _onClearRecognizedText(ClearRecognizedText event, Emitter<SpeechToTextState> emit) {
    _currentText = '';
    _results.clear();

    if (_currentRecognitionState.isListening) {
      emit(SpeechToTextListening(currentText: _currentText, soundLevel: _soundLevel, recognitionState: _currentRecognitionState, results: _results));
    } else {
      emit(SpeechToTextStopped(finalText: _currentText, results: _results));
    }
  }

  void _onSpeechRecognitionResultReceived(SpeechRecognitionResultReceived event, Emitter<SpeechToTextState> emit) {
    _currentText = event.recognizedText;

    final result = SpeechRecognitionResult(
      recognizedText: event.recognizedText,
      isFinal: event.isFinal,
      confidence: event.confidence,
      timestamp: DateTime.now(),
    );

    if (event.isFinal) {
      _results.add(result);
    }

    if (_currentRecognitionState.isListening) {
      emit(SpeechToTextListening(currentText: _currentText, soundLevel: _soundLevel, recognitionState: _currentRecognitionState, results: _results));
    }
  }

  void _onSpeechRecognitionStateChanged(SpeechRecognitionStateChanged event, Emitter<SpeechToTextState> emit) {
    _currentRecognitionState = SpeechRecognitionState.values.firstWhere(
      (state) => state.name == event.state,
      orElse: () => SpeechRecognitionState.stopped,
    );

    switch (_currentRecognitionState) {
      case SpeechRecognitionState.listening:
        emit(
          SpeechToTextListening(currentText: _currentText, soundLevel: _soundLevel, recognitionState: _currentRecognitionState, results: _results),
        );
        break;
      case SpeechRecognitionState.stopped:
        emit(SpeechToTextStopped(finalText: _currentText, results: _results));
        break;
      case SpeechRecognitionState.paused:
        emit(SpeechToTextPaused(currentText: _currentText, results: _results));
        break;
      case SpeechRecognitionState.processing:
        emit(SpeechToTextProcessing(currentText: _currentText, results: _results));
        break;
      case SpeechRecognitionState.error:
        emit(const SpeechToTextError(message: 'Speech recognition error occurred'));
        break;
    }
  }

  void _onSpeechRecognitionSoundLevelChanged(SpeechRecognitionSoundLevelChanged event, Emitter<SpeechToTextState> emit) {
    _soundLevel = event.soundLevel;

    if (_currentRecognitionState.isListening && state is SpeechToTextListening) {
      emit((state as SpeechToTextListening).copyWith(soundLevel: _soundLevel));
    }
  }

  @override
  Future<void> close() async {
    await _recognitionResultsSubscription?.cancel();
    await _stateChangesSubscription?.cancel();
    await _soundLevelSubscription?.cancel();
    await repository.dispose();
    return super.close();
  }
}
