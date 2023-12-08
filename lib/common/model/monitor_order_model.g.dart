// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitorOrderModel _$MonitorOrderModelFromJson(Map<String, dynamic> json) =>
    MonitorOrderModel(
      allocCnt: json['allocCnt'] as int?,
      preOrder: json['preOrder'] as int?,
      todayOrder: json['todayOrder'] as int?,
      todayFinish: json['todayFinish'] as int?,
      tomorrowFinish: json['tomorrowFinish'] as int?,
      allocDelay: json['allocDelay'] as int?,
      enterDelay: json['enterDelay'] as int?,
      finishDelay: json['finishDelay'] as int?,
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
