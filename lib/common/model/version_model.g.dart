// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionModel _$VersionModelFromJson(Map<String, dynamic> json) => VersionModel(
      versionKind: json['versionKind'] as String?,
      versionCode: json['versionCode'] as String?,
      updateCode: json['updateCode'] as String?,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$VersionModelToJson(VersionModel instance) =>
    <String, dynamic>{
      'versionKind': instance.versionKind,
      'versionCode': instance.versionCode,
      'updateCode': instance.updateCode,
      'memo': instance.memo,
    };
