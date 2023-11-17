// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpa_flag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpaFlagModel _$RpaFlagModelFromJson(Map<String, dynamic> json) => RpaFlagModel(
      linkCd: json['linkCd'] as String?,
      linkFlag: json['linkFlag'] as String?,
    )
      ..status = json['status'] as String?
      ..message = json['message'] as String?
      ..path = json['path'] as String?
      ..resultMap = json['resultMap'] as Map<String, dynamic>?;

Map<String, dynamic> _$RpaFlagModelToJson(RpaFlagModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'path': instance.path,
      'resultMap': instance.resultMap,
      'linkCd': instance.linkCd,
      'linkFlag': instance.linkFlag,
    };
