
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends ResultModel {

  String? authorization;
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
  Object? custTypeName;
  String? bizNum;
  String? masterYn;

  UserModel({
    this.authorization,
    this.custId,
    this.deptId,
    this.userId,
    this.userName,
    this.bizName,
    this.deptName,
    this.telnum,
    this.email,
    this.mobile,
    this.grade,
    this.custTypeCode,
    this.custTypeName,
    this.bizNum,
    this.masterYn,
  });

  factory UserModel.fromJSON(Map<String,dynamic> json) => _$UserModelFromJson(json);

  Map<String,dynamic> toJson() => _$UserModelToJson(this);

  @override
  bool operator ==(Object other) {
    return other is UserModel &&

        other.authorization == this.authorization &&
        other.custId == this.custId &&
        other.deptId == this.deptId &&
        other.userId == this.userId &&
        other.userName == this.userName &&
        other.bizName == this.bizName &&
        other.deptName == this.deptName &&
        other.telnum == this.telnum &&
        other.email == this.email &&
        other.mobile == this.mobile &&
        other.grade == this.grade &&
        other.custTypeCode == this.custTypeCode &&
        other.custTypeName == this.custTypeName &&
        other.bizNum == this.bizNum &&
        other.masterYn == this.masterYn;
  }

  @override
  int get hashCode {
        return this.authorization.hashCode +
            this.custId.hashCode +
            this.deptId.hashCode +
            this.userId.hashCode +
            this.userName.hashCode +
            this.bizName.hashCode +
            this.deptName.hashCode +
            this.telnum.hashCode +
            this.email.hashCode +
            this.mobile.hashCode +
            this.grade.hashCode +
            this.custTypeCode.hashCode +
            this.custTypeName.hashCode +
            this.bizNum.hashCode +
            this.masterYn.hashCode;
  }

}