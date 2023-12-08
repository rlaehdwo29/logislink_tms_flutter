// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
      boardSeq: json['boardSeq'] as int?,
      custId: json['custId'] as String?,
      readCnt: json['readCnt'] as String?,
      userName: json['userName'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      regdate: json['regdate'] as String?,
      regid: json['regid'] as String?,
      attachCnt: json['attachCnt'] as int?,
    );

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'boardSeq': instance.boardSeq,
      'custId': instance.custId,
      'readCnt': instance.readCnt,
      'userName': instance.userName,
      'title': instance.title,
      'content': instance.content,
      'regdate': instance.regdate,
      'regid': instance.regid,
      'attachCnt': instance.attachCnt,
    };
