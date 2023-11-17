import 'package:json_annotation/json_annotation.dart';
part 'result_model.g.dart';

@JsonSerializable()
class ResultModel {

  final bool? result;
  final String? msg;
  final String? total;

  ResultModel({this.result,this.msg,this.total});

  factory ResultModel.fromJSON(Map<String,dynamic> json) =>
      _$ResultModelFromJson(json);

  Map<String,dynamic> toJson() => _$ResultModelToJson(this);

}