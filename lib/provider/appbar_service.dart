import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';

class AppbarService with ChangeNotifier {
  final addrList = List.empty(growable: true).obs;

  AppbarService() {
    addrList.value = List.empty(growable: true);
  }

  void init() {
    addrList.value = List.empty(growable: true);
  }

  Future getAddr(BuildContext? context, String? keyword) async {
    Logger logger = Logger();
    addrList.value = List.empty(growable: true);
    await DioService.jusoDioClient().getJuso(Const.JUSU_KEY,"1","20",keyword,"json").then((it) {
      if (addrList.isNotEmpty == true) addrList.value = List.empty(growable: true);
      addrList.value = DioService.jusoDioResponse(it);
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getAddr() Error Default => ");
          break;
      }
    });
    return addrList;
  }

}