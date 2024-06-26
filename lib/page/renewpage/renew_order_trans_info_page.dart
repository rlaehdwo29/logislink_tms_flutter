import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
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

class RenewOrderTransInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  RenewOrderTransInfoPage({Key? key,required this.order_vo, this.code}):super(key:key);

  _RenewOrderTransInfoPageState createState() => _RenewOrderTransInfoPageState();
}


class _RenewOrderTransInfoPageState extends State<RenewOrderTransInfoPage> with TickerProviderStateMixin {

  ProgressDialog? pr;

  final code = "".obs;
  final orderCarTonCode = "".obs;
  final orderCarTypeCode = "".obs;
  final orderBuyCharge = "".obs;

  final isTransInfoExpanded = [].obs;
  final isEtcExpanded = [].obs;
  final mTabCode = "01".obs;
  late TabController _tabController;

  final mData = OrderModel().obs;
  final mTempData = OrderModel().obs;
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
  late TextEditingController etRegistController;
  late TextEditingController etCustNameController;
  late TextEditingController etKeeperController;
  late TextEditingController etCarNumController;

  //추가 운임 EditText
  late TextEditingController etWayPointController;
  late TextEditingController etWayPointMemoController;
  late TextEditingController etStayChargeController;
  late TextEditingController etStayChargeMemoController;
  late TextEditingController etHandWorkChargeController;
  late TextEditingController ethandWorkMemoController;
  late TextEditingController etRoundChargeController;
  late TextEditingController etRoundMemoController;
  late TextEditingController etOtherAddChargeController;
  late TextEditingController etOtherAddMemoController;

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
    etRegistController = TextEditingController();
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


    Future.delayed(Duration.zero, () async {

      userInfo.value = await controller.getUserInfo();
      if(widget.order_vo != null) {
        var order = widget.order_vo;
        mData.value = OrderModel(
            orderId: order.orderId,
            reqCustId: order.reqCustId,
            reqCustName: order.reqCustName,
            reqDeptId: order.reqDeptId,
            reqDeptName: order.reqDeptName,
            reqStaff: order.reqStaff,
            reqTel: order.reqTel,
            reqAddr: order.reqAddr,
            reqAddrDetail: order.reqAddrDetail,
            custId: order.custId,
            custName: order.custName,
            deptId: order.deptId,
            deptName: order.deptName,
            inOutSctn: order.inOutSctn,
            inOutSctnName: order.inOutSctnName,
            truckTypeCode: order.truckTypeCode,
            truckTypeName: order.truckTypeName,
            sComName: order.sComName,
            sSido: order.sSido,
            sGungu: order.sGungu,
            sDong: order.sDong,
            sAddr: order.sAddr,
            sAddrDetail: order.sAddrDetail,
            sDate: order.sDate,
            sStaff: order.sStaff,
            sTel: order.sTel,
            sMemo: order.sMemo,
            eComName: order.eComName,
            eSido: order.eSido,
            eGungu: order.eGungu,
            eDong: order.eDong,
            eAddr: order.eAddr,
            eAddrDetail: order.eAddrDetail,
            eDate: order.eDate,
            eStaff: order.eStaff,
            eTel: order.eTel,
            eMemo: order.eMemo,
            sLat: order.sLat,
            sLon: order.sLon,
            eLat: order.eLat,
            eLon: order.eLon,
            goodsName: order.goodsName,
            goodsWeight: order.goodsWeight,
            weightUnitCode: order.weightUnitCode,
            weightUnitName: order.weightUnitName,
            goodsQty: order.goodsQty,
            qtyUnitCode: order.qtyUnitCode,
            qtyUnitName: order.qtyUnitName,
            sWayCode: order.sWayCode,
            sWayName: order.sWayName,
            eWayCode: order.eWayCode,
            eWayName: order.eWayName,
            mixYn: order.mixYn,
            mixSize: order.mixSize,
            returnYn: order.returnYn,
            carTonCode: order.carTonCode,
            carTonName: order.carTonName,
            carTypeCode: order.carTypeCode,
            carTypeName: order.carTypeName,
            chargeType: order.chargeType,
            chargeTypeName: order.chargeTypeName,
            distance: order.distance,
            time: order.time,
            reqMemo: order.reqMemo,
            driverMemo: order.driverMemo,
            itemCode: order.itemCode,
            itemName: order.itemName,
            orderState: order.orderState,
            orderStateName: order.orderStateName,
            regid: order.regid,
            regdate: order.regdate,
            stopCount: order.stopCount,
            sellAllocId: order.sellAllocId,
            sellCustId: order.sellCustId,
            sellDeptId: order.sellDeptId,
            sellStaff: order.sellStaff,
            sellStaffName: order.sellStaffName,
            sellStaffTel: order.sellStaffTel,
            sellCustName: order.sellCustName,
            sellDeptName: order.sellDeptName,
            sellCharge: order.sellCharge,
            sellFee: order.sellFee,
            sellWeight: order.sellWeight,
            sellWayPointMemo: order.sellWayPointMemo,
            sellWayPointCharge: order.sellWayPointCharge,
            sellStayMemo: order.sellStayMemo,
            sellStayCharge: order.sellStayCharge,
            sellHandWorkMemo: order.sellHandWorkMemo,
            sellHandWorkCharge: order.sellHandWorkCharge,
            sellRoundMemo: order.sellRoundMemo,
            sellRoundCharge: order.sellRoundCharge,
            sellOtherAddMemo: order.sellOtherAddMemo,
            sellOtherAddCharge: order.sellOtherAddCharge,
            custPayType: order.custPayType,
            allocId: order.allocId,
            allocState: order.allocState,
            allocStateName: order.allocStateName,
            buyCustId: order.buyCustId,
            buyDeptId: order.buyDeptId,
            buyCustName: order.buyCustName,
            buyDeptName: order.buyDeptName,
            buyStaff: order.buyStaff,
            buyStaffName: order.buyStaffName,
            buyStaffTel: order.buyStaffTel,
            buyCharge: order.buyCharge,
            buyFee: order.buyFee,
            allocDate: order.allocDate,
            driverState: order.driverState,
            vehicId: order.vehicId,
            driverId: order.driverId,
            carNum: order.carNum,
            driverName: order.driverName,
            driverTel: order.driverTel,
            driverStateName: order.driverStateName,
            carMngName: order.carMngName,
            carMngMemo: order.carMngMemo,
            receiptYn: order.receiptYn,
            receiptPath: order.receiptPath,
            receiptDate: order.receiptDate,
            charge: order.charge,
            startDate: order.startDate,
            finishDate: order.finishDate,
            enterDate: order.enterDate,
            payDate: order.payDate,
            linkCode: order.linkCode,
            linkCodeName: order.linkCodeName,
            linkType: order.linkType,
            buyLinkYn: order.buyLinkYn,
            linkName: order.linkName,
            wayPointMemo: order.wayPointMemo,
            wayPointCharge: order.wayPointCharge,
            stayMemo: order.stayMemo,
            stayCharge: order.stayCharge,
            handWorkMemo: order.handWorkMemo,
            handWorkCharge: order.handWorkCharge,
            roundMemo: order.roundMemo,
            roundCharge: order.roundCharge,
            otherAddMemo: order.otherAddMemo,
            otherAddCharge: order.otherAddCharge,
            unitPrice: order.unitPrice,
            unitPriceType: order.unitPriceType,
            unitPriceTypeName: order.unitPriceTypeName,
            custMngName: order.custMngName,
            custMngMemo: order.custMngMemo,
            payType: order.payType,
            reqPayYN: order.reqPayYN,
            reqPayDate: order.reqPayDate,
            talkYn: order.talkYn,
            orderStopList: order.orderStopList,
            reqStaffName: order.reqStaffName,
            call24Cargo: order.call24Cargo,
            manCargo: order.manCargo,
            oneCargo: order.oneCargo,
            call24Charge: order.call24Charge,
            manCharge: order.manCharge,
            oneCharge: order.oneCharge
        );
      }else{
        mData.value = OrderModel();
      }
      mTempData.value = OrderModel.fromJSON(mData.value.toMap());
      if(widget.code != null) {
        code.value = widget.code!;
      }
      mCustData.value = CustomerModel();

      orderCarTonCode.value = mTempData.value.carTonCode??"";
      orderCarTypeCode.value = mTempData.value.carTypeCode??"";
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
                            mTempData.value.buyCustName?.isEmpty == true || mTempData.value.buyCustName == null ?
                            Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해 주세요._" : mTempData.value.buyCustName!,
                            style: CustomStyle.CustomFont(styleFontSize14,  mTempData.value.buyCustName?.isEmpty == true || mTempData.value.buyCustName == null ? styleDefaultGrey : text_color_01),
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
                          mTempData.value.buyStaffName == null || mTempData.value.buyStaffName?.isNotEmpty == true ? "담당자를 선택해주세요.":  mTempData.value.buyStaffName??"",
                          style: CustomStyle.CustomFont(styleFontSize14,  mTempData.value.buyStaffName == null || mTempData.value.buyStaffName?.isNotEmpty == true ? styleDefaultGrey : text_color_01),
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
                        Util.makePhoneNumber(mTempData.value.buyStaffTel),
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                    ],
                  )
              ),

              // 지불운임
              InkWell(
                onTap: () async {
                  await openRpaModiDialog(context,mTempData.value);
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
                        Text(
                          "${Util.getInCodeCommaWon(mTempData.value.buyCharge??"0")}   원",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01, font_weight: FontWeight.w700),
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
              !isOption.value ? transInfoPannelWidget(mTempData.value) : const SizedBox(),
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
                    mTempData.value.carNum?.isEmpty == true || mTempData.value.carNum == null ?
                    Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해 주세요._": mTempData.value.carNum!,
                    style: CustomStyle.CustomFont(styleFontSize14,  mTempData.value.carNum?.isEmpty == true || mTempData.value.carNum == null ? styleDefaultGrey : text_color_01),
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
                    mTempData.value.driverName??"",
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
                    Util.makePhoneNumber(mTempData.value.driverTel),
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
                    mTempData.value.carTypeName??"",
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
                    mTempData.value.carTonName??"",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                ],
              )
          ),

          // 지불운임
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
                  Text(
                    "${Util.getInCodeCommaWon(mTempData.value.buyCharge??"0")} 원",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01, font_weight: FontWeight.w700),
                  ),
                ],
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
                          "assets/image/ic_trans_idcard.png",
                          width: CustomStyle.getWidth(17.0),
                          height: CustomStyle.getHeight(17.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_regist")??"빠른지급여부_",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500)
                            )
                        )
                      ]
                  ),
                  Text(
                    etRegistController.text,
                    style: CustomStyle.CustomFont(styleFontSize14,  text_color_01),
                  ),
                ],
              )
          ),
          !isOption.value ? transInfoPannelWidget(mTempData.value) : const SizedBox(),
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
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Text(
                Strings.of(context)?.get("order_trans_info_type_01")??"운송사_",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
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
    etRegistController.dispose();
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
  }

  Widget mainBodyWidget() {

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: line,
                          width: 1.w
                      )
                  )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_sub_title_01")??"배차_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                  !isOption.value?
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Text(
                            Strings.of(context)?.get("order_trans_info_sub_title_05")??"카카오톡 수신여부_",
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          )
                      ),
                      Switch(
                          value: talkYn.value,
                          onChanged: (value) {
                            if (kakaoPushEnable.value) {
                              setState(() async {
                                talkYn.value = value;
                              });
                            }
                          }
                      )
                    ],
                  ) : const SizedBox()
                ],
              )),
          !isOption.value?
          Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(15.h)),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            transType.value = TRANS_TYPE_01;
                            await setTransType();
                            etBuyChargeController.text = orderBuyCharge.value;
                            mTempData.value.buyCharge = orderBuyCharge.value;
                            await setTotal();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                            decoration: BoxDecoration(
                              border: Border.all(color: tvTransType01.value?text_box_color_01 : text_box_color_02, width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w)),
                            ),
                            child: Text(
                              Strings.of(context)?.get("order_trans_info_type_01")??"운송사_",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, tvTransType01.value?text_box_color_01 : text_box_color_02),
                            ),
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            transType.value = TRANS_TYPE_02;
                            await setTransType();
                            etBuyChargeController.text = orderBuyCharge.value;
                            mTempData.value.buyCharge = orderBuyCharge.value;
                            await setTotal();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                            decoration: BoxDecoration(
                              border: Border.all(color: tvTransType02.value?text_box_color_01 : text_box_color_02, width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w)),
                            ),
                            child: Text(
                              Strings.of(context)?.get("order_trans_info_type_02")??"차량_",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, tvTransType02.value?text_box_color_01 : text_box_color_02),
                            ),
                          )
                      )
                  )
                ],
              )) : const SizedBox(),
          // 운송사(필수)
          !isOption.value && llTransType01.value ?
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_trans_info_cust")??"운송사_",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                        child: Text(
                          Strings.of(context)?.get("essential")??"(필수)_",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                        )
                    )
                  ],
                ),
                InkWell(
                    onTap: () async {
                      await goToCustomer();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                        height: CustomStyle.getHeight(35.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: text_box_color_02, width: 1.w),
                            borderRadius: BorderRadius.all(Radius.circular(5.w))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mTempData.value.buyCustName?.isEmpty == true || mTempData.value.buyCustName == null ?
                              Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해 주세요._" : mTempData.value.buyCustName!,
                              style: CustomStyle.CustomFont(styleFontSize14, mTempData.value.buyCustName?.isEmpty == true || mTempData.value.buyCustName == null ? styleDefaultGrey : text_color_01),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Icon(
                                Icons.search,
                                size: 24.h,
                                color: text_color_03,
                              ),
                            )
                          ],
                        )
                    )
                )
              ],
            ),
          ) : const SizedBox(),
          // 담당자(필수) / 연락처(필수)
          !isOption.value && llTransType01.value ?
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_company_keeper")??"담당자_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      InkWell(
                          onTap: () async {
                            await goToCompanyKeeper();
                          },
                          child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                              height: CustomStyle.getHeight(35.h),
                              decoration: BoxDecoration(
                                  border: Border.all(color: text_box_color_02, width: 1.w),
                                  borderRadius: BorderRadius.all(Radius.circular(5.w))
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    mTempData.value.buyStaffName??"",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                                    child: Icon(
                                      Icons.search,
                                      size: 24.h,
                                      color: text_color_03,
                                    ),
                                  )
                                ],
                              )
                          )
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex:1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_company_tel")??"연락처_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w)),
                          height: CustomStyle.getHeight(35.h),
                          decoration: BoxDecoration(
                              border: Border.all(color: text_box_color_02, width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                          ),
                          child: Text(
                            Util.makePhoneNumber(mTempData.value.buyStaffTel),
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
          // 차량번호(필수)
          !isOption.value &&llTransType02.value ?
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_trans_info_car_num")??"차량번호_",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                        child: Text(
                          Strings.of(context)?.get("essential")??"(필수)_",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                        )
                    )
                  ],
                ),
                InkWell(
                    onTap: () async {
                      await goToCarSearch();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                        height: CustomStyle.getHeight(35.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: text_box_color_02, width: 1.w),
                            borderRadius: BorderRadius.all(Radius.circular(5.w))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mTempData.value.carNum?.isEmpty == true || mTempData.value.carNum == null ?
                              Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해 주세요._": mTempData.value.carNum!,
                              style: CustomStyle.CustomFont(styleFontSize14,  mTempData.value.carNum?.isEmpty == true || mTempData.value.carNum == null ? styleDefaultGrey : text_color_01),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Icon(
                                Icons.search,
                                size: 24.h,
                                color: text_color_03,
                              ),
                            )
                          ],
                        )
                    )
                )
              ],
            ),
          ) : const SizedBox(),
          // 차주성명(필수) / 연락처(필수)
          !isOption.value && llTransType02.value ?
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_driver_name")??"차주성명",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                        height: CustomStyle.getHeight(35.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: text_box_color_02, width: 1.w),
                            borderRadius: BorderRadius.all(Radius.circular(5.w))
                        ),
                        child: Text(
                          mTempData.value.driverName??"",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex:1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_driver_tel")??"연락처_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w)),
                          height: CustomStyle.getHeight(35.h),
                          decoration: BoxDecoration(
                              border: Border.all(color: text_box_color_02, width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                          ),
                          child: Text(
                            Util.makePhoneNumber(mTempData.value.driverTel),
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
          // 차종/ 톤급
          !isOption.value && llTransType02.value ?
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_car_type_name")??"차종_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                        height: CustomStyle.getHeight(35.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: text_box_color_02, width: 1.w),
                            borderRadius: BorderRadius.all(Radius.circular(5.w))
                        ),
                        child: Text(
                          mTempData.value.carTypeName??"",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex:1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_car_ton_name")??"톤급_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w)),
                          height: CustomStyle.getHeight(35.h),
                          decoration: BoxDecoration(
                              border: Border.all(color: text_box_color_02, width: 1.w),
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                          ),
                          child: Text(
                            Util.makePhoneNumber(mTempData.value.carTonName),
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
          // 지불운임(필수) / 빠른지급여부
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Strings.of(context)?.get("order_trans_info_charge")??"지불운임_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                              child: Text(
                                Strings.of(context)?.get("essential")??"(필수)_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                          )
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                          height: CustomStyle.getHeight(34.h),
                          child: TextField(
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.number,
                            controller: etBuyChargeController,
                            maxLines: 1,
                            decoration: etBuyChargeController.text.isNotEmpty
                                ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  etBuyChargeController.clear();
                                  mTempData.value.buyCharge = "0";
                                },
                                icon: Icon(
                                  Icons.clear,
                                  size: 18.h,
                                  color: Colors.black,
                                ),
                              ),
                              suffix: Text(
                                "원",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                            )
                                : InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                            ),
                            onChanged: (value) async {
                              if(value.length > 0) {
                                etBuyChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                mTempData.value.buyCharge = etBuyChargeController.text.replaceAll(",", "");
                              }else{
                                mTempData.value.buyCharge = "0";
                                etBuyChargeController.text = "0";
                              }
                              await setTotal();
                            },
                            maxLength: 50,
                          )
                      )
                    ],
                  ),
                ),
                !isOption.value ?
                Expanded(
                  flex:1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          child: Text(
                            Strings.of(context)?.get("order_trans_info_pay")??"빠른지급여부_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      ),
                      InkWell(
                          onTap: () async {
                            await showPayTypeDialog();
                          },
                          child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w)),
                              height: CustomStyle.getHeight(35.h),
                              decoration: BoxDecoration(
                                  border: Border.all(color: text_box_color_02, width: 1.w),
                                  borderRadius: BorderRadius.all(Radius.circular(5.w))
                              ),
                              child: Text(
                                tvPayType.value,
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              )
                          )
                      )
                    ],
                  ),
                ) : const SizedBox(),
              ],
            ),
          ),
          // 운전자 주민번호
          registType.value && !isOption.value?
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Strings.of(context)?.get("order_trans_info_regist")??"운전자 주민번호_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(5.w)),
                          height: CustomStyle.getHeight(34.h),
                          child: TextField(
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.number,
                            controller: etRegistController,
                            maxLines: 1,
                            decoration: etRegistController.text.isNotEmpty
                                ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  etRegistController.clear();
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
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(5.h)
                              ),
                            ),
                            onChanged: (value){
                              etRegistController.text = (value != null ?  value?.replaceAllMapped(RegExp(r'(\d{6})(\d{6,7})'), (m) => '${m[1]}-${m[2]}') : "")!;
                            },
                            maxLength: 14,
                          )
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex:1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Text(
                        Strings.of(context)?.get("order_trans_info_regit_explain")??"*산재보험 적용 시 주민번호 입력_",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  Widget transInfoPannelWidget(OrderModel temp) {
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
                            style: CustomStyle.CustomFont(styleFontSize16, text_color_01)
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
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: etWayPointController,
                                    maxLines: 1,
                                    decoration: etWayPointController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etWayPointController.clear();
                                          temp.wayPointCharge = "0";
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
                                      hintText: Strings.of(context)?.get("order_trans_info_way_point_charge_hint")??"경유비를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      if(value.length > 0) {
                                        temp.wayPointCharge = int.parse(value.trim()).toString();
                                        etWayPointController.text = int.parse(value.trim()).toString();
                                      }else{
                                        temp.wayPointCharge = "0";
                                        etWayPointController.text = "0";
                                      }
                                      await setTotal();
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
                      //경유비 메모
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
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.text,
                                    controller: etWayPointMemoController,
                                    maxLines: 1,
                                    decoration: etWayPointMemoController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etWayPointMemoController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_way_point_memo_hint")??"경유비 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
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
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: etStayChargeController,
                                    maxLines: 1,
                                    decoration: etStayChargeController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etStayChargeController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_stay_charge_hint")??"대기료를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      if(value.length > 0) {
                                        temp.stayCharge = int.parse(value.trim()).toString();
                                        etStayChargeController.text = int.parse(value.trim()).toString();
                                      }else{
                                        temp.stayCharge = "0";
                                        etStayChargeController.text = "0";
                                      }
                                      await setTotal();
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
                      //대기료 메모
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etStayChargeMemoController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_stay_memo_hint")??"대기료 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
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
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: etHandWorkChargeController,
                                    maxLines: 1,
                                    decoration: etHandWorkChargeController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etHandWorkChargeController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_hand_work_charge_hint")??"수작업비를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
                      //수작업비 메모
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          ethandWorkMemoController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_hand_work_memo_hint")??"수작업비 메모를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
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
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: etRoundChargeController,
                                    maxLines: 1,
                                    decoration: etRoundChargeController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etRoundChargeController.clear();
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
                                      hintText: Strings.of(context)?.get("order_trans_info_round_charge_hint")??"회차료를 입력해주세요._",
                                      hintStyle: CustomStyle.greyDefFont(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      if(value.length > 0) {
                                        temp.roundCharge = int.parse(value.trim()).toString();
                                        etRoundChargeController.text = int.parse(value.trim()).toString();
                                      }else{
                                        temp.roundCharge = "0";
                                        etRoundChargeController.text = "0";
                                      }
                                      await setTotal();
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
                      //회차료 메모
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
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etRoundMemoController.clear();
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
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
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
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  height: CustomStyle.getHeight(35.h),
                                  child: TextField(
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: etOtherAddChargeController,
                                    maxLines: 1,
                                    decoration: etOtherAddChargeController.text.isNotEmpty
                                        ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etOtherAddChargeController.clear();
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
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      if(value.length > 0) {
                                        temp.otherAddCharge = int.parse(value.trim()).toString();
                                        etOtherAddChargeController.text = int.parse(value.trim()).toString();
                                      }else{
                                        temp.otherAddCharge = "0";
                                        etOtherAddChargeController.text = "0";
                                      }
                                      await setTotal();
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),
                      //기타 추가비 메모
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
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          etOtherAddMemoController.clear();
                                          temp.driverMemo = "";
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
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(5.h)
                                      ),
                                    ),
                                    onChanged: (value){
                                      temp.driverMemo = value;
                                    },
                                    maxLength: 50,
                                  )
                              )
                            ],
                          )
                      ),

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
            color: Colors.white,
            child: Text(
                "기타",
                textAlign: TextAlign.start,
                style: CustomStyle.CustomFont(styleFontSize16, text_color_01)
            )
        ),
        CustomStyle.getDivider1(),
        Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        color: line, width: 1.w
                    )
                )
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
                      controller: etOtherAddMemoController,
                      maxLines: null,
                      decoration: etOtherAddMemoController.text.isNotEmpty
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
                            etOtherAddMemoController.clear();
                            mTempData.value.driverMemo = "";
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
                        mTempData.value.driverMemo = value;
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

  Future<void> openRpaModiDialog(BuildContext context, OrderModel item) async {

    final SelectNumber = "0".obs;
    SelectNumber.value = item.buyCharge??"0";

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
                        child: Text(
                              "${Util.getInCodeCommaWon(SelectNumber.value)} 원",
                              style: CustomStyle.CustomFont(
                                  styleFontSize28, Colors.black,
                                  font_weight: FontWeight.w600),
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

                              if(int.parse(SelectNumber.value) > 20000){
                                Navigator.of(context).pop({buyCharge: SelectNumber.value});
                              }else{
                                Util.toast("지불운임은 20,000원이상입니다.");
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
    await setTransType();
    llChargeInfo.value = isCharge.value;

    if(mTempData.value.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }

    if(code.value != "") {
      isOption.value = true;
    }else{
      await getOrderOption();
    }
    etBuyChargeController.text = mTempData.value.buyCharge??"0";
    etOtherAddMemoController.text = mTempData.value.driverMemo??"";
    await setTotal();
  }

  Future<void> _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _tabController.index;
      switch(selectedTabIndex) {
        case 0 :
          mTabCode.value = "01";
          mTempData.value = OrderModel.fromJSON(mData.value.toMap());
          await initView();
          break;
        case 1 :
          mTabCode.value = "02";
          mTempData.value = OrderModel.fromJSON(mData.value.toMap());
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
                mOrderOption.value = itemsList[0];
                mTempData.value.buyCharge = mOrderOption.value.buyCharge??"0";
                orderBuyCharge.value = mOrderOption.value.buyCharge??"";
                if(!(mOrderOption.value.driverMemo?.isEmpty == true) && !(mOrderOption.value.driverMemo == null)) {
                  mTempData.value.driverMemo = mOrderOption.value.driverMemo;
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
    int buyCharge = mTempData.value.buyCharge?.isEmpty == true || mTempData.value.buyCharge == null ? 0 : int.parse(mTempData.value.buyCharge!);
    int wayPointCharge = mTempData.value.wayPointCharge?.isEmpty == true || mTempData.value.wayPointCharge == null ? 0 : int.parse(mTempData.value.wayPointCharge!);
    int stayCharge = mTempData.value.stayCharge?.isEmpty == true || mTempData.value.stayCharge == null ? 0 : int.parse(mTempData.value.stayCharge!);
    int handWorkCharge = mTempData.value.handWorkCharge?.isEmpty == true || mTempData.value.handWorkCharge == null ? 0 : int.parse(mTempData.value.handWorkCharge!);
    int roundCharge = mTempData.value.roundCharge?.isEmpty == true || mTempData.value.roundCharge == null ? 0 : int.parse(mTempData.value.roundCharge!);
    int otherAddCharge = mTempData.value.otherAddCharge?.isEmpty == true || mTempData.value.otherAddCharge == null ? 0 : int.parse(mTempData.value.otherAddCharge!);

    int total = buyCharge + wayPointCharge + stayCharge + handWorkCharge + handWorkCharge + roundCharge + otherAddCharge;
    print("뭐지 => $buyCharge // $wayPointCharge // $stayCharge // $handWorkCharge// $handWorkCharge // $roundCharge // $otherAddCharge // ${total}");
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

        mTempData.value.vehicId = null;
        mTempData.value.driverId = null;
        mTempData.value.carNum = null;
        mTempData.value.driverName = null;
        mTempData.value.driverTel = null;
        mTempData.value.carMngName = null;
        mTempData.value.carMngMemo = null;

        mTempData.value.carTonCode = null;
        mTempData.value.carTonName = null;
        mTempData.value.carTypeCode = null;
        mTempData.value.carTypeName = null;

        talkYn.value = false;
        kakaoPushEnable.value = false;

        etRegistController.text = "";
        break;
      case TRANS_TYPE_02 :
      //차량
        tvTransType01.value = false;
        tvTransType02.value = true;

        llTransType01.value = false;
        llTransType02.value = true;

        registType.value = true;

        mTempData.value.buyCustId = null;
        mTempData.value.buyCustName = null;

        mTempData.value.buyDeptId = null;
        mTempData.value.buyDeptName = null;

        mTempData.value.buyStaffTel = null;
        mTempData.value.buyStaffName = null;
        mTempData.value.buyStaff = null;

        talkYn.value = false;
        kakaoPushEnable.value = false;

        etRegistController.text = "";
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
          setState(() {});
        }
      }
    }
  }

  Future<void> setCustomer(CustomerModel data) async {
    mTempData.value.buyCustId = data.custId;
    mTempData.value.buyCustName = data.custName;
    mTempData.value.buyDeptId = data.deptId;
    mTempData.value.buyDeptName = data.deptName;

    mCustData.value = data;

    mTempData.value.buyStaffTel = null;
    mTempData.value.buyStaffName = null;
    mTempData.value.buyStaff = null;

    UserModel user = await controller.getUserInfo();

    await getUnitChargeComp(user.custId, user.deptId,mTempData.value.buyCustId, mTempData.value.buyDeptId);
  }

  Future<void> setCustUser(CustUserModel data) async {
    mTempData.value.buyStaff = data.userId;
    mTempData.value.buyStaffTel = data.mobile;
    mTempData.value.buyStaffName = data.userName;

    kakaoPushEnable.value = true;

    if(data.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }
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
    mTempData.value.vehicId = data.vehicId;
    mTempData.value.driverId = data.driverId;
    mTempData.value.carNum = data.carNum;
    mTempData.value.driverName = data.driverName;
    mTempData.value.driverTel = data.mobile;
    mTempData.value.carMngName = data.carMngName;
    mTempData.value.carMngMemo = data.carMngMemo;

    // 차량 데이터 부르고 Setting 다시 하는 모듈
    // 해당 업데이트 설정 시 Side Effect 있는지 확인
    mTempData.value.carTypeCode = data.carTypeCode;
    mTempData.value.carTypeName = data.carTypeName;
    mTempData.value.carTonCode = data.carTonCode;
    mTempData.value.carTonName = data.carTonName;

    //차주 알림톡 여부 추가
    mTempData.value.talkYn = data.talkYn;
    if(data.talkYn == "Y") {
      talkYn.value = true;
    }else{
      talkYn.value = false;
    }
    kakaoPushEnable.value = true;

    driverPayType.value = data.payType??"";

    if(Util.ynToBoolean(mTempData.value.custPayType)) {
      if(!(mTempData.value.chargeType == "01")) {
        await setPayType("N","미사용");
      }else{
        await setPayType(Util.ynToBoolean(data.payType) ? "Y" : "N", Util.ynToBoolean(data.payType) ? "사용" : "미사용");
      }
    }

    String? dncStr = null;
    if(!(data.buyDriverLicenseNumber?.isEmpty == true) && data.buyDriverLicenseNumber != null) {
      try {
        dncStr = await Util.dataDecode(data.buyDriverLicenseNumber ?? "");
      } catch (e) {
        e.printError();
      }

      StringBuffer dummy;

      if (dncStr != null) {
        if (dncStr.length > 6) {
          etRegistController.text = dncStr;
        }else{
          etRegistController.text = dncStr;
        }
      }
    }else{
      etRegistController.text = "";
    }
  }

  Future<void> showPayTypeDialog() async {
    if(Util.ynToBoolean(mTempData.value.custPayType)) {
      if(Util.ynToBoolean(driverPayType.value)) {
        if(mTempData.value.chargeType == "01") {
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
    String value = etRegistController.text.trim();
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
      if(mTempData.value.allocState == "11") {
        await showCancelLink();
      }else{
        await orderAlloc();
      }
    }
  }

  Future<bool> validation() async {
    if(transType.value == TRANS_TYPE_01) {
      if(mTempData.value.buyCustName?.isEmpty == true || mTempData.value.buyCustName == null) {
        Util.toast(Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해주세요._");
        return false;
      }

      if(mTempData.value.buyStaffName?.isEmpty == true || mTempData.value.buyStaffName == null) {
        Util.toast(Strings.of(context)?.get("order_trans_info_keeper_hint")??"담당자를 지정해주세요._");
        return false;
      }
    }else{
      if(mTempData.value.carNum?.trim().isEmpty == true || mTempData.value.carNum?.trim() == null) {
        Util.toast(Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해주세요._");
        return false;
      }
    }
    if(mTempData.value.buyCharge?.trim().isEmpty == true || mTempData.value.buyCharge?.trim() == null) {
      Util.toast(Strings.of(context)?.get("order_trans_info_charge_hint")??"운임비를 입력해주세요._");
      return false;
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
        mTempData.value.sSido,
        mTempData.value.sGungu,
        mTempData.value.sDong,
        mTempData.value.eSido,
        mTempData.value.eGungu,
        mTempData.value.eDong,
      orderCarTonCode.value,
      orderCarTypeCode.value,
        mTempData.value.sDate,
        mTempData.value.eDate

    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getUnitChargeComp() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              UnitChargeModel value = UnitChargeModel.fromJSON(it.response.data["data"]);
              mTempData.value.buyCharge = value.unit_charge;
              etBuyChargeController.text = value.unit_charge??"0";
            }else{
              mTempData.value.buyCharge = orderBuyCharge.value??"0";
              etBuyChargeController.text = orderBuyCharge.value??"0";
            }
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
          mTempData.value.orderId,
          user.custId, user.deptId, user.userId, user.mobile,
          mTempData.value.buyCustId, mTempData.value.buyDeptId, mTempData.value.buyStaff, mTempData.value.buyStaffTel,
          mTempData.value.buyCharge, mTempData.value.buyFee, "", "", "",
          mTempData.value.carTonCode, mTempData.value.carTypeCode,"","",mTempData.value.driverMemo,
          mTempData.value.wayPointMemo, mTempData.value.wayPointCharge, mTempData.value.stayMemo, mTempData.value.stayCharge,
          mTempData.value.handWorkMemo, mTempData.value.handWorkCharge, mTempData.value.roundMemo, mTempData.value.roundCharge,
          mTempData.value.otherAddMemo,mTempData.value.otherAddCharge, "",talkYn.value ? "Y" : "N",buyDrivLicNum.value
      ).then((it) async {
        try {
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("getUnitChargeComp() TRANS_TYPE_01 _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid ? "trans_order_aos" : "trans_order_ios",
                parameters: {
                  "user_id": user.userId,
                  "user_custId" : user.custId,
                  "user_deptId": user.deptId,
                  "orderId" : mTempData.value.orderId,
                  "buyCustId" : mTempData.value.buyCustId,
                  "buyDeptId" : mTempData.value.buyDeptId
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
          mTempData.value.orderId,
          mTempData.value.custId, mTempData.value.deptId, user.userId, user.mobile,
          "", "", "", "", mTempData.value.buyCharge, mTempData.value.buyFee,
          mTempData.value.vehicId, mTempData.value.driverId, mTempData.value.carNum, mTempData.value.carTonCode,
          mTempData.value.carTypeCode,mTempData.value.driverName,mTempData.value.driverTel,mTempData.value.driverMemo,
          mTempData.value.wayPointMemo, mTempData.value.wayPointCharge, mTempData.value.stayMemo, mTempData.value.stayCharge,
          mTempData.value.handWorkMemo, mTempData.value.handWorkCharge, mTempData.value.roundMemo, mTempData.value.roundCharge,
          mTempData.value.otherAddMemo,mTempData.value.otherAddCharge, payType.value,talkYn.value ? "Y" : "N",buyDrivLicNum.value
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
          user.authorization, mTempData.value.orderId
      ).then((it) async {
        await pr?.hide();
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            mTempData.value.allocState == "00";
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
    await DioService.dioClient(header: true).setOptionTrans(
        user.authorization, "Y",mTempData.value.buyCharge,mTempData.value.driverMemo
    ).then((it) async {
      await pr?.hide();
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("save() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
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
                    style: CustomStyle.appBarTitleFont(styleFontSize16, styleWhiteCol)
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back,size: 24.h, color: Colors.white),
                ),
              ),
          body: SafeArea(
              child: Obx(() {
                return SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                          customTabBarWidget(),
                          tabBarViewWidget(),
                          //mainBodyWidget(),
                        ],
                   )
                );
              })
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