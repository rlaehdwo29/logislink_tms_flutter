// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cust_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustUserModel _$CustUserModelFromJson(Map<String, dynamic> json) =>
    CustUserModel(
      custId: json['custId'] as String?,
      deptId: json['deptId'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      bizName: json['bizName'] as String?,
      telnum: json['telnum'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      grade: json['grade'] as String?,
      custTypeCode: json['custTypeCode'] as String?,
      custTypeName: json['custTypeName'] as String?,
      bizNum: json['bizNum'] as String?,
      talkYn: json['talkYn'] as String?,
    )..deptName = json['deptName'] as String?;

Map<String, dynamic> _$CustUserModelToJson(CustUserModel instance) =>
    <String, dynamic>{
      'custId': instance.custId,
      'deptId': instance.deptId,
      'userId': instance.userId,
      'userName': instance.userName,
      'bizName': instance.bizName,
      'deptName': instance.deptName,
      'telnum': instance.telnum,
      'email': instance.email,
      'mobile': instance.mobile,
      'grade': instance.grade,
      'custTypeCode': instance.custTypeCode,
      'custTypeName': instance.custTypeName,
      'bizNum': instance.bizNum,
      'talkYn': instance.talkYn,
    };
