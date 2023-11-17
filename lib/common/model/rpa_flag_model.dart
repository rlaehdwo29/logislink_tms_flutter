import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
part 'rpa_flag_model.g.dart';

@JsonSerializable()
class RpaFlagModel extends ReturnMap {

  String? linkCd;
  String? linkFlag;

  RpaFlagModel({
    this.linkCd,
    this.linkFlag
  });

  factory RpaFlagModel.fromJSON(Map<String,dynamic> json) => _$RpaFlagModelFromJson(json);

  Map<String,dynamic> toJson() => _$RpaFlagModelToJson(this);

}