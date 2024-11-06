// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_profit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitorProfitModel _$MonitorProfitModelFromJson(Map<String, dynamic> json) =>
    MonitorProfitModel(
      deptName: json['deptName'] as String?,
      userName: json['userName'] as String?,
      buyCharge: (json['buyCharge'] as num?)?.toInt(),
      sellCharge: (json['sellCharge'] as num?)?.toInt(),
      profitCharge: (json['profitCharge'] as num?)?.toInt(),
      custName: json['custName'] as String?,
      buyAmt: (json['buyAmt'] as num?)?.toInt(),
      sellAmt: (json['sellAmt'] as num?)?.toInt(),
      profitAmt: (json['profitAmt'] as num?)?.toInt(),
      profitPercent: (json['profitPercent'] as num?)?.toDouble(),
      subTotal: json['subTotal'] as String?,
    );

Map<String, dynamic> _$MonitorProfitModelToJson(MonitorProfitModel instance) =>
    <String, dynamic>{
      'deptName': instance.deptName,
      'userName': instance.userName,
      'buyCharge': instance.buyCharge,
      'sellCharge': instance.sellCharge,
      'profitCharge': instance.profitCharge,
      'custName': instance.custName,
      'buyAmt': instance.buyAmt,
      'sellAmt': instance.sellAmt,
      'profitAmt': instance.profitAmt,
      'profitPercent': instance.profitPercent,
      'subTotal': instance.subTotal,
    };
