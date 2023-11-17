// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_charge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitChargeModel _$UnitChargeModelFromJson(Map<String, dynamic> json) =>
    UnitChargeModel(
      unit_charge: json['unit_charge'] as String?,
      omsUnit_charge: json['omsUnit_charge'] as String?,
      sePointFlag: json['sePointFlag'] as String?,
      unitCostId: json['unitCostId'] as String?,
    );

Map<String, dynamic> _$UnitChargeModelToJson(UnitChargeModel instance) =>
    <String, dynamic>{
      'unit_charge': instance.unit_charge,
      'omsUnit_charge': instance.omsUnit_charge,
      'sePointFlag': instance.sePointFlag,
      'unitCostId': instance.unitCostId,
    };
