// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionAvailabilityModel _$SessionAvailabilityModelFromJson(
  Map<String, dynamic> json,
) => SessionAvailabilityModel(
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  slotMinutes: (json['slot_minutes'] as num).toInt(),
  days:
      (json['days'] as List<dynamic>)
          .map((e) => AvailabilityDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SessionAvailabilityModelToJson(
  SessionAvailabilityModel instance,
) => <String, dynamic>{
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'slot_minutes': instance.slotMinutes,
  'days': instance.days,
};

AvailabilityDayModel _$AvailabilityDayModelFromJson(
  Map<String, dynamic> json,
) => AvailabilityDayModel(
  date: json['date'] as String,
  weekday: json['weekday'] as String,
  slots:
      (json['slots'] as List<dynamic>)
          .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AvailabilityDayModelToJson(
  AvailabilityDayModel instance,
) => <String, dynamic>{
  'date': instance.date,
  'weekday': instance.weekday,
  'slots': instance.slots,
};

TimeSlotModel _$TimeSlotModelFromJson(Map<String, dynamic> json) =>
    TimeSlotModel(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$TimeSlotModelToJson(TimeSlotModel instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};
