// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      driverId: json['driverId'] as String?,
      allocId: json['allocId'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      regDate: json['regDate'] as String?,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'allocId': instance.allocId,
      'lat': instance.lat,
      'lon': instance.lon,
      'regDate': instance.regDate,
    };
