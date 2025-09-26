import 'package:json_annotation/json_annotation.dart';

part 'book_session_request_model.g.dart';

@JsonSerializable()
class BookSessionSlotModel {
  final String start;
  final String end;

  const BookSessionSlotModel({required this.start, required this.end});

  factory BookSessionSlotModel.fromJson(Map<String, dynamic> json) => _$BookSessionSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionSlotModelToJson(this);
}

@JsonSerializable()
class BookSessionRequestModel {
  final String stripePaymentMethodId;
  final String date;
  final BookSessionSlotModel slot;
  final String summary;

  const BookSessionRequestModel({required this.stripePaymentMethodId, required this.date, required this.slot, required this.summary});

  factory BookSessionRequestModel.fromJson(Map<String, dynamic> json) => _$BookSessionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionRequestModelToJson(this);
}
