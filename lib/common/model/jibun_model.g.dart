// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jibun_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JibunModel _$JibunModelFromJson(Map<String, dynamic> json) => JibunModel(
      sido: json['sido'] as String?,
      gugun: json['gugun'] as String?,
      dong: json['dong'] as String?,
      ri: json['ri'] as String?,
      number: json['number'] as int?,
      fullAddr: json['fullAddr'] as String?,
      sAddr: json['sAddr'] as String?,
      sLat: (json['sLat'] as num?)?.toDouble(),
      sLon: (json['sLon'] as num?)?.toDouble(),
      eAddr: json['eAddr'] as String?,
      eLat: (json['eLat'] as num?)?.toDouble(),
      eLon: (json['eLon'] as num?)?.toDouble(),
      totalTime: json['totalTime'] as int?,
      totalDistance: json['totalDistance'] as String?,
      regdate: json['regdate'] as String?,
    );

Map<String, dynamic> _$JibunModelToJson(JibunModel instance) =>
    <String, dynamic>{
      'sido': instance.sido,
      'gugun': instance.gugun,
      'dong': instance.dong,
      'ri': instance.ri,
      'number': instance.number,
      'fullAddr': instance.fullAddr,
      'sAddr': instance.sAddr,
      'sLat': instance.sLat,
      'sLon': instance.sLon,
      'eAddr': instance.eAddr,
      'eLat': instance.eLat,
      'eLon': instance.eLon,
      'totalTime': instance.totalTime,
      'totalDistance': instance.totalDistance,
      'regdate': instance.regdate,
    };
