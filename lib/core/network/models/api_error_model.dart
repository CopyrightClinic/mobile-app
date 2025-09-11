import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String message;
  final int statusCode;
  final String error;

  const ApiErrorModel({required this.message, required this.statusCode, required this.error});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) => _$ApiErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);

  factory ApiErrorModel.fromResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return ApiErrorModel(
        message: _extractMessage(responseData['message']),
        statusCode: responseData['statusCode'] as int? ?? 500,
        error: responseData['error'] as String? ?? 'Unknown Error',
      );
    }

    return const ApiErrorModel(message: 'Unknown error occurred', statusCode: 500, error: 'Unknown Error');
  }

  static String _extractMessage(dynamic message) {
    if (message == null) return 'Unknown error occurred';

    if (message is List) {
      return message.join(', ');
    }

    return message.toString();
  }

  @override
  String toString() => 'ApiErrorModel(message: $message, statusCode: $statusCode, error: $error)';
}
