import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_main_widget.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/terms_agree_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/main_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_main_page.dart';
import 'package:logislink_tms_flutter/page/subpage/find_user_page.dart';
import 'package:logislink_tms_flutter/page/terms_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class ReNewLoginPage extends StatefulWidget {
  const ReNewLoginPage({Key? key}) : super(key:key);

  @override
  _ReNewLoginPageState createState() => _ReNewLoginPageState();
}

class _ReNewLoginPageState extends State<ReNewLoginPage> with CommonMainWidget {

  bool m_TermsCheck = false;
  late TERMS m_TermsMode;
  final controller = Get.find<App>();
  final userID = "".obs;
  final userPassword = "".obs;

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    m_TermsMode=TERMS.NONE;
  }

  Widget _entryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: App().isTablet(context) ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(20.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50)
            ),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              obscureText: true,
              onChanged: (value){
                userPassword.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "비밀번호 입력",
                  hintStyle:CustomStyle.CustomFont(styleFontSize14, light_gray2),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  border: InputBorder.none
              ),
            )
        )
      ],
    );
  }

  Future<void> join() async {
    var url = Uri.parse(URL_JOIN);
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    }
  }

  Future<void> goToFindUser() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => FindUserPage())
    );
  }

  bool validate() {
    if(userID.replaceAll(" ", "").isEmpty){
      Util.snackbar(context, "아이디를 입력해주세요.");
      return false;
    }else if(userPassword.replaceAll(" ", "").isEmpty){
      Util.snackbar(context, "비밀번호를 입력해주세요.");
      return false;
    }
    return true;
  }

  void goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const RenewMainPage()),
            (route) => false);
  }

  Future<void> sendAlarmTalk() async {
    var nowDate = DateTime.now();
    var mFormRes = await DateFormat("MM월dd일 HH시mm분").format(nowDate);

    var mDate = DateTime.now();
    String result2 = DateFormat("MM월dd일 HH시mm분").format(mDate);

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).smsSendLoginService(
        user?.authorization,
        user?.mobile,
        user?.userName,
        userID.value.trim(),
        "00000000000000",
        Platform.isAndroid?"Android":Platform.isIOS?"IOS":"ETC",
        result2
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("sendAlarmTalk() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {

        }else{
          openOkBox(context,_response.resultMap?["msg"]??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart sendAlarmTalk() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart sendAlarmTalk() error2222 =>");
          break;
      }
    });
  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    String? push_id = await SP.get(Const.KEY_PUSH_ID)??"";
    var setting_push = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH);
    var setting_talk = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK);
    await DioService.dioClient(header: true).deviceUpdate(
        user?.authorization,
        Util.booleanToYn(setting_push),
        Util.booleanToYn(setting_talk),
        push_id,
        controller.device_info["model"],
        controller.device_info["deviceOs"],
        controller.app_info["version"]
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("sendDeviceInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          goToMain();
        }
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
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

  Future<void> CheckTermsAgree() async {
    var logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getTermsUserAgree(user?.authorization??"",userID.value).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("CheckTermsAgree() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            TermsAgreeModel user = TermsAgreeModel.fromJSON(it.response.data["data"]);
            if (user != null) {
              if (user.necessary == "N" || user.necessary == "") {
                m_TermsCheck = true;
                m_TermsMode = TERMS.UPDATE;
              } else {
                m_TermsCheck = true;
                m_TermsMode = TERMS.DONE;
              }
            } else {
              m_TermsCheck = false;
              m_TermsMode = TERMS.INSERT;
            }
          }else{
            m_TermsCheck = false;
            m_TermsMode = TERMS.DONE;
          }
          await SP.putBool(Const.KEY_TERMS, true);
          await userLogin();
        }else{
          openOkBox(context, _response.resultMap?["msg"],
              Strings.of(context)?.get("confirm") ?? "Error!!", () {
                Navigator.of(context).pop(false);
              });
        }
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart CheckTermsAgree() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart CheckTermsAgree() error2222 :");
          break;
      }
    });
  }

  void goToGuestQuestion() {
    openCommonConfirmBox(
        context,
        "Guest 모드는 사용에 제한이 있습니다.\n계속 진행하시겠습니까? ",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () {
          Navigator.of(context).pop(false);
          guestLogin();
        }
    );
  }

  Future<void> guestLogin() async {
    Logger logger = Logger();
    SP.putBool(Const.KEY_GUEST_MODE, true);
    var password = Util.encryption(Const.GUEST_PW);
    await pr?.show();
    await DioService.dioClient(header: true).login(Const.GUEST_ID, password).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        UserModel userInfo = UserModel.fromJSON(it.response.data["data"]);
        if (userInfo != null) {
          userInfo.authorization = it.response.headers["authorization"]?[0];
          logger.i("userJson => $userInfo");
          controller.setUserInfo(userInfo);
          var app = await controller.getUserInfo();
          goToMain();
        } else {
          openOkBox(context, _response.message ?? "",
              Strings.of(context)?.get("confirm") ?? "Error!!", () {
                Navigator.of(context).pop(false);
              });
        }
      }else{
        Util.snackbar(context, "등록된 사용자가 아닙니다.");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart guestLogin() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart guestLogin() error2 =>");
          break;
      }
    });
  }

  Future<void> userLogin() async {
    Logger logger = Logger();
    SP.putBool(Const.KEY_GUEST_MODE, false);
    if (validate()) {
      var terms = await SP.getBoolean(Const.KEY_TERMS);
      if (!terms) {
        await CheckTermsAgree();
      } else {
        var password = Util.encryption(userPassword.value);
        password.replaceAll("\n", "");
        await pr?.show();
        await DioService.dioClient(header: true).login(userID.value, password).then((it) async {
          await pr?.hide();
          ReturnMap _response = DioService.dioResponse(it);
          logger.i("userLogin() _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              if (_response.resultMap?["data"] != null) {
                UserModel userInfo = UserModel.fromJSON(
                    it.response.data["data"]);
                if (userInfo != null) {
                  userInfo.authorization =
                  it.response.headers["authorization"]?[0];
                  await controller.setUserInfo(userInfo);
                  if (m_TermsCheck == false && m_TermsMode == TERMS.INSERT) {
                    var results = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (
                                BuildContext context) => const TermsPage())
                    );

                    if (results != null && results.containsKey("code")) {
                      if (results["code"] == 200) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (
                                    BuildContext context) => const ReNewLoginPage()),
                                (route) => false);
                      }
                    }
                  } else {
                    await sendDeviceInfo();
                    await sendAlarmTalk();
                  }
                } else {
                  openOkBox(context, _response.message ?? "",
                      Strings.of(context)?.get("confirm") ?? "Error!!", () {
                        Navigator.of(context).pop(false);
                      });
                }
              }
            }else{
              openOkBox(context, _response.resultMap?["msg"],
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          } else {
            Util.snackbar(context, "등록된 사용자가 아닙니다.");
          }
        }).catchError((Object obj) async {
          await pr?.hide();
          switch (obj.runtimeType) {
            case DioError:
            // Here's the sample to get the failed response error code and message
              final res = (obj as DioError).response;
              logger.e(
                  "login_page.dart userLogin() error : ${res
                      ?.statusCode} -> ${res
                      ?.statusMessage}");
              break;
            default:
              logger.e("login_page.dart userLogin() error222 :");
              break;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    pr = Util.networkProgress(context);
    final height = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
    final width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
    return mainWidget(
        context,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: SafeArea(
            child: Container(
                width:width,
                height:height,
                color:const Color(0xff3D4656),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constranints) {
                    return Stack(
                        alignment: Alignment.center,
                        children:<Widget> [
                          SizedBox(
                              height: height * 0.6,
                              width: width*0.8,
                              child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset("assets/image/ic_logo.png"),
                                      CustomStyle.sizedBoxHeight(100.0),
                                      Container(
                                          height: App().isTablet(context) ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(20.h),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(bottom: CustomStyle.getHeight(20)),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(50)
                                          ),
                                          child: TextField(
                                            style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.text,
                                            onChanged: (value){
                                              userID.value = value;
                                            },
                                            maxLength: 50,
                                            decoration: InputDecoration(
                                                counterText: '',
                                                hintText: "아이디 입력",
                                                hintStyle:CustomStyle.CustomFont(styleFontSize14, light_gray2),
                                                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                                border: InputBorder.none
                                            ),
                                          )
                                      ),
                                      _entryField(),
                                      CustomStyle.sizedBoxHeight(20.0),
                                      InkWell(
                                        onTap: () async {
                                          if(validate()) await userLogin();
                                        },
                                        child: Container(
                                          width: width,
                                          height:  App().isTablet(context) ? CustomStyle.getHeight(35.h): CustomStyle.getHeight(25.h),
                                          decoration: BoxDecoration(
                                            color: renew_main_color2_sub,
                                            borderRadius: BorderRadius.circular(50)
                                          ),
                                          alignment: Alignment.center,
                                          child:Text(
                                            Strings.of(context)?.get("login_btn")??"Not Found",
                                            style: CustomStyle.CustomFont(styleFontSize15, Colors.white,font_weight: FontWeight.w800),
                                          )
                                      )
                                        ),
                                      CustomStyle.sizedBoxHeight(20.0),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Platform.isAndroid?
                                            InkWell(
                                              onTap: () async {
                                                await join();
                                              },
                                              child: Text(
                                                  Strings.of(context)?.get("join")?? "Not Found",
                                                  style: TextStyle(
                                                    color: const Color(0xff667082),
                                                    fontSize: styleFontSize15,
                                                  )
                                              ),
                                            ) : InkWell(
                                              onTap: () {
                                                goToGuestQuestion();
                                              },
                                              child: Text(
                                                  "Guest 로그인",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: styleFontSize15,
                                                  )
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                await goToFindUser();
                                              },
                                              child: Text(
                                                  Strings.of(context)?.get("find_user")?? "Not Found",
                                                  style: TextStyle(
                                                    color: const Color(0xff667082),
                                                    fontSize: styleFontSize15,
                                                  )
                                              ),
                                            )
                                          ])
                                    ],
                                  )
                              )
                          )
                        ]
                    );
                  },
                )
            ),
          ),
        )
    );
  }
}
