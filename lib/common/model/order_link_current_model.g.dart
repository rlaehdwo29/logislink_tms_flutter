// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_link_current_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLinkCurrentModel _$OrderLinkCurrentModelFromJson(
        Map<String, dynamic> json) =>
    OrderLinkCurrentModel(
      procId: json['procId'] as String?,
      jobStat: json['jobStat'] as String?,
      orderId: json['orderId'] as String?,
      linkCd: json['linkCd'] as String?,
      linkStat: json['linkStat'] as String?,
      allocCharge: json['allocCharge'] as String?,
      linkId: json['linkId'] as String?,
      rpaMsg: json['rpaMsg'] as String?,
      regDate: json['regDate'] as String?,
      editDate: json['editDate'] as String?,
      allocChargeYn: json['allocChargeYn'] as String?,
      allocCd: json['allocCd'] as String?,
      refProcId: json['refProcId'] as String?,
      allocStatus: json['allocStatus'] as String?,
      driverName: json['driverName'] as String?,
      driverTel: json['driverTel'] as String?,
      carNum: json['carNum'] as String?,
      carTon: json['carTon'] as String?,
      carType: json['carType'] as String?,
    );

Map<String, dynamic> _$OrderLinkCurrentModelToJson(
        OrderLinkCurrentModel instance) =>
    <String, dynamic>{
      'procId': instance.procId,
      'jobStat': instance.jobStat,
      'orderId': instance.orderId,
      'linkCd': instance.linkCd,
      'linkStat': instance.linkStat,
      'allocCharge': instance.allocCharge,
      'linkId': instance.linkId,
      'rpaMsg': instance.rpaMsg,
      'regDate': instance.regDate,
      'editDate': instance.editDate,
      'allocChargeYn': instance.allocChargeYn,
      'allocCd': instance.allocCd,
      'refProcId': instance.refProcId,
      'allocStatus': instance.allocStatus,
      'driverName': instance.driverName,
      'driverTel': instance.driverTel,
      'carNum': instance.carNum,
      'carTon': instance.carTon,
      'carType': instance.carType,
    };
