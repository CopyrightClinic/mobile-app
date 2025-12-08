import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({required this.id, this.name, required this.email, this.phoneNumber, this.address, this.createdAt, this.updatedAt});

  @override
  List<Object?> get props => [id, name, email, phoneNumber, address, createdAt, updatedAt];
}
