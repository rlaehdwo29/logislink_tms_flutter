
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'car_model.g.dart';

@JsonSerializable()
class CarModel extends ResultModel {

  String? driverId;
  String? vehicId;
  String? custId;
  String? deptId;
  String? driverName;
  String? mobile;
  String? carNum;
  String? regid;
  String? retCode;
  String? retMsg;
  String? carTonCode;
  String? carTonName;
  String? carTypeCode;
  String? carTypeName;
  String? carMngName;  //차량관리(정상,블랙리스트)
  String? carMngMemo;  //차량관리메모
  String? payType;     //빠른지급여부
  String? talkYn;
  String? buyDriverLicenseNumber;  // 산재보험 주민번호

  CarModel({
    this.driverId,
    this.vehicId,
    this.custId,
    this.deptId,
    this.driverName,
    this.mobile,
    this.carNum,
    this.regid,
    this.retCode,
    this.retMsg,
    this.carTonCode,
    this.carTonName,
    this.carTypeCode,
    this.carTypeName,
    this.carMngName,
    this.carMngMemo,
    this.payType,
    this.talkYn,
    this.buyDriverLicenseNumber
  });

  factory CarModel.fromJSON(Map<String,dynamic> json) => _$CarModelFromJson(json);

  Map<String,dynamic> toJson() => _$CarModelToJson(this);

}
