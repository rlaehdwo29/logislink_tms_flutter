// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      authorization: json['authorization'] as String?,
      custId: json['custId'] as String?,
      deptId: json['deptId'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      bizName: json['bizName'] as String?,
      deptName: json['deptName'] as String?,
      telnum: json['telnum'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      grade: json['grade'] as String?,
      custTypeCode: json['custTypeCode'] as String?,
      custTypeName: json['custTypeName'],
      bizNum: json['bizNum'] as String?,
      masterYn: json['masterYn'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'authorization': instance.authorization,
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
      'masterYn': instance.masterYn,
    };
