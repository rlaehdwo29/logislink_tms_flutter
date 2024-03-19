import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/jibun_model.dart';
import 'package:logislink_tms_flutter/common/model/notice_model.dart';
import 'package:logislink_tms_flutter/common/model/point_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';

class AppbarService with ChangeNotifier {
  final addrList = List.empty(growable: true).obs;
  final jibunList = List.empty(growable: true).obs;
  final noticeList = List.empty(growable: true).obs;
  final pointList = List.empty(growable: true).obs;

  AppbarService() {
    addrList.value = List.empty(growable: true);
    noticeList.value = List.empty(growable: true);
    pointList.value = List.empty(growable: true);
  }

  void init() {
    addrList.value = List.empty(growable: true);
    noticeList.value = List.empty(growable: true);
    pointList.value = List.empty(growable: true);
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

  Future getJibunAddr(BuildContext context, String? keyword) async {
    Logger logger = Logger();
    jibunList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getJibun(keyword).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("getJibunAddr() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<JibunModel> itemsList = list.map((i) => JibunModel.fromJSON(i)).toList();
            if(jibunList.isNotEmpty) jibunList.clear();
            jibunList.addAll(itemsList);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getJibunAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getJibunAddr() Error Default => ");
          break;
      }
    });
    return jibunList;
  }

  Future getNotice(BuildContext? context) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    noticeList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getNotice(app.authorization).then((it) {
      if (noticeList.isNotEmpty == true) noticeList.value = List.empty(growable: true);
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getNotice() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<NoticeModel> itemsList = list.map((i) => NoticeModel.fromJSON(i)).toList();
            noticeList?.addAll(itemsList);
          }catch(e) {
            print("getNotice() Error => $e");
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }else{
        noticeList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getNotice() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getNotice() Error Default => ");
          break;
      }
    });
    return noticeList;
  }

  Future getUserPoint(BuildContext? context,int page) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    pointList.value = List.empty(growable: true);
    int totalPage = 1;
    await DioService.dioClient(header: true).getTmsUserPointList(app.authorization,page).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("appbar_service.dart getUserPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<PointModel> itemsList = list.map((i) => PointModel.fromJSON(i)).toList();
            pointList?.addAll(itemsList);
            int total = 0;
            if(_response.resultMap?["total"].runtimeType.toString() == "String") {
              total = int.parse(_response.resultMap?["total"]);
            }else{
              total = _response.resultMap?["total"];
            }
            totalPage = Util.getTotalPage(total);
          }catch(e) {
            print("appbar_service.dart getUserPoint() Error => $e");
          }
        }
      }else{
        pointList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("appbar_service.dart getUserPoint() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("appbar_service.dart getUserPoint() Error Default => ");
          break;
      }
    });
    Map<String,dynamic> maps = {"total":totalPage,"list":pointList};
    return maps;
  }

}