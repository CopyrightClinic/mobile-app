import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session_availability_entity.dart';

part 'session_availability_model.g.dart';

@JsonSerializable()
class SessionAvailabilityModel {
  @JsonKey(name: 'start_date')
  final String startDate;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'slot_minutes')
  final int slotMinutes;

  final List<AvailabilityDayModel> days;

  @JsonKey(name: 'session_fee')
  final SessionFeeModel fee;

  const SessionAvailabilityModel({required this.startDate, required this.endDate, required this.slotMinutes, required this.days, required this.fee});

  factory SessionAvailabilityModel.fromJson(Map<String, dynamic> json) => _$SessionAvailabilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionAvailabilityModelToJson(this);

  SessionAvailabilityEntity toEntity() {
    return SessionAvailabilityEntity(
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      slotMinutes: slotMinutes,
      days: days.map((day) => day.toEntity()).toList(),
      fee: fee.toEntity(),
    );
  }
}

@JsonSerializable()
class AvailabilityDayModel {
  final String date;
  final String weekday;
  final List<TimeSlotModel> slots;

  const AvailabilityDayModel({required this.date, required this.weekday, required this.slots});

  factory AvailabilityDayModel.fromJson(Map<String, dynamic> json) => _$AvailabilityDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityDayModelToJson(this);

  AvailabilityDayEntity toEntity() {
    return AvailabilityDayEntity(date: DateTime.parse(date), weekday: weekday, slots: slots.map((slot) => slot.toEntity()).toList());
  }
}

@JsonSerializable()
class TimeSlotModel {
  final String start;
  final String end;

  const TimeSlotModel({required this.start, required this.end});

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) => _$TimeSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotModelToJson(this);

  TimeSlotEntity toEntity() {
    return TimeSlotEntity(start: DateTime.parse(start), end: DateTime.parse(end));
  }
}

@JsonSerializable()
class SessionFeeModel {
  @JsonKey(name: 'sessionFee')
  final num sessionFee;

  @JsonKey(name: 'processingFee')
  final num processingFee;

  @JsonKey(name: 'totalFee')
  final num totalFee;

  final String currency;

  const SessionFeeModel({required this.sessionFee, required this.processingFee, required this.totalFee, required this.currency});

  factory SessionFeeModel.fromJson(Map<String, dynamic> json) => _$SessionFeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionFeeModelToJson(this);

  SessionFeeEntity toEntity() {
    return SessionFeeEntity(sessionFee: sessionFee, processingFee: processingFee, totalFee: totalFee, currency: currency);
  }
}
