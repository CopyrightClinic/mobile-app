import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthResult extends Equatable {
  final UserEntity user;
  final String message;

  const AuthResult({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}
