// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
      orderId: json['orderId'] as String?,
      fileSeq: json['fileSeq'] as int?,
      fileTypeCode: json['fileTypeCode'] as String?,
      fileName: json['fileName'] as String?,
      filePath: json['filePath'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      fileRealName: json['fileRealName'] as String?,
      regid: json['regid'] as String?,
      regdate: json['regdate'] as String?,
      viewType: json['viewType'] as int?,
    )
      ..status = json['status'] as String?
      ..message = json['message'] as String?
      ..path = json['path'] as String?
      ..resultMap = json['resultMap'] as Map<String, dynamic>?;

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'path': instance.path,
      'resultMap': instance.resultMap,
      'orderId': instance.orderId,
      'fileSeq': instance.fileSeq,
      'fileTypeCode': instance.fileTypeCode,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'fileRealName': instance.fileRealName,
      'regid': instance.regid,
      'regdate': instance.regdate,
      'viewType': instance.viewType,
    };
