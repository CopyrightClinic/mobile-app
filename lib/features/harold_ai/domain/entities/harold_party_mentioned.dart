import 'package:equatable/equatable.dart';

class HaroldPartyMentioned extends Equatable {
  final String name;
  final String kind;

  const HaroldPartyMentioned({required this.name, required this.kind});

  @override
  List<Object?> get props => [name, kind];
}

