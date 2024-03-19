import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'jibun_model.g.dart';

@JsonSerializable()
class JibunModel extends ResultModel {

  String? sido;
  String? gugun;
  String? dong;
  String? ri;
  int? number;
  String? fullAddr;
  String? sAddr;
  double? sLat;
  double? sLon;
  String? eAddr;
  double? eLat;
  double? eLon;
  int? totalTime;
  String? totalDistance;
  String? regdate;

  JibunModel({
    this.sido,
    this.gugun,
    this.dong,
    this.ri,
    this.number,
    this.fullAddr,
    this.sAddr,
    this.sLat,
    this.sLon,
    this.eAddr,
    this.eLat,
    this.eLon,
    this.totalTime,
    this.totalDistance,
    this.regdate,
  });

  factory JibunModel.fromJSON(Map<String,dynamic> json) => _$JibunModelFromJson(json);

  Map<String,dynamic> toJson() => _$JibunModelToJson(this);

}
