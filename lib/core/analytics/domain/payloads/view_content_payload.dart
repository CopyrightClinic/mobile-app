import 'package:equatable/equatable.dart';

import '../view_content_subject.dart';

final class ViewContentPayload extends Equatable {
  final ViewContentSubject subject;
  final String contentId;
  final String? contentName;
  final String? contentCategory;
  final Map<String, String> attributes;

  const ViewContentPayload({
    required this.subject,
    required this.contentId,
    this.contentName,
    this.contentCategory,
    this.attributes = const {},
  });

  @override
  List<Object?> get props => [
    subject,
    contentId,
    contentName,
    contentCategory,
    attributes,
  ];
}
