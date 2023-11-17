import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'juso_model.g.dart';

@JsonSerializable()
class JusoModel extends ResultModel {

  String? roadFullAddr;
  String? roadAddr;
  String? roadAddrPart1;
  String? roadAddrPart2;
  String? jibunAddr;
  String? engAddr;
  String? addrDetail;
  String? zipNo;
  String? admCd;
  String? rnMgtSn;
  String? bdMgtSn;
  String? detBdNmList;
  String? bdNm;
  String? bdKdcd;
  String? siNm;
  String? sggNm;
  String? emdNm;
  String? liNm;
  String? rn;
  String? udrtYn;
  String? buldMnnm;
  String? buldSlno;
  String? mtYn;
  String? lnbrMnnm;
  String? lnbrSlno;
  String? emdNo;
  String? hstryYn;
  String? relJibun;
  String? hemdNm;
  String? entX;
  String? entY;

  JusoModel({
    this.roadFullAddr,
    this.roadAddr,
    this.roadAddrPart1,
    this.roadAddrPart2,
    this.jibunAddr,
    this.engAddr,
    this.addrDetail,
    this.zipNo,
    this.admCd,
    this.rnMgtSn,
    this.bdMgtSn,
    this.detBdNmList,
    this.bdNm,
    this.bdKdcd,
    this.siNm,
    this.sggNm,
    this.emdNm,
    this.liNm,
    this.rn,
    this.udrtYn,
    this.buldMnnm,
    this.buldSlno,
    this.mtYn,
    this.lnbrMnnm,
    this.lnbrSlno,
    this.emdNo,
    this.hstryYn,
    this.relJibun,
    this.hemdNm,
    this.entX,
    this.entY
});

  factory JusoModel.fromJSON(Map<String,dynamic> json) => _$JusoModelFromJson(json);

  Map<String,dynamic> toJson() => _$JusoModelToJson(this);

}