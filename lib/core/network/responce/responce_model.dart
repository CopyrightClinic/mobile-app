// ignore_for_file: library_private_types_in_public_api, lines_longer_than_80_chars
import '../../utils/typedefs/type_defs.dart';

class ResponseModel<T> {
  final T data;

  const ResponseModel({required this.data});

  factory ResponseModel.fromJson(JSON json) {
    return ResponseModel(data: json as T);
  }
}

// For backward compatibility, you can still use this if needed
class LegacyResponseModel<T> {
  final _ResponseHeadersModel headers;
  final T body;

  const LegacyResponseModel({required this.headers, required this.body});

  factory LegacyResponseModel.fromJson(JSON json) {
    return LegacyResponseModel(headers: _ResponseHeadersModel.fromJson(json['headers'] as JSON), body: json['body'] as T);
  }
}

class _ResponseHeadersModel {
  final bool error;
  final String message;
  final String? code;

  const _ResponseHeadersModel({required this.error, required this.message, this.code});

  factory _ResponseHeadersModel.fromJson(JSON json) {
    return _ResponseHeadersModel(error: json['error'], message: json['message'] as String, code: json['code'] as String?);
  }
}
