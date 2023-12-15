
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel extends ResultModel {

  String? driverId;
  String? allocId;
  double? lat;
  double? lon;
  String? regDate;

  LocationModel({
    this.driverId,
    this.allocId,
    this.lat,
    this.lon,
    this.regDate
  });

  factory LocationModel.fromJSON(Map<String,dynamic> json) => _$LocationModelFromJson(json);

  Map<String,dynamic> toJson() => _$LocationModelToJson(this);

}
