import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.createdAt,
    super.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      createdAt: entity.createdAt,
      metadata: entity.metadata,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(id: id, title: title, description: description, type: type, createdAt: createdAt, metadata: metadata);
  }
}
