// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_link_status_sub_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLinkStatusSubModel _$OrderLinkStatusSubModelFromJson(
        Map<String, dynamic> json) =>
    OrderLinkStatusSubModel(
      orderId: json['orderId'] as String?,
      call24Cargo: json['call24Cargo'] as String?,
      oneCargo: json['oneCargo'] as String?,
      manCargo: json['manCargo'] as String?,
      call24Charge: json['call24Charge'] as String?,
      oneCharge: json['oneCharge'] as String?,
      manCharge: json['manCharge'] as String?,
    );

Map<String, dynamic> _$OrderLinkStatusSubModelToJson(
        OrderLinkStatusSubModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'call24Cargo': instance.call24Cargo,
      'oneCargo': instance.oneCargo,
      'manCargo': instance.manCargo,
      'call24Charge': instance.call24Charge,
      'oneCharge': instance.oneCharge,
      'manCharge': instance.manCharge,
    };
