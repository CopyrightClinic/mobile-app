import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';
import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

double? _ratingFromJson(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

dynamic _ratingToJson(double? value) => value;

@JsonSerializable()
class AttorneyModel {
  final String id;
  final String? name;
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
  @JsonKey(fromJson: _ratingFromJson, toJson: _ratingToJson)
  final double? rating;
  final String? review;
  @JsonKey(name: 'cancelTime')
  final String? cancelTime;
  @JsonKey(name: 'cancelTimeExpired')
  final bool? cancelTimeExpired;
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
    this.cancelTime,
    this.cancelTimeExpired,
    required this.attorney,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  SessionEntity toEntity() {
    final holdAmount = 50.0;
    final canCancel =
        cancelTimeExpired != null
            ? !cancelTimeExpired!
            : (status == 'upcoming' && DateTime.parse('${scheduledDate}T$startTime').difference(DateTime.now()).inHours > 24);

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
      cancelTime: cancelTime,
      cancelTimeExpired: cancelTimeExpired,
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
      cancelTime: null,
      cancelTimeExpired: !entity.canCancel,
      attorney: AttorneyModel(id: entity.attorney.id, name: entity.attorney.name, email: entity.attorney.email),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
