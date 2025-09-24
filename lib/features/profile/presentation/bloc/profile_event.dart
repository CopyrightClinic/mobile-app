import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileRequested extends ProfileEvent {
  final String name;
  final String phoneNumber;
  final String address;

  const UpdateProfileRequested({required this.name, required this.phoneNumber, required this.address});

  @override
  List<Object?> get props => [name, phoneNumber, address];
}

class GetProfileRequested extends ProfileEvent {
  const GetProfileRequested();
}
