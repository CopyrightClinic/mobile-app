// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationListResponseModel _$NotificationListResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationListResponseModel(
  data:
      (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$NotificationListResponseModelToJson(
  NotificationListResponseModel instance,
) => <String, dynamic>{
  'data': instance.data,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
};
