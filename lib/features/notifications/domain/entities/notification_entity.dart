import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/api/notifications_enums.dart';
import '../../data/models/notification_data_model.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String? recipientId;
  final String recipientRole;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationDataModel? data;
  final bool isRead;
  final bool isCleared;
  final List<String> channels;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    this.recipientId,
    required this.recipientRole,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.isRead,
    required this.isCleared,
    required this.channels,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? recipientRole,
    String? title,
    String? body,
    NotificationType? type,
    NotificationDataModel? data,
    bool? isRead,
    bool? isCleared,
    List<String>? channels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientRole: recipientRole ?? this.recipientRole,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isCleared: isCleared ?? this.isCleared,
      channels: channels ?? this.channels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, recipientId, recipientRole, title, body, type, data, isRead, isCleared, channels, createdAt, updatedAt];
}
