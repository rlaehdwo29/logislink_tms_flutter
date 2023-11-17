// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      custId: json['custId'] as String?,
      deptId: json['deptId'] as String?,
      sellBuySctn: json['sellBuySctn'] as String?,
      custName: json['custName'] as String?,
      telnum: json['telnum'] as String?,
      mobile: json['mobile'] as String?,
      itemCode: json['itemCode'] as String?,
      custMemo: json['custMemo'] as String?,
      orderMemo: json['orderMemo'] as String?,
      deptName: json['deptName'] as String?,
      bizName: json['bizName'] as String?,
      bizNum: json['bizNum'] as String?,
      ceo: json['ceo'] as String?,
      bizAddr: json['bizAddr'] as String?,
      bizAddrDetail: json['bizAddrDetail'] as String?,
      custMngName: json['custMngName'] as String?,
      custMngMemo: json['custMngMemo'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'custId': instance.custId,
      'deptId': instance.deptId,
      'sellBuySctn': instance.sellBuySctn,
      'custName': instance.custName,
      'telnum': instance.telnum,
      'mobile': instance.mobile,
      'itemCode': instance.itemCode,
      'custMemo': instance.custMemo,
      'orderMemo': instance.orderMemo,
      'deptName': instance.deptName,
      'bizName': instance.bizName,
      'bizNum': instance.bizNum,
      'ceo': instance.ceo,
      'bizAddr': instance.bizAddr,
      'bizAddrDetail': instance.bizAddrDetail,
      'custMngName': instance.custMngName,
      'custMngMemo': instance.custMngMemo,
    };
