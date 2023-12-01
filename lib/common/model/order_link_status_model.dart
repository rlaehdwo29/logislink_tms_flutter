import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'order_link_status_model.g.dart';

@JsonSerializable()
class OrderLinkStatusModel extends ResultModel{

  String? order_id;
  String? orderStateName;
  String? chargeType;
  String? orderCarName;
  String? orderCarTonName;
  String? sDateDay;
  String? sDateTime;
  String? eDateDay;
  String? eDateTime;
  String? driverName;
  String? driverTel;
  String? carNum;
  String? goodsName;
  String? custName;
  String? regdate;
  String? sAddr;
  String? eAddr;
  String? call24Status;
  String? manStatus;
  String? oneCallStatus;

  OrderLinkStatusModel({
    this.order_id,
    this.orderStateName,
    this.chargeType,
    this.orderCarName,
    this.orderCarTonName,
    this.sDateDay,
    this.sDateTime,
    this.eDateDay,
    this.eDateTime,
    this.driverName,
    this.driverTel,
    this.carNum,
    this.goodsName,
    this.custName,
    this.regdate,
    this.sAddr,
    this.eAddr,
    this.call24Status,
    this.manStatus,
    this.oneCallStatus
  });

  factory OrderLinkStatusModel.fromJSON(Map<String,dynamic> json) => _$OrderLinkStatusModelFromJson(json);

  Map<String,dynamic> toJson() => _$OrderLinkStatusModelToJson(this);

}