// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointModel _$PointModelFromJson(Map<String, dynamic> json) => PointModel(
      number: json['number'] as int?,
      pCode: json['pCode'] as String?,
      custId: json['custId'] as String?,
      ptypeCD: json['ptypeCD'] as String?,
      pointType: json['pointType'] as String?,
      pointData: json['pointData'] as String?,
      point: json['point'] as int?,
      pointDate: json['pointDate'] as String?,
      pointInfo: json['pointInfo'] as String?,
      pointUseChk: json['pointUseChk'] as String?,
    );

Map<String, dynamic> _$PointModelToJson(PointModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'pCode': instance.pCode,
      'custId': instance.custId,
      'ptypeCD': instance.ptypeCD,
      'pointType': instance.pointType,
      'pointData': instance.pointData,
      'point': instance.point,
      'pointDate': instance.pointDate,
      'pointInfo': instance.pointInfo,
      'pointUseChk': instance.pointUseChk,
    };
