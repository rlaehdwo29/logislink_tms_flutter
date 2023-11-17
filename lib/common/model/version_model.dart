import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'version_model.g.dart';

@JsonSerializable()
class VersionModel extends ResultModel {
  String? versionKind;
  String? versionCode;
  String? updateCode;
  String? memo;

  VersionModel({
    this.versionKind,
    this.versionCode,
    this.updateCode,
    this.memo
});

  factory VersionModel.fromJSON(Map<String,dynamic> json) => _$VersionModelFromJson(json);

  Map<String,dynamic> toJson() => _$VersionModelToJson(this);

}