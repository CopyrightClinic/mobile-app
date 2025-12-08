import '../../domain/entities/paginated_sessions_entity.dart';
import 'session_model.dart';
import 'session_availability_model.dart';

class PaginatedSessionsModel {
  final List<SessionModel> sessions;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final SessionFeeModel? sessionFee;

  const PaginatedSessionsModel({
    required this.sessions,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.sessionFee,
  });

  factory PaginatedSessionsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    final sessionFeeJson = json['session_fee'] as Map<String, dynamic>?;

    return PaginatedSessionsModel(
      sessions: data.map((sessionJson) => SessionModel.fromJson(sessionJson as Map<String, dynamic>)).toList(),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
      totalPages: meta['totalPages'] as int,
      sessionFee: sessionFeeJson != null ? SessionFeeModel.fromJson(sessionFeeJson) : null,
    );
  }

  PaginatedSessionsEntity toEntity() {
    return PaginatedSessionsEntity(
      sessions: sessions.map((session) => session.toEntity(sharedSessionFee: sessionFee)).toList(),
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      sessionFee: sessionFee?.toEntity(),
    );
  }
}
