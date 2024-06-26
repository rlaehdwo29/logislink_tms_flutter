
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'user_rpa_model.g.dart';

@JsonSerializable()
class UserRpaModel extends ResultModel {

  String? link24Id;
  String? link24Pass;
  String? man24Id;
  String? man24Pass;
  String? one24Id;
  String? one24Pass;

  UserRpaModel({
    this.link24Id,
    this.link24Pass,
    this.man24Id,
    this.man24Pass,
    this.one24Id,
    this.one24Pass
  });

  factory UserRpaModel.fromJSON(Map<String,dynamic> json) => _$UserRpaModelFromJson(json);

  Map<String,dynamic> toJson() => _$UserRpaModelToJson(this);

}