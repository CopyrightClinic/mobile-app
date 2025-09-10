import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel {
  final String id;
  final String title;
  @JsonKey(name: 'scheduled_date')
  final DateTime scheduledDate;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  final double price;
  final String status;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  const SessionModel({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.price,
    required this.status,
    this.description,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      title: title,
      scheduledDate: scheduledDate,
      duration: Duration(minutes: durationMinutes),
      price: price,
      status: _parseStatus(status),
      description: description,
      createdAt: createdAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
    );
  }

  static SessionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return SessionStatus.upcoming;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.upcoming;
    }
  }

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      title: entity.title,
      scheduledDate: entity.scheduledDate,
      durationMinutes: entity.duration.inMinutes,
      price: entity.price,
      status: entity.status.name,
      description: entity.description,
      createdAt: entity.createdAt,
      cancelledAt: entity.cancelledAt,
      cancellationReason: entity.cancellationReason,
    );
  }
}
