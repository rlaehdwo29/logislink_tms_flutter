import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/juso_model.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/constants/custom_log_interceptor.dart';
import 'package:logislink_tms_flutter/interfaces/juso_rest.dart';
import 'package:logislink_tms_flutter/interfaces/rest.dart';


class DioService {


  static Rest dioClient({header = false, image_option = false}) {
    Logger logger = Logger();
    logger.i("login_page.dart userLogin() => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    if(image_option) dio.options.contentType = 'multipart/form-data';
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return Rest(dio);
  }

  static JusoRest jusoDioClient({header = false, image_option = false}) {
    Logger logger = Logger();
    logger.i("login_page.dart userLogin() => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    if(image_option) dio.options.contentType = 'multipart/form-data';
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return JusoRest(dio);
  }

  static ReturnMap dioResponse(dynamic it) {
    Logger logger = Logger();
    ReturnMap response;
    try {
      logger.i("DioResponse() => ${it.response.data}");
      if(it.response.data["result"] == true) {
        var jsonString = jsonEncode(it.response.data);
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        print("Dio jsonData -> ${jsonData}");
        ResultModel result = ResultModel.fromJSON(jsonData);
        print("Dio response data -> ${it.response.data}");
        print("Dio response data data -> ${it.response.data["data"]}");
        response = ReturnMap(status: it.response.statusCode.toString(), message: result.msg,resultMap:it.response.data );
      }else{
        response = ReturnMap(status: "401", message: it.response.data["msg"]);
      }
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnMap(status: "500", message: "json parser error");
    }
    return response;
  }

  static List<JusoModel> jusoDioResponse(dynamic it) {
    Logger logger = Logger();
    List<JusoModel> mList = List.empty(growable: true);
    try {
      logger.i("jusoDioResponse() => ${it.response.data}");
      if(it.response.data["results"]["common"]["errorMessage"] == "정상") {
          var list = it.response.data["results"]["juso"] as List;
          List<JusoModel> itemsList = list.map((i) => JusoModel.fromJSON(i)).toList();
          mList.addAll(itemsList);
      }else{
       mList = List.empty(growable: true);
      }
    }catch(e) {
      logger.e("Error => $e");
      mList = List.empty(growable: true);
    }
    return mList;
  }

}

