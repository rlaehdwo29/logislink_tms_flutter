import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';

class App extends GetxController{
  final device_info = <String, dynamic>{}.obs;
  final app_info = <String,dynamic>{}.obs;
  final user = UserModel().obs;
  final isIsNoticeOpen = false.obs;
  final renew_value = true.obs;

  Future<void> setUserInfo(UserModel userInfo) async {
    await SP.putUserModel(Const.KEY_USER_INFO, userInfo);
    user.value = userInfo;
    update();
  }
  Future<UserModel> getUserInfo() async {
    user.value = await SP.getUserInfo(Const.KEY_USER_INFO)??UserModel();
    return user.value;
  }

  Future<void> setRenewValue(bool value) async {
    await SP.putBool(Const.RENEW_APP, value);
    renew_value.value = value;
    update();
  }

  Future<bool> getRenewValue() async {
    bool state = await SP.getBoolean(Const.RENEW_APP);
    print("리뉴얼 설정 => ${state}");
    if(state == null) {
      await setRenewValue(true);
      renew_value.value = true;
    }else{
      renew_value.value = state;
    }

    return renew_value.value;
  }

  bool isTablet(BuildContext context) {
    bool isTablet;
    double ratio = MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
      if( (ratio >= 0.74) && (ratio < 1.5) )
      {
        isTablet = true;
      } else{
        isTablet = false;
      }
    return isTablet;
  } 

  AppDataBase getRepository() {
    var db = AppDataBase();
    return db;
  }

}