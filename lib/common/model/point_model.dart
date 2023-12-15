
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'point_model.g.dart';

@JsonSerializable()
class PointModel extends ResultModel {

  int? number;
  String? pCode;
  String? custId;
  String? ptypeCD;
  String? pointType;
  String? pointData;
  int? point;
  String? pointDate;
  String? pointInfo;
  String? pointUseChk;

  PointModel({
    this.number,
    this.pCode,
    this.custId,
    this.ptypeCD,
    this.pointType,
    this.pointData,
    this.point,
    this.pointDate,
    this.pointInfo,
    this.pointUseChk
  });

  factory PointModel.fromJSON(Map<String,dynamic> json) => _$PointModelFromJson(json);

  Map<String,dynamic> toJson() => _$PointModelToJson(this);

}
