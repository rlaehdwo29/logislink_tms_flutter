import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/page/renewpage/template_manage_page.dart';
import 'package:logislink_tms_flutter/page/subpage/old_order_request_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/old_order_trans_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cargo_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_charge_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/old_regist_order_page.dart';
import 'package:logislink_tms_flutter/page/subpage/webview_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:fbroadcast/fbroadcast.dart' as FBroad;

import '../../constants/const.dart';
import 'order_trans_info_page.dart';

class AppBarSettingPage extends StatefulWidget {
  _AppBarSettingPageState createState() => _AppBarSettingPageState();
}

class _AppBarSettingPageState extends State<AppBarSettingPage> {
  final controller = Get.find<App>();

  final _wakeChecked = false.obs;
  final _pushChecked = false.obs;
  final _talkChecked = false.obs;
  final _screen = "기본".obs;

  final mOrderOption = OrderModel().obs;

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await Util.setEventLog("Settings", "설정");
      await initView();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _screen.value = await SP.getFirstScreen(context);
      _wakeChecked.value = await SP.getBoolean(Const.KEY_SETTING_WAKE);
      _pushChecked.value = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH);
      _talkChecked.value = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK);
    });
  }

  Future<void> initView() async {
    await getOrderOption();
  }

  Future<void> getOrderOption() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOption(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderOption() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            try{
              var list = _response.resultMap?["data"] as List;
              List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
              if(itemsList.length > 0) {
                mOrderOption.value = itemsList[0];
              }
            }catch(e) {
              print(e);
            }
          } else {
            mOrderOption.value = OrderModel();
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
          print("getOrderOption() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderOption() getOrder Default => ");
          break;
      }
    });
  }

  Future openSelectDialog(List mList,String? type) async {
    final typeValue = "기본".obs;
    typeValue.value = await SP.getFirstScreen(context);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: "시작화면",
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: App().isTablet(context) ? 0.5 :  0.35,
            child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                          child: Text(
                              "앱 실행 시\n초기 화면을 선택해주세요.",
                              style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                          )
                      ),
                      Expanded(
                          child: GridView.builder(
                              itemCount: mList?.length,
                              physics: ScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                childAspectRatio: (1 / 1),
                                mainAxisSpacing: 10, //수평 Padding
                                crossAxisSpacing: 10, //수직 Padding
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                var item = mList[index];
                                return Obx(() => InkWell(
                                    onTap: () async {
                                      typeValue.value = item;
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color:Colors.white,
                                            border: typeValue == item ? Border.all(width: 1,color: renew_main_color2) : Border.all(width: 1,color: light_gray24),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${mList?[index]}",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(
                                                styleFontSize12, typeValue == item ? renew_main_color2 : text_color_01,
                                                font_weight:  FontWeight.w600),
                                          ),
                                        )
                                    )
                                  )
                                );
                              }
                          )
                      ),
                      InkWell(
                          onTap: () async {
                            SP.putString(Const.KEY_SETTING_SCREEN,typeValue.value);
                            _screen.value = await SP.getFirstScreen(context);
                            Navigator.of(context).pop(false);
                          },
                          child: Center(
                              child: Container(
                                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.7,
                                height: CustomStyle.getHeight(50),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "적용",
                                  style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                ),
                              )
                          )
                      )
                    ]
                )
            )
        );
      },
    );
  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    String? push_id = await SP.get(Const.KEY_PUSH_ID) ?? "";
    var setting_push = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH);
    var setting_talk = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK);
    await DioService.dioClient(header: true).deviceUpdate(
      app.authorization,
      Util.booleanToYn(setting_push),
      Util.booleanToYn(setting_talk),
      push_id,
      controller.device_info["model"],
      controller.device_info["deviceOs"],
      controller.app_info["version"],
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("sendDeviceInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {

      } else {
        Util.toast("디바이스 정보 업데이트에 실패하였습니다.");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("old_appbar_setting_page.dart sendDeviceInfo() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          Util.toast("디바이스 정보 업데이트에 실패하였습니다.\n ${res?.statusMessage}");
          break;
        default:
          logger.e("old_appbar_setting_page.dart sendDeviceInfo() Error Default:");
          break;
      }
    });
  }

  Future<void> goToRequest() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OldOrderRequestInfoPage(order_vo: mOrderOption.value,code: Const.RESULT_SETTING_REQUEST,)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToSAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:OrderModel(),code:Const.RESULT_SETTING_SADDR)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToCargo() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCargoInfoPage(order_vo:mOrderOption.value,code:Const.RESULT_SETTING_CARGO)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToCharge() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderChargeInfoPage(
      order_vo:mOrderOption.value,
      unit_buy_charge_local: mOrderOption.value.buyCharge??"",
      unit_price_local: mOrderOption.value.unitPrice??"",
      unit_sell_charge_local: mOrderOption.value.sellCharge??"",
      code: Const.RESULT_SETTING_CHARGE,
    )));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToTrans() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderTransInfoPage(order_vo:mOrderOption.value,code: Const.RESULT_SETTING_TRANS)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setActivityResult(results);
      }
    }
  }

  Future<void> setActivityResult(Map<String,dynamic> results)async {
    switch(results[Const.RESULT_WORK]){
      case Const.RESULT_SETTING_REQUEST:
        Util.toast("화주 정보 설정이 저장되었습니다.");
        break;
      case Const.RESULT_SETTING_SADDR:
        Util.toast("상차지 설정이 저장되었습니다.");
        break;
      case Const.RESULT_SETTING_CARGO:
        Util.toast("화물 정보 설정이 저장되었습니다.");
        break;
      case Const.RESULT_SETTING_CHARGE:
        Util.toast("운임 정보 설정이 저장되었습니다.");
        break;
      case Const.RESULT_SETTING_TRANS:
        Util.toast("배차 정보 설정이 저장되었습니다.");
        break;
    }
    await getOrderOption();
    setState(() {});
  }

  Widget appSettingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Text(
              Strings.of(context)?.get("setting_work")??"업무 초기값 설정_",
              style: CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w700),
            )
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              // 1번째 Line
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      await goToRequest();
                    },
                    child: Container(
                      width:CustomStyle.getWidth(90),
                      height: CustomStyle.getHeight(90),
                      decoration: const BoxDecoration(
                        color: light_gray24,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                              "assets/image/ic_client.png",
                              width: CustomStyle.getWidth(38.0),
                              height: CustomStyle.getHeight(38.0),
                              color: renew_main_color2
                          ),
                          Container(
                            margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                            child: Text(
                              "화주 정보 설정",
                              style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                            )
                          )
                        ],
                      )
                    )
                  ),
                  InkWell(
                      onTap: () async {
                        await goToSAddr();
                      },
                      child: Container(
                          width:CustomStyle.getWidth(90),
                          height: CustomStyle.getHeight(90),
                          decoration: const BoxDecoration(
                              color: light_gray24,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                  "assets/image/ic_location.png",
                                  width: CustomStyle.getWidth(38.0),
                                  height: CustomStyle.getHeight(38.0),
                                  color: renew_main_color2
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                                  child: Text(
                                      "상차지 정보 설정",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                  )
                              )
                            ],
                          )
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        await goToCargo();
                      },
                      child: Container(
                          width:CustomStyle.getWidth(90),
                          height: CustomStyle.getHeight(90),
                          decoration: const BoxDecoration(
                              color: light_gray24,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                  "assets/image/ic_hwa.png",
                                  width: CustomStyle.getWidth(38.0),
                                  height: CustomStyle.getHeight(38.0),
                                  color: renew_main_color2
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                                  child: Text(
                                      "화물 정보 설정",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                  )
                              )
                            ],
                          )
                      )
                  )
                ],
              ),
              // 2번째 Line
            Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: () async {
                        await goToCharge();
                      },
                      child: Container(
                          width:CustomStyle.getWidth(90),
                          height: CustomStyle.getHeight(90),
                          decoration: const BoxDecoration(
                              color: light_gray24,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                  "assets/image/ic_sell.png",
                                  width: CustomStyle.getWidth(38.0),
                                  height: CustomStyle.getHeight(38.0),
                                  color: renew_main_color2
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                                  child: Text(
                                    "운임 정보 설정",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                  )
                              )
                            ],
                          )
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        await goToTrans();
                      },
                      child: Container(
                          width:CustomStyle.getWidth(90),
                          height: CustomStyle.getHeight(90),
                          decoration: const BoxDecoration(
                              color: light_gray24,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                  "assets/image/ic_support.png",
                                  width: CustomStyle.getWidth(38.0),
                                  height: CustomStyle.getHeight(38.0),
                                  color: renew_main_color2
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                                  child: Text(
                                    "배차 정보 설정",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                  )
                              )
                            ],
                          )
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(PageAnimationTransition(page: TemplateManagePage(), pageAnimationType: LeftToRightTransition()));
                      },
                      child: Container(
                          width:CustomStyle.getWidth(90),
                          height: CustomStyle.getHeight(90),
                          decoration: const BoxDecoration(
                              color: light_gray24,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                  "assets/image/ic_temple.png",
                                  width: CustomStyle.getWidth(38.0),
                                  height: CustomStyle.getHeight(38.0),
                                  color: renew_main_color2
                              ),
                              Container(
                                  margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                                  child: Text(
                                    "탬플릿 관리",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                  )
                              )
                            ],
                          )
                      )
                  )
                ],
              )
              )
            ],
          )
        ),
        Container(
          margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Text(
            Strings.of(context)?.get("setting_app")??"_앱 설정",
            style: CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w700),
          )
        ),
        // 시작 화면 설정
        InkWell(
          onTap: (){
            openSelectDialog(Const.first_screen,"S");
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_start_screen")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      _screen.value,
                      style: CustomStyle.CustomFont(styleFontSize14, text_box_color_01,font_weight: FontWeight.w700),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0.w)),
                      child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        // 화면 꺼짐 방지
        Container(
            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            decoration: const BoxDecoration(
                color: styleWhiteCol,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_wake")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Switch(
                    value: _wakeChecked.value,
                    activeColor: renew_main_color2,
                    onChanged: (value) {
                      setState(() async {
                        _wakeChecked.value = value;
                        await SP.putBool(Const.KEY_SETTING_WAKE, _wakeChecked.value);
                        await SP.getBoolean(Const.KEY_SETTING_WAKE) == true ? WakelockPlus.enable() : WakelockPlus.disable();
                        await sendDeviceInfo();
                      });
                    }
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget alramWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Text(
              Strings.of(context)?.get("setting_notice")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w700),
            )
        ),
        // 푸시메시지 수신
        Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
          decoration: const BoxDecoration(
              color: styleWhiteCol,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("setting_push")??"Not Found",
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
              ),
              Switch(
                  value: _pushChecked.value,
                  activeColor: renew_main_color2,
                  onChanged: (value) {
                    setState(() async {
                      _pushChecked.value = value;
                      await SP.putBool(Const.KEY_SETTING_PUSH, _pushChecked.value);
                      await sendDeviceInfo();
                    });
                  }
              )
            ],
          ),
        ),
        // 알림톡 수신
        Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
          decoration: const BoxDecoration(
              color: styleWhiteCol
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("setting_talk")??"Not Found",
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
              ),
              Switch(
                  value: _talkChecked.value,
                  activeColor: renew_main_color2,
                  onChanged: (value) {
                    setState(() async {
                      _talkChecked.value = value;
                      await SP.putBool(Const.KEY_SETTING_TALK, _talkChecked.value);
                      await sendDeviceInfo();
                    });
                  }
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget termsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
            color: Colors.white,
            child: Text(
              Strings.of(context)?.get("setting_terms")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w700),
            )
        ),
        // 이용약관
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_agree")??"Not Found", URL_AGREE_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            color: styleWhiteCol,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_agree")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 개인정보수집 이용동의
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_privacy")??"Not Found", URL_PRIVACY_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            color: styleWhiteCol,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_privacy")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          )
        ),
        // 개인정보 처리방침
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_privateInfo")??"Not Found", URL_PRIVATE_INFO_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            color: styleWhiteCol,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_privateInfo")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 데이터보안서약
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_dataSecure")??"Not Found", URL_DATA_SECURE_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            color: styleWhiteCol,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_dataSecure")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 마케팅 정보 수신 동의
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_marketing")??"Not Found", URL_MARKETING_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: styleWhiteCol,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_marketing")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget etcWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
            color: Colors.white,
            child: Text(
              Strings.of(context)?.get("setting_etc")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w700),
            )
        ),
        // 이용약관
        InkWell(
          onTap: () async {
            var url = Uri.parse(URL_MANUAL);
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            }
          },
          child: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: const BoxDecoration(
                color: styleWhiteCol,
                border: Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_manual")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: Icon(Icons.keyboard_arrow_right,size: 24.h,color: const Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          return Future((){
            FBroad.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
            return true;
          });
        },
        child: Scaffold(
      backgroundColor: light_gray24,
      appBar: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("drawer_menu_setting")??"Not Found",
                style: CustomStyle.appBarTitleFont(
                    styleFontSize16, styleBlackCol1)
            ),
            toolbarHeight: 50.h,
            leading: IconButton(
              onPressed: () {
                FBroad.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                Navigator.of(context).pop();
              },
              color: light_gray24,
              icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.black),
            ),
          ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  appSettingWidget(),
                  alramWidget(),
                  termsWidget(),
                  etcWidget()
                ],
              ),
            );
          }),
        ))
    );
  }

}