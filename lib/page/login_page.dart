import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_main_widget.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/terms_agree_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/main_page.dart';
import 'package:logislink_tms_flutter/page/subpage/find_user_page.dart';
import 'package:logislink_tms_flutter/page/terms_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/config_url.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key:key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with CommonMainWidget {

  bool m_TermsCheck = false;
  late TERMS m_TermsMode;
  final controller = Get.find<App>();
  final userID = "".obs;
  final userPassword = "".obs;

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
  }

  Widget _entryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: CustomStyle.getHeight(70.0),
          child: TextField(
            style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            obscureText: true,
            onChanged: (value){
              userPassword.value = value;
            },
            maxLength: 50,
            decoration: InputDecoration(
                counterText: '',
                hintText: "비밀번호",
                hintStyle:CustomStyle.whiteFont(),
                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              ),
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              )

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
            builder: (BuildContext context) => const MainPage()),
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

      if(_response.status == "200") {
        TermsAgreeModel user = TermsAgreeModel.fromJSON(it.response.data["data"]);
        if(user != null) {
          if(user.necessary == "N" || user.necessary == ""){
            m_TermsCheck = true;
            m_TermsMode = TERMS.UPDATE;
          }else{
            m_TermsCheck = true;
            m_TermsMode = TERMS.DONE;
          }
        }else{
          m_TermsCheck = false;
          m_TermsMode= TERMS.INSERT;
        }
        await SP.putBool(Const.KEY_TERMS, true);
        await userLogin();
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

  Future<void> userLogin() async {
    if (validate()) {
      var terms = await SP.getBoolean(Const.KEY_TERMS);
      if (!terms) {
        CheckTermsAgree();
      } else {
        Logger logger = Logger();
        var password = Util.encryption(userPassword.value);
        password.replaceAll("\n", "");
        await pr?.show();
        await DioService.dioClient(header: true)
            .login(userID.value, password)
            .then((it) async {
          await pr?.hide();
          ReturnMap _response = DioService.dioResponse(it);
          logger.i("userLogin() _response -> ${_response.status} // ${_response
              .resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              if (_response.resultMap?["data"] != null) {
              UserModel userInfo = UserModel.fromJSON(it.response.data["data"]);
                if (userInfo != null) {
                  userInfo.authorization =
                  it.response.headers["authorization"]?[0];
                  await controller.setUserInfo(userInfo);
                  if (m_TermsCheck == false && m_TermsMode == TERMS.INSERT) {
                    var results = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (BuildContext context) => const TermsPage())
                    );

                    if (results != null && results.containsKey("code")) {
                      if (results["code"] == 200) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (
                                    BuildContext context) => const LoginPage()),
                                (route) => false);
                      }
                    }
                  } else {
                    sendDeviceInfo();
                    sendAlarmTalk();
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
            color:main_color,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(50.0)),
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
                            SizedBox(
                                height: CustomStyle.getHeight(70.0),
                                child: TextField(
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value){
                                    userID.value = value;
                                  },
                                  maxLength: 50,
                                  decoration: InputDecoration(
                                      counterText: '',
                                      hintText: "아이디",
                                      hintStyle:CustomStyle.whiteFont(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: CustomStyle.getWidth(0.5))
                                      )

                                  ),
                                )
                            ),
                            _entryField(),
                            CustomStyle.sizedBoxHeight(20.0),
                            SizedBox(
                                width: width,
                                height: CustomStyle.getHeight(50.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        onPrimary: Colors.white
                                    ),
                                    onPressed: () async {
                                      if(validate()) await userLogin();
                                    },
                                    child:Text(
                                      Strings.of(context)?.get("login_btn")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize12, main_color,font_weight: FontWeight.w800),
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
                                        color: Colors.white,
                                        fontSize: styleFontSize15,
                                    )
                                ),
                              ) : const SizedBox(),
                                InkWell(
                                  onTap: () async {
                                    await goToFindUser();
                                  },
                                  child: Text(
                                      Strings.of(context)?.get("find_user")?? "Not Found",
                                      style: TextStyle(
                                        color: Colors.white,
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
