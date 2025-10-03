import 'package:equatable/equatable.dart';

enum NotificationType { sessionSummary, sessionReminder, sessionCancelled, sessionConfirmed, general }

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.metadata,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    NotificationType? type,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, title, description, type, createdAt, metadata];
}
