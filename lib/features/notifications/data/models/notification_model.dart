import '../../../../core/utils/enumns/api/notifications_enums.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_data_model.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    super.recipientId,
    required super.recipientRole,
    required super.title,
    required super.body,
    required super.type,
    super.data,
    required super.isRead,
    required super.isCleared,
    required super.channels,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = NotificationType.fromString(json['type'] as String);
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String?,
      recipientRole: json['recipientRole'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: type,
      data: NotificationDataModel.fromJson(json['data'] as Map<String, dynamic>?, type),
      isRead: json['isRead'] as bool,
      isCleared: json['isCleared'] as bool,
      channels: (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'recipientRole': recipientRole,
      'title': title,
      'body': body,
      'type': type.toApiString(),
      'data': data?.toJson(),
      'isRead': isRead,
      'isCleared': isCleared,
      'channels': channels,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      recipientRole: entity.recipientRole,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      data: entity.data,
      isRead: entity.isRead,
      isCleared: entity.isCleared,
      channels: entity.channels,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      recipientRole: recipientRole,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead,
      isCleared: isCleared,
      channels: channels,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
