import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'terms_agree_model.g.dart';

@JsonSerializable()
class TermsAgreeModel extends ResultModel{

  String? tel;
  String? userId;
  String? necessary;
  String? selective;
  String? agreeDate;
  String? version;

  TermsAgreeModel(this.tel,this.userId,this.necessary,this.selective,this.agreeDate,this.version);

  factory TermsAgreeModel.fromJSON(Map<String,dynamic> json) => _$TermsAgreeModelFromJson(json);

  Map<String,dynamic> toJson() => _$TermsAgreeModelToJson(this);

}