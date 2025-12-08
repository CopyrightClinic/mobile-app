import '../../domain/entities/paginated_sessions_entity.dart';
import 'session_model.dart';

class PaginatedSessionsModel {
  final List<SessionModel> sessions;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedSessionsModel({required this.sessions, required this.total, required this.page, required this.limit, required this.totalPages});

  factory PaginatedSessionsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    return PaginatedSessionsModel(
      sessions: data.map((sessionJson) => SessionModel.fromJson(sessionJson as Map<String, dynamic>)).toList(),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  PaginatedSessionsEntity toEntity() {
    return PaginatedSessionsEntity(
      sessions: sessions.map((session) => session.toEntity()).toList(),
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }
}

