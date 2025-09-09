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
  final String? stripeCustomerId;
  final DateTime? createdAt;
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
    this.stripeCustomerId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber, address, role, status, totalSessions, stripeCustomerId, createdAt, updatedAt];
}
