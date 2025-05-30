import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/juso_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/constants/custom_log_interceptor.dart';
import 'package:logislink_tms_flutter/interfaces/juso_rest.dart';
import 'package:logislink_tms_flutter/interfaces/kakao_rest.dart';
import 'package:logislink_tms_flutter/interfaces/rest.dart';


class DioService {


  static Rest dioClient({header = false, image_option = false}) {
    Logger logger = Logger();
    logger.i("old_login_page.dart userLogin() => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    if(image_option) dio.options.contentType = 'multipart/form-data';
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return Rest(dio);
  }

  static JusoRest jusoDioClient({header = false, image_option = false}) {
    Logger logger = Logger();
    logger.i("old_login_page.dart userLogin() => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    if(image_option) dio.options.contentType = 'multipart/form-data';
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return JusoRest(dio);
  }

  static KakaoRest kakaoClient({header = false, image_option = false}) {
    Logger logger = Logger();
    logger.i("old_login_page.dart userLogin() => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    if(image_option) dio.options.contentType = 'multipart/form-data';
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return KakaoRest(dio);
  }

  static ReturnMap dioResponse(dynamic it) {
    Logger logger = Logger();
    ReturnMap response;
    try {
      logger.i("DioResponse() => ${it.response.data}");
      if(it.response.data["result"] == true) {
        var jsonString = jsonEncode(it.response.data);
        print("Dio jsonString -> ${jsonString}");
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


  static KakaoModel kakaoDioResponse(dynamic it) {
    Logger logger = Logger();
    KakaoModel kakao = KakaoModel();
    try {
      logger.i("kakaoDioResponse() => ${it.response.data}");
      var meta = it.response.data["meta"];
      kakao.total_count = meta["total_count"];

      var documents = it.response.data["documents"][0];
      kakao.x = documents["x"];
      kakao.y = documents["y"];

      var addressItem = it.response.data["documents"][0]["address"];
      kakao.address_name = addressItem["address_name"];
      kakao.region_1depth_name = addressItem["region_1depth_name"];
      kakao.region_2depth_name = addressItem["region_2depth_name"];
      kakao.region_3depth_name = addressItem["region_3depth_name"];
      kakao.mountain_yn = addressItem["mountain_yn"];
      kakao.main_address_no = addressItem["main_address_no"];
      kakao.sub_address_no = addressItem["sub_address_no"];

      var roadItem = it.response.data["documents"][0]["road_address"];
      kakao.rd_address_name = roadItem["rd_address_name"];
      kakao.rd_region_1depth_name = roadItem["region_1depth_name"];
      kakao.rd_region_2depth_name = roadItem["region_2depth_name"];
      kakao.rd_region_3depth_name = roadItem["region_3depth_name"];
      kakao.road_name = roadItem["road_name"];
      kakao.underground_yn = roadItem["underground_yn"];
      kakao.main_building_no = roadItem["main_building_no"];
      kakao.sub_building_no = roadItem["sub_building_no"];
      kakao.building_name = roadItem["building_name"];
      kakao.zone_no = roadItem["zone_no"];
      return kakao;
    }catch(e) {
      logger.e("Error => $e");
    }
    return kakao;
  }

  static KakaoModel kakaoDioResponse2(dynamic it) {
    Logger logger = Logger();
    KakaoModel kakao = KakaoModel();

    logger.i("kakaoDioResponse2() => ${it.response.data}");

    try {
      var documents = it.response.data["documents"][0];
      kakao.x = documents["x"];
      kakao.y = documents["y"];

      var addressItem = it.response.data["documents"][0]["address"];
      kakao.address_name = addressItem["address_name"];
      kakao.region_1depth_name = addressItem["region_1depth_name"];
      kakao.region_2depth_name = addressItem["region_2depth_name"];
      kakao.region_3depth_name = addressItem["region_3depth_name"];
    } catch(e) {

      var documents = it.response.data["documents"][0];
      kakao.x = documents["x"];
      kakao.y = documents["y"];

      var roadItem = it.response.data["documents"][0]["road_address"];
      kakao.rd_address_name = roadItem["rd_address_name"];
      kakao.rd_region_1depth_name = roadItem["region_1depth_name"];
      kakao.rd_region_2depth_name = roadItem["region_2depth_name"];
      kakao.rd_region_3depth_name = roadItem["region_3depth_name"];
    }
    return kakao;
  }

}

