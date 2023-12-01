import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'order_link_current_model.g.dart';

@JsonSerializable()
class OrderLinkCurrentModel extends ResultModel{

  String? procId;
  String? jobStat;
  String? orderId;
  String? linkCd;
  String? linkStat;
  String? allocCharge;
  String? linkId;
  String? rpaMsg;
  String? regDate;
  String? editDate;
  String? allocChargeYn;
  String? allocCd;
  String? refProcId;
  String? allocStatus;
  String? driverName;
  String? driverTel;
  String? carNum;
  String? carTon;
  String? carType;

  OrderLinkCurrentModel({
    this.procId,
    this.jobStat,
    this.orderId,
    this.linkCd,
    this.linkStat,
    this.allocCharge,
    this.linkId,
    this.rpaMsg,
    this.regDate,
    this.editDate,
    this.allocChargeYn,
    this.allocCd,
    this.refProcId,
    this.allocStatus,
    this.driverName,
    this.driverTel,
    this.carNum,
    this.carTon,
    this.carType
  });

  factory OrderLinkCurrentModel.fromJSON(Map<String,dynamic> json) => _$OrderLinkCurrentModelFromJson(json);

  Map<String,dynamic> toJson() => _$OrderLinkCurrentModelToJson(this);

}