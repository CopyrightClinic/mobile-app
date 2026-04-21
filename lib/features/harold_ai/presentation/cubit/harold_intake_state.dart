import 'package:equatable/equatable.dart';

import '../../domain/entities/harold_intake_result.dart';

enum HaroldIntakeQuestionType { singleChoice, text }

class HaroldIntakeOption extends Equatable {
  final String id;
  final String labelKey;

  const HaroldIntakeOption({required this.id, required this.labelKey});

  @override
  List<Object?> get props => [id, labelKey];
}

class HaroldIntakeStep extends Equatable {
  final String id;
  final String promptKey;
  final HaroldIntakeQuestionType type;
  final List<HaroldIntakeOption> options;
  final bool allowNotSure;

  const HaroldIntakeStep({
    required this.id,
    required this.promptKey,
    required this.type,
    this.options = const [],
    this.allowNotSure = false,
  });

  @override
  List<Object?> get props => [id, promptKey, type, options, allowNotSure];
}

class HaroldIntakeState extends Equatable {
  final List<HaroldIntakeStep> steps;
  final int currentIndex;
  final Map<String, String> answersById;
  final bool isTerminated;
  final String? terminationMessageKey;
  final bool isComplete;
  final HaroldIntakeResult? result;

  const HaroldIntakeState({
    required this.steps,
    required this.currentIndex,
    required this.answersById,
    required this.isTerminated,
    required this.terminationMessageKey,
    required this.isComplete,
    required this.result,
  });

  factory HaroldIntakeState.initial() {
    return const HaroldIntakeState(
      steps: [],
      currentIndex: 0,
      answersById: {},
      isTerminated: false,
      terminationMessageKey: null,
      isComplete: false,
      result: null,
    );
  }

  HaroldIntakeState copyWith({
    List<HaroldIntakeStep>? steps,
    int? currentIndex,
    Map<String, String>? answersById,
    bool? isTerminated,
    String? terminationMessageKey,
    bool? isComplete,
    HaroldIntakeResult? result,
  }) {
    return HaroldIntakeState(
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      answersById: answersById ?? this.answersById,
      isTerminated: isTerminated ?? this.isTerminated,
      terminationMessageKey: terminationMessageKey ?? this.terminationMessageKey,
      isComplete: isComplete ?? this.isComplete,
      result: result ?? this.result,
    );
  }

  HaroldIntakeStep? get currentStep => currentIndex >= 0 && currentIndex < steps.length ? steps[currentIndex] : null;

  String? answerFor(String stepId) => answersById[stepId];

  @override
  List<Object?> get props => [steps, currentIndex, answersById, isTerminated, terminationMessageKey, isComplete, result];
}

