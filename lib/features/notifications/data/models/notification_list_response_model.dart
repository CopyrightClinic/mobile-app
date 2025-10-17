import 'package:json_annotation/json_annotation.dart';
import 'notification_model.dart';

part 'notification_list_response_model.g.dart';

@JsonSerializable()
class NotificationListResponseModel {
  final List<NotificationModel> data;
  final int total;
  final int page;
  final int limit;

  const NotificationListResponseModel({required this.data, required this.total, required this.page, required this.limit});

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) => _$NotificationListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseModelToJson(this);
}

