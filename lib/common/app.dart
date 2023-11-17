import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';

class App extends GetxController{
  final device_info = <String, dynamic>{}.obs;
  final app_info = <String,dynamic>{}.obs;
  final user = UserModel().obs;

  Future<void> setUserInfo(UserModel userInfo) async {
    await SP.putUserModel(Const.KEY_USER_INFO, userInfo);
    user.value = userInfo;
    update();
  }
  Future<UserModel> getUserInfo() async {
    user.value = await SP.getUserInfo(Const.KEY_USER_INFO)??UserModel();
    return user.value;
  }


  AppDataBase getRepository() {
    var db = AppDataBase();
    return db;
  }

}