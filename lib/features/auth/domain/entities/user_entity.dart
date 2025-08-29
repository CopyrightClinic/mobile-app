import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role;
  final String status;
  final int? totalSessions;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.role,
    required this.status,
    this.totalSessions,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber, address, role, status, totalSessions, isVerified, createdAt, updatedAt];
}
