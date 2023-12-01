// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_link_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLinkStatusModel _$OrderLinkStatusModelFromJson(
        Map<String, dynamic> json) =>
    OrderLinkStatusModel(
      order_id: json['order_id'] as String?,
      orderStateName: json['orderStateName'] as String?,
      chargeType: json['chargeType'] as String?,
      orderCarName: json['orderCarName'] as String?,
      orderCarTonName: json['orderCarTonName'] as String?,
      sDateDay: json['sDateDay'] as String?,
      sDateTime: json['sDateTime'] as String?,
      eDateDay: json['eDateDay'] as String?,
      eDateTime: json['eDateTime'] as String?,
      driverName: json['driverName'] as String?,
      driverTel: json['driverTel'] as String?,
      carNum: json['carNum'] as String?,
      goodsName: json['goodsName'] as String?,
      custName: json['custName'] as String?,
      regdate: json['regdate'] as String?,
      sAddr: json['sAddr'] as String?,
      eAddr: json['eAddr'] as String?,
      call24Status: json['call24Status'] as String?,
      manStatus: json['manStatus'] as String?,
      oneCallStatus: json['oneCallStatus'] as String?,
    );

Map<String, dynamic> _$OrderLinkStatusModelToJson(
        OrderLinkStatusModel instance) =>
    <String, dynamic>{
      'order_id': instance.order_id,
      'orderStateName': instance.orderStateName,
      'chargeType': instance.chargeType,
      'orderCarName': instance.orderCarName,
      'orderCarTonName': instance.orderCarTonName,
      'sDateDay': instance.sDateDay,
      'sDateTime': instance.sDateTime,
      'eDateDay': instance.eDateDay,
      'eDateTime': instance.eDateTime,
      'driverName': instance.driverName,
      'driverTel': instance.driverTel,
      'carNum': instance.carNum,
      'goodsName': instance.goodsName,
      'custName': instance.custName,
      'regdate': instance.regdate,
      'sAddr': instance.sAddr,
      'eAddr': instance.eAddr,
      'call24Status': instance.call24Status,
      'manStatus': instance.manStatus,
      'oneCallStatus': instance.oneCallStatus,
    };
