import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';

part 'order_link_status_sub_model.g.dart';

@JsonSerializable()
class OrderLinkStatusSubModel extends ResultModel{

  String? orderId;
  String? call24Cargo;
  String? oneCargo;
  String? manCargo;
  String? call24Charge;
  String? oneCharge;
  String? manCharge;

  OrderLinkStatusSubModel({
    this.orderId,
    this.call24Cargo,
    this.oneCargo,
    this.manCargo,
    this.call24Charge,
    this.oneCharge,
    this.manCharge
  });

  factory OrderLinkStatusSubModel.fromJSON(Map<String,dynamic> json) => _$OrderLinkStatusSubModelFromJson(json);

  Map<String,dynamic> toJson() => _$OrderLinkStatusSubModelToJson(this);

}