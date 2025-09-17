import '../../../../core/utils/typedefs/type_defs.dart';

class HaroldEvaluateRequestModel {
  final String query;

  const HaroldEvaluateRequestModel({required this.query});

  JSON toJson() {
    return {'query': query};
  }

  factory HaroldEvaluateRequestModel.fromJson(JSON json) {
    return HaroldEvaluateRequestModel(query: json['query'] as String);
  }

  @override
  String toString() {
    return 'HaroldEvaluateRequestModel(query: $query)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HaroldEvaluateRequestModel && other.query == query;
  }

  @override
  int get hashCode => query.hashCode;
}
