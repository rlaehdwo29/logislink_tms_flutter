// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitorOrderModel _$MonitorOrderModelFromJson(Map<String, dynamic> json) =>
    MonitorOrderModel(
      allocCnt: (json['allocCnt'] as num?)?.toInt(),
      preOrder: (json['preOrder'] as num?)?.toInt(),
      todayOrder: (json['todayOrder'] as num?)?.toInt(),
      todayFinish: (json['todayFinish'] as num?)?.toInt(),
      tomorrowFinish: (json['tomorrowFinish'] as num?)?.toInt(),
      allocDelay: (json['allocDelay'] as num?)?.toInt(),
      enterDelay: (json['enterDelay'] as num?)?.toInt(),
      finishDelay: (json['finishDelay'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MonitorOrderModelToJson(MonitorOrderModel instance) =>
    <String, dynamic>{
      'allocCnt': instance.allocCnt,
      'preOrder': instance.preOrder,
      'todayOrder': instance.todayOrder,
      'todayFinish': instance.todayFinish,
      'tomorrowFinish': instance.tomorrowFinish,
      'allocDelay': instance.allocDelay,
      'enterDelay': instance.enterDelay,
      'finishDelay': instance.finishDelay,
    };
