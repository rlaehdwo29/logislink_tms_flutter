import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'cust_user_model.g.dart';

@JsonSerializable()
class CustUserModel extends ResultModel{

  String? custId;
  String? deptId;
  String? userId;
  String? userName;
  String? bizName;
  String? deptName;
  String? telnum;
  String? email;
  String? mobile;
  String? grade;
  String? custTypeCode;
  String? custTypeName;
  String? bizNum;
  String? talkYn;

  CustUserModel({
    this.custId,
    this.deptId,
    this.userId,
    this.userName,
    this.bizName,
    this.telnum,
    this.email,
    this.mobile,
    this.grade,
    this.custTypeCode,
    this.custTypeName,
    this.bizNum,
    this.talkYn,
  });

  factory CustUserModel.fromJSON(Map<String,dynamic> json) => _$CustUserModelFromJson(json);

  Map<String,dynamic> toJson() => _$CustUserModelToJson(this);

}