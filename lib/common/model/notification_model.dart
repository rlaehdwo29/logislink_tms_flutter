
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel extends ResultModel {

  String? msgSeq;
  String? orderId;
  String? allocId;
  String? title;
  String? contents;
  String? sendDate;

  NotificationModel({
    this.msgSeq,
    this.orderId,
    this.allocId,
    this.title,
    this.contents,
    this.sendDate
  });

  factory NotificationModel.fromJSON(Map<String,dynamic> json) => _$NotificationModelFromJson(json);

  Map<String,dynamic> toJson() => _$NotificationModelToJson(this);

}
