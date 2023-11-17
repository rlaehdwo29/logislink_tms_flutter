import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'sido_area_model.g.dart';

@JsonSerializable()
class SidoAreaModel extends ResultModel{

  String? areaCd;
  String? sido;
  String? sigun;
  String? sidoCd;

  SidoAreaModel({this.areaCd,this.sido,this.sigun,this.sidoCd});

  factory SidoAreaModel.fromJSON(Map<String,dynamic> json) => _$SidoAreaModelFromJson(json);

  Map<String,dynamic> toJson() => _$SidoAreaModelToJson(this);

}