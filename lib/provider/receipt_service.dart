import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/receipt_model.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';

class ReceiptService with ChangeNotifier {

  final receiptList = List.empty(growable: true).obs;

  ReceiptService() {
    receiptList.value = List.empty(growable: true);
  }

  void init() {
    receiptList.value = List.empty(growable: true);
  }

  Future getReceipt(BuildContext? context, String? _orderId) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    receiptList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getReceipt(app.authorization, _orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getReceipt() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<ReceiptModel> itemsList = list.map((i) => ReceiptModel.fromJSON(i)).toList();
          receiptList?.addAll(itemsList);
        }
      }else{
        receiptList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getReceipt() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getReceipt() Error Default => ");
          break;
      }
    });
    return receiptList;
  }

}