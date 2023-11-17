// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_agree_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermsAgreeModel _$TermsAgreeModelFromJson(Map<String, dynamic> json) =>
    TermsAgreeModel(
      json['tel'] as String?,
      json['userId'] as String?,
      json['necessary'] as String?,
      json['selective'] as String?,
      json['agreeDate'] as String?,
      json['version'] as String?,
    );

Map<String, dynamic> _$TermsAgreeModelToJson(TermsAgreeModel instance) =>
    <String, dynamic>{
      'tel': instance.tel,
      'userId': instance.userId,
      'necessary': instance.necessary,
      'selective': instance.selective,
      'agreeDate': instance.agreeDate,
      'version': instance.version,
    };
