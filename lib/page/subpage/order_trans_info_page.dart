import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/car_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/unit_charge_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/subpage/car_search_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cust_user_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

import '../../common/config_url.dart';

class OrderTransInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  OrderTransInfoPage({Key? key,required this.order_vo, this.code}):super(key:key);

  _OrderTransInfoPageState createState() => _OrderTransInfoPageState();
}


class _OrderTransInfoPageState extends State<OrderTransInfoPage> with TickerProviderStateMixin {

  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter.currency(locale: 'ko', decimalDigits: 0, symbol: '￦');
  ProgressDialog? pr;

  final code = "".obs;
  final orderCarTonCode = "".obs;
  final orderCarTypeCode = "".obs;
  final orderBuyCharge = "".obs;

  final isTransInfoExpanded = [].obs;
  final isEtcExpanded = [].obs;
  late TabController _tabController;

  final mData = OrderModel().obs;
  final mOrderOption = OrderModel().obs;
  final userInfo = UserModel().obs;
  final mCustData = CustomerModel().obs;

  final controller = Get.find<App>();

  static const String TRANS_TYPE_01 = "01";
  static const String TRANS_TYPE_02 = "02";

  final isOption = false.obs;

  final tvPayType = "미사용".obs;

  final tvTotal = 0.obs;
  final transType = TRANS_TYPE_02.obs;
  final tvTransType01 = false.obs;
  final tvTransType02 = false.obs;
  final driverPayType = "N".obs;
  final payType = "N".obs;
  final talkYn = false.obs;
  final kakaoPushEnable = false.obs;
  final buyDrivLicNum = "N".obs;
  final isCharge = false.obs;
  final llTransType01 = false.obs;
  final llTransType02 = false.obs;
  final registType = false.obs;
  final llChargeInfo = false.obs;

  final ivChargeExpand = false.obs;

  late TextEditingController etBuyChargeController;
  late TextEditingController etCustNameController;
  late TextEditingController etKeeperController;
  late TextEditingController etCarNumController;

  //추가 운임 EditText
  late TextEditingController etWayPointController;
  final wayPointChecked = false.obs;
  late TextEditingController etWayPointMemoController;

  late TextEditingController etStayChargeController;
  final stayChargeChecked = false.obs;
  late TextEditingController etStayChargeMemoController;

  late TextEditingController etHandWorkChargeController;
  final handWorkChecked = false.obs;
  late TextEditingController ethandWorkMemoController;

  late TextEditingController etRoundChargeController;
  final roundChargeChecked = false.obs;
  late TextEditingController etRoundMemoController;

  late TextEditingController etOtherAddChargeController;
  final otherAddChargeChecked = false.obs;
  late TextEditingController etOtherAddMemoController;

  late TextEditingController etDriverMemoController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 2,
        vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
        initialIndex: 1
    );
    _tabController.addListener(_handleTabSelection);

    etBuyChargeController = TextEditingController();
    etCustNameController = TextEditingController();
    etKeeperController = TextEditingController();
    etCarNumController = TextEditingController();

    //추가 운임 EditText
    etWayPointController = TextEditingController();
    etWayPointMemoController = TextEditingController();
    etStayChargeController = TextEditingController();
    etStayChargeMemoController = TextEditingController();
    etHandWorkChargeController = TextEditingController();
    ethandWorkMemoController = TextEditingController();
    etRoundChargeController = TextEditingController();
    etRoundMemoController = TextEditingController();
    etOtherAddChargeController = TextEditingController();
    etOtherAddMemoController = TextEditingController();

    etDriverMemoController = TextEditingController();

    Future.delayed(Duration.zero, () async {

      userInfo.value = await controller.getUserInfo();
      if(widget.order_vo != null) {
        var order = widget.order_vo;
        mData.value = OrderModel.fromJSON(order.toMap());
      }else{
        mData.value = OrderModel();
      }
      if(widget.code != null) {
        code.value = widget.code!;
      }
      mCustData.value = CustomerModel();

      orderCarTonCode.value = mData.value.carTonCode??"";
      orderCarTypeCode.value = mData.value.carTypeCode??"";
      orderBuyCharge.value = "";

      await initView();
    });

  }

  // Widget Start

  Widget tabBarValueWidget(String? tabValue) {
    Widget _widget = carFragment(tabValue);
    switch(tabValue) {
      case "01" :
        _widget = transFragment(tabValue);
        break;
      case "02" :
        _widget = carFragment(tabValue);
        break;
    }
    return _widget;
  }

  Widget transFragment(String? tab) {

    return SingleChildScrollView(
        child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
            children: [
              // 운송사
              InkWell(
                  onTap: () async {
                    await goToCustomer();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color:Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/image/ic_trans_car.png",
                                  width: CustomStyle.getWidth(17.0),
                                  height: CustomStyle.getHeight(17.0),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                    child: Text(
                                        Strings.of(context)?.get("order_trans_info_cust")??"운송사_",
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                                    )
                                )
                              ]
                          ),
                          Text(
                            mData.value.buyCustName?.isEmpty == true || mData.value.buyCustName == null ?
                            Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해 주세요._" : mData.value.buyCustName!,
                            style: CustomStyle.CustomFont(styleFontSize14,  mData.value.buyCustName?.isEmpty == true || mData.value.buyCustName == null ? styleDefaultGrey : text_color_01),
                          ),
                        ],
                      )
                  )
              ),

              // 담당자
              InkWell(
                onTap: () async {
                  await goToCompanyKeeper();
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color:Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/image/ic_trans_staff.png",
                                width: CustomStyle.getWidth(17.0),
                                height: CustomStyle.getHeight(17.0),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                  child: Text(
                                      Strings.of(context)?.get("order_trans_info_company_keeper")??"담당자",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                                  )
                              )
                            ]
                        ),
                        Text(
                          mData.value.buyStaffName == null || mData.value.buyStaffName?.isEmpty == true ? "담당자를 선택해주세요.":  mData.value.buyStaffName??"",
                          style: CustomStyle.CustomFont(styleFontSize14,  mData.value.buyStaffName == null || mData.value.buyStaffName?.isEmpty == true ? styleDefaultGrey : text_color_01),
                        ),
                      ],
                    )
                )
              ),

              // 연락처
              Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color:Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/image/ic_trans_call.png",
                              width: CustomStyle.getWidth(17.0),
                              height: CustomStyle.getHeight(17.0),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                child: Text(
                                    Strings.of(context)?.get("order_trans_info_company_tel")??"연락처_",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                                )
                            )
                          ]
                      ),
                      Text(
                        Util.makePhoneNumber(mData.value.buyStaffTel),
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                    ],
                  )
              ),

              // 지불운임
              InkWell(
                onTap: () async {
                  await openRpaModiDialog(context);
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color:Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/image/ic_trans_pay.png",
                                width: CustomStyle.getWidth(17.0),
                                height: CustomStyle.getHeight(17.0),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                  child: Text(
                                      Strings.of(context)?.get("order_trans_info_charge")??"지불운임_",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                                  )
                              )
                            ]
                        ),
                        Obx(() =>
                          Text(
                            "${Util.getInCodeCommaWon(mData.value.buyCharge??"0")}   원",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01, font_weight: FontWeight.w700),
                          )
                        )
                      ],
                    )
                )
              ),

              // 빠른지급여부
              Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10), bottom: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color:Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/image/ic_trans_quick.png",
                              width: CustomStyle.getWidth(17.0),
                              height: CustomStyle.getHeight(17.0),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                child: Text(
                                    Strings.of(context)?.get("order_trans_info_pay")??"빠른지급여부_",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                                )
                            )
                          ]
                      ),
                      Text(
                        tvPayType.value,
                        style: CustomStyle.CustomFont(styleFontSize14,  text_color_01),
                      ),
                    ],
                  )
              ),
              !isOption.value ? transInfoPannelWidget() : const SizedBox(),
              etcPannelWidget()
        ]
      )
    )
    );
  }

  Widget carFragment(String? tab) {

    return SingleChildScrollView(
        child: Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          // 차량번호
          InkWell(
          onTap: () async {
            await goToCarSearch();
          },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color:Colors.white,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/image/ic_trans_car.png",
                        width: CustomStyle.getWidth(17.0),
                        height: CustomStyle.getHeight(17.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                          child: Text(
                              Strings.of(context)?.get("order_trans_info_car_num")??"차량번호_",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                          )
                      )
                    ]
                  ),
                  Text(
                    mData.value.carNum?.isEmpty == true || mData.value.carNum == null ?
                    Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해 주세요._": mData.value.carNum!,
                    style: CustomStyle.CustomFont(styleFontSize14,  mData.value.carNum?.isEmpty == true || mData.value.carNum == null ? styleDefaultGrey : text_color_01),
                  ),
                ],
              )
            )
          ),

          // 차주 성명
          Container(
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color:Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/ic_trans_name.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_driver_name")??"차주성명_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    mData.value.driverName??"",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                ],
              )
          ),

          // 차주 연락처
          Container(
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color:Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/ic_trans_call.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_driver_tel")??"연락처_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    Util.makePhoneNumber(mData.value.driverTel),
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                ],
              )
          ),

          // 차종
          Container(
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color:Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/ic_trans_cartype.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_car_type_name")??"차종_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    mData.value.carTypeName??"",
                    style: CustomStyle.CustomFont(styleFontSize14,  text_color_01),
                  ),
                ],
              )
          ),

          // 톤급
          Container(
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color:Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/ic_trans_weight.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_car_ton_name")??"톤급_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    mData.value.carTonName??"",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                ],
              )
          ),

          // 지불운임
         InkWell(
           onTap: () async {
             await openRpaModiDialog(context);
           },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/image/ic_trans_pay.png",
                            width: CustomStyle.getWidth(17.0),
                            height: CustomStyle.getHeight(17.0),
                          ),
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                              child: Text(
                                  Strings.of(context)?.get("order_trans_info_charge")??"지불운임_",
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                              )
                          )
                        ]
                    ),
                    Obx(() =>
                      Text(
                        "${Util.getInCodeCommaWon(mData.value.buyCharge??"0")} 원",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01, font_weight: FontWeight.w700),
                      )
                    ),
                  ],
                )
            )
          ),

          // 빠른지급여부
          Container(
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color:Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/ic_trans_quick.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_pay")??"빠른지급여부_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    tvPayType.value,
                    style: CustomStyle.CustomFont(styleFontSize14,  text_color_01),
                  ),
                ],
              )
          ),

          // 운전자 주민번호
          InkWell(
            onTap: (){
              openIdentityNumberDialog(context);
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
                margin: EdgeInsets.only(top: CustomStyle.getHeight(10), bottom: CustomStyle.getHeight(10)),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/image/ic_trans_idcard.png",
                            width: CustomStyle.getWidth(17.0),
                            height: CustomStyle.getHeight(17.0),
                          ),
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                              child: Text(
                                  Strings.of(context)?.get("order_trans_info_regist")??"운전자 주민번호_",
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                              )
                          )
                        ]
                    ),
                    Text(
                      (buyDrivLicNum.value != '' ?  buyDrivLicNum.value.replaceAllMapped(RegExp(r'(\d{6})(\d{6,7})'), (m) => '${m[1]}-${m[2]}') : "")!,
                      style: CustomStyle.CustomFont(styleFontSize14,  text_color_01),
                    ),
                  ],
                )
            )
          ),
          !isOption.value ? transInfoPannelWidget() : const SizedBox(),
          etcPannelWidget()
        ]
      )
    )
    );
  }

  Widget tabBarViewWidget() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          tabBarValueWidget("01"),
          tabBarValueWidget("02"),
        ],
      )
    );
  }

  Widget customTabBarWidget() {
    return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: light_gray18,
                  width:1
                )
              ),
            ),
        child: TabBar(
          tabs: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Text(
                Strings.of(context)?.get("order_trans_info_type_01")??"운송사_",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Text(
                Strings.of(context)?.get("order_trans_info_type_02")??"차량_",
                textAlign: TextAlign.center,
              ),
            )
          ],
          indicator: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: renew_main_color2, width: 1)
          ),
          labelColor: renew_main_color2,
          labelStyle: CustomStyle.CustomFont(styleFontSize14,renew_main_color2, font_weight: FontWeight.w700),
          overlayColor: MaterialStatePropertyAll(Colors.blue.shade100),
          unselectedLabelColor: text_color_03,
          unselectedLabelStyle: CustomStyle.CustomFont(styleFontSize12,text_color_03, font_weight: FontWeight.w400),
          controller: _tabController,
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    etBuyChargeController.dispose();
    etCustNameController.dispose();
    etKeeperController.dispose();
    etCarNumController.dispose();
    etRoundChargeController.dispose();

    //추가 운임 EditText
    etWayPointController.dispose();
    etWayPointMemoController.dispose();
    etStayChargeController.dispose();
    etStayChargeMemoController.dispose();
    etHandWorkChargeController.dispose();
    ethandWorkMemoController.dispose();
    etRoundMemoController.dispose();
    etOtherAddChargeController.dispose();
    etOtherAddMemoController.dispose();

    etDriverMemoController.dispose();
  }

  Widget transInfoPannelWidget() {
    isTransInfoExpanded.value = List.filled(1, false);

    return Flex(
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
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(5.h)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            Strings.of(context)?.get("order_trans_info_sub_title_03")??"추가운임_",
                            style: CustomStyle.CustomFont(styleFontSize18, text_color_01, font_weight: FontWeight.w700)
                        )
                      ],
                    ));
              },
              body: !llChargeInfo.value ? Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //경유비(지불)
                      Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_way_point_charge")??"경유비(지불)",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Row(
                                children : [
                                  Expanded(
                                    flex: 4,
                                  child: Container(
                                      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                      height: CustomStyle.getHeight(35.h),
                                      child: TextFormField(
                                        inputFormatters: <TextInputFormatter>[
                                          CurrencyTextInputFormatter.currency(
                                            locale: 'ko',
                                            decimalDigits: 0,
                                            symbol: '￦',
                                          ),
                                        ],
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        textAlign: TextAlign.start,
                                        keyboardType: TextInputType.number,
                                        controller: etWayPointController,
                                        maxLines: 1,
                                        decoration: etWayPointController.text.isNotEmpty
                                            ? InputDecoration(
                                          counterText: '',
                                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                          ),
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              etWayPointController.clear();
                                              mData.value.wayPointCharge = "0";
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
                                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                            hintText: Strings.of(context)?.get("order_trans_info_way_point_charge_hint")??"경유비를 입력해주세요._",
                                            hintStyle: CustomStyle.greyDefFont(),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                            ),
                                            disabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                            )
                                        ),
                                        onChanged: (value) async {
                                          if(value.length > 0) {
                                            mData.value.wayPointCharge = int.parse(value.trim().replaceAll("￦", '').replaceAll(",", '')).toString();
                                          }else{
                                            mData.value.wayPointCharge = "0";
                                            etWayPointController.text = "0";
                                          }
                                          await setTotal();
                                        },
                                        maxLength: 50,
                                      )
                                    )
                                  ),
                                  Expanded(
                                    flex: 3,
                                   child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                      child:Row(
                                        children: [
                                          Text(
                                            "메모작성",
                                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                          ),
                                        Checkbox(
                                          value: wayPointChecked.value,
                                          onChanged: (value) {
                                            setState(() {
                                              wayPointChecked.value = value!;
                                            });
                                          },
                                        ),
                                        ]
                                      )
                                    )
                                  )
                                ]
                              )
                            ],
                          )
                      ),
                      //경유비 메모
                     wayPointChecked.value ?
                      Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_way_point_memo")??"경유비 메모",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  height: CustomStyle.getHeight(35),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: etWayPointMemoController,
                                    maxLines: 1,
                                    decoration: etWayPointMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etWayPointMemoController.clear();
                                          mData.value.wayPointMemo = "";
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
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      hintText: Strings.of(context)?.get("order_trans_info_way_point_memo_hint")??"경유비 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                        )
                                    ),
                                    onChanged: (value){
                                      mData.value.wayPointMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                        ):const SizedBox(),
                      //대기료(지불)
                      Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_stay_charge")??"대기료(지불)_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Row(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                            height: CustomStyle.getHeight(35.h),
                                            child: TextFormField(
                                              inputFormatters: <TextInputFormatter>[
                                                CurrencyTextInputFormatter.currency(
                                                  locale: 'ko',
                                                  decimalDigits: 0,
                                                  symbol: '￦',
                                                ),
                                              ],
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                              textAlign: TextAlign.start,
                                              keyboardType: TextInputType.number,
                                              controller: etStayChargeController,
                                              maxLines: 1,
                                              decoration: etStayChargeController.text.isNotEmpty
                                                  ? InputDecoration(
                                                counterText: '',
                                                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    etStayChargeController.clear();
                                                    mData.value.stayCharge = "0";
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
                                                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                                hintText: Strings.of(context)?.get("order_trans_info_stay_charge_hint")??"대기료를 입력해주세요._",
                                                hintStyle: CustomStyle.greyDefFont(),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                              ),
                                              onChanged: (value) async {
                                                if(value.length > 0) {
                                                  mData.value.stayCharge = int.parse(value.trim().replaceAll("￦", '').replaceAll(",", '')).toString();
                                                }else{
                                                  mData.value.stayCharge = "0";
                                                  etStayChargeController.text = "0";
                                                }
                                                await setTotal();
                                              },
                                              maxLength: 50,
                                            )
                                        )
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                            child:Row(
                                                children: [
                                                  Text(
                                                    "메모작성",
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                  ),
                                                  Checkbox(
                                                    value: stayChargeChecked.value,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        stayChargeChecked.value = value!;
                                                      });
                                                    },
                                                  ),
                                                ]
                                            )
                                        )
                                    )
                                  ]
                              )
                            ],
                          )
                      ),
                      //대기료 메모
                      stayChargeChecked.value ?
                      Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_stay_memo")??"대기료 메모_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: etStayChargeMemoController,
                                    maxLines: 1,
                                    decoration: etStayChargeMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etStayChargeMemoController.clear();
                                          mData.value.stayMemo = "";
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      hintText: Strings.of(context)?.get("order_trans_info_stay_memo_hint")??"대기료 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                    ),
                                    onChanged: (value){
                                      mData.value.stayMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ) : const SizedBox(),
                      //수작업비(지불)
                      Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_hand_work_charge")??"수작업비(지불)_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                      child: Container(
                                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                          height: CustomStyle.getHeight(35.h),
                                          child: TextFormField(
                                            inputFormatters: <TextInputFormatter>[
                                              CurrencyTextInputFormatter.currency(
                                                locale: 'ko',
                                                decimalDigits: 0,
                                                symbol: '￦',
                                              ),
                                            ],
                                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.number,
                                            controller: etHandWorkChargeController,
                                            maxLines: 1,
                                            decoration: etHandWorkChargeController.text.isNotEmpty
                                                ? InputDecoration(
                                              counterText: '',
                                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              disabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  etHandWorkChargeController.clear();
                                                  mData.value.handWorkCharge = "0";
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
                                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                              hintText: Strings.of(context)?.get("order_trans_info_hand_work_charge_hint")??"수작업비를 입력해주세요._",
                                              hintStyle: CustomStyle.greyDefFont(),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              disabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                            ),
                                            onChanged: (value) async {
                                              if(value.length > 0) {
                                                mData.value.handWorkCharge = int.parse(value.trim().replaceAll("￦", '').replaceAll(",", '')).toString();
                                              }else{
                                                mData.value.handWorkCharge = "0";
                                                etHandWorkChargeController.text = "0";
                                              }
                                              await setTotal();
                                            },
                                            maxLength: 50,
                                          )
                                      )
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                          child:Row(
                                              children: [
                                                Text(
                                                  "메모작성",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                                Checkbox(
                                                  value: handWorkChecked.value,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      handWorkChecked.value = value!;
                                                    });
                                                  },
                                                ),
                                              ]
                                          )
                                      )
                                  )
                                ]
                              )
                            ],
                          )
                      ),
                      //수작업비 메모
                      handWorkChecked.value ?
                      Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_hand_work_memo")??"수작업비 메모_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: ethandWorkMemoController,
                                    maxLines: 1,
                                    decoration: ethandWorkMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          ethandWorkMemoController.clear();
                                          mData.value.handWorkMemo = "";
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                      hintText: Strings.of(context)?.get("order_trans_info_hand_work_memo_hint")??"수작업비 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                    ),
                                    onChanged: (value){
                                      mData.value.handWorkMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ) : const SizedBox(),
                      //회차료(지불)
                      Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_round_charge")??"회차료(지불)_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                      child: Container(
                                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                          height: CustomStyle.getHeight(35.h),
                                          child: TextFormField(
                                            inputFormatters: <TextInputFormatter>[
                                              CurrencyTextInputFormatter.currency(
                                                locale: 'ko',
                                                decimalDigits: 0,
                                                symbol: '￦',
                                              ),
                                            ],
                                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.number,
                                            controller: etRoundChargeController,
                                            maxLines: 1,
                                            decoration: etRoundChargeController.text.isNotEmpty
                                                ? InputDecoration(
                                              counterText: '',
                                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              disabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  etRoundChargeController.clear();
                                                  mData.value.roundCharge = "0";
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
                                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(5)),
                                              hintText: Strings.of(context)?.get("order_trans_info_round_charge_hint")??"회차료를 입력해주세요._",
                                              hintStyle: CustomStyle.greyDefFont(),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              disabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                              ),
                                            ),
                                            onChanged: (value) async {
                                              if(value.length > 0) {
                                                mData.value.roundCharge = int.parse(value.trim().replaceAll("￦", '').replaceAll(",", '')).toString();
                                              }else{
                                                mData.value.roundCharge = "0";
                                                etRoundChargeController.text = "0";
                                              }
                                              await setTotal();
                                            },
                                            maxLength: 50,
                                          )
                                      )
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                          child:Row(
                                              children: [
                                                Text(
                                                  "메모작성",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                                Checkbox(
                                                  value: roundChargeChecked.value,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      roundChargeChecked.value = value!;
                                                    });
                                                  },
                                                ),
                                              ]
                                          )
                                      )
                                  )
                                ]
                              )
                            ],
                          )
                      ),
                      //회차료 메모
                      roundChargeChecked.value ?
                      Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_round_memo")??"회차료 메모_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: etRoundMemoController,
                                    maxLines: 1,
                                    decoration: etRoundMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etRoundMemoController.clear();
                                          mData.value.roundMemo = "";
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
                                      hintText: Strings.of(context)?.get("order_trans_info_round_memo_hint")??"회차료 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                    ),
                                    onChanged: (value){
                                      mData.value.roundMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ) : const SizedBox(),
                      //기타추가비(지불)
                      Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_other_add_charge")??"기타추가비(지불)_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Row(
                                  children :[
                                    Expanded(
                                      flex: 4,
                                        child: Container(
                                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                            height: CustomStyle.getHeight(35.h),
                                            child: TextFormField(
                                              inputFormatters: <TextInputFormatter>[
                                                CurrencyTextInputFormatter.currency(
                                                  locale: 'ko',
                                                  decimalDigits: 0,
                                                  symbol: '￦',
                                                ),
                                              ],
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                              textAlign: TextAlign.start,
                                              keyboardType: TextInputType.number,
                                              controller: etOtherAddChargeController,
                                              maxLines: 1,
                                              decoration: etOtherAddChargeController.text.isNotEmpty
                                                  ? InputDecoration(
                                                counterText: '',
                                                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    etOtherAddChargeController.clear();
                                                    mData.value.otherAddCharge = "0";
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
                                                hintText: Strings.of(context)?.get("order_trans_info_other_add_charge_hint")??"기타 추가비를 입력해주세요._",
                                                hintStyle: CustomStyle.greyDefFont(),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                                ),
                                              ),
                                              onChanged: (value) async {
                                                if(value.length > 0) {
                                                  mData.value.otherAddCharge = int.parse(value.trim().replaceAll("￦", '').replaceAll(",", '')).toString();
                                                }else{
                                                  mData.value.otherAddCharge = "0";
                                                  etOtherAddChargeController.text = "0";
                                                }
                                                await setTotal();
                                              },
                                              maxLength: 50,
                                            )
                                        )
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                            child:Row(
                                                children: [
                                                  Text(
                                                    "메모작성",
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                  ),
                                                  Checkbox(
                                                    value: otherAddChargeChecked.value,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        otherAddChargeChecked.value = value!;
                                                      });
                                                    },
                                                  ),
                                                ]
                                            )
                                        )
                                    )
                                  ]
                              )
                            ],
                          )
                      ),
                      //기타 추가비 메모
                      otherAddChargeChecked.value ?
                      Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_other_add_memo")??"기타추가비 메모_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: etOtherAddMemoController,
                                    maxLines: 1,
                                    decoration: etOtherAddMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etOtherAddMemoController.clear();
                                          mData.value.otherAddMemo = "";
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
                                      hintText: Strings.of(context)?.get("order_trans_info_other_add_memo_hint")??"기타 추가비를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(0.5))
                                      ),
                                    ),
                                    onChanged: (value){
                                      mData.value.otherAddMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ) : const SizedBox(),

                    ],
                  )
              ) : const SizedBox(),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isTransInfoExpanded[index] = !isTransInfoExpanded[index];
          },
        )
        );
      }),
    );
  }

  Widget etcPannelWidget() {
    return Container(
      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
      children: [
        Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white,
            ),
            child: Text(
                "기타",
                textAlign: TextAlign.start,
                style: CustomStyle.CustomFont(styleFontSize16, text_color_01)
            )
        ),
        CustomStyle.getDivider1(),
        Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Strings.of(context)?.get("order_trans_info_driver_memo")??"차주확인사항_",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      controller: etDriverMemoController,
                      maxLines: null,
                      decoration: etDriverMemoController.text.isNotEmpty
                          ? InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            etDriverMemoController.clear();
                            mData.value.driverMemo = "";
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
                        hintText: Strings.of(context)?.get("order_trans_info_driver_memo_hint")??"차주님에게 전달할 내용을 입력해 주세요._",
                        hintStyle: CustomStyle.greyDefFont(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                      onChanged: (value){
                        mData.value.driverMemo = value;
                      },
                    )
                )
              ],
            )
        )
      ],
      )
    );
  }

  String getPadvalue(index) {
    if (index < 9) {
      return (index + 1).toString();
    } else if (index == 9) {
      return '초기화';
    } else if (index == 10) {
      return '0';
    } else {
      return '<';
    }
  }

  Future<void> openRpaModiDialog(BuildContext context) async {

    final SelectNumber = "0".obs;
    SelectNumber.value = mData.value.buyCharge??"0";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.70,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              child: Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              "assets/image/icon_won.png",
                              width: CustomStyle.getWidth(25),
                              height: CustomStyle.getHeight(25)
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: CustomStyle.getWidth(10)),
                              child: Text(
                                "지불운임\n금액을 등록해주세요.",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, Colors.black,
                                    font_weight: FontWeight.w600),
                              )
                          )
                        ]
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                            vertical: CustomStyle.getHeight(15)),
                        child: Obx(() => Text(
                              "${Util.getInCodeCommaWon(SelectNumber.value)} 원",
                              style: CustomStyle.CustomFont(
                                  styleFontSize28, Colors.black,
                                  font_weight: FontWeight.w600),
                            )
                        )
                    ),
                    // 숫자 키패드
                    GridView.builder(
                        shrinkWrap: true,
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                          childAspectRatio: 1.5 / 1, //item 의 가로 1, 세로 1 의 비율
                          mainAxisSpacing: 5, //수평 Padding
                          crossAxisSpacing: 5, //수직 Padding
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          // return Text(index.toString());
                          return InkWell(
                              onTap: () {
                                switch (index) {
                                  case 9:
                                  //reset
                                    SelectNumber.value = '0';
                                    return;
                                  case 10:
                                    if(SelectNumber.value.length >= 8) return;
                                    if (SelectNumber.value == '0') return;
                                    else SelectNumber.value = '${SelectNumber.value}0';
                                    return;
                                  case 11:
                                  //remove
                                    if (SelectNumber.value.length == 1) SelectNumber.value = '0';
                                    else SelectNumber.value = SelectNumber.value.substring(0, SelectNumber.value.length - 1);
                                    return;

                                  default:
                                    if(SelectNumber.value.length >= 8) return;
                                    if (SelectNumber.value == '0') SelectNumber.value = '${index + 1}';
                                    else SelectNumber.value = '${SelectNumber.value}${index + 1}';
                                    return;
                                }
                              },
                              child: Ink(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Center(
                                        child: Text(getPadvalue(index),
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)
                                        )
                                    ),
                                  )
                              )
                          );
                        }
                    ),

                    Container(
                        width: double.infinity,
                        height: CustomStyle.getHeight(45),
                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: rpa_btn_regist,
                        ),
                        child: TextButton(
                            onPressed: () async {
                              if(SelectNumber.value == null || SelectNumber.value.isEmpty == true) SelectNumber.value = "0";

                                mData.value.buyCharge = SelectNumber.value;
                                setState(() {
                                  mData.value.buyCharge = SelectNumber.value;
                                });
                                await setTotal();
                                Navigator.of(context).pop();
                            },
                            child: Text(
                              "등록",
                              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                            )
                        )
                    )
                  ]
              ),
            ));
      },
    );
  }

  Future<void> openIdentityNumberDialog(BuildContext context) async {

    final iDentityNumber = buyDrivLicNum.value.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.70,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              child: Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              "assets/image/ic_trans_idcard.png",
                              width: CustomStyle.getWidth(25),
                              height: CustomStyle.getHeight(25)
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: CustomStyle.getWidth(10)),
                              child: Text(
                                "운전자\n주민등록번호를 입력해주세요.",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, Colors.black,
                                    font_weight: FontWeight.w600),
                              )
                          )
                        ]
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                            vertical: CustomStyle.getHeight(15)),
                        child: Obx(() => Text(
                          (iDentityNumber.value != '' ?  iDentityNumber.value?.replaceAllMapped(RegExp(r'(\d{6})(\d{6,7})'), (m) => '${m[1]}-${m[2]}') : "")!,
                          style: CustomStyle.CustomFont(
                              styleFontSize28, Colors.black,
                              font_weight: FontWeight.w600),
                          )
                        )
                    ),
                    // 숫자 키패드
                    GridView.builder(
                        shrinkWrap: true,
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                          childAspectRatio: 1.5 / 1, //item 의 가로 1, 세로 1 의 비율
                          mainAxisSpacing: 5, //수평 Padding
                          crossAxisSpacing: 5, //수직 Padding
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          // return Text(index.toString());
                          return InkWell(
                              onTap: () {
                                switch (index) {
                                  case 9:
                                  //reset
                                    iDentityNumber.value = '';
                                    return;
                                  case 10:
                                    if(iDentityNumber.value.length >= 13) return;
                                    if (iDentityNumber.value == '0') return;
                                    else iDentityNumber.value = '${iDentityNumber.value}0';
                                    return;
                                  case 11:
                                  //remove
                                    if (iDentityNumber.value.length == 1) iDentityNumber.value = '0';
                                    else iDentityNumber.value = iDentityNumber.value.substring(0, iDentityNumber.value.length - 1);
                                    return;

                                  default:
                                    if(iDentityNumber.value.length >= 13) return;
                                    if (iDentityNumber.value == '0') iDentityNumber.value = '${index + 1}';
                                    else iDentityNumber.value = '${iDentityNumber.value}${index + 1}';
                                    return;
                                }
                              },
                              child: Ink(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Center(
                                        child: Text(getPadvalue(index),
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)
                                        )
                                    ),
                                  )
                              )
                          );
                        }
                    ),

                    Container(
                        width: double.infinity,
                        height: CustomStyle.getHeight(45),
                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: rpa_btn_regist,
                        ),
                        child: TextButton(
                            onPressed: () async {
                              if(iDentityNumber.value == null || iDentityNumber.value.isEmpty == true) iDentityNumber.value = "";

                              if(iDentityNumber.value.length == 13){
                                setState(() {
                                  buyDrivLicNum.value = iDentityNumber.value;
                                });
                                Navigator.of(context).pop();
                              }else{
                                Util.toast("주민등록번호는 13자리만 작성 가능합니다.");
                              }
                            },
                            child: Text(
                              "등록",
                              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                            )
                        )
                    )
                  ]
              ),
            ));
      },
    );
  }

  // Widget End


  // Function Start

  Future<void> initView() async {

    etWayPointController.text = Util.getInCodeCommaWon(mData.value.wayPointCharge??"");
    etStayChargeController.text = Util.getInCodeCommaWon(mData.value.stayCharge??"");
    etHandWorkChargeController.text = Util.getInCodeCommaWon(mData.value.handWorkCharge??"");
    etRoundChargeController.text = Util.getInCodeCommaWon(mData.value.roundCharge??"");
    etOtherAddChargeController.text = Util.getInCodeCommaWon(mData.value.otherAddCharge??"");

    //추가 운임 EditText
    etWayPointMemoController.text = mData.value.wayPointMemo??"";
    if(mData.value.wayPointMemo != "" && mData.value.wayPointMemo != null) wayPointChecked.value = true;
    etStayChargeMemoController.text = mData.value.stayMemo??"";
    if(mData.value.stayMemo != "" && mData.value.stayMemo != null) stayChargeChecked.value = true;
    ethandWorkMemoController.text = mData.value.handWorkMemo??"";
    if(mData.value.handWorkMemo != "" && mData.value.handWorkMemo != null) handWorkChecked.value = true;
    etRoundMemoController.text = mData.value.roundMemo??"";
    if(mData.value.roundCharge != "" && mData.value.roundCharge != null) roundChargeChecked.value = true;
    etOtherAddMemoController.text = mData.value.otherAddMemo??"";
    if(mData.value.otherAddMemo != "" && mData.value.otherAddMemo != null) otherAddChargeChecked.value = true;

    await setTransType();
    llChargeInfo.value = isCharge.value;

    if(mData.value.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }

    if(code.value != "") {
      isOption.value = true;
    }else{
      await getOrderOption();
    }

    etBuyChargeController.text = mData.value.buyCharge??"0";
    etDriverMemoController.text = mData.value.driverMemo??"";
    await setTotal();
  }

  Future<void> _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _tabController.index;
      switch(selectedTabIndex) {
        case 0 :
          transType.value = "01";
          mData.value = OrderModel.fromJSON(widget.order_vo.toMap());
          await initView();
          break;
        case 1 :
          transType.value = "02";
          mData.value = OrderModel.fromJSON(widget.order_vo.toMap());
          await initView();
          break;
      }
    }
  }

  Future<void> getOrderOption() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOption(user.authorization).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getOrderOption() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              if (list.length > 0) {
                List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
                setState(() {
                  mOrderOption.value = itemsList[0];
                  mData.value.buyCharge = mOrderOption.value.buyCharge??"0";
                  orderBuyCharge.value = mOrderOption.value.buyCharge??"";
                });
                if(!(mOrderOption.value.driverMemo?.isEmpty == true) && !(mOrderOption.value.driverMemo == null)) {
                  mData.value.driverMemo = mOrderOption.value.driverMemo;
                }
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
        print("getOrderOption() Exeption =>$e");
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

  Future<void> setTotal() async {
    int buyCharge = mData.value.buyCharge?.isEmpty == true || mData.value.buyCharge == null ? 0 : int.parse(mData.value.buyCharge!);
    int wayPointCharge = mData.value.wayPointCharge?.isEmpty == true || mData.value.wayPointCharge == null ? 0 : int.parse(mData.value.wayPointCharge!);
    int stayCharge = mData.value.stayCharge?.isEmpty == true || mData.value.stayCharge == null ? 0 : int.parse(mData.value.stayCharge!);
    int handWorkCharge = mData.value.handWorkCharge?.isEmpty == true || mData.value.handWorkCharge == null ? 0 : int.parse(mData.value.handWorkCharge!);
    int roundCharge = mData.value.roundCharge?.isEmpty == true || mData.value.roundCharge == null ? 0 : int.parse(mData.value.roundCharge!);
    int otherAddCharge = mData.value.otherAddCharge?.isEmpty == true || mData.value.otherAddCharge == null ? 0 : int.parse(mData.value.otherAddCharge!);

    int total = buyCharge + wayPointCharge + stayCharge + handWorkCharge + roundCharge + otherAddCharge;
    tvTotal.value = total;
  }

  Future<void> setTransType() async {
    switch(transType.value) {
      case TRANS_TYPE_01 :
      // 운송사
        tvTransType01.value = true;
        tvTransType02.value = false;

        llTransType01.value = true;
        llTransType02.value = false;

        registType.value = false;

        tvPayType.value = "미사용";
        payType.value = "N";
        driverPayType.value = "N";

        mData.value.vehicId = null;
        mData.value.driverId = null;
        mData.value.carNum = null;
        mData.value.driverName = null;
        mData.value.driverTel = null;
        mData.value.carMngName = null;
        mData.value.carMngMemo = null;

        mData.value.carTonCode = null;
        mData.value.carTonName = null;
        mData.value.carTypeCode = null;
        mData.value.carTypeName = null;

        talkYn.value = false;
        kakaoPushEnable.value = false;

        buyDrivLicNum.value = "";
        break;
      case TRANS_TYPE_02 :
      //차량
        tvTransType01.value = false;
        tvTransType02.value = true;

        llTransType01.value = false;
        llTransType02.value = true;

        registType.value = true;

        mData.value.buyCustId = null;
        mData.value.buyCustName = null;

        mData.value.buyDeptId = null;
        mData.value.buyDeptName = null;

        mData.value.buyStaffTel = null;
        mData.value.buyStaffName = null;
        mData.value.buyStaff = null;

        talkYn.value = false;
        kakaoPushEnable.value = false;

        buyDrivLicNum.value = "";
        mCustData.value = CustomerModel();
        break;
    }
  }

  Future<void> displayChargeInfo() async {
    isCharge.value = !isCharge.value;
    llChargeInfo.value = isCharge.value;
    ivChargeExpand.value = isCharge.value;
  }

  Future<void> goToCustomer() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCustomerPage(sellBuySctn:"02")));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["cust"] != null) {
          await setCustomer(results["cust"]);
          setState(() {});
        }
      }
    }
  }

  Future<void> goToCompanyKeeper() async {
    if(mCustData.value == null) {
      return;
    }

    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCustUserPage(mode: MODE.KEEPER, custId: mCustData.value.custId, deptId: mCustData.value.deptId)));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["custUser"] != null) {
          await setCustUser(results["custUser"]);
        }
      }
    }
  }

  Future<void> setCustomer(CustomerModel data) async {
    mData.value.buyCustId = data.custId;
    mData.value.buyCustName = data.custName;
    mData.value.buyDeptId = data.deptId;
    mData.value.buyDeptName = data.deptName;

    mCustData.value = data;

    mData.value.buyStaffTel = null;
    mData.value.buyStaffName = null;
    mData.value.buyStaff = null;

    UserModel user = await controller.getUserInfo();

    await getUnitChargeComp(user.custId, user.deptId,mData.value.buyCustId, mData.value.buyDeptId);
  }

  Future<void> setCustUser(CustUserModel data) async {
    mData.value.buyStaff = data.userId;
    mData.value.buyStaffTel = data.mobile;
    mData.value.buyStaffName = data.userName;

    kakaoPushEnable.value = true;

    if(data.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }
    setState(() {});
  }

  Future<void> goToCarSearch() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CarSearchPage()));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["car"] != null) {
          await setCar(results["car"]);
          setState(() {});
        }
      }
    }
  }

  Future<void> setCar(CarModel data) async {
    mData.value.vehicId = data.vehicId;
    mData.value.driverId = data.driverId;
    mData.value.carNum = data.carNum;
    mData.value.driverName = data.driverName;
    mData.value.driverTel = data.mobile;
    mData.value.carMngName = data.carMngName;
    mData.value.carMngMemo = data.carMngMemo;

    // 차량 데이터 부르고 Setting 다시 하는 모듈
    // 해당 업데이트 설정 시 Side Effect 있는지 확인
    mData.value.carTypeCode = data.carTypeCode;
    mData.value.carTypeName = data.carTypeName;
    mData.value.carTonCode = data.carTonCode;
    mData.value.carTonName = data.carTonName;

    //차주 알림톡 여부 추가
    mData.value.talkYn = data.talkYn;
    if(data.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }
    kakaoPushEnable.value = true;

    driverPayType.value = data.payType??"";

    if(Util.ynToBoolean(mData.value.custPayType)) {
      if(!(mData.value.chargeType == "01")) {
        await setPayType("N","미사용");
      }else{
        await setPayType(Util.ynToBoolean(data.payType) ? "Y" : "N", Util.ynToBoolean(data.payType) ? "사용" : "미사용");
      }
    }

    /*String? dncStr = null;
    if(!(data.buyDriverLicenseNumber?.isEmpty == true) && data.buyDriverLicenseNumber != null) {
      try {
        dncStr = await Util.dataDecode(data.buyDriverLicenseNumber ?? "");
      } catch (e) {
        e.printError();
      }

      StringBuffer dummy;

      if (dncStr != null) {
        if (dncStr.length > 6) {
          buyDrivLicNum.value = dncStr;
        }else{
          buyDrivLicNum.value = dncStr;
        }
      }
    }else{
      buyDrivLicNum.value = "";
    }*/
  }

  Future<void> showPayTypeDialog() async {
    if(Util.ynToBoolean(mData.value.custPayType)) {
      if(Util.ynToBoolean(driverPayType.value)) {
        if(mData.value.chargeType == "01") {
          ShowCodeDialogWidget(context:context, mTitle: "검색 조건", codeType: Const.USE_YN, mFilter: "", callback: searchItem).showDialog();
        }
      }
    }
  }

  Future<void> setPayType(String? type, String? name) async {
    payType.value = type??"";
    tvPayType.value = name??"";
  }

 void searchItem(CodeModel? codeModel,String? codeType) {
    if(codeType != "") {
      switch (codeType) {
        case 'USE_YN' :
          payType.value = codeModel?.code??"";
          tvPayType.value = codeModel?.codeName??"";
          break;
      }
    }
    setState(() {});
  }

  Future<void> encodeBuyDLN() async {
    String? encStr = null;
    String value = buyDrivLicNum.trim();
    if(value == "" || value == null) {
      return;
    }
    String res = value.replaceAll(RegExp(r'[^0-9]'), "");

    try {
      String enc = await Util.dataEncryption(res);
      encStr = enc.replaceAll("\n", "");
      buyDrivLicNum.value = encStr;
    }catch(e) {
      buyDrivLicNum.value = "";
      e.printError();
    }
  }

  Future<void> confirm() async {
    await encodeBuyDLN();

    var result = await validation();
    if(result) {
      if(mData.value.allocState == "11") {
        await showCancelLink();
      }else{
        await orderAlloc();
      }
    }
  }

  Future<bool> validation() async {
    if(transType.value == TRANS_TYPE_01) {
      if(mData.value.buyCustName?.isEmpty == true || mData.value.buyCustName == null) {
        Util.snackbar(context,Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해주세요._");
        return false;
      }

      if(mData.value.buyStaffName?.isEmpty == true || mData.value.buyStaffName == null) {
        Util.snackbar(context,Strings.of(context)?.get("order_trans_info_keeper_hint")??"담당자를 지정해주세요._");
        return false;
      }
    }else{
      if(mData.value.carNum?.trim().isEmpty == true || mData.value.carNum?.trim() == null) {
        Util.snackbar(context,Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해주세요._");
        return false;
      }
    }
    if(mData.value.buyCharge?.trim().isEmpty == true || mData.value.buyCharge?.trim() == null) {
      Util.snackbar(context,Strings.of(context)?.get("order_trans_info_charge_hint")??"운임비를 입력해주세요._");
      return false;
    }

    if(mData.value.call24Cargo == "I" || mData.value.call24Cargo == "U" ||  mData.value.call24Cargo == "Y"
        || mData.value.manCargo == "I" || mData.value.manCargo == "U" || mData.value.manCargo == "Y"
        || mData.value.oneCargo == "I" || mData.value.oneCargo == "U" || mData.value.oneCargo == "Y") {
      if(tvTotal.value < 20000) {
        Util.toast("지불운임은 20,000원이상입니다.");
        return false;
      }
    }

    return true;
  }

  Future<void> getUnitChargeComp(String? sellCustId, String? sellDeptId, String? buyCustId, String? buyDeptId) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTmsUnitCompCharge(
      user.authorization,
      "01",
      sellCustId??"",
      sellDeptId??"",
      buyCustId??"",
      buyDeptId??"",
        mData.value.sSido,
        mData.value.sGungu,
        mData.value.sDong,
        mData.value.sComName,
        mData.value.eSido,
        mData.value.eGungu,
        mData.value.eDong,
        orderCarTonCode.value,
        orderCarTypeCode.value,
        mData.value.sDate,
        mData.value.eDate,
        mData.value.eComName,
        mData.value.unitPriceType
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getUnitChargeComp() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              UnitChargeModel value = UnitChargeModel.fromJSON(it.response.data["data"]);
              setState(() {
                mData.value.buyCharge = value.unit_charge;
                etBuyChargeController.text = value.unit_charge??"0";
              });
            }else{
              setState(() {
                mData.value.buyCharge = orderBuyCharge.value;
                etBuyChargeController.text = orderBuyCharge.value;
              });
            }
            setTotal();
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getUnitChargeComp() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getUnitChargeComp() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeComp() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> orderAlloc() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    var call;
    if(transType.value == TRANS_TYPE_01) {
      await DioService.dioClient(header: true).orderAlloc(
          user.authorization,
          mData.value.orderId,
          user.custId, user.deptId, user.userId, user.mobile,
          mData.value.buyCustId, mData.value.buyDeptId, mData.value.buyStaff, mData.value.buyStaffTel,
          mData.value.buyCharge, mData.value.buyFee, "", "", "",
          mData.value.carTonCode, mData.value.carTypeCode,"","",mData.value.driverMemo,
          mData.value.wayPointMemo, mData.value.wayPointCharge, mData.value.stayMemo, mData.value.stayCharge,
          mData.value.handWorkMemo, mData.value.handWorkCharge, mData.value.roundMemo, mData.value.roundCharge,
          mData.value.otherAddMemo,mData.value.otherAddCharge, "",talkYn.value ? "Y" : "N",buyDrivLicNum.value
      ).then((it) async {
        try {
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("getUnitChargeComp() TRANS_TYPE_01 _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid ? "trans_order_aos" : "trans_order_ios",
                parameters: {
                  "user_id": user.userId??"",
                  "user_custId" : user.custId??"",
                  "user_deptId": user.deptId??"",
                  "orderId" : mData.value.orderId??"",
                  "buyCustId" : mData.value.buyCustId??"",
                  "buyDeptId" : mData.value.buyDeptId??""
                },
              );
              Navigator.of(context).pop({'code': 200});
            } else {
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          }
        }catch(e) {
          print("getUnitChargeComp() TRANS_TYPE_01 Exeption =>$e");
        }
      }).catchError((Object obj){
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("getUnitChargeComp() TRANS_TYPE_01 Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("getUnitChargeComp() TRANS_TYPE_01 getOrder Default => ");
            break;
        }
      });
    }else{
      await DioService.dioClient(header: true).orderAlloc(
          user.authorization,
          mData.value.orderId,
          mData.value.custId, mData.value.deptId, user.userId, user.mobile,
          "", "", "", "", mData.value.buyCharge, mData.value.buyFee,
          mData.value.vehicId, mData.value.driverId, mData.value.carNum, mData.value.carTonCode,
          mData.value.carTypeCode,mData.value.driverName,mData.value.driverTel,mData.value.driverMemo,
          mData.value.wayPointMemo, mData.value.wayPointCharge, mData.value.stayMemo, mData.value.stayCharge,
          mData.value.handWorkMemo, mData.value.handWorkCharge, mData.value.roundMemo, mData.value.roundCharge,
          mData.value.otherAddMemo,mData.value.otherAddCharge, payType.value,talkYn.value ? "Y" : "N",buyDrivLicNum.value
      ).then((it) async {
        try {
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("getUnitChargeComp() TRANS_TYPE_02 _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              Navigator.of(context).pop({'code': 200});
            } else {
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          }
        }catch(e) {
          print("getUnitChargeComp() TRANS_TYPE_02 Exeption =>$e");
        }
      }).catchError((Object obj){
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("getUnitChargeComp() TRANS_TYPE_02 Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("getUnitChargeComp() TRANS_TYPE_02 getOrder Default => ");
            break;
        }
      });
    }
  }

  Future<void> showCancelLink() async {
    await  openCommonConfirmBox(
        context,
        "정보망에 접수되어 있는 오더입니다.\n정보망 취소 후 배차하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await cancelLink();
        }
    );
  }

  Future<void> cancelLink() async {
    await pr?.show();
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).cancelAllLink(
          user.authorization, mData.value.orderId
      ).then((it) async {
        await pr?.hide();
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            mData.value.allocState == "00";
            await orderAlloc();
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
    }).catchError((Object obj) async {
        await pr?.hide();
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

  Future<void> save() async {
    await pr?.show();
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOptionTrans(user.authorization, "Y",mData.value.buyCharge,mData.value.driverMemo
    ).then((it) async {
      await pr?.hide();
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("save() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            await Util.setEventLog(URL_ORDER_ALLOC_REG, "배차하기");
            Navigator.of(context).pop({'code': 200,Const.RESULT_WORK_STOP_POINT:Const.RESULT_SETTING_TRANS});
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("save() Exeption =>$e");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("save() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("save() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showResetDialog() async {
    await  openCommonConfirmBox(
        context,
        "배차 정보 설정값을 초기화 하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await reset();
        }
    );
  }

  Future<void> reset() async {
    await pr?.show();
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOptionTrans(
        user.authorization, "Y", null, null
    ).then((it) async {
      await pr?.hide();
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("reset() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Navigator.of(context).pop({'code': 200,Const.RESULT_WORK:Const.RESULT_SETTING_TRANS});
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("reset() Exeption =>$e");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("reset() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("reset() getOrder Default => ");
          break;
      }
    });
  }

  // Function End



  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          backgroundColor: light_gray24,
          appBar: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_trans_info_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(styleFontSize16, Colors.black)
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back,size: 24.h, color: Colors.black),
                ),
              ),
          body: SafeArea(
              child: //Obx(() {
                 SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                          customTabBarWidget(),
                          tabBarViewWidget(),
                          //mainBodyWidget(),
                        ],
                   )
                )
             // })
          ),
            bottomNavigationBar: Obx((){
              return SizedBox(
                height: CustomStyle.getHeight(55),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    !isOption.value?
                        Expanded(
                          flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children :[
                            Expanded(
                              flex:4,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Strings.of(context)?.get("order_trans_info_total_charge")??"지불운임(소계)_",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w700),
                                    ),
                                      Text(
                                        "총 ${Util.getInCodeCommaWon(tvTotal.value.toString())} 원",
                                        style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w700),
                                      )
                                  ],
                                )
                              )
                            ),
                            //확인 버튼
                            Expanded(
                                flex:3,
                                child: InkWell(
                                onTap: () async {
                                  await confirm();
                                  },
                                child: Container(
                                  decoration: const BoxDecoration(color: renew_main_color2),
                                  alignment: Alignment.center,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      Strings.of(context)?.get("confirm") ?? "Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol)),
                                  )
                              )
                            )
                          ]
                        )
                        )
                        : Expanded(
                            flex: 1,
                            child: Row(
                            children : [
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () async {
                                        await showResetDialog();
                                      },
                                      child: Container(
                                          height: CustomStyle.getHeight(60),
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(color: sub_btn),
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.refresh, size: 20, color: styleWhiteCol),
                                                CustomStyle.sizedBoxWidth(5.0),
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  Strings.of(context)?.get("reset") ?? "Not Found",
                                                  style: CustomStyle.CustomFont(
                                                      styleFontSize16, styleWhiteCol),
                                                ),
                                              ]
                                          )
                                      )
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () async {
                                        await save();
                                      },
                                      child: Container(
                                          height: CustomStyle.getHeight(60),
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(color: renew_main_color2),
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.save_alt, size: 20, color: styleWhiteCol),
                                                CustomStyle.sizedBoxWidth(5.0),
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  Strings.of(context)?.get("save") ?? "Not Found",
                                                  style: CustomStyle.CustomFont(
                                                      styleFontSize16, styleWhiteCol),
                                                ),
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                          )
                        )
                    //초기화 버튼
                  ],
                ));
          })
        )
    );
  }




}