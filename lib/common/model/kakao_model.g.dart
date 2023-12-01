// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KakaoModel _$KakaoModelFromJson(Map<String, dynamic> json) => KakaoModel(
      total_count: json['total_count'] as int?,
      x: json['x'] as String?,
      y: json['y'] as String?,
      address_name: json['address_name'] as String?,
      region_1depth_name: json['region_1depth_name'] as String?,
      region_2depth_name: json['region_2depth_name'] as String?,
      region_3depth_name: json['region_3depth_name'] as String?,
      mountain_yn: json['mountain_yn'] as String?,
      main_address_no: json['main_address_no'] as String?,
      sub_address_no: json['sub_address_no'] as String?,
      rd_address_name: json['rd_address_name'] as String?,
      rd_region_1depth_name: json['rd_region_1depth_name'] as String?,
      rd_region_2depth_name: json['rd_region_2depth_name'] as String?,
      rd_region_3depth_name: json['rd_region_3depth_name'] as String?,
      road_name: json['road_name'] as String?,
      underground_yn: json['underground_yn'] as String?,
      main_building_no: json['main_building_no'] as String?,
      sub_building_no: json['sub_building_no'] as String?,
      building_name: json['building_name'] as String?,
      zone_no: json['zone_no'] as String?,
    );

Map<String, dynamic> _$KakaoModelToJson(KakaoModel instance) =>
    <String, dynamic>{
      'total_count': instance.total_count,
      'x': instance.x,
      'y': instance.y,
      'address_name': instance.address_name,
      'region_1depth_name': instance.region_1depth_name,
      'region_2depth_name': instance.region_2depth_name,
      'region_3depth_name': instance.region_3depth_name,
      'mountain_yn': instance.mountain_yn,
      'main_address_no': instance.main_address_no,
      'sub_address_no': instance.sub_address_no,
      'rd_address_name': instance.rd_address_name,
      'rd_region_1depth_name': instance.rd_region_1depth_name,
      'rd_region_2depth_name': instance.rd_region_2depth_name,
      'rd_region_3depth_name': instance.rd_region_3depth_name,
      'road_name': instance.road_name,
      'underground_yn': instance.underground_yn,
      'main_building_no': instance.main_building_no,
      'sub_building_no': instance.sub_building_no,
      'building_name': instance.building_name,
      'zone_no': instance.zone_no,
    };
