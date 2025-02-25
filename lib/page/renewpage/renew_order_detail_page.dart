import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fbroadcast/fbroadcast.dart' as BroadCast;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/car_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/order_link_status_sub_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/rpa_flag_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_general_regist_order_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_order_trans_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/link_page.dart';
import 'package:logislink_tms_flutter/page/subpage/location_control_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/receipt_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/regist_order_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/stop_point_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:phone_call/phone_call.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';

class RenewOrderDetailPage extends StatefulWidget {

  OrderModel? order_vo;
  String? code;
  int? position;
  String? allocId;

  RenewOrderDetailPage({Key? key,this.order_vo, this.code, this.position, this.allocId}):super(key:key);

  _RenewOrderDetailPageState createState() => _RenewOrderDetailPageState();
}


class _RenewOrderDetailPageState extends State<RenewOrderDetailPage> {

  ProgressDialog? pr;

  final mData = OrderModel().obs;

  final controller = Get.find<App>();

  final mStopList = List.empty(growable: true).obs;
  final mLinkStatusSub = OrderLinkStatusSubModel().obs;
  final mAllocId = "".obs;

  final tvOrderCancel = false.obs;
  final tvReOrder = false.obs;
  final tvAlloc = false.obs;
  final tvModify = false.obs;
  final tvAllocCancel = false.obs;
  final tvAllocReg = false.obs;

  final tvOrderState = false.obs;
  final tvAllocState = false.obs;
  final llDriverInfo = false.obs;

  final llStopPointHeader = false.obs;
  final llStopPointList = false.obs;
  final llBottom = false.obs;
  final mRpaUseYn = "".obs;
  final mLinkState = false.obs;
  final tvSendLink = false.obs;
  final tvReceipt = false.obs;

  final isStopPointExpanded = [].obs;
  final isCargoExpanded = [].obs;
  final isEtcExpanded = [].obs;

  late TextEditingController etCarNumController;
  late TextEditingController etDriverNameController;
  late TextEditingController etTelController;
  late TextEditingController etCarTypeController;
  late TextEditingController etCarTonController;

  @override
  void initState() {
    super.initState();

    BroadCast.FBroadcast.instance().register(Const.INTENT_ORDER_DETAIL_REFRESH, (value, callback) async {
      if(mData.value.orderId != null) {
        await getOrderLinkStatusSub();
      }
      if(!(mAllocId.value == "") && mAllocId.value != null) {
        await getOrderLinkStatusAlloc(mAllocId.value);
      }
      await rpaUseYnResume();
    },context: this);

    etCarNumController = TextEditingController();
    etDriverNameController = TextEditingController();
    etTelController = TextEditingController();
    etCarTypeController = TextEditingController();
    etCarTonController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      if(widget.order_vo != null) {
        mData.value = widget.order_vo!;
      }else{
        mData.value = OrderModel();
      }

      if(mData.value.orderId != null) {
        await rpaUseYn();
        await getOrderLinkStatusSub();
      }else{
        if(widget.allocId != null) {
          mAllocId.value = widget.allocId!;
          await getOrderLinkStatusAlloc(mAllocId.value);
          await getOrderDetail(mAllocId.value);
        }else{
          Navigator.of(context).pop();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // 앱이 표시되고 사용자 입력에 응답합니다.
      // 주의! 최초 앱 실행때는 해당 이벤트가 발생하지 않습니다.
        BroadCast.FBroadcast.instance().broadcast(Const.INTENT_ORDER_DETAIL_REFRESH);
        print("resumed");
        break;
      case AppLifecycleState.inactive:
      // 앱이 비활성화 상태이고 사용자의 입력을 받지 않습니다.
      // ios에서는 포 그라운드 비활성 상태에서 실행되는 앱 또는 Flutter 호스트 뷰에 해당합니다.
      // 안드로이드에서는 화면 분할 앱, 전화 통화, PIP 앱, 시스템 대화 상자 또는 다른 창과 같은 다른 활동이 집중되면 앱이이 상태로 전환됩니다.
      // inactive가 발생되고 얼마후 pasued가 발생합니다.
        print("inactive");
        break;
      case AppLifecycleState.paused:
      // 앱이 현재 사용자에게 보이지 않고, 사용자의 입력을 받지 않으며, 백그라운드에서 동작 중입니다.
      // 안드로이드의 onPause()와 동일합니다.
      // 응용 프로그램이 이 상태에 있으면 엔진은 Window.onBeginFrame 및 Window.onDrawFrame 콜백을 호출하지 않습니다.
        print("paused");
        break;
      case AppLifecycleState.detached:
      // 응용 프로그램은 여전히 flutter 엔진에서 호스팅되지만 "호스트 View"에서 분리됩니다.
      // 앱이 이 상태에 있으면 엔진이 "View"없이 실행됩니다.
      // 엔진이 처음 초기화 될 때 "View" 연결 진행 중이거나 네비게이터 팝으로 인해 "View"가 파괴 된 후 일 수 있습니다.
        print("detached");
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  void dispose() {
    super.dispose();
    etCarNumController.dispose();
    etDriverNameController.dispose();
    etTelController.dispose();
    etCarTypeController.dispose();
    etCarTonController.dispose();
  }

  // Function Start

  int chargeTotal(String? chargeFlag) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(mData.value.sellCharge ?? "0") +
          int.parse(mData.value.sellWayPointCharge ?? "0") +
          int.parse(mData.value.sellStayCharge ?? "0") +
          int.parse(mData.value.sellHandWorkCharge ?? "0") +
          int.parse(mData.value.sellRoundCharge ?? "0") +
          int.parse(mData.value.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(mData.value.buyCharge ?? "0") +
          int.parse(mData.value.wayPointCharge ?? "0") +
          int.parse(mData.value.stayCharge ?? "0") +
          int.parse(mData.value.handWorkCharge ?? "0") +
          int.parse(mData.value.roundCharge ?? "0") +
          int.parse(mData.value.otherAddCharge ?? "0") -
          int.parse(mData.value.sellFee ?? "0");
    }
    return total;
  }


  // Function End


  // Widget Start

  Widget HorizontalDashedDivider() {
    final DividerThemeData dividerTheme = DividerTheme.of(context);

    return Padding(
        padding: EdgeInsets.only(top: CustomStyle.getHeight(0),bottom: CustomStyle.getHeight(0)),
        child: Container(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final dashCount = App().isTablet(context) ? (constraints.constrainWidth().toInt() / 15.0).floor() : (constraints.constrainWidth().toInt() / 8.0).floor();
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                        width: CustomStyle.getWidth(3),
                        height:  CustomStyle.getHeight(1),
                        child: const DecoratedBox(
                            decoration: BoxDecoration(color: light_gray18)
                        )
                    );
                  }),
                );
              },
            )
        )
    );
  }

  Widget orderEtcChargeWidget(String chargeFlag) {
    return Column(
      children: [
        //수수료
        Util.equalsCharge(chargeFlag == "S" ? mData.value.buyFee??"0" : mData.value.sellFee??"0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        textAlign: TextAlign.left,
                        Strings.of(context)?.get("order_charge_info_sell_fee")??"수수료_()" ,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " - ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.buyFee??"0": mData.value.sellFee??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ):const SizedBox(),
        // 경유비(지불)
        Util.equalsCharge(chargeFlag == "S" ? mData.value.sellWayPointCharge??"0" : mData.value.wayPointCharge??"0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        textAlign: TextAlign.left,
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_way_point_charge" : "order_trans_info_way_point_charge")??"경유지_()" ,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellWayPointCharge??"0": mData.value.wayPointCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ):const SizedBox(),
        // 대기료(지불)
        Util.equalsCharge(chargeFlag == "S" ? mData.value.sellStayCharge??"0" : mData.value.stayCharge??"0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_stay_charge" : "order_trans_info_stay_charge")??"대기료_()" ,
                        textAlign: TextAlign.left,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellStayCharge??"0" : mData.value.stayCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 수작업비(지불)
        Util.equalsCharge(chargeFlag == "S" ? mData.value.sellHandWorkCharge??"0" : mData.value.handWorkCharge??"0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                      child: Text(
                        Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_hand_work_charge" : "order_trans_info_hand_work_charge")??"수작업비_()",
                        textAlign: TextAlign.left,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 4,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellHandWorkCharge??"0" : mData.value.handWorkCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 회차료(지불)
        Util.equalsCharge(chargeFlag == "S" ? mData.value.sellRoundCharge??"0" : mData.value.roundCharge ?? "0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_round_charge" : "order_trans_info_round_charge")??"회차료_()",
                        textAlign: TextAlign.left,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellRoundCharge??"0" : mData.value.roundCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 기타추가비(지불)
        Util.equalsCharge(chargeFlag == "S" ? mData.value.sellOtherAddCharge??"0" : mData.value.otherAddCharge??"0") ?
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_other_add_charge" : "order_trans_info_other_add_charge")??"기타추가비_()",
                        textAlign: TextAlign.left,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellOtherAddCharge??"0" : mData.value.otherAddCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
            height: CustomStyle.getHeight(1),
            color: light_gray19
        ),
      ]
    );
  }

  Widget cargoInfoPannel() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"수출입구분_",
              style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
            ),
            Text(
              mData.value.inOutSctnName??"",
              style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
            )
          ]
        ),
        Container(
          margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("order_cargo_info_truck_type")??"운송유형_",
                  style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                ),
                Text(
                  mData.value.truckTypeName??"",
                  style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                )
              ]
          )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_car_ton")??"톤수_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.carTonName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_car_type")??"차종_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.carTypeName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(15)),
                    child: Text(
                      Strings.of(context)?.get("order_cargo_info_cargo")??"화물정보_",
                      style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                    )
                  ),
                  Flexible(
                      child: RichText(
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: "${mData.value.goodsName}",
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                          )
                      )
                  ),
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"운송품목_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.itemName??"-",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_wgt")??"적재중량_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    "${mData.value.goodsWeight} ${mData.value.weightUnitCode}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_way_on")??"상차방법_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.sWayName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_way_off")??"하차방법_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.eWayName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_mix_type")??"혼적여부_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.mixYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_mix_y")}":"${Strings.of(context)?.get("order_cargo_info_mix_n")}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_return_type")??"왕복여부_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.returnYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_return_y")}":"${Strings.of(context)?.get("order_cargo_info_return_n")}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
      ],
    );
  }

  // Widget End

  Future<void> goToLocationControl() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LocationControlPage(order_vo:mData.value)));
  }

  bool equalsCharge(String? text) {
    if(text != null) {
      return !(text == "0");
    }else{
      return false;
    }
  }

  Future<void> copyOrder() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegistOrderPage(order_vo:mData.value,flag: "CR",)));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["link"] != null) {
          if(results["link"] != null && results["link"] == "") {
            mAllocId.value = results["link"];
          }
        }
      }
    }

  }

  Future<void> getOrderDetail(String? allocId) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderDetail(
      user.authorization,
      allocId,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getOrderDetail() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              try {
                var list = _response.resultMap?["data"] as List;
                List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
                if(itemsList.length > 0){
                  mData.value = itemsList[0];
                  await rpaUseYn();
                }else{
                  openOkBox(context,"삭제되었거나 완료된 오더입니다.", Strings.of(context)?.get("confirm")??"Not Found", () { Navigator.of(context).pop(false);});
                }
              } catch (e) {
                print(e);
              }
            }else{
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getOrderDetail() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderDetail() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderDetail() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showNoDetail() async {
    await openOkBox(context,"삭제되었거나 완료된 오더입니다.", Strings.of(context)?.get("confirm")??"Not Found", () { Navigator.of(context).pop(false);});
  }

  Future<void> goToStopPoint() async {
    if(mStopList.value.length == 0) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => StopPointPage(code:"detail",result_work_stopPoint:jsonEncode(mStopList.value))));
    }else{
      await getStopPoint();
    }
  }

  Future<void> getStopPoint() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getStopPoint(
        user.authorization,
        mData.value.orderId
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              List<StopPointModel> itemsList = list.map((i) => StopPointModel.fromJSON(i)).toList();
              if (mStopList.isNotEmpty) mStopList.clear();
              mStopList?.addAll(itemsList);
              await goToStopPoint();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getStopPoint() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getStopPoint() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getStopPoint() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getOrderLinkStatusSub() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).currentNewLinkSub(
        user.authorization,
        mData.value.orderId
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getOrderLinkStatusSub() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              OrderLinkStatusSubModel newLinkStatusSub = OrderLinkStatusSubModel.fromJSON(it.response.data["data"]);
              mLinkStatusSub.value = newLinkStatusSub;
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getOrderLinkStatusSub() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderLinkStatusSub() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderLinkStatusSub() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getOrderLinkStatusAlloc(String? allocId) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).currentNewLinkAlloc(
        user.authorization,
        allocId
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getOrderLinkStatusAlloc() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              OrderLinkStatusSubModel newLinkStatusSub = OrderLinkStatusSubModel.fromJSON(it.response.data["data"]);
              mLinkStatusSub.value = newLinkStatusSub;
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getOrderLinkStatusAlloc() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderLinkStatusAlloc() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderLinkStatusAlloc() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getStopPointFore() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getStopPoint(
        user.authorization,
        mData.value.orderId
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getStopPointFore() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              List<StopPointModel> itemsList = list.map((i) => StopPointModel.fromJSON(i)).toList();
              if (mStopList.isNotEmpty) mStopList.clear();
              mStopList?.addAll(itemsList);
              await getRpaLinkFlag();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getStopPointFore() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getStopPointFore() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getStopPointFore() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getRpaLinkFlag() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getLinkFlag(user.authorization).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getRpaLinkFlag() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              List<RpaFlagModel> itemsList = list.map((i) => RpaFlagModel.fromJSON(i)).toList();
              if(itemsList.length != 0) {
                mLinkState.value = true;
              }else{
                mLinkState.value = false;
              }
              await initView();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getRpaLinkFlag() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getRpaLinkFlag() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getRpaLinkFlag() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> rpaUseYn() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).rpaUseYn(user.authorization).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("rpaUseYn() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
              mRpaUseYn.value = _response.resultMap?["msg"];
              logger.i("cheraf ... rpaUseYn: ${mRpaUseYn.value}");
              await getStopPointFore();
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("rpaUseYn() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("rpaUseYn() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("rpaUseYn() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> rpaUseYnResume() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).rpaUseYn(user.authorization).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("rpaUseYnResume() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            mRpaUseYn.value = _response.resultMap?["msg"];
            logger.i("cheraf ... rpaUseYn: ${mRpaUseYn.value}");
            if(mData.value.orderId != null) await initView();
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("rpaUseYnResume() Exeption =>$e");
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("rpaUseYnResume() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("rpaUseYnResume() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> goToAlloc() async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RenewOrderTransInfoPage(order_vo: mData.value), pageAnimationType: LeftToRightTransition()));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        await Util.setEventLog(URL_ORDER_ALLOC_REG, "배차하기_M${Platform.isAndroid ? "A" : "I"}");
        Util.toast("배차가 완료되었습니다.");
        await getOrderDetail(mData.value.sellAllocId);
      }
    }
  }

  Future<void> showOrderCancel() async {
    openCommonConfirmBox(
        context,
        "오더를 취소하시겠습니까?",
        "닫기",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await setOrderCancel("09");
        }
    );
  }

  Future<void> showReOrder() async {
    openCommonConfirmBox(
        context,
        "오더를 접수하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await _setOrderState("00");
        }
    );
  }

  Future<void> _setOrderState(String state) async {
    // 재 오더 시
    // 정보망 전송 까지 다시 보내는것으로 처리
    // Junghwan.Hwang - 2023-08-22

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();

    await DioService.dioClient(header: true).stateOrder(
        user.authorization,
        mData.value.orderId,
        state,
        mData.value.call24Cargo,
        mData.value.oneCargo,
        mData.value.manCargo,
        mData.value.call24Charge,
        mData.value.oneCharge,
        mData.value.manCharge
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("_setOrderState() _response -> ${_response.status} // ${_response.resultMap}");
      try {
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.snackbar(context, "오더가 접수되었습니다.");
            await Util.setEventLog(URL_ORDER_STATE, "오더접수_M${Platform.isAndroid ? "A" : "I"}");
            await getOrderDetail(mData.value.sellAllocId);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("_setOrderState() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("_setOrderState() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("_setOrderState() getOrder Default => ");
          break;
      }
    });

  }

  Future<void> setOrderCancel(String state) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelOrder(
        user.authorization,
        mData.value.orderId,
        state,
        mData.value.call24Cargo,
        mData.value.oneCargo,
        mData.value.manCargo,
        mData.value.call24Charge,
        mData.value.oneCharge,
        mData.value.manCharge
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("setOrderCancel() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.snackbar(context,"오더가 취소되었습니다.");
            await getOrderDetail(mData.value.sellAllocId);

            if(mLinkStatusSub != null) {
              if(!(mLinkStatusSub.value.call24Cargo != "" && mLinkStatusSub.value.call24Cargo != null)) {
                if(!(mLinkStatusSub.value.call24Cargo == "D")) {
                  _cancelLink(mLinkStatusSub.value.call24Cargo,"24Cargo",false);
                }
              }

              if(!(mLinkStatusSub.value.oneCargo != "" && mLinkStatusSub.value.oneCargo != null)) {
                if(!(mLinkStatusSub.value.oneCargo == "D")) {
                  _cancelLink(mLinkStatusSub.value.oneCharge,"oneCargo",false);
                }
              }

              if(!(mLinkStatusSub.value.manCargo != "" && mLinkStatusSub.value.manCargo != null)) {
                if(!(mLinkStatusSub.value.manCargo == "D")) {
                  _cancelLink(mLinkStatusSub.value.manCargo,"manCargo",false);
                }
              }
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
          await Util.setEventLog(URL_ORDER_CANCEL, "오더 취소_M${Platform.isAndroid ? "A" : "I"}");
        }
      }catch(e) {
        print("setOrderCancel() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setOrderCancel() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setOrderCancel() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showAllocCancel() async {
    openCommonConfirmBox(
        context,
        mData.value.buyLinkYn == "Y" ? "정보망 배차를 취소하시겠습니까?" : "배차를 취소하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          if(mData.value.buyLinkYn == "Y") {
            await cancelLink();
          }else{
            await _setAllocState("00");
          }
        }
    );
  }

  Future<void> _setAllocState(String? state) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setAllocState(
        user.authorization,
        mData.value.orderId,
        mData.value.allocId,
        state
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("_setAllocState() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            await Util.setEventLog(URL_ORDER_ALLOC_STATE, "배차취소_M${Platform.isAndroid ? "A" : "I"}");
            await getOrderDetail(mData.value.sellAllocId);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }else{
          Util.toast(_response.message);
        }
      }catch(e) {
        print("_setAllocState() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("_setAllocState() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("_setAllocState() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> _cancelLink(String? rpqPay, String LinkCd, bool flag) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelNewLink(
        user.authorization,
        mData.value.orderId,
        rpqPay,
      "09",
      LinkCd
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("_cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(flag) {
              logger.i("Cancel Check => $LinkCd");
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("_cancelLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("_cancelLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("_cancelLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> cancelLink() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelLink(
        user.authorization,
        mData.value.orderId,
        mData.value.allocId,
        "CANCELALLOC",
        mData.value.linkType,
        "01"
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("정보망 배차가 취소되었습니다.");
            await Util.setEventLog(URL_SEND_LINK, "(정보망) 배차취소_M${Platform.isAndroid ? "A" : "I"}");
            await getOrderDetail(mData.value.sellAllocId??"");
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("cancelLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("cancelLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("cancelLink() getOrder Default => ");
          break;
      }
    });
  }

  Future showAllocReg() async {
    etCarNumController.text = "";
    etDriverNameController.text = "";
    etTelController.text = "";
    etCarTypeController.text = "";
    etCarTonController.text = "";

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context ){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))
                    ),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(5.0)),
                        decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                        child: Text(
                          '${Strings.of(context)?.get("order_detail_vehicle_dispatch")}',
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                        )
                    ),
                    content: SingleChildScrollView(
                          child: SizedBox(
                              width:MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.9,
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 차량번호(필수)
                                Container(
                                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5),top:CustomStyle.getHeight(10), left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5)),
                                            child: Text(
                                              Strings.of(context)?.get("order_detail_car_num")??"차랑변호_",
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            )
                                        ),
                                        Text(
                                          Strings.of(context)?.get("essential")??"(필수_)",
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                        )
                                      ],
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                                    height: CustomStyle.getHeight(35),
                                    child: TextField(
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      controller: etCarNumController,
                                      maxLines: 1,
                                      decoration: etCarNumController.text.isNotEmpty
                                          ? InputDecoration(
                                        counterText: '',
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                            borderRadius: BorderRadius.circular(5.h)
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                            borderRadius: BorderRadius.circular(5.h)
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            etCarNumController.clear();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            size: 18.h,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                          : InputDecoration(
                                        counterText: '',
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                            borderRadius: BorderRadius.circular(5.h)
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                            borderRadius: BorderRadius.circular(5.h)
                                        ),
                                      ),
                                      onChanged: (value){
                                      },
                                      maxLength: 50,
                                    )
                                ),
                                // 성명/연락처
                                Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_driver_name")??"성명_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(5)),
                                                  height: CustomStyle.getHeight(35),
                                                  child: TextField(
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                    textAlign: TextAlign.start,
                                                    keyboardType: TextInputType.text,
                                                    controller: etDriverNameController,
                                                    maxLines: 1,
                                                    decoration: etDriverNameController.text.isNotEmpty
                                                        ? InputDecoration(
                                                      counterText: '',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      disabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      suffixIcon: IconButton(
                                                        onPressed: () {
                                                          etDriverNameController.clear();
                                                        },
                                                        icon: Icon(
                                                          Icons.clear,
                                                          size: 18.h,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                        : InputDecoration(
                                                      counterText: '',
                                                     contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      disabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                    ),
                                                    onChanged: (value){
                                                    },
                                                    maxLength: 50,
                                                  )
                                              ),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(5)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_driver_tel")??"연락처_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5),left: CustomStyle.getWidth(5)),
                                                  height: CustomStyle.getHeight(35),
                                                  child: TextField(
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                    textAlign: TextAlign.start,
                                                    keyboardType: TextInputType.phone,
                                                    controller: etTelController,
                                                    maxLines: 1,
                                                    decoration: etDriverNameController.text.isNotEmpty
                                                        ? InputDecoration(
                                                      counterText: '',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      disabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      suffixIcon: IconButton(
                                                        onPressed: () {
                                                          etDriverNameController.clear();
                                                        },
                                                        icon: Icon(
                                                          Icons.clear,
                                                          size: 18.h,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                        : InputDecoration(
                                                      counterText: '',
                                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                      disabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5))
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                          borderRadius: BorderRadius.circular(5.h)
                                                      ),
                                                    ),
                                                    onChanged: (value){
                                                    },
                                                    maxLength: 50,
                                                  )
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                // 차종 / 톤급
                                Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_type_code")??"차종_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                width:double.infinity,
                                                height: CustomStyle.getHeight(30),
                                                margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: text_color_01,width: 0.5.w),
                                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                ),
                                                child: Text(
                                                  "",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5),left: CustomStyle.getWidth(5)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_ton_code")??"톤급_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                width:double.infinity,
                                                height: CustomStyle.getHeight(30),
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: text_color_01,width: 0.5.w),
                                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                ),
                                                child: Text(
                                                  "",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: CustomStyle.getHeight(50),
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop(false);
                                              },
                                              child: Container(
                                                  color: sub_btn,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    Strings.of(context)?.get("cancel") ?? "취소_",
                                                    style: CustomStyle
                                                        .CustomFont(
                                                        styleFontSize16,
                                                        Colors.white),
                                                  )
                                              )
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: InkWell(
                                              onTap: () async {
                                                var validation = await allocRegValid();
                                                if(validation){
                                                  if(Util.regexCarNumber(etCarNumController.text.trim())) {
                                                    Util.toast("차량번호를 확인해 주세요.");
                                                  }else{
                                                    CarModel car = CarModel();
                                                    car.carNum = etCarNumController.text.trim();
                                                    car.driverName = etDriverNameController.text.trim();
                                                    car.mobile = etTelController.text.trim();
                                                    await setAllocReg(car);
                                                    Navigator.of(context).pop();
                                                  }
                                                }
                                              },
                                              child: Container(
                                                  color: main_btn,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    Strings.of(context)?.get("confirm") ?? "확인_",
                                                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                                                  )
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                )

                              ]
                          ))
                      )
                );
              }
          );
        }
    );
  }

  Future<bool> allocRegValid() async {
    if(etCarNumController.text.trim().isEmpty) {
      Util.toast("차량번호를 입력해주세요.");
      return false;
    }
    if(etDriverNameController.text.trim().isEmpty) {
      Util.toast("파주성명을 입력해 주세요.");
      return false;
    }
    if(etTelController.text.trim().isEmpty) {
      Util.toast("연락처를 입력해 주세요.");
      return false;
    }
    return true;
  }

  Future<void> setAllocReg(CarModel car) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).orderAllocReg(
        user.authorization,
        mData.value.orderId,
        mData.value.allocId,
        mData.value.buyCustId,
        mData.value.buyDeptId,
        mData.value.buyStaff,
        mData.value.buyStaffTel,
        car.vehicId,
        car.driverId,
        car.carNum,
        mData.value.carTonCode,
        mData.value.carTypeCode,
        car.driverName,
        car.mobile
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("setAllocReg() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            await getOrderDetail(mData.value.sellAllocId);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("setAllocReg() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setAllocReg() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setAllocReg() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setOrderState() async {
    if(mData.value.orderState == "09") {
      tvOrderState.value = true;
      tvAllocState.value = false;
      llDriverInfo.value = false;
    }else{
      if(mData.value.driverState != null) {
        tvOrderState.value = false;
        tvAllocState.value = false;
        llDriverInfo.value = true;
      }else{
        tvOrderState.value = false;
        tvAllocState.value = true;
        llDriverInfo.value = false;
      }
    }
  }

  Future<void> setAllocState() async {
    llBottom.value = true;
    await setVisibilitySendLink(false);
    switch(mData.value.allocState) {
      case "00" :
        // 접수
        if(mData.value.orderState == "09") { // 09 재접수
          tvReOrder.value = true;
          tvModify.value = true;
          await setVisibilitySendLink(false);
          tvOrderCancel.value = false;
          tvAlloc.value = false;
        }else{
          tvReOrder.value = false;
          await setVisibilitySendLink(true);
          tvOrderCancel.value = true;
          tvAlloc.value = true;
          tvModify.value = true;
        }
        tvAllocCancel.value = false;
        tvAllocReg.value = false;
        break;
      case "01" :
      case "20" :
        if(mData.value.buyLinkYn == "Y") {
          await setVisibilitySendLink(true);
        }
        // 배차, 취소요청
        tvReOrder.value = false;
        tvOrderCancel.value = false;

        tvAlloc.value = false;
        tvAllocCancel.value = true;
        tvModify.value = true;
        tvAllocReg.value = false;
        break;

      case "04":
      case "05":
      case "12":
      case "21":
        //출발, 도착, 입차, 취소
        llBottom.value = false;
        break;
      case "10": //운송사지정
        tvReOrder.value = false;
        tvOrderCancel.value = false;

        if(mData.value.orderState == "00") {
          tvAlloc.value = false;
          tvModify.value = true;
          tvAllocCancel.value = true;
          tvAllocReg.value = true;
        }else if(mData.value.orderState == "01") {
          tvAlloc.value = false;
          tvModify.value = true;
          tvAllocCancel.value = true;
          tvAllocReg.value = false;
        }else{
          llBottom.value = false;
        }
        break;
      case "11":
      case "13":
      case "23":
      case "24":
      case "25":
        await setVisibilitySendLink(true);

        // 정보망접수, 정보망접수 완료, 배차실패(화물맨), 배차대기(화물맨), 정보망오류
      if(mData.value.orderState == "00" || mData.value.orderState =="01"){
        tvReOrder.value = false;
        tvAlloc.value = true;
        tvModify.value = true;
        tvAllocCancel.value = false;
        tvOrderCancel.value = true;
        tvAllocReg.value = false;
      }else{
        llBottom.value = false;
      }
      break;
    }
  }

  Future<void> setVisibilitySendLink(bool val) async {
    if(mRpaUseYn.value == "Y") {
      if(mLinkState.value) {
        // 정보망 전송 버튼 활성화, 비활성화
        // 수정 메뉴 정하기 전까지 일단 활성화 하지 말 것
        tvSendLink.value = val? true : false;
      }else{
        tvSendLink.value = false;
      }
    }else{
      tvSendLink.value = false;
    }
  }

  Future<void> showDriverState() async {
    if(mData.value.allocState == "05") {
      return;
    }
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_detail_driver_state_edit")??"", codeType: Const.DRIVER_STATE, mFilter: "", callback: selectDriverState).showDialog();
  }

  void selectDriverState(CodeModel? codeModel,String? codeType) {
    if(codeType != ""){
      switch(codeType) {
        case 'DRIVER_STATE':
          if(codeModel?.code == "21") {
            if(!(mData.value.allocState == "01")) {
              Util.toast("운행이 시작된 후엔 취소할 수 없습니다.");
              return;
            }
          }
          _setAllocState(codeModel?.code);
          break;
      }
      setState(() {});
    }
  }

  Future<void> goToSendLink() async {
    if(mData.value.carTonName == "톤") {
      if(Util.checkTonOver(mData.value.carTonName??"0톤".split("톤")[0], mData.value.goodsWeight??"0.0")){
        Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LinkPage(order_vo: mData.value)));

        if(results != null && results.containsKey("code")) {
          if (results["code"] == 200) {
            if(results["link"] != null) {
              if(results["link"] == "Y") {
                Navigator.of(context).pop({'code' : 200});
              }
            }
          }
        }
      }else{
        Util.toast("과적은 정보망에 전송할 수 없습니다.");
      }
    }else{
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LinkPage(order_vo: mData.value)));

      if(results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          if(results["link"] != null) {
            if(results["link"] == "Y") {
              Navigator.of(context).pop({'code' : 200});
            }
          }
        }
      }
    }
  }

  Future<void> goToReceipt() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ReceiptPage(order_vo: mData.value)));
  }

  Future<void> initView() async {
    await setOrderState();
    await setAllocState();
    setState(() {
      if(mData.value.stopCount != 0) {
        llStopPointHeader.value = true;
        llStopPointList.value = true;
      }else{
        llStopPointHeader.value = false;
        llStopPointList.value = false;
      }

      if(!(mData.value.receiptYn == "N")) {
        tvReceipt.value = true;
      }else{
        tvReceipt.value = false;
      }
    });
  }

  Widget orderSellWidget() {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(10),
        child: Column(
      children: [
        Container(
          padding:  tvAllocState.value ? EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15)) : EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  mData.value.sellCustName?.isNotEmpty == true?
                  Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          mData.value.sellCustName??"",
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                        ),
                      ) : const SizedBox(),
                  mData.value.sellDeptName?.isNotEmpty == true?
                  Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          mData.value.sellDeptName??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      ) : const SizedBox(),
                ],
              ),
              tvOrderState.value ?
              Container(
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                  child: Text(
                    mData.value.orderStateName??"접수_",
                    style: CustomStyle.CustomFont(styleFontSize14, order_state_01,font_weight: FontWeight.w700),
                  )
              ) : const SizedBox(),
            ],
          ),
        ) ,
        // 운송사 접수
        tvAllocState.value ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15), top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                      child: Text(
                        mData.value.allocStateName??"운송사접수",
                        style: CustomStyle.CustomFont(styleFontSize15, order_state_01,font_weight: FontWeight.w700),
                      )
                  )
              ),
              mData.value.linkName?.isNotEmpty == true ?
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                    child: Text(
                      mData.value.linkName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
              mData.value.buyCustName?.isNotEmpty == true ?
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                    child: Text(
                      mData.value.buyCustName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
              mData.value.buyDeptName?.isNotEmpty == true ?
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                    child: Text(
                      mData.value.buyDeptName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
            ],
          ),
        ) : const SizedBox(),
        HorizontalDashedDivider(),
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(top: CustomStyle.getHeight(10), right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        textAlign: TextAlign.left,
                        "청구운임",
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    "${Util.getInCodeCommaWon(mData.value.sellCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ),
        orderEtcChargeWidget("S"),
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5),bottom: CustomStyle.getHeight(10)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        textAlign: TextAlign.left,
                        "청구운임(소계)",
                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    "${Util.getInCodeCommaWon(chargeTotal("S").toString())} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                  )
              ),
            ],
          ),
        ),
        HorizontalDashedDivider(),
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(top: CustomStyle.getHeight(10), right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
          child: Row(
            children: [
              tvAllocState.value ?
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                      child: Text(
                        mData.value.allocStateName??"운송사접수",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ) : Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                      child: Text(
                        "지불운임",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  )
              ) ,
              mData.value.linkName?.isNotEmpty == true ?
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                    child: Text(
                      mData.value.linkName??"",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
              mData.value.buyCustName?.isNotEmpty == true ?
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                    child: Text(
                      mData.value.buyCustName??"",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
              mData.value.buyDeptName?.isNotEmpty == true ?
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                    child: Text(
                      mData.value.buyDeptName??"",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                  )
              ) : const SizedBox(),
              Expanded(
                  flex: 2,
                  child: Text(
                    "${Util.getInCodeCommaWon(mData.value.buyCharge??"0")} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ),
        orderEtcChargeWidget("T"),
        Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
          padding: EdgeInsets.only(left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5),bottom: CustomStyle.getHeight(10)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                      child: Text(
                        textAlign: TextAlign.left,
                        "지불운임(소계)",
                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                      )
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    "${Util.getInCodeCommaWon(chargeTotal("T").toString())} 원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                  )
              ),
            ],
          ),
        ),
      ],
    )
    );
  }

  Widget driverInfoWidget() {
    return Container(
        margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                child: Text(
                  mData.value.driverStateName??"출발",
                  style: CustomStyle.CustomFont(styleFontSize18, order_state_01, font_weight: FontWeight.w700),
                )
              ),
              Container(
                padding: EdgeInsets.all(10.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tvReceipt.value?
                    InkWell(
                        onTap: () async {
                          await goToReceipt();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                          decoration: BoxDecoration(
                              border: Border.all(color: order_state_01,width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                          ),
                          child: Text(
                            "인수증 확인",
                            style: CustomStyle.CustomFont(styleFontSize12, order_state_01),
                          ),
                        )
                    ) :const SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
        HorizontalDashedDivider(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(5)),
          child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                mData.value.driverName == null ? "" : "${mData.value.driverName}",
                                style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w700),
                              ),
                              Text(
                                " 차주님",
                                style: CustomStyle.CustomFont(styleFontSize18, text_color_01),
                              ),
                            ],
                          )
                      ),
                      Text(
                        mData.value.carNum??"",
                        style: CustomStyle.CustomFont(styleFontSize18, text_color_01,font_weight: FontWeight.w500),
                      ),
                    ],
                  )
                ),
                Expanded(
                        flex: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                          InkWell(
                              onTap: () async {
                                if (Platform.isAndroid) {
                                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                  AndroidDeviceInfo info = await deviceInfo.androidInfo;
                                  if (info.version.sdkInt >= 23) {
                                    await PhoneCall.calling("${mData.value.driverTel}");
                                  } else {
                                    await launch("tel://${mData.value.driverTel}");
                                  }
                                } else {
                                  await launch("tel://${mData.value.driverTel}");
                                }
                              },
                              child: Container(
                                width: CustomStyle.getWidth(40),
                                height: CustomStyle.getHeight(40),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(50),
                                  color: renew_main_color2
                                ),
                                child:  const Icon(Icons.call,size: 28,color: Colors.white)
                              )

                          ),
                          InkWell(
                              onTap:(){
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LocationControlPage(order_vo: mData.value)));
                              } ,
                              child:  Container(
                                  width: CustomStyle.getWidth(40),
                                  height: CustomStyle.getHeight(40),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadiusDirectional.circular(50),
                                      color: renew_main_color2
                                  ),
                                  child:  const Icon(Icons.location_on_outlined,size: 28,color: Colors.white)
                              )
                          ),
                        ]
                      )
                    )
                  ],
            )
        ),
        HorizontalDashedDivider(),
              //입차
              mData.value.enterDate != null ?
              Container(
                padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5), top: CustomStyle.getHeight(10), right: CustomStyle.getWidth(10), left: CustomStyle.getWidth(10)),
                child:  Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_reg_enter")??"입차",
                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                        child: Text(
                          mData.value.enterDate??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                  ],
                )
              ) : const SizedBox(),
              // 출발
              mData.value.startDate != null ?
              Container(
                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5), top: CustomStyle.getHeight(5), right: CustomStyle.getWidth(10), left: CustomStyle.getWidth(10)),
                  child:  Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("order_reg_start")??"출발",
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                          child: Text(
                            mData.value.startDate??"",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ) : const SizedBox(),
              // 도착
              mData.value.finishDate != null ?
              Container(
                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10), top: CustomStyle.getHeight(5), right: CustomStyle.getWidth(10), left: CustomStyle.getWidth(10)),
                  child:  Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("order_reg_end")??"도착",
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                          child: Text(
                            mData.value.finishDate??"",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ) : const SizedBox(),
      ],
    )
    );
  }

  Widget transInfoWidget() {
    return Container(
      alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15),horizontal: CustomStyle.getWidth(5)),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white
        ),
        child: Column(
            children:[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: App().isTablet(context) ? const EdgeInsets.all(10) : const EdgeInsets.all(3),
                                        margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                        decoration: const BoxDecoration(
                                            color: renew_main_color2,
                                            shape: BoxShape.circle
                                        ),
                                        child: Text("상",style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w600),)
                                    ),
                                    Text(
                                      "${Util.splitSDate(mData.value.sDate)}",
                                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w400),
                                      textAlign: TextAlign.center,
                                    ),
                                  ]
                              ),
                              Flexible(
                                  child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign:TextAlign.center,
                                      text: TextSpan(
                                        text: mData.value.sComName??"",
                                        style:  CustomStyle.CustomFont(styleFontSize18, main_color, font_weight: FontWeight.w800),
                                      )
                                  )
                              ),
                              CustomStyle.sizedBoxHeight(5.0.h),
                              Flexible(
                                  child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      textAlign:TextAlign.center,
                                      text: TextSpan(
                                        text: mData.value.sAddr??"",
                                        style: CustomStyle.CustomFont(styleFontSize14, main_color),
                                      )
                                  )
                              ),
                            ]
                        )
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/image/ic_arrow.png",
                              width: CustomStyle.getWidth(38.0),
                              height: CustomStyle.getHeight(38.0),
                              color: const Color(0xffC7CBDE),
                            ),
                            Text(
                              "${Util.makeDistance(mData.value.distance)}",
                              style: CustomStyle.CustomFont(styleFontSize13, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                            ),
                            Text(
                              "${Util.makeTime(mData.value.time??0)}",
                              style: CustomStyle.CustomFont(styleFontSize13, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                            )
                          ]
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                          decoration: const BoxDecoration(
                            borderRadius:  BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          padding: App().isTablet(context) ? const EdgeInsets.all(10) : const EdgeInsets.all(3),
                                          margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                          decoration: const BoxDecoration(
                                              color: rpa_btn_cancle,
                                              shape: BoxShape.circle
                                          ),
                                          child: Text("하",style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w600),)
                                      ),
                                      Text(
                                        "${Util.splitSDate(mData.value.eDate)}",
                                        style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w400),
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                ),
                                Flexible(
                                    child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text:
                                          mData.value.eComName ?? "",
                                          style: CustomStyle.CustomFont(styleFontSize18, main_color, font_weight: FontWeight.w800),
                                        )
                                    )
                                ),
                                CustomStyle.sizedBoxHeight(5.h),
                                Flexible(
                                    child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 5,
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: mData.value.eAddr??"",
                                            style:CustomStyle.CustomFont(styleFontSize14, main_color)
                                        )
                                    )
                                ),
                              ]
                          )
                      )
                  )
                ],
              ) ,
              Container(
                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w), right: CustomStyle.getWidth(5.w), bottom: CustomStyle.getHeight(5.0.h),top: CustomStyle.getHeight(15.h)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          children:[
                            Container(
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                decoration: BoxDecoration(
                                    color: const Color(0xffC7CBDE),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${mData.value.carTonName}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02,font_weight: FontWeight.w600),
                                )
                            ),
                            Container(
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                decoration: BoxDecoration(
                                    color: const Color(0xffC7CBDE),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${mData.value.carTypeName}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02,font_weight: FontWeight.w600),
                                )
                            ),
                          ]
                      ),
                      Row(
                          children: [
                            mData.value.truckTypeName != null || mData.value.truckTypeName?.isNotEmpty == true?
                            Container(
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                decoration: BoxDecoration(
                                    color: const Color(0xffC7CBDE),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${mData.value.truckTypeName}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02,font_weight: FontWeight.w600),
                                )
                            ) : const SizedBox(),
                            Container(
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                decoration: BoxDecoration(
                                    color: const Color(0xffC7CBDE),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${mData.value.mixYn == "Y" ? "혼적" : "독차"}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02,font_weight: FontWeight.w600),
                                )
                            ),
                            Container(
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                decoration: BoxDecoration(
                                    color: const Color(0xffC7CBDE),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  mData.value.returnYn == "Y" ? "왕복" : "편도",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02,font_weight: FontWeight.w600),
                                )
                            ),
                          ])
                    ],
                  )
              )
            ]
        )
    );
  }

  Widget stopPointPannelWidget() {
    isStopPointExpanded.value = List.filled(1, false);
    return Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line,
                      width: 5.w
                  ),
                )
            ),
          child: ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          children: [
            ExpansionPanelRadio(
              value: index,
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                     padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(5.h)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("경유지 ${mData.value.stopCount}곳",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
                      ],
                    )
                );
              },
              body: llStopPointList.value ?
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: line,
                                  width: 1.w
                              ),
                          )
                      ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    mStopList.length,
                        (index) {
                      return stopPointItems(index);
                    },
                  ))) : const SizedBox(),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isStopPointExpanded[index] = !isStopPointExpanded[index];
          },
        ));
      }),
    );
  }

  Widget stopPointItems(int index) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
        decoration: BoxDecoration(
          color: styleGreyCol3,
          border: Border(bottom: BorderSide(color: line, width: 1.w)),
        ),
        child: Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                      flex: 2,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                              border: Border.all(color: text_box_color_01,width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                            ),
                            child: Text(
                              "경유지 ${index + 1}",
                              style: CustomStyle.CustomFont(styleFontSize12, text_box_color_01),
                            )
                        )
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                            child: Text(
                              mStopList.value[index].eComName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        )
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                          alignment: Alignment.centerRight,
                          child: Text(
                            mStopList.value[index].stopSe == "S" ? "상차" : "하자",
                            style: CustomStyle.CustomFont(styleFontSize14, mStopList.value[index].stopSe == "S" ? order_state_04 : order_state_09),
                          ),
                        )
                      )
                    ],
                  ),
                  !(mStopList.value[index].eStaff?.isEmpty == true) || !(mStopList.value[index].eTel?.isEmpty == true) ?
                  Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    child: Row(
                      children: [
                        Text(
                          mStopList.value[index].eStaff??"",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        ),
                        InkWell(
                          onTap: () async {
                            if(Platform.isAndroid) {
                              DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                              AndroidDeviceInfo info = await deviceInfo.androidInfo;
                              if (info.version.sdkInt >= 23) {
                                await PhoneCall.calling("${mStopList.value[index].eTel}");
                              }else{
                                await launch("tel://${mStopList.value[index].eTel}");
                              }
                            }else{
                              await launch("tel://${mStopList.value[index].eTel}");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                            child: Text(
                              Util.makePhoneNumber(mStopList.value[index].eTel),
                              style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                            ),
                          ),
                        )
                      ],
                    )
                  ): const SizedBox(),
                  !(mStopList.value[index].eAddrDetail?.isEmpty == true)?
                  Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                      child: Text(
                      mStopList.value[index].eAddr??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    )
                  ) : const SizedBox(),
                  !(mStopList.value[index].eAddrDetail?.isEmpty == true) ?
                  Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                      child: Text(
                      mStopList.value[index].eAddrDetail??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    )
                  ): const SizedBox()
                ],
              )
            )
    );
  }

  Widget cargoInfoWidget() {
    isCargoExpanded.value = List.filled(1, false);
    return Container(
      margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10)),
        child: Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
          child: ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          children: [
            ExpansionPanelRadio(
              value: index,
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(5)),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(isExpanded ? "접기" : "펼치기",style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w700))
                      ],
                    )
                );
              },
              body: Obx((){
              return Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: line,
                      width: 1.w
                    )
                  )
                ),
                child: cargoInfoPannel()
              );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isCargoExpanded[index] = !isCargoExpanded[index];
          },
        )
        );
      }),
    ));
  }

  Widget etcPannelWidget() {

    isEtcExpanded.value = List.filled(1, false);
    return Container(
        margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10)),
        child: Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          children: [
            ExpansionPanelRadio(
              value: index,
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(5.w)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(isExpanded ? "접기" : "펼치기",style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w700))
                      ],
                    )
                );
              },
              body: Obx((){
                return Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: line, width: 1.w
                        )
                      )
                    ),
                    child: Row(
                        children : [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_driver_memo")??"차주확인사항_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w500),
                              ),
                              Container(
                                width: App().isTablet(context) ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(80) : MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(50),
                                padding: const EdgeInsets.all(10),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                child: Text(
                                  !(mData.value.driverMemo?.isEmpty == true) ? mData.value.driverMemo??"-" : "-",
                                  style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                child: Text(
                                  Strings.of(context)?.get("order_request_info_reg_memo")??"요청사항_",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w500),
                                )
                              ),
                              Container(
                                width: App().isTablet(context) ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(80) : MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(50),
                                padding: const EdgeInsets.all(10),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                child: Text(
                                  !(mData.value.reqMemo?.isEmpty == true) ? mData.value.reqMemo??"-" : "-",
                                  style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                                ),
                              )
                            ],
                          )
                        ]
                    )
                );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isEtcExpanded[index] = !isEtcExpanded[index];
          },
        )
        );
      }),
    )
    );
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  Future goToModifyOrder() async {
    //Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewRegistOrderPage(order_vo: mData.value,flag: "M")));
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RenewGeneralRegistOrderPage(order_vo: mData.value, flag: "M"), pageAnimationType: LeftToRightTransition()));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setModifyResult(results);
      }
    }
  }

  Future<void> setModifyResult(Map<String,dynamic> results) async {
    if(results["allocId"] != null){
      String allocId = results["allocId"].toString();
      Util.toast("오더가 수정되었습니다.");
      await getOrderDetail(allocId);
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          return Future((){
            BroadCast.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
            Navigator.of(context).pop({'code':100});
            return true;
          });
        } ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: light_gray24,
          appBar: AppBar(

                actions: [
                  tvModify.value ?
                  InkWell(
                      onTap: () async {
                        var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                        if(guest) {
                          showGuestDialog();
                          return;
                        }
                        await goToModifyOrder();
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(10)),
                          width: CustomStyle.getWidth(70),
                          decoration: const BoxDecoration(
                              color: rpa_btn_modify,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            Strings.of(context)?.get("order_detail_order_modify")??"오더 수정_",
                            style: CustomStyle.CustomFont(styleFontSize11, Colors.white),
                          )
                      )
                  ) : const SizedBox(),
                  tvOrderCancel.value ?
                  InkWell(
                      onTap: () async {
                        var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                        if(guest) {
                          showGuestDialog();
                          return;
                        }
                        await showOrderCancel();
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(10)),
                          width: CustomStyle.getWidth(70),
                          decoration: const BoxDecoration(
                              color: rpa_btn_cancle,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            Strings.of(context)?.get("order_detail_order_cancel")??"오더 취소_",
                            style: CustomStyle.CustomFont(styleFontSize11, Colors.white),
                          )
                      )
                  ) : const SizedBox()
                ],
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    BroadCast.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Image.asset(
                    "assets/image/ic_arrow_left.png",
                    width: CustomStyle.getWidth(28.0),
                    height: CustomStyle.getHeight(28.0),
                    color: Colors.black,
                  ),
                ),
              ),
          body: SafeArea(
              child: Obx((){
                return SizedBox(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                    child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                              child: Text(
                                "운임 정보",
                                style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                              )
                          ),
                          orderSellWidget(),
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                              child: Text(
                                "배차 정보",
                                style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                              )
                          ),
                          transInfoWidget(), // 배차 정보
                          llDriverInfo.value ?  Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                              child: Text(
                                Strings.of(context)?.get("order_detail_sub_title_05")?? "차주 정보_",
                                style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                              )
                          ) : const SizedBox(),
                          llDriverInfo.value ? driverInfoWidget() : const SizedBox(),
                          llStopPointHeader.value ? stopPointPannelWidget() : const SizedBox(),
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                              child: Text(
                                "화물 정보",
                                style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                              )
                          ),
                          cargoInfoWidget(), // 화물 정보
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                              child: Text(
                                "기타",
                                style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                              )
                          ),
                          etcPannelWidget()
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: CustomStyle.getHeight(7.h),
                        right: CustomStyle.getWidth(10.w),
                        child: InkWell(
                          onTap: () async {
                            await copyOrder();
                          },
                          child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7.h),horizontal: CustomStyle.getWidth(10.w)),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(30),
                              color: copy_btn
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                child: Icon(Icons.file_copy, size: 24.h,color: Colors.white),
                              ),
                              Text(
                                Strings.of(context)?.get("order_detail_copy")??"오더복사_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                              ),
                              ],
                            )
                        )
                      )
                    )
                  ],
                ));
              })
          ),
          bottomNavigationBar: Obx((){
            return Container(
                height: CustomStyle.getHeight(50),
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 오더 접수 Button
                    tvReOrder.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                                var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest) {
                                showGuestDialog();
                                return;
                                }
                              await showReOrder();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(40)),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: renew_main_color2,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                Strings.of(context)?.get("order_detail_re_order")??"Not Found",
                                style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol, font_weight: FontWeight.w700),
                              ),
                            )
                        )
                    ) : const SizedBox(),
                    // 배차하기 Button
                    tvAlloc.value ?
                    Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                                var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest) {
                                showGuestDialog();
                                return;
                                }
                              await goToAlloc();
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(40)),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: renew_main_color2,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc")??"Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol, font_weight: FontWeight.w700),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                    // 배차 취소 Button
                    tvAllocCancel.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                                var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest) {
                                showGuestDialog();
                                return;
                                }
                              await showAllocCancel();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: sub_btn),
                                child:Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc_cancel")??"Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                    // 차량 직접 배차 Button
                    tvAllocReg.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                                var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest) {
                                showGuestDialog();
                                return;
                                }
                              await showAllocReg();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child:Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc_reg")??"Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                  ],
                ));
          }),
        )
    );
  }

}