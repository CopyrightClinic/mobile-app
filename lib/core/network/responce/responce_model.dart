// ignore_for_file: library_private_types_in_public_api, lines_longer_than_80_chars
import '../../utils/typedefs/type_defs.dart';

class ResponseModel<T> {
  final T data;

  const ResponseModel({required this.data});

  factory ResponseModel.fromJson(JSON json) {
    return ResponseModel(data: json as T);
  }
}
