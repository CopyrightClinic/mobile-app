import 'package:equatable/equatable.dart';
import 'session_entity.dart';

class PaginatedSessionsEntity extends Equatable {
  final List<SessionEntity> sessions;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedSessionsEntity({required this.sessions, required this.total, required this.page, required this.limit, required this.totalPages});

  bool get hasMore => page < totalPages;

  @override
  List<Object> get props => [sessions, total, page, limit, totalPages];
}

