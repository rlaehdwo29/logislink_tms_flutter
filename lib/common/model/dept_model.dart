
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'dept_model.g.dart';

@JsonSerializable()
class DeptModel extends ResultModel {

  String? deptId;
  String? deptName;

  DeptModel({
    this.deptId,
    this.deptName
  });

  factory DeptModel.fromJSON(Map<String,dynamic> json) => _$DeptModelFromJson(json);

  Map<String,dynamic> toJson() => _$DeptModelToJson(this);

}
