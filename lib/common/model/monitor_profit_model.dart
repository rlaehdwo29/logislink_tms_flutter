
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'monitor_profit_model.g.dart';

@JsonSerializable()
class MonitorProfitModel extends ResultModel {

  // 부서별
  String? deptName;
  String? userName;
  int? buyCharge;
  int? sellCharge;
  int? profitCharge;
  // 거래처별
  String? custName;
  int? buyAmt;
  int? sellAmt;
  int? profitAmt;
  double? profitPercent;
  String? subTotal;

  MonitorProfitModel({
    this.deptName,
    this.userName,
    this.buyCharge,
    this.sellCharge,
    this.profitCharge,
    this.custName,
    this.buyAmt,
    this.sellAmt,
    this.profitAmt,
    this.profitPercent,
    this.subTotal
  });

  factory MonitorProfitModel.fromJSON(Map<String,dynamic> json) => _$MonitorProfitModelFromJson(json);

  Map<String,dynamic> toJson() => _$MonitorProfitModelToJson(this);

}
