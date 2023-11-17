// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultModel _$ResultModelFromJson(Map<String, dynamic> json) => ResultModel(
      result: json['result'] as bool?,
      msg: json['msg'] as String?,
      total: json['total'] as String?,
    );

Map<String, dynamic> _$ResultModelToJson(ResultModel instance) =>
    <String, dynamic>{
      'result': instance.result,
      'msg': instance.msg,
      'total': instance.total,
    };
