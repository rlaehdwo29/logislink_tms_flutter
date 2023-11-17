import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends ResultModel{

  String? custId;
  String? deptId;
  String? sellBuySctn;
  String? custName;
  String? telnum;
  String? mobile;
  String? itemCode;
  String? custMemo;
  String? orderMemo;
  String? deptName;
  String? bizName;
  String? bizNum;
  String? ceo;
  String? bizAddr;
  String? bizAddrDetail;
  String? custMngName;
  String? custMngMemo;

  CustomerModel({
    this.custId,
    this.deptId,
    this.sellBuySctn,
    this.custName,
    this.telnum,
    this.mobile,
    this.itemCode,
    this.custMemo,
    this.orderMemo,
    this.deptName,
    this.bizName,
    this.bizNum,
    this.ceo,
    this.bizAddr,
    this.bizAddrDetail,
    this.custMngName,
    this.custMngMemo
  });

  factory CustomerModel.fromJSON(Map<String,dynamic> json) => _$CustomerModelFromJson(json);

  Map<String,dynamic> toJson() => _$CustomerModelToJson(this);

}