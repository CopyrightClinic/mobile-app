// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookSessionCardModel _$BookSessionCardModelFromJson(
  Map<String, dynamic> json,
) => BookSessionCardModel(
  brand: json['brand'] as String,
  last4: json['last4'] as String,
  expMonth: (json['expMonth'] as num).toInt(),
  expYear: (json['expYear'] as num).toInt(),
);

Map<String, dynamic> _$BookSessionCardModelToJson(
  BookSessionCardModel instance,
) => <String, dynamic>{
  'brand': instance.brand,
  'last4': instance.last4,
  'expMonth': instance.expMonth,
  'expYear': instance.expYear,
};

BookSessionPaymentMethodModel _$BookSessionPaymentMethodModelFromJson(
  Map<String, dynamic> json,
) => BookSessionPaymentMethodModel(
  id: json['id'] as String,
  type: json['type'] as String,
  card: BookSessionCardModel.fromJson(json['card'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookSessionPaymentMethodModelToJson(
  BookSessionPaymentMethodModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'card': instance.card,
};

BookSessionRequestEntityModel _$BookSessionRequestEntityModelFromJson(
  Map<String, dynamic> json,
) => BookSessionRequestEntityModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  requestedDate: json['requestedDate'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  status: json['status'] as String,
  acceptedBy: json['acceptedBy'] as String?,
  expiresAt: json['expiresAt'] as String,
  paymentMethod:
      json['paymentMethod'] == null
          ? null
          : BookSessionPaymentMethodModel.fromJson(
            json['paymentMethod'] as Map<String, dynamic>,
          ),
  summary: json['summary'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$BookSessionRequestEntityModelToJson(
  BookSessionRequestEntityModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'requestedDate': instance.requestedDate,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'acceptedBy': instance.acceptedBy,
  'expiresAt': instance.expiresAt,
  'paymentMethod': instance.paymentMethod,
  'summary': instance.summary,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

BookSessionAvailableAttorneyModel _$BookSessionAvailableAttorneyModelFromJson(
  Map<String, dynamic> json,
) => BookSessionAvailableAttorneyModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$BookSessionAvailableAttorneyModelToJson(
  BookSessionAvailableAttorneyModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

BookSessionDataModel _$BookSessionDataModelFromJson(
  Map<String, dynamic> json,
) => BookSessionDataModel(
  sessionRequest: BookSessionRequestEntityModel.fromJson(
    json['sessionRequest'] as Map<String, dynamic>,
  ),
  availableAttorneys:
      (json['availableAttorneys'] as List<dynamic>)
          .map(
            (e) => BookSessionAvailableAttorneyModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
);

Map<String, dynamic> _$BookSessionDataModelToJson(
  BookSessionDataModel instance,
) => <String, dynamic>{
  'sessionRequest': instance.sessionRequest,
  'availableAttorneys': instance.availableAttorneys,
};

BookSessionResponseModel _$BookSessionResponseModelFromJson(
  Map<String, dynamic> json,
) => BookSessionResponseModel(
  message: json['message'] as String,
  data: BookSessionDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookSessionResponseModelToJson(
  BookSessionResponseModel instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};
