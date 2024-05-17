import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/model/user_rpa_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:path/path.dart';

import '../common/model/order_link_current_model.dart';

class OrderService with ChangeNotifier {

  final orderList = List.empty(growable: true).obs;
  final orderRecentList = List.empty(growable: true).obs;
  List<StopPointModel> stopPointList = List.empty(growable: true);
  List<OrderModel> historyList = List.empty(growable: true);
  final orderLinkList = List.empty(growable: true).obs;

  OrderService() {
    orderList.value = List.empty(growable: true);
    orderRecentList.value = List.empty(growable: true);
    stopPointList = List.empty(growable: true);
    historyList = List.empty(growable: true);
    orderLinkList.value = List.empty(growable: true);
  }

  void init() {
    orderList.value = List.empty(growable: true);
    orderRecentList.value = List.empty(growable: true);
    stopPointList = List.empty(growable: true);
    historyList = List.empty(growable: true);
    orderLinkList.value = List.empty(growable: true);
  }

  Future getStopPoint(BuildContext? context, String? orderId) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).getStopPoint(app.authorization, orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getStopPoint() _response -> ${_response.status} // ${_response.resultMap}");

      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try{
            var list = _response.resultMap?["data"] as List;
            List<StopPointModel> itemsList = list.map((i) => StopPointModel.fromJSON(i)).toList();
            if(stopPointList.isNotEmpty) stopPointList.clear();
            stopPointList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          stopPointList = List.empty(growable: true);
        }
      }

    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getStopPoint() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getStopPoint() Error Default => ");
          break;
      }
    });
    return stopPointList;
  }

  Future getOrder(context, String? startDate, String? endDate, String? orderState, String? allocState, String? myOrder,int? page, String? searchColumn, String? searchValue ) async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    orderList.value = List.empty(growable: true);
    Map<String,dynamic> api24Data  = Map<String,dynamic>();
    int totalPage = 1;
    await DioService.dioClient(header: true).getOrder(user.authorization, startDate, endDate, orderState, allocState, myOrder, page, searchColumn, searchValue ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("orderService.dartgetOrder() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
           if(_response.resultMap?["api24Data"] != null) api24Data = _response.resultMap?["api24Data"];
          if (_response.resultMap?["data"] != null) {
            try {
              var list = _response.resultMap?["data"] as List;
              List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
              var db = App().getRepository();
              if(itemsList.length > 0){
                if(page == 1) await db.deleteAll();
                await db.insertAll(context,itemsList);
              }else{
                await db.deleteAll();
              }
              if(orderList.isNotEmpty) orderList.clear();
              var reposi_order = await db.getOrderList(context);
              orderList?.addAll(reposi_order);
              totalPage = Util.getTotalPage(int.parse(_response.resultMap?["total"]));
            } catch (e) {
              print(e);
            }
          } else {
            orderList.value = List.empty(growable: true);
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
          print("orderService.dart getOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("orderService.dart getOrder() getOrder Default => ");
          break;
      }
    });
    Map<String,dynamic> maps = {"total":totalPage,"api24Data":api24Data,"list":orderList};
    return maps;
  }

  Future currentLink(BuildContext context, String? orderId) async {
    // link_type = 03: 24시콜, 18: 원콜, 21: 화물맨
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    UserRpaModel rpa = UserRpaModel();

    await DioService.dioClient(header: true).currentNewLink(
      user.authorization,
      orderId,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("order_service.dart currentLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["rpa"] != null) rpa = UserRpaModel(
              link24Id: _response.resultMap?["rpa"]["link24Id"],
              link24Pass: _response.resultMap?["rpa"]["link24Pass"],
              man24Id: _response.resultMap?["rpa"]["man24Id"],
              man24Pass: _response.resultMap?["rpa"]["man24Pass"],
              one24Id: _response.resultMap?["rpa"]["one24Id"],
              one24Pass: _response.resultMap?["rpa"]["one24Pass"]
            );
            if (_response.resultMap?["data"] != null) {
              var mList = _response.resultMap?["data"] as List;
              if(orderLinkList.length > 0) orderLinkList.clear();
              if(mList.length > 0) {
                  List<OrderLinkCurrentModel> itemsList = mList.map((i) => OrderLinkCurrentModel.fromJSON(i)).toList();
                  orderLinkList.addAll(itemsList);
              }
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("order_service.dart currentLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("order_service.dart currentLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("order_service.dart currentLink() getOrder Default => ");
          break;
      }
    });
    Map<String,dynamic> maps = {"rpa":rpa,"list":orderLinkList};
    return maps;
  }

  Future getOrderList2(context, String? auth, String? allocId, String? orderId) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getOrderList2(auth, allocId, orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderList2() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,_response.resultMap!["data"].toString(),Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try{
            var list = _response.resultMap?["data"] as List;
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
            orderList!.isNotEmpty? orderList.value = List.empty(growable: true) : orderList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          orderList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderList2() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderList2() getOrder Default => ");
          break;
      }
    });
    return orderList;
  }

  Future getRecentOrder(context, String? startDate, String? endDate, String? custId, String? deptId, int? page) async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    orderRecentList.value = List.empty(growable: true);
    int totalPage = 1;
    await DioService.dioClient(header: true).getRecentOrder(user.authorization, startDate, endDate, custId, deptId, page).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getRecentOrder() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            try {
              var list = _response.resultMap?["data"] as List;
              List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
              if(orderRecentList.isNotEmpty) orderRecentList.clear();
              orderRecentList?.addAll(itemsList);
              totalPage = Util.getTotalPage(int.parse(_response.resultMap?["total"]));
            } catch (e) {
              print(e);
            }
          } else {
            orderRecentList.value = List.empty(growable: true);
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
          print("getRecentOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getRecentOrder() getOrder Default => ");
          break;
      }
    });
    Map<String,dynamic> maps = {"total":totalPage,"list":orderRecentList};
    return maps;
  }

}