import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';
import '../../../../core/utils/enumns/ui/summary_approval_status.dart';
import '../../domain/entities/session_details_entity.dart';

part 'session_details_model.g.dart';

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
class SessionDetailsAttorneyModel {
  final String id;
  final String? name;
  final String email;
  final String? profileUrl;

  const SessionDetailsAttorneyModel({required this.id, required this.name, required this.email, this.profileUrl});

  factory SessionDetailsAttorneyModel.fromJson(Map<String, dynamic> json) => _$SessionDetailsAttorneyModelFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDetailsAttorneyModelToJson(this);

  SessionDetailsAttorneyEntity toEntity() {
    return SessionDetailsAttorneyEntity(id: id, name: name, email: email, profileUrl: profileUrl);
  }
}

@JsonSerializable()
class SessionDetailsUserModel {
  final String id;
  final String name;
  final String email;

  const SessionDetailsUserModel({required this.id, required this.name, required this.email});

  factory SessionDetailsUserModel.fromJson(Map<String, dynamic> json) => _$SessionDetailsUserModelFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDetailsUserModelToJson(this);

  SessionDetailsUserEntity toEntity() {
    return SessionDetailsUserEntity(id: id, name: name, email: email);
  }
}

@JsonSerializable()
class SessionRequestModel {
  final String id;
  final String summary;

  const SessionRequestModel({required this.id, required this.summary});

  factory SessionRequestModel.fromJson(Map<String, dynamic> json) => _$SessionRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$SessionRequestModelToJson(this);

  SessionRequestEntity toEntity() {
    return SessionRequestEntity(id: id, summary: summary);
  }
}

@JsonSerializable()
class SessionDetailsModel {
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
  @JsonKey(name: 'summaryLocked')
  final bool summaryLocked;
  @JsonKey(name: 'summaryApprovalStatus')
  final String? summaryApprovalStatus;
  @JsonKey(fromJson: _ratingFromJson, toJson: _ratingToJson)
  final double? rating;
  final String? review;
  @JsonKey(name: 'cancelTime')
  final String? cancelTime;
  @JsonKey(name: 'cancelTimeExpired')
  final bool? cancelTimeExpired;
  final SessionDetailsAttorneyModel attorney;
  final SessionDetailsUserModel user;
  @JsonKey(name: 'sessionRequest')
  final SessionRequestModel sessionRequest;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const SessionDetailsModel({
    required this.id,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.summary,
    required this.summaryLocked,
    this.summaryApprovalStatus,
    this.rating,
    this.review,
    this.cancelTime,
    this.cancelTimeExpired,
    required this.attorney,
    required this.user,
    required this.sessionRequest,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionDetailsModel.fromJson(Map<String, dynamic> json) => _$SessionDetailsModelFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDetailsModelToJson(this);

  SessionDetailsEntity toEntity() {
    final holdAmount = 50.0;
    final canCancel =
        cancelTimeExpired != null
            ? !cancelTimeExpired!
            : (status == 'upcoming' && DateTime.parse('${scheduledDate}T$startTime').difference(DateTime.now()).inHours > 24);

    return SessionDetailsEntity(
      id: id,
      scheduledDate: scheduledDate,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      status: SessionStatus.fromString(status),
      summary: summary,
      summaryLocked: summaryLocked,
      summaryApprovalStatus: summaryApprovalStatus != null ? SummaryApprovalStatus.fromString(summaryApprovalStatus!) : null,
      rating: rating,
      review: review,
      cancelTime: cancelTime,
      cancelTimeExpired: cancelTimeExpired,
      attorney: attorney.toEntity(),
      user: user.toEntity(),
      sessionRequest: sessionRequest.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      holdAmount: holdAmount,
      canCancel: canCancel,
    );
  }
}
