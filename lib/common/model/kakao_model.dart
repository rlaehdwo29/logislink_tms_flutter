
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'kakao_model.g.dart';

@JsonSerializable()
class KakaoModel extends ResultModel {

  int? total_count;
  String? x;
  String? y;
  //Address
  String? address_name;
  String? region_1depth_name;
  String? region_2depth_name;
  String? region_3depth_name;
  String? mountain_yn;
  String? main_address_no;
  String? sub_address_no;
  //RoadAddress
  String? rd_address_name;
  String? rd_region_1depth_name;
  String? rd_region_2depth_name;
  String? rd_region_3depth_name;
  String? road_name;
  String? underground_yn;
  String? main_building_no;
  String? sub_building_no;
  String? building_name;
  String? zone_no;

  KakaoModel({
    this.total_count,
    this.x,
    this.y,
    this.address_name,
    this.region_1depth_name,
    this.region_2depth_name,
    this.region_3depth_name,
    this.mountain_yn,
    this.main_address_no,
    this.sub_address_no,
    this.rd_address_name,
    this.rd_region_1depth_name,
    this.rd_region_2depth_name,
    this.rd_region_3depth_name,
    this.road_name,
    this.underground_yn,
    this.main_building_no,
    this.sub_building_no,
    this.building_name,
    this.zone_no
  });

  factory KakaoModel.fromJSON(Map<String,dynamic> json) => _$KakaoModelFromJson(json);

  Map<String,dynamic> toJson() => _$KakaoModelToJson(this);

}

