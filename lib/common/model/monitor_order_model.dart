
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'monitor_order_model.g.dart';

@JsonSerializable()
class MonitorOrderModel extends ResultModel {

  int? allocCnt;           // 전체오더
  int? preOrder;           // 사전오더:소계
  int? todayOrder;         // 당일오더:소계
  int? todayFinish;        // 당일오더:당착
  int? tomorrowFinish;     // 당일오더:익착
  int? allocDelay;         // 책임배차
  int? enterDelay;         // 입차준수
  int? finishDelay;        // 미준수

  MonitorOrderModel({
    this.allocCnt,
    this.preOrder,
    this.todayOrder,
    this.todayFinish,
    this.tomorrowFinish,
    this.allocDelay,
    this.enterDelay,
    this.finishDelay,
  });

  factory MonitorOrderModel.fromJSON(Map<String,dynamic> json) => _$MonitorOrderModelFromJson(json);

  Map<String,dynamic> toJson() => _$MonitorOrderModelToJson(this);

}
