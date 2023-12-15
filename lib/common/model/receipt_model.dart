import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';

part 'receipt_model.g.dart';

@JsonSerializable()
class ReceiptModel extends ReturnMap{

  String? orderId;
  int? fileSeq;
  String? fileTypeCode;
  String? fileName;
  String? filePath;
  int? fileSize;
  String? mimeType;
  String? fileRealName;
  String? regid;
  String? regdate;
  int? viewType = 1;

  ReceiptModel({
    this.orderId,
    this.fileSeq,
    this.fileTypeCode,
    this.fileName,
    this.filePath,
    this.fileSize,
    this.mimeType,
    this.fileRealName,
    this.regid,
    this.regdate,
    this.viewType
  });

  factory ReceiptModel.fromJSON(Map<String,dynamic> json) => _$ReceiptModelFromJson(json);

  Map<String,dynamic> toJson() => _$ReceiptModelToJson(this);

}