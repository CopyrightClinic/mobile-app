import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/book_session_response_entity.dart';

part 'book_session_response_model.g.dart';

@JsonSerializable()
class BookSessionCardModel {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  const BookSessionCardModel({required this.brand, required this.last4, required this.expMonth, required this.expYear});

  factory BookSessionCardModel.fromJson(Map<String, dynamic> json) => _$BookSessionCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionCardModelToJson(this);

  BookSessionCardEntity toEntity() {
    return BookSessionCardEntity(brand: brand, last4: last4, expMonth: expMonth, expYear: expYear);
  }
}

@JsonSerializable()
class BookSessionPaymentMethodModel {
  final String id;
  final String type;
  final BookSessionCardModel card;

  const BookSessionPaymentMethodModel({required this.id, required this.type, required this.card});

  factory BookSessionPaymentMethodModel.fromJson(Map<String, dynamic> json) => _$BookSessionPaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionPaymentMethodModelToJson(this);

  BookSessionPaymentMethodEntity toEntity() {
    return BookSessionPaymentMethodEntity(id: id, type: type, card: card.toEntity());
  }
}

@JsonSerializable()
class BookSessionRequestEntityModel {
  final String id;
  final String userId;
  final String requestedDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? acceptedBy;
  final String expiresAt;
  final BookSessionPaymentMethodModel? paymentMethod;
  final String? summary;
  final String createdAt;
  final String updatedAt;

  const BookSessionRequestEntityModel({
    required this.id,
    required this.userId,
    required this.requestedDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.acceptedBy,
    required this.expiresAt,
    this.paymentMethod,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookSessionRequestEntityModel.fromJson(Map<String, dynamic> json) => _$BookSessionRequestEntityModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionRequestEntityModelToJson(this);

  BookSessionRequestEntity toEntity() {
    return BookSessionRequestEntity(
      id: id,
      userId: userId,
      requestedDate: requestedDate,
      startTime: startTime,
      endTime: endTime,
      status: status,
      acceptedBy: acceptedBy,
      expiresAt: DateTime.parse(expiresAt),
      paymentMethod: paymentMethod?.toEntity(),
      summary: summary,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

@JsonSerializable()
class BookSessionAvailableAttorneyModel {
  final String id;
  final String name;
  final String email;

  const BookSessionAvailableAttorneyModel({required this.id, required this.name, required this.email});

  factory BookSessionAvailableAttorneyModel.fromJson(Map<String, dynamic> json) => _$BookSessionAvailableAttorneyModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionAvailableAttorneyModelToJson(this);

  BookSessionAvailableAttorneyEntity toEntity() {
    return BookSessionAvailableAttorneyEntity(id: id, name: name, email: email);
  }
}

@JsonSerializable()
class BookSessionDataModel {
  final BookSessionRequestEntityModel sessionRequest;
  final List<BookSessionAvailableAttorneyModel> availableAttorneys;

  const BookSessionDataModel({required this.sessionRequest, required this.availableAttorneys});

  factory BookSessionDataModel.fromJson(Map<String, dynamic> json) => _$BookSessionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionDataModelToJson(this);

  BookSessionDataEntity toEntity() {
    return BookSessionDataEntity(
      sessionRequest: sessionRequest.toEntity(),
      availableAttorneys: availableAttorneys.map((attorney) => attorney.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class BookSessionResponseModel {
  final String message;
  final BookSessionDataModel data;

  const BookSessionResponseModel({required this.message, required this.data});

  factory BookSessionResponseModel.fromJson(Map<String, dynamic> json) => _$BookSessionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionResponseModelToJson(this);

  BookSessionResponseEntity toEntity() {
    return BookSessionResponseEntity(message: message, data: data.toEntity());
  }
}
