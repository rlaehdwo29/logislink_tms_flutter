// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      msgSeq: json['msgSeq'] as String?,
      orderId: json['orderId'] as String?,
      allocId: json['allocId'] as String?,
      title: json['title'] as String?,
      contents: json['contents'] as String?,
      sendDate: json['sendDate'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'msgSeq': instance.msgSeq,
      'orderId': instance.orderId,
      'allocId': instance.allocId,
      'title': instance.title,
      'contents': instance.contents,
      'sendDate': instance.sendDate,
    };
