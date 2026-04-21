import 'package:json_annotation/json_annotation.dart';

part 'book_session_request_model.g.dart';

@JsonSerializable()
class BookSessionSlotModel {
  final String start;
  final String end;

  const BookSessionSlotModel({required this.start, required this.end});

  factory BookSessionSlotModel.fromJson(Map<String, dynamic> json) =>
      _$BookSessionSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionSlotModelToJson(this);
}

@JsonSerializable()
class BookSessionRequestModel {
  final String stripePaymentMethodId;
  final String? couponCode;
  final String date;
  final BookSessionSlotModel slot;
  final String summary;
  @JsonKey(includeIfNull: false)
  final String? eligibilityCategory;
  @JsonKey(includeIfNull: false)
  final String? eligibilitySummary;
  @JsonKey(includeIfNull: false)
  final bool? eligibilityIsLegitimate;

  const BookSessionRequestModel({
    required this.stripePaymentMethodId,
    this.couponCode,
    required this.date,
    required this.slot,
    required this.summary,
    this.eligibilityCategory,
    this.eligibilitySummary,
    this.eligibilityIsLegitimate,
  });

  factory BookSessionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BookSessionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookSessionRequestModelToJson(this);
}
