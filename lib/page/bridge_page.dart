import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/model/version_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/login_page.dart';
import 'package:logislink_tms_flutter/page/main_page.dart';
import 'package:logislink_tms_flutter/page/permission_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_login_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_main_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  _BridgePageState createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  //UserInfoService loginService;

  bool m_TermsCheck = false;
  var m_TermsMode;
  final controller = Get.find<App>();
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      controller.renew_value.value = await controller.getRenewValue();

      bool? chkPermission = await checkPermission();
      if(chkPermission == true){
        await checkVersion();
      }else {
        await goToPermission();
      }
    });

  }

  Future goToPermission() async {
    Map<String,int> results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const PermissionPage())
    );

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await checkVersion();
      }
    }
  }

  Future<bool?> checkPermission() async {
        var notification_per = await Permission.notification.status;
      if (notification_per != PermissionStatus.granted) {
          return false;
        }
        return true;
  }

  Future<void> checkVersion() async {
    Logger logger = Logger();
    var type = "A";
    if(Platform.isIOS){
      type = "AI";
    }
    await DioService.dioClient(header: true).getVersion(type).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      logger.d("checkVersion() _response -> ${_response.status} // ${_response.resultMap}");
      try {
        if (_response.status == "200") {
          var list = _response.resultMap?["data"] as List;

          if (list != null && list.isNotEmpty) {
            VersionModel? codeVersion = VersionModel();
            VersionModel? appVersion = VersionModel();
            if(Platform.isIOS) {
               codeVersion = VersionModel.fromJSON(list[0]);
               appVersion = VersionModel.fromJSON(list[1]);
            }else{
              appVersion = VersionModel.fromJSON(list[0]);
              codeVersion = VersionModel.fromJSON(list[1]);
            }
            String? shareVersion = await SP.get(Const.CD_VERSION);
            var server_version_arr = appVersion.versionCode?.split('.');
            String server_version = server_version_arr!.elementAt(0) + "." + server_version_arr!.elementAt(1) + server_version_arr!.elementAt(2);
            var app_version_arr = packageInfo.version?.split('.');
            String app_version = app_version_arr!.elementAt(0) + "." + app_version_arr!.elementAt(1) + app_version_arr!.elementAt(2);
            if (appVersion.updateCode == "1") {
              if(double.parse(app_version) < double.parse(server_version)){
                Util.toast("새로운 앱 버전이 있습니다.");
                if (Platform.isAndroid) {
                  launch(Const.ANDROID_STORE);
                } else if (Platform.isIOS) {
                  launch(Const.IOS_STORE);
                }
              }else{
                if (shareVersion != codeVersion.versionCode) {
                  await SP.putString(Const.CD_VERSION, codeVersion.versionCode ?? "");
                  await GetCodeTask();
                }
                await checkLogin();
              }
            } else{
              if (shareVersion != codeVersion.versionCode) {
                await SP.putString(Const.CD_VERSION, codeVersion.versionCode ?? "");
                await GetCodeTask();
              }
              await checkLogin();
            }
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }catch(e) {
        print("checkVersion() Exection=>$e");
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("brige_page.dart checkVersion() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("brige_page.dart checkVersion() Error Default:");
          break;
      }
    });
  }

  Future<void> GetCodeTask() async {
    Logger logger = Logger();
    List<String> codeList = Const.getCodeList();
    for(String code in codeList){
      await DioService.dioClient(header: true).getCodeList(code).then((it) async {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("GetCodeTask() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["data"] != null) {
            var jsonString = jsonEncode(it.response.data);
            await SP.putCodeList(code, jsonString);
          }
        }
      }).catchError((Object obj) async {
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            logger.e("brige_page.dart GetCodeTask() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
            break;
          default:
            logger.e("brige_page.dart GetCodeTask() Error Default:");
            break;
        }
      });
    }
  }

  Future<void> checkLogin() async {
    var app = await App().getUserInfo();
    if(app.authorization != null ){
      await getUserInfo();
    }else{
      await goToLogin();
    }

  }

  Future<void> getUserInfo() async {
    Logger logger = Logger();
    UserModel? nowUser = await controller.getUserInfo();
    //await pr?.show();
    await DioService.dioClient(header: true).getUserInfo(nowUser?.authorization).then((it) async {
      //await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("getUserInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            UserModel newUser = UserModel.fromJSON(it.response.data["data"]);
            newUser.authorization = nowUser?.authorization;
            controller.setUserInfo(newUser);
            await sendDeviceInfo();
          } else {
            goToLogin();
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
      //await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("bridge_page.dart getUserInfo() Exeption=> ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("bridge_page.dart getUserInfo() Default Exeption => ");
          break;
      }
    });

  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    //await pr?.show();
    var push_id = await SP.get(Const.KEY_PUSH_ID)??"";
    var setting_push = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH);
    var setting_talk = await  SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK);
    var app_version = await Util.getVersionName();
    await DioService.dioClient(header: true).deviceUpdate(
        user?.authorization,
        Util.booleanToYn(setting_push),
        Util.booleanToYn(setting_talk),
        push_id,
        controller.device_info["model"],
        controller.device_info["deviceOs"],
        app_version
    ).then((it) async {
      //await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("sendDeviceInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          goToMain();
        }
      }else{
        Util.toast("${_response.message}");
      }
    }).catchError((Object obj) async {
     // await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart sendDeviceInfo() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart sendDeviceInfo() error2222 =>");
          break;
      }
    });
  }

  void goToMain() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const RenewMainPage()), (route) => false);
  }

  Future<void> goToLogin() async {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const ReNewLoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Container(
      color: styleWhiteCol,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        backgroundColor: styleGreyCol1,
      ),
    );
  }
}
