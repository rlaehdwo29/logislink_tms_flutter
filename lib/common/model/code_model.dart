import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'code_model.g.dart';

@JsonSerializable()
class CodeModel extends ResultModel {

  String? code;
  String? codeName;
  bool? isCheck;

  CodeModel({this.code, this.codeName});

  factory CodeModel.fromJSON(Map<String,dynamic> json) => _$CodeModelFromJson(json);

  Map<String,dynamic> toJson() => _$CodeModelToJson(this);

}