import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'unit_charge_model.g.dart';

@JsonSerializable()
class UnitChargeModel extends ResultModel{

  String? unit_charge;
  String? omsUnit_charge;
  String? sePointFlag;
  String? unitCostId;

  UnitChargeModel({this.unit_charge,this.omsUnit_charge,this.sePointFlag,this.unitCostId});

  factory UnitChargeModel.fromJSON(Map<String,dynamic> json) => _$UnitChargeModelFromJson(json);

  Map<String,dynamic> toJson() => _$UnitChargeModelToJson(this);

}