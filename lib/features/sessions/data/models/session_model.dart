import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';
import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

@JsonSerializable()
class AttorneyModel {
  final String id;
  final String name;
  final String email;

  const AttorneyModel({required this.id, required this.name, required this.email});

  factory AttorneyModel.fromJson(Map<String, dynamic> json) => _$AttorneyModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttorneyModelToJson(this);

  AttorneyEntity toEntity() {
    return AttorneyEntity(id: id, name: name, email: email);
  }
}

@JsonSerializable()
class SessionModel {
  final String id;
  @JsonKey(name: 'scheduledDate')
  final String scheduledDate;
  @JsonKey(name: 'startTime')
  final String startTime;
  @JsonKey(name: 'endTime')
  final String endTime;
  @JsonKey(name: 'durationMinutes')
  final int durationMinutes;
  final String status;
  final String? summary;
  final double? rating;
  final String? review;
  final AttorneyModel attorney;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const SessionModel({
    required this.id,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.summary,
    this.rating,
    this.review,
    required this.attorney,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  SessionEntity toEntity() {
    final holdAmount = 50.0;
    final canCancel = status == 'upcoming' && DateTime.parse('${scheduledDate}T$startTime').difference(DateTime.now()).inHours > 24;

    return SessionEntity(
      id: id,
      scheduledDate: scheduledDate,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      status: SessionStatus.fromString(status),
      summary: summary,
      rating: rating,
      review: review,
      attorney: attorney.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      holdAmount: holdAmount,
      canCancel: canCancel,
    );
  }

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      scheduledDate: entity.scheduledDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      durationMinutes: entity.durationMinutes,
      status: entity.status.apiValue,
      summary: entity.summary,
      rating: entity.rating,
      review: entity.review,
      attorney: AttorneyModel(id: entity.attorney.id, name: entity.attorney.name, email: entity.attorney.email),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
