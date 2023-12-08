import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'notice_model.g.dart';

@JsonSerializable()
class NoticeModel extends ResultModel {
  int? boardSeq;
  String? custId;
  String? readCnt;
  String? userName;
  String? title;
  String? content;
  String? regdate;
  String? regid;
  int? attachCnt;

  NoticeModel({
    this.boardSeq,
    this.custId,
    this.readCnt,
    this.userName,
    this.title,
    this.content,
    this.regdate,
    this.regid,
    this.attachCnt
  });

  factory NoticeModel.fromJSON(Map<String,dynamic> json) => _$NoticeModelFromJson(json);

  Map<String,dynamic> toJson() => _$NoticeModelToJson(this);

}