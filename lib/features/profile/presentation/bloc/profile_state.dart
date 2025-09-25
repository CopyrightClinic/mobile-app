import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateProfileLoading extends ProfileState {}

class UpdateProfileSuccess extends ProfileState {
  final ProfileEntity profile;
  final String message;

  const UpdateProfileSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

class UpdateProfileError extends ProfileState {
  final String message;

  const UpdateProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChangePasswordLoading extends ProfileState {}

class ChangePasswordSuccess extends ProfileState {
  final String message;

  const ChangePasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChangePasswordError extends ProfileState {
  final String message;

  const ChangePasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
