
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'addr_model.g.dart';

@JsonSerializable()
class AddrModel extends ResultModel {

  int? addrSeq;
  String? addrName;
  String? addr;
  String? addrDetail;
  String? lat;
  String? lon;
  String? staffName;
  String? staffTel;
  String? orderMemo;
  String? sido;
  String? gungu;
  String? dong;
  String? goodsWeight;
  String? weightUnitCode;
  String? goodsQty;
  String? qtyUnitCode;
  String? qtyUnitName;
  String? goodsName;

  AddrModel({
    this.addrSeq,
    this.addrName,
    this.addr,
    this.addrDetail,
    this.lat,
    this.lon,
    this.staffName,
    this.staffTel,
    this.orderMemo,
    this.sido,
    this.gungu,
    this.dong,
    this.goodsWeight,
    this.weightUnitCode,
    this.goodsQty,
    this.qtyUnitCode,
    this.qtyUnitName,
    this.goodsName
  });

  factory AddrModel.fromJSON(Map<String,dynamic> json) => _$AddrModelFromJson(json);

  Map<String,dynamic> toJson() => _$AddrModelToJson(this);

}
