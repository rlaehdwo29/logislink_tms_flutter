import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/rpa_flag_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/template_model.dart';
import 'package:logislink_tms_flutter/common/model/template_stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_template_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_reg_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cargo_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cust_user_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:phone_call/phone_call.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateTemplatePage extends StatefulWidget {

  String? code;
  String? flag;
  TemplateModel? tModel;


  CreateTemplatePage({Key? key,this.tModel,this.code,this.flag}):super(key:key);

  _CreateTemplatePageState createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> with TickerProviderStateMixin {

  final code = "".obs;
  final mData = OrderModel().obs;

  MotionTabBarController? _motionTabBarController;

  /**
   * Function Start
   */

  @override
  void initState() {
    super.initState();

    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );

    Future.delayed(Duration.zero, () async {

      if(widget.tModel != null) {
        final orderStopList = <StopPointModel>[].obs;
        if(widget.tModel?.templateStopList?.length != 0) {
          for(int i = 0; i < widget.tModel!.templateStopList!.length; i++) {
            orderStopList.add(StopPointModel(
              stopSeq : widget.tModel!.templateStopList![i].stopSeq,
              stopNo : widget.tModel!.templateStopList![i].stopNo,
              eComName : widget.tModel!.templateStopList![i].eComName,
              eAddr : widget.tModel!.templateStopList![i].eAddr,
              eAddrDetail : widget.tModel!.templateStopList![i].eAddrDetail,
              eStaff : widget.tModel!.templateStopList![i].eStaff,
              eTel : widget.tModel!.templateStopList![i].eTel,
              finishYn : widget.tModel!.templateStopList![i].finishYn,
              finishDate : widget.tModel!.templateStopList![i].finishDate,
              beginYn : widget.tModel!.templateStopList![i].beginYn,
              beginDate : widget.tModel!.templateStopList![i].beginDate,
              goodsWeight : widget.tModel!.templateStopList![i].goodsWeight,
              eLat : widget.tModel!.templateStopList![i].eLat,
              eLon : widget.tModel!.templateStopList![i].eLon,
              weightUnitCode : widget.tModel!.templateStopList![i].weightUnitCode,
              goodsQty : widget.tModel!.templateStopList![i].goodsQty,
              qtyUnitCode : widget.tModel!.templateStopList![i].qtyUnitCode,
              qtyUnitName : widget.tModel!.templateStopList![i].qtyUnitName,
              goodsName : widget.tModel!.templateStopList![i].goodsName,
              useYn : widget.tModel!.templateStopList![i].useYn,
              stopSe : widget.tModel!.templateStopList![i].stopSe,
            ));
          }
        }
        mData.value = OrderModel(
            reqCustId: widget.tModel?.reqCustId??"",
            reqCustName: widget.tModel?.reqCustName??"",
            reqDeptId: widget.tModel?.reqDeptId??"",
            reqDeptName: widget.tModel?.reqDeptName??"",
            reqStaff: widget.tModel?.reqStaff??"",
            reqTel: widget.tModel?.reqTel??"",
            reqAddr: widget.tModel?.reqAddr??"",
            reqAddrDetail: widget.tModel?.reqAddrDetail??"",
            custId: widget.tModel?.custId,
            custName: widget.tModel?.custName,
            deptId: widget.tModel?.deptId,
            deptName: widget.tModel?.deptName,
            inOutSctn: widget.tModel?.inOutSctn,
            inOutSctnName: widget.tModel?.inOutSctnName,
            truckTypeCode: widget.tModel?.truckTypeCode,
            truckTypeName: widget.tModel?.truckTypeName,

            sComName: widget.tModel?.sComName,
            sSido: widget.tModel?.sSido,
            sGungu: widget.tModel?.sGungu,
            sDong: widget.tModel?.sDong,
            sAddr: widget.tModel?.sAddr,
            sAddrDetail: widget.tModel?.sAddrDetail,
            sDate: widget.tModel?.sDate,
            sStaff: widget.tModel?.sStaff,
            sTel: widget.tModel?.sTel,
            sMemo: widget.tModel?.sMemo,
            eComName: widget.tModel?.eComName,
            eSido: widget.tModel?.eSido,
            eGungu: widget.tModel?.eGungu,
            eDong: widget.tModel?.eDong,
            eAddr: widget.tModel?.eAddr,
            eAddrDetail: widget.tModel?.eAddrDetail,
            eDate: widget.tModel?.eDate,
            eStaff: widget.tModel?.eStaff,
            eTel: widget.tModel?.eTel,
            eMemo: widget.tModel?.eMemo,
            sLat: widget.tModel?.sLat,
            sLon: widget.tModel?.sLon,
            eLat: widget.tModel?.eLat,
            eLon: widget.tModel?.eLon,
            goodsName: widget.tModel?.goodsName,
            goodsWeight: widget.tModel?.goodsWeight,
            weightUnitCode: widget.tModel?.weightUnitCode,
            weightUnitName: widget.tModel?.weightUnitName,
            goodsQty: widget.tModel?.goodsQty,
            qtyUnitCode: widget.tModel?.qtyUnitCode,
            qtyUnitName: widget.tModel?.qtyUnitName,
            sWayCode: widget.tModel?.sWayCode,
            sWayName: widget.tModel?.sWayName,
            eWayCode: widget.tModel?.eWayCode,
            eWayName: widget.tModel?.eWayName,
            mixYn: widget.tModel?.mixYn,
            mixSize: widget.tModel?.mixSize,
            returnYn: widget.tModel?.returnYn,
            carTonCode: widget.tModel?.carTonCode,
            carTonName: widget.tModel?.carTonName,
            carTypeCode: widget.tModel?.carTypeCode,
            carTypeName: widget.tModel?.carTypeName,
            chargeType: widget.tModel?.chargeType,
            chargeTypeName: widget.tModel?.chargeTypeName,
            distance: widget.tModel?.distance,
            time: widget.tModel?.time,
            reqMemo: widget.tModel?.reqMemo,
            driverMemo: widget.tModel?.driverMemo,
            itemCode: widget.tModel?.itemCode,
            itemName: widget.tModel?.itemName,
            regid: widget.tModel?.regid,
            regdate: widget.tModel?.regdate,
            stopCount: widget.tModel?.stopCount,
            sellCustId: widget.tModel?.sellCustId,
            sellDeptId: widget.tModel?.sellDeptId,
            sellStaff: widget.tModel?.sellStaff,
            sellStaffName: widget.tModel?.sellStaffName,
            sellStaffTel: widget.tModel?.sellStaffTel,
            sellCustName: widget.tModel?.sellCustName,
            sellDeptName: widget.tModel?.sellDeptName,
            sellCharge: widget.tModel?.sellCharge,
            sellFee: widget.tModel?.sellFee,
            sellWeight: widget.tModel?.sellWeight,
            sellWayPointMemo: widget.tModel?.sellWayPointMemo,
            sellWayPointCharge: widget.tModel?.sellWayPointCharge,
            sellStayMemo: widget.tModel?.sellStayMemo,
            sellStayCharge: widget.tModel?.sellStayCharge,
            sellHandWorkMemo: widget.tModel?.sellHandWorkMemo,
            sellHandWorkCharge: widget.tModel?.sellHandWorkCharge,
            sellRoundMemo: widget.tModel?.sellRoundMemo,
            sellRoundCharge: widget.tModel?.sellRoundCharge,
            sellOtherAddMemo: widget.tModel?.sellOtherAddMemo,
            sellOtherAddCharge: widget.tModel?.sellOtherAddCharge,
            custPayType: widget.tModel?.custPayType,
            buyCharge: widget.tModel?.buyCharge,
            buyFee: widget.tModel?.buyFee,
            wayPointMemo: widget.tModel?.wayPointMemo,
            wayPointCharge: widget.tModel?.wayPointCharge,
            stayMemo: widget.tModel?.stayMemo,
            stayCharge: widget.tModel?.stayCharge,
            handWorkMemo: widget.tModel?.handWorkMemo,
            handWorkCharge: widget.tModel?.handWorkCharge,
            roundMemo: widget.tModel?.roundMemo,
            roundCharge: widget.tModel?.roundCharge,
            otherAddMemo: widget.tModel?.otherAddMemo,
            otherAddCharge: widget.tModel?.otherAddCharge,
            unitPrice: widget.tModel?.unitPrice,
            unitPriceType: widget.tModel?.unitPriceType,
            unitPriceTypeName: widget.tModel?.unitPriceTypeName,
            custMngName: widget.tModel?.custMngName,
            custMngMemo: widget.tModel?.custMngMemo,
            payType: widget.tModel?.payType,
            reqPayYN: widget.tModel?.reqPayYN,
            reqPayDate: widget.tModel?.reqPayDate,
            talkYn: widget.tModel?.talkYn,
            orderStopList: orderStopList.value,
            reqStaffName: widget.tModel?.reqStaffName,
            call24Cargo: widget.tModel?.call24Cargo,
            manCargo: widget.tModel?.manCargo,
            oneCargo: widget.tModel?.oneCargo,
            call24Charge: widget.tModel?.call24Charge,
            manCharge: widget.tModel?.manCharge,
            oneCharge: widget.tModel?.oneCharge
        );
      }

      if(widget.flag == "D") {
        if (mData.value.sellCustName == null || mData.value.sellCustName?.isEmpty == true) {
          Util.toast("거래처명을 선택해주세요.");
          _motionTabBarController!.index = 0;
        } else if (mData.value.sellDeptId == null || mData.value.sellDeptId?.isEmpty == true) {
          Util.toast("담당부서를 선택해주세요.");
          _motionTabBarController!.index = 0;
        } else if (mData.value.sAddr == null || mData.value.sAddr?.isEmpty == true) {
          Util.toast("상차지를 선택해주세요.");
          _motionTabBarController!.index = 1;
        } else if (mData.value.eAddr == null || mData.value.eAddr?.isEmpty == true) {
          Util.toast("하차지를 선택해주세요.");
          _motionTabBarController!.index = 1;
        } else if (mData.value.carTypeCode == null || mData.value.carTypeCode?.isEmpty == true) {
          Util.toast("차종을 선택해주세요.");
          _motionTabBarController!.index = 2;
        } else if (mData.value.carTypeCode == null || mData.value.carTonCode?.isEmpty == true) {
          Util.toast("톤수를 선택해주세요.");
          _motionTabBarController!.index = 2;
        } else if (mData.value.goodsName == null || mData.value.goodsName?.isEmpty == true) {
          Util.toast("화물정보를 입력해주세요.");
          _motionTabBarController!.index = 2;
        }else{
          _motionTabBarController!.index = 4;
        }
      }
    });

  }

  @override
  void dispose() {
    super.dispose();

    _motionTabBarController!.dispose();
  }

  /**
   * Function End
   */





  /**
   * Widget Start
   */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code': 100});
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xffECECEC),
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    widget.flag == "M" ? "탬플릿 수정" : widget.flag == "D" ? "오더 등록" :  "탬플릿 생성",
                    textAlign: TextAlign.center,
                    style: CustomStyle.appBarTitleFont(styleFontSize16, Colors.black)
                ),
              ],
            ),
            toolbarHeight: 50.h,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              SizedBox(
                width: CustomStyle.getWidth(50),
              )
            ],
            leading: IconButton(
              onPressed: () async {
                Navigator.of(context).pop({'code': 100});
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
            ),
          ),

          body: Obx(() =>
            TabBarView(
                physics: const NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
                controller: _motionTabBarController,
                children: <Widget>[
                  MainPageContentComponent1(context: context, mData: mData.value, title: "화주 정보", tabController: _motionTabBarController!,flag: widget.flag,),
                  MainPageContentComponent2(context: context, mData: mData.value, title: "상/하차지", tabController: _motionTabBarController!,flag: widget.flag),
                  MainPageContentComponent3(context: context, mData: mData.value, title: "화물 정보", tabController: _motionTabBarController!,flag: widget.flag),
                  MainPageContentComponent4(context: context, mData: mData.value, title: "운임 정보", tabController: _motionTabBarController!,flag: widget.flag),
                  MainPageContentComponent5(context: context, mData: mData.value, title: "최종 확인", tabController: _motionTabBarController!,flag: widget.flag),
                ],
            )
          ),
          bottomNavigationBar:
              MotionTabBar(
                controller: _motionTabBarController, // ADD THIS if you need to change your tab programmatically
                initialSelectedTab: "화주 정보",
                labels: const ["화주 정보", "상/하차지", "화물 정보", "운임 정보", "최종 확인"],
                icons: const [Icons.dashboard, Icons.location_on_sharp, Icons.fire_truck, Icons.payment, Icons.receipt_long],

                // optional badges, length must be same with labels
                badges: const [
                  // Default Motion Badge Widget
                   MotionBadgeWidget(
                    text: "1",
                    textColor: Colors.white, // optional, default to Colors.white
                    color: Colors.red, // optional, default to Colors.red
                    size: 18, // optional, default to 18
                  ),

                  // custom badge Widget
                  MotionBadgeWidget(
                    text: "2",
                    textColor: Colors.white, // optional, default to Colors.white
                    color: Colors.red, // optional, default to Colors.red
                    size: 18, // optional, default to 18
                  ),

                  // allow null
                  MotionBadgeWidget(
                    text: "3",
                    textColor: Colors.white, // optional, default to Colors.white
                    color: Colors.red, // optional, default to Colors.red
                    size: 18, // optional, default to 18
                  ),

                  // Default Motion Badge Widget with indicator only
                  MotionBadgeWidget(
                    text: "4",
                    textColor: Colors.white, // optional, default to Colors.white
                    color: Colors.red, // optional, default to Colors.red
                    size: 18, // optional, default to 18
                  ),

                  MotionBadgeWidget(
                    text: "5",
                    textColor: Colors.white, // optional, default to Colors.white
                    color: Colors.red, // optional, default to Colors.red
                    size: 18, // optional, default to 18
                  ),

                ],
                tabSize: 50,
                tabBarHeight: 55,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                tabIconColor: light_gray23,
                tabIconSize: 28.0,
                tabIconSelectedSize: 26.0,
                tabSelectedColor: renew_main_color2,
                tabIconSelectedColor: Colors.white,
                tabBarColor: Colors.white,
                onTabItemSelected: (int value) {
                  setState(() {
                    _motionTabBarController!.index = value;
                  });
                },
              ),
          ),
    );
  }

  /**
   * Widget End
   */

}

/**
 * 화주 정보
 */
class MainPageContentComponent1 extends StatefulWidget {
  final BuildContext context;
  final String title;
  final OrderModel mData;
  final MotionTabBarController tabController;
  String? code;
  String? flag;

  MainPageContentComponent1({Key? key,required this.context,required this.mData, required this.title,required this.tabController,this.code,this.flag}):super(key:key);

  @override
  _MainPageContentComponent1State createState() => _MainPageContentComponent1State();
}
class _MainPageContentComponent1State extends State<MainPageContentComponent1> {
  
  final chargeCheck = "".obs;

  Future<void> goToCustomer() async {
    Map<String, dynamic> results = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) => OrderCustomerPage(
                sellBuySctn: "01",
                code:"")
        )
    );

    if (results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        bool res = results["nonCust"]??false;
        if(res) {
          chargeCheck.value = "N";
        }
        await setCustomer(results["cust"]);
      }
    }
  }

  Future<void> setCustomer(CustomerModel data) async {
    setState(() {
      widget.mData.sellCustId = data.custId;
      widget.mData.sellCustName = data.custName;

      widget.mData.sellDeptId = data.deptId;
      widget.mData.sellDeptName = data.deptName;

      widget.mData.custMngName = data.custMngName;
      widget.mData.custMngMemo = data.custMngMemo;

      widget.mData.reqAddr = data.bizAddr;
      widget.mData.reqAddrDetail = data.bizAddrDetail;
    });
  }

  Future<void> goToCustUser() async {
    if (widget.mData.sellCustId != null) {
      Map<String, dynamic> results = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => OrderCustUserPage(
                  mode: MODE.USER,
                  custId: widget.mData.sellCustId,
                  deptId: widget.mData.sellDeptId)));

      if (results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          await setCustUser(results["custUser"]);
        }
      }
    }
  }

  Future<void> setCustUser(CustUserModel data) async {
    setState(() {
      widget.mData.sellStaff = data.userId;
      widget.mData.sellStaffTel = data.mobile;
      widget.mData.sellStaffName = data.userName;
    });
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20), vertical: CustomStyle.getHeight(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "화주 정보",
              style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
            ),
            Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () async {
                        await goToCustomer();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: light_gray22,width: 1),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "* ",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.red,font_weight: FontWeight.w600),
                                  ),
                                  Text(
                                    "거래처명",
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Text(
                                  widget.mData.sellCustName == "" || widget.mData.sellCustName == null ? "거래처를 선택해주세요." : widget.mData.sellCustName??"",
                                  style: CustomStyle.CustomFont(styleFontSize14, widget.mData.sellCustName == "" || widget.mData.sellCustName == null ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                              ),
                            ],
                          )
                      )
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: light_gray22,width: 1),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "* ",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize15, Colors.red,font_weight: FontWeight.w600),
                              ),
                              Text(
                                "담당부서",
                                style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                              widget.mData.sellDeptName ?? "",
                              style: CustomStyle.CustomFont(styleFontSize14,   widget.mData.sellDeptName == null || widget.mData.sellDeptName?.isEmpty == true ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        await goToCustUser();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: light_gray22,width: 1),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "담당자",
                                style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                              ),
                              Text(
                                  widget.mData.sellStaffName??"담당자를 지정해주세요.",
                                  style: CustomStyle.CustomFont(styleFontSize14, widget.mData.sellStaffName == null || widget.mData.sellStaffName?.isEmpty == true ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                              ),
                            ],
                          )
                      )
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: light_gray22,width: 1),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "연락처",
                            style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                          ),
                          Text(
                              Util.makePhoneNumber(widget.mData.sellStaffTel),
                              style: CustomStyle.CustomFont(styleFontSize14, widget.mData.sellStaffTel == null || widget.mData.sellStaffTel?.isEmpty == true ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  (widget.code?.isEmpty == true || widget.code == null)?
                  Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: light_gray22,width: 1),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "거래처등급",
                            style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                          ),
                          Text(
                              widget.mData.custMngName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, widget.mData.custMngName == null || widget.mData.custMngName?.isEmpty == true ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                          ),
                        ],
                      )
                  ) : const SizedBox(),
                  (widget.code?.isEmpty == true || widget.code == null)?
                    Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: light_gray22,width: 1),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "거래처등급사유",
                              style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                            ),
                            Text(
                                widget.mData.custMngMemo??"",
                                style: CustomStyle.CustomFont(styleFontSize14, widget.mData.custMngMemo == null || widget.mData.custMngMemo?.isEmpty == true ? light_gray23 : Colors.black, font_weight: FontWeight.w500)
                            ),
                          ],
                        )
                    ) : const SizedBox()
                ],
              ),
            )
          ],
        ),
      );
  }
}

/**
 * 상/하차
 */
class MainPageContentComponent2 extends StatefulWidget {
  final BuildContext context;
  final OrderModel mData;
  final String title;
  final MotionTabBarController tabController;
  String? code;
  String? flag;

  MainPageContentComponent2({Key? key,required this.context,required this.mData, required this.title,required this.tabController,this.code,this.flag}):super(key:key);

  @override
  _MainPageContentComponent2State createState() => _MainPageContentComponent2State();
}
class _MainPageContentComponent2State extends State<MainPageContentComponent2> {

  final chargeCheck = "".obs;

  final llNonSAddr = false.obs;
  final llSAddr = false.obs;

  final isSAddr = false.obs;
  final isEAddr = false.obs;
  final llNonEAddr = false.obs;
  final llEAddr = false.obs;

  final llAddStopPoint = false.obs;
  final llStopPoint = false.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if(widget.mData.sAddr != null && widget.mData.sAddr?.isNotEmpty == true) {
        llSAddr.value = true;
      }
      if(widget.mData.eAddr != null && widget.mData.eAddr?.isNotEmpty == true) {
        llEAddr.value = true;
      }
    });
  }

  /**
   * 상하자 Function Start
   */

  Future<void> setActivityResult(Map<String,dynamic> results)async {
    switch(results[Const.RESULT_WORK]) {
      case Const.RESULT_WORK_SADDR :
        OrderModel OData = results[Const.ORDER_VO];
        setState(() {
          widget.mData.sComName = OData.sComName;
          widget.mData.sSido = OData.sSido;
          widget.mData.sGungu = OData.sGungu;
          widget.mData.sDong = OData.sDong;
          widget.mData.sAddr = OData.sAddr;
          widget.mData.sAddrDetail = OData.sAddrDetail;
          widget.mData.sStaff = OData.sStaff;
          widget.mData.sTel = OData.sTel;
          widget.mData.sMemo = OData.sMemo;
          widget.mData.sLat = OData.sLat;
          widget.mData.sLon = OData.sLon;
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        });
        if(!isEAddr.value) {
          await goToRegEAddr();
        }
        break;
      case Const.RESULT_WORK_EADDR :
        OrderModel OData = results[Const.ORDER_VO];
        setState(() {
          widget.mData.eComName = OData.eComName;
          widget.mData.eSido = OData.eSido;
          widget.mData.eGungu = OData.eGungu;
          widget.mData.eDong = OData.eDong;
          widget.mData.eAddr = OData.eAddr;
          widget.mData.eAddrDetail = OData.eAddrDetail;
          widget.mData.eStaff = OData.eStaff;
          widget.mData.eTel = OData.eTel;
          widget.mData.eMemo = OData.eMemo;
          widget.mData.eLat = OData.eLat;
          widget.mData.eLon = OData.eLon;
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        });
        break;
      case Const.RESULT_WORK_STOP_POINT :
        OrderModel OData = results[Const.ORDER_VO];
        setState(() {
          if(widget.mData.orderStopList == null) widget.mData.orderStopList = List.empty(growable: true);
          widget.mData.orderStopList?.addAll(OData.orderStopList??List.empty(growable: true));
        });
        await setStopPoint();
        break;
    }
  }

  Future<void> goToCargoInfo() async {
    if(isSAddr.value && isEAddr.value) {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCargoInfoPage(order_vo:widget.mData)));
      if(results["code"] == 200) {
        print("goToCargoInfo() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }else{
      Util.toast(Strings.of(context)?.get("order_reg_addr_hint")??"Not Found");
    }
  }

  Future<void> goToRegEAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo: widget.mData,code:Const.RESULT_WORK_EADDR)));
    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegEAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToAddrRegPage(String? flag) async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrRegPage(flag: flag)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToAddrReg() -> ${results["flag"]}");
        if(results["flag"] == Const.RESULT_WORK_SADDR) {
          AddrModel addr = results[Const.ADDR_VO];
          widget.mData.sComName = addr.addrName;
          widget.mData.sSido = addr.sido;
          widget.mData.sGungu = addr.gungu;
          widget.mData.sDong = addr.dong;
          widget.mData.sAddr = addr.addr;
          widget.mData.sAddrDetail = addr.addrDetail;
          widget.mData.sStaff = addr.staffName;
          widget.mData.sTel = addr.staffTel;
          widget.mData.sMemo = addr.orderMemo;
          widget.mData.sLat = double.parse(addr.lat??"0.0");
          widget.mData.sLon = double.parse(addr.lon??"0.0");
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        }else if(results["flag"] == Const.RESULT_WORK_EADDR) {
          AddrModel addr = results[Const.ADDR_VO];
          widget.mData.eComName = addr.addrName;
          widget.mData.eSido = addr.sido;
          widget.mData.eGungu = addr.gungu;
          widget.mData.eDong = addr.dong;
          widget.mData.eAddr = addr.addr;
          widget.mData.eAddrDetail = addr.addrDetail;
          widget.mData.eStaff = addr.staffName;
          widget.mData.eTel = addr.staffTel;
          widget.mData.eMemo = addr.orderMemo;
          widget.mData.eLat = double.parse(addr.lat??"0.0");
          widget.mData.eLon = double.parse(addr.lon??"0.0");
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        }else if(results["flag"] == Const.RESULT_WORK_STOP_POINT) {
          StopPointModel stopModel = results["data"];
          if(widget.mData.orderStopList != null) widget.mData.orderStopList = List.empty(growable: true);
          widget.mData.orderStopList?.add(stopModel);
        }
        setState(() {});
      }
    }
  }

  Future<void> goToRegSAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo: widget.mData, code:Const.RESULT_WORK_SADDR)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegSAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
  }

  Future<void> setStopPoint() async {
    if(widget.mData.orderStopList?.isEmpty != true && !widget.mData.orderStopList.isNull ){
      llAddStopPoint.value = false;
      llStopPoint.value = true;
    }else{
      llAddStopPoint.value = true;
      llStopPoint.value = false;
    }
  }

  Future<void> addStopPoint() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewTemplateAddrPage(code:Const.RESULT_WORK_STOP_POINT)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("addStopPoint() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
  }

  /**
   * 상하차 Function End
   */

  Future<void> goToCustomer() async {
    Map<String, dynamic> results = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) => OrderCustomerPage(
                sellBuySctn: "01",
                code:"")
        )
    );

    if (results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        bool res = results["nonCust"]??false;
        if(res) {
          chargeCheck.value = "N";
        }
        await setCustomer(results["cust"]);
      }
    }
  }

  Future<void> setCustomer(CustomerModel data) async {
    setState(() {
      widget.mData.sellCustId = data.custId;
      widget.mData.sellCustName = data.custName;

      widget.mData.sellDeptId = data.deptId;
      widget.mData.sellDeptName = data.deptName;

      widget.mData.custMngName = data.custMngName;
      widget.mData.custMngMemo = data.custMngMemo;

      widget.mData.reqAddr = data.bizAddr;
      widget.mData.reqAddrDetail = data.bizAddrDetail;
    });
  }

  Future<void> goToCustUser() async {
    if (widget.mData.sellCustId != null) {
      Map<String, dynamic> results = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => OrderCustUserPage(
                  mode: MODE.USER,
                  custId: widget.mData.sellCustId,
                  deptId: widget.mData.sellDeptId)));

      if (results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          await setCustUser(results["custUser"]);
        }
      }
    }
  }

  Future<void> setCustUser(CustUserModel data) async {
    setState(() {
      widget.mData.sellStaff = data.userId;
      widget.mData.sellStaffTel = data.mobile;
      widget.mData.sellStaffName = data.userName;
    });
  }

  /**
   * Widget Start
   */

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Container(
        padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20), vertical: CustomStyle.getHeight(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "상/하차지",
              style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
            ),
            InkWell(
              onTap: () async {
                if(widget.mData.sellCustId == null || widget.mData.sellCustId?.isEmpty == true) {
                  await goToAddrRegPage(Const.RESULT_WORK_SADDR);
                }else{
                  await goToRegSAddr();
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(10)),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,border: Border.all(color: light_gray23,width: 1)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: CustomStyle.getWidth(38),
                        height: CustomStyle.getHeight(38),
                        decoration: BoxDecoration(color: renew_main_color2,borderRadius: BorderRadius.circular(50)),
                        alignment: Alignment.center,
                        child: Text(
                            "상차",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w600),
                        )
                      )
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: llSAddr.value ? "${widget.mData.sComName}" : "상차지를 선택해주세요.",
                                style: CustomStyle.CustomFont(llSAddr.value ? styleFontSize16 : styleFontSize14,  llSAddr.value ? text_color_01 : light_gray23, font_weight: llSAddr.value ? FontWeight.w700 : FontWeight.w500),
                              ),
                            ),
                            llSAddr.value ?
                                Container(
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child: Icon(
                                            Icons.home,
                                            size: 21.h,
                                            color: light_gray23,
                                          )
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: RichText(
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            text: TextSpan(
                                                text: "${widget.mData.sAddr}",
                                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                            ),
                                          )
                                        ),
                                      ]
                                    ),
                                    widget.mData.sAddrDetail != null && widget.mData.sAddrDetail?.isEmpty == false ?
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children:[
                                          Expanded(
                                            flex:1,
                                            child:Icon(
                                              Icons.home_work,
                                              size: 21.h,
                                              color: light_gray23,
                                            )
                                          ),
                                          Expanded(
                                          flex: 7,
                                          child: Container(
                                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                              child: RichText(
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                text: TextSpan(
                                                    text: "${widget.mData.sAddrDetail}",
                                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                                ),
                                              )
                                          ))
                                          ]
                                    ) : const SizedBox(),
                                    Container(
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Icon(
                                                Icons.manage_accounts,
                                                size: 21.h,
                                                color: light_gray23,
                                              )
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Row(
                                                children: [
                                                  widget.mData.sStaff != null && widget.mData.sStaff?.isEmpty == false ?
                                                  Text(
                                                      "${widget.mData.sStaff}",
                                                      textAlign: TextAlign.start,
                                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                                  ) : const SizedBox(),
                                                  widget.mData.sTel != null && widget.mData.sTel?.isEmpty == false ?
                                                  Container(
                                                      margin: EdgeInsets.only(left: widget.mData.sStaff != null && widget.mData.sStaff?.isEmpty == false ? CustomStyle.getWidth(5) : CustomStyle.getWidth(0)),
                                                      child: Text(
                                                          "${Util.makePhoneNumber(widget.mData.sTel)}",
                                                          textAlign: TextAlign.start,
                                                          style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w400)
                                                      )
                                                  ) : const SizedBox(),
                                                ]
                                              )
                                            )

                                          ]
                                      )
                                    ),
                                    widget.mData.sMemo != null && widget.mData.sMemo?.isEmpty == false ?
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                                child: Container(
                                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                                    child: Icon(
                                                    Icons.mark_email_unread,
                                                    size: 21.h,
                                                    color: light_gray23,
                                                  )
                                                )
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                                  child: RichText(
                                                    textAlign: TextAlign.start,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    text: TextSpan(
                                                        text: "${widget.mData.sMemo}",
                                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                                    ),
                                                  )
                                              )
                                            )
                                          ],
                                        ) : const SizedBox(),
                                  ],
                                )
                              )
                             : const SizedBox()
                          ],
                        ),
                      )
                    ),
                  ],
                ),
              )
            ),
            InkWell(
              onTap: () async {
                if(widget.mData.sellCustId == null || widget.mData.sellCustId?.isEmpty == true) {
                  await goToAddrRegPage(Const.RESULT_WORK_STOP_POINT);
                }else{
                  await addStopPoint();
                }
              },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(15)),
              decoration:  BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "경유지 추가",
                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                  ),
                  const Icon(
                    Icons.add,
                    size: 21,
                    color: Colors.black,
                  )
                ],
              )
            )),
            widget.mData.orderStopList?.isNotEmpty == true ?
            Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                    widget.mData.orderStopList!.length,
                        (index) {
                      var item = widget.mData.orderStopList?[index];
                      return InkWell(
                          onTap: () async {

                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: CustomStyle.getWidth(3),
                                        height: CustomStyle.getHeight(100),
                                        margin:EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                        decoration: BoxDecoration(
                                            borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)) : index+1 == widget.mData.orderStopList!.length ? BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)) : BorderRadius.zero,
                                            color: item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle,
                                        ),
                                        child: Stack(
                                            children: [
                                              Positioned(
                                                  top: 15,
                                                  child:Icon(
                                                    Icons.circle,
                                                    size: 10.h,
                                                    color: Colors.white,
                                                  )
                                              )
                                            ]
                                        ),
                                      )
                                    ),
                                    Expanded(
                                      flex: 14,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(7)),
                                                      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                      decoration: BoxDecoration(
                                                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                                                          border: Border.all(color: text_box_color_01,width: 1.w)
                                                      ),
                                                      child: Text(
                                                        "경유지 ${(index+1)}",
                                                        style: CustomStyle.CustomFont(styleFontSize10, text_box_color_01),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(7)),
                                                      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(3)),
                                                      decoration: BoxDecoration(
                                                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                                                          border: Border.all(color: item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle,width: 1.w)
                                                      ),
                                                      child: Text(
                                                        item?.stopSe == "S" ? "상차" :"하차",
                                                        style: CustomStyle.CustomFont(styleFontSize10, item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle),
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                                InkWell(
                                                  onTap:(){
                                                    widget.mData.orderStopList?.removeAt(index);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    margin: const EdgeInsets.all(10),
                                                    child: Image.asset(
                                                      "assets/image/cancel.png",
                                                      width: CustomStyle.getWidth(13.0),
                                                      height: CustomStyle.getHeight(13.0),
                                                      color: Colors.black,
                                                    )
                                                  )
                                                )
                                              ]
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                text: "${item?.eComName}",
                                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                              child: RichText(
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  text:  "${item?.eAddr}",
                                                  style: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w400),
                                                ),
                                              ),
                                          ),
                                          item?.eAddrDetail != null && item?.eAddrDetail?.isNotEmpty == true ?
                                          Container(
                                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                              child: RichText(
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  text:   "${item?.eAddrDetail}",
                                                  style: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w400),
                                                ),
                                              ),
                                          ) : const SizedBox(),
                                        ]
                                      )
                                    )
                                  ]
                              )
                          )
                      );
                    }
                )
            )) : const SizedBox(),
            InkWell(
              onTap: () async {

                if(widget.mData.sellCustId == null || widget.mData.sellCustId?.isEmpty == true) {
                  await goToAddrRegPage(Const.RESULT_WORK_EADDR);
                }else{
                  await goToRegEAddr();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(10)),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,border: Border.all(color: light_gray23,width: 1)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          width: CustomStyle.getWidth(38),
                          height: CustomStyle.getHeight(38),
                          decoration: BoxDecoration(color: rpa_btn_cancle,borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          child: Text(
                            "하차",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w600),
                          )
                      )
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                text: llEAddr.value ? "${widget.mData.eComName}" : "하차지를 선택해주세요.",
                              style: CustomStyle.CustomFont(
                                  llEAddr.value ? styleFontSize16 : styleFontSize14,  llEAddr.value ? text_color_01 : light_gray23, font_weight: llEAddr.value ? FontWeight.w700 : FontWeight.w500),
                            ),
                          ),
                          llEAddr.value ?
                          Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex:1,
                                      child: Icon(
                                        Icons.home,
                                        size: 21.h,
                                        color: light_gray23,
                                      )
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                          text:  "${widget.mData.eAddr}",
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                      ),
                                    )
                                  ),
                                ],
                              ),
                              widget.mData.eAddrDetail != null && widget.mData.eAddrDetail?.isEmpty == false ?
                              Row(
                                children: [
                                  Expanded(
                                      flex:1,
                                      child:Icon(
                                        Icons.home_work,
                                        size: 21.h,
                                        color: light_gray23,
                                      )
                                  ),
                                  Expanded(
                                    flex: 7,
                                      child: RichText(
                                        text: TextSpan(
                                            text: "${widget.mData.eAddrDetail}",
                                            style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                        ),
                                      )
                                  )
                                ],
                              ) : const SizedBox(),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.manage_accounts,
                                          size: 21.h,
                                          color: light_gray23,
                                        )
                                    ),
                                    Expanded(
                                      flex: 7,
                                        child: Row(
                                          children: [
                                            widget.mData.eStaff != null && widget.mData.eStaff?.isEmpty == false ?
                                            Text(
                                                "${widget.mData.eStaff}",
                                                textAlign: TextAlign.start,
                                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                            ) : const SizedBox(),
                                            widget.mData.eTel != null && widget.mData.eTel?.isEmpty == false ?
                                            Container(
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                child: Text(
                                                    "${Util.makePhoneNumber(widget.mData.eTel)}",
                                                    textAlign: TextAlign.start,
                                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w400)
                                                )
                                            ) : const SizedBox(),
                                          ],
                                        )
                                    )
                                  ]
                              ),
                              widget.mData.eMemo != null && widget.mData.eMemo?.isEmpty == false ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                              child: Icon(
                                                Icons.mark_email_unread,
                                                size: 21.h,
                                                color: light_gray23,
                                              )
                                          )
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                              text: "${widget.mData.eMemo}",
                                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                          ),
                                        )
                                      )
                                    ],
                                  ) : const SizedBox(),
                            ],
                          )) : const SizedBox()
                        ],
                      ),
                    )),
                  ],
                ),
              )
            )
          ],
        ),
      ));
    });
  }
}

/**
 * 화물 정보
 */
class MainPageContentComponent3 extends StatefulWidget {
  final BuildContext context;
  final String title;
  final OrderModel mData;
  final MotionTabBarController tabController;
  String? code;
  String? flag;

  MainPageContentComponent3({Key? key,required this.context, required this.mData, required this.title,required this.tabController,this.code,this.flag}):super(key:key);

  @override
  _MainPageContentComponent3State createState() => _MainPageContentComponent3State();
}
class _MainPageContentComponent3State extends State<MainPageContentComponent3> {
  
  final mCargoList = List.empty(growable: true).obs;
  final mCargoTruckList = List.empty(growable: true).obs;
  final mCarTypeList = List.empty(growable: true).obs;
  final mCarTonList = List.empty(growable: true).obs;
  final mWayTypeList = List.empty(growable: true).obs;
  final mCargoInfoList = List.empty(growable: true).obs;
  final mQtyUnitList = List.empty(growable: true).obs;

  late TextEditingController goodsNameController;
  late TextEditingController cargoWgtController;
  late TextEditingController goodsQtyController;

  @override
  void initState() {
    super.initState();

    goodsNameController = TextEditingController();
    cargoWgtController = TextEditingController();
    goodsQtyController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      if(widget.mData.inOutSctn?.isEmpty == true || widget.mData.inOutSctn.isNull == true) {
        setCargoDefault();
      }

      widget.mData.mixYn = "N";
      widget.mData.returnYn = "N";
      widget.mData.weightUnitCode = "TON";
      widget.mData.goodsWeight = widget.mData.goodsWeight??"0";
      cargoWgtController.text = widget.mData.goodsWeight!;
      widget.mData.goodsQty = widget.mData.goodsQty??"0";
      goodsQtyController.text = widget.mData.goodsQty??"0";
      goodsNameController.text = widget.mData.goodsName??"";

      mCargoList.addAll(getCodeList(Const.IN_OUT_SCTN));
      mCargoTruckList.addAll(getCodeList(Const.TRUCK_TYPE_CD));
      mCarTypeList.addAll(getCodeList(Const.CAR_TYPE_CD));
      mCarTonList.addAll(getCodeList(Const.CAR_TON_CD));
      mWayTypeList.addAll(getCodeList(Const.WAY_TYPE_CD));
      mCargoInfoList.addAll(getCodeList(Const.ITEM_CD));
      mQtyUnitList.addAll(getCodeList(Const.QTY_UNIT_CD));

    });
  }

  @override
  void dispose() {
    super.dispose();

    goodsNameController.dispose();
    cargoWgtController.dispose();
    goodsQtyController.dispose();
  }

  Future<void> setCargoDefault() async {
    widget.mData.inOutSctn = "01";
    widget.mData.inOutSctnName = "내수";
    widget.mData.truckTypeCode = "TR";
    widget.mData.truckTypeName = "일반트럭";
    widget.mData.sWayCode = "지";
    widget.mData.sWayName = SP.getCodeName(Const.WAY_TYPE_CD, widget.mData.sWayCode??"");
    widget.mData.eWayCode = "지";
    widget.mData.eWayName = SP.getCodeName(Const.WAY_TYPE_CD, widget.mData.eWayCode??"");
  }

  List<CodeModel> getCodeList(String codeType) {
    List<CodeModel>? mList = SP.getCodeList(codeType);
    if (codeType == Const.CHARGE_TYPE_CD) {
      mList?.removeAt(1);
    }
    if (codeType == Const.ORDER_STATE_CD) {
      mList?.insert(0, CodeModel(code: "",codeName:  "전체"));
    }
    if (codeType == Const.ALLOC_STATE_CD) {
      mList?.insert(0, CodeModel(code: "",codeName:  "전체"));
    }
    if (codeType == Const.DRIVER_STATE) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "01",codeName:  "배차"));
      mList.add(CodeModel(code: "12",codeName:  "입차"));
      mList.add(CodeModel(code: "04",codeName:  "출발"));
      mList.add(CodeModel(code: "05",codeName:  "도착"));
      mList.add(CodeModel(code: "21",codeName:  "취소"));
    }
    if (codeType == Const.ORDER_SEARCH) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "carNum",codeName:  "차량번호"));
      mList.add(CodeModel(code: "driverName", codeName: "차주명"));
      mList.add(CodeModel(code: "sellCustName", codeName: "거래처명"));
    }
    if (codeType == Const.USE_YN) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "Y",codeName:  "사용"));
      mList.add(CodeModel(code: "N",codeName:  "미사용"));
    }
    return mList!;
  }

  void selectItem(String? codeType,CodeModel? codeModel) {
    switch(codeType) {
      case 'CAR_TYPE_CD':
        setState(() {
          widget.mData.carTypeCode = codeModel?.code;
          widget.mData.carTypeName = codeModel?.codeName;
        });
        break;
      case 'CAR_TON_CD':
        setState(() {
          widget.mData.carTonCode = codeModel?.code;
          widget.mData.carTonName = codeModel?.codeName;
        });
        break;
      case 'ITEM_CD':
        setState(() {
          widget.mData.itemCode = codeModel?.code;
          widget.mData.itemName = codeModel?.codeName;
        });
        break;
      case 'QTY_UNIT_CD':
        setState(() {
          widget.mData.qtyUnitCode = codeModel?.code;
          widget.mData.qtyUnitName = codeModel?.codeName;
        });
        break;
    }
  }

  Future<void> openCodeBottomSheet(BuildContext context, String title,String codeType, List<dynamic> mCodeList, Function(String codeType,CodeModel codeModel) callback) async {

    final tempCodemodel = CodeModel().obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: title,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: App().isTablet(context) ? mCodeList!.length > 16 ? 0.60 : mCodeList.length > 12 ? 0.5 : 0.4 :  mCodeList!.length > 16 ? 0.50 : mCodeList.length > 12 ? 0.4 : 0.3,
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
                              title,
                              style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                          )
                      ),
                      Expanded(
                          child: AnimationLimiter(
                              child: GridView.builder(
                                  itemCount: mCodeList.length,
                                  physics: const ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                    childAspectRatio: (1 / .4),
                                    mainAxisSpacing: 10, //수평 Padding
                                    crossAxisSpacing: 10, //수직 Padding
                                  ),
                                  itemBuilder: (BuildContext context, int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                        position: index,
                                        duration: const Duration(milliseconds: 400),
                                        columnCount: 4,
                                        child: ScaleAnimation(
                                            child: FadeInAnimation(
                                                child: Obx(() =>  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        tempCodemodel.value = CodeModel(code: mCodeList[index].code,codeName: mCodeList[index].codeName);
                                                      });
                                                    },
                                                    child: Container(
                                                        height: CustomStyle.getHeight(70.0),
                                                        decoration: BoxDecoration(
                                                            color: tempCodemodel.value.code  == mCodeList[index].code ? renew_main_color2 : light_gray24,
                                                            borderRadius: BorderRadius.circular(30)
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${mCodeList[index].codeName}",
                                                            textAlign: TextAlign.center,
                                                            style: CustomStyle.CustomFont(
                                                                styleFontSize12, tempCodemodel.value.code  == mCodeList[index].code ? Colors.white: text_color_01,
                                                                font_weight: tempCodemodel.value.code  == mCodeList[index].code ? FontWeight.w800 : FontWeight.w600),
                                                          ),
                                                        )
                                                    )
                                                )))));
                                  }
                              ))
                      ),
                      Obx(() =>
                        InkWell(
                            onTap: () async {
                              if(tempCodemodel.value.code == null || tempCodemodel.value.code?.isEmpty == true){
                                Util.toast("${codeType == Const.CAR_TYPE_CD ? "차종" : codeType == Const.CAR_TON_CD ? "톤수" : "기타"}을 선택해주세요.");
                              }else{
                                callback(codeType, tempCodemodel.value);
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            child: Center(
                                child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                  height: CustomStyle.getHeight(50),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: tempCodemodel.value.code == null || tempCodemodel.value.code?.isEmpty == true ? light_gray24 : renew_main_color2),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "적용",
                                    style: CustomStyle.CustomFont(styleFontSize18, tempCodemodel.value.code == null || tempCodemodel.value.code?.isEmpty == true ? light_gray23 : styleWhiteCol),
                                  ),
                                )
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),
                  horizontal: CustomStyle.getWidth(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "화물 정보",
                      style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
                    ),
                    /**
                     * 수출입구분
                     */
                    Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      child: Row(
                        children: [
                          Text(
                              "수출입구분",
                              style: CustomStyle.CustomFont(
                                  styleFontSize16, Colors.black,
                                  font_weight: FontWeight.w500)
                          ),
                          Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                            child: Text(
                              "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                              style: CustomStyle.CustomFont(
                                  styleFontSize12, text_color_03),
                            ),
                          )
                        ],
                      )
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(
                            vertical: CustomStyle.getHeight(10)),
                        child: GridView.builder(
                            itemCount: mCargoList.length,
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                              childAspectRatio: (1 / .35),
                              mainAxisSpacing: 10, //수평 Padding
                              crossAxisSpacing: 10, //수직 Padding
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              var item = mCargoList[index];
                              return InkWell(
                                  onTap: () async {
                                    setState(() {
                                      widget.mData.inOutSctn = item.code;
                                      widget.mData.inOutSctnName = item.codeName;
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: widget.mData.inOutSctn == item.code ? renew_main_color2 : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.codeName,
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, widget.mData.inOutSctn == item.code ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                          ),
                                          widget.mData.inOutSctn == item.code ?
                                          Image.asset(
                                            "assets/image/ic_check_off.png",
                                            width: CustomStyle.getWidth(10.0),
                                            height: CustomStyle.getHeight(10.0),
                                            color: Colors.white,
                                          ) : const SizedBox(),
                                        ],
                                      )
                                  )
                              );
                            }
                        ),
                    ),
                    /**
                     * 운송유형
                     */
                    Row(
                      children: [
                        Text(
                            "운송유형",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: mCargoTruckList.length,
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .35),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 10, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            var item = mCargoTruckList[index];
                            return InkWell(
                                onTap: () async {
                                  setState(() {
                                    widget.mData.truckTypeCode = item.code;
                                    widget.mData.truckTypeName = item.codeName;
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: widget.mData.truckTypeCode == item.code ? renew_main_color2 : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.codeName,
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, widget.mData.truckTypeCode == item.code ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                        ),
                                        widget.mData.truckTypeCode == item.code ?
                                        Image.asset(
                                          "assets/image/ic_check_off.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: Colors.white,
                                        ) : const SizedBox(),
                                      ],
                                    )
                                )
                            );
                          }
                      ),
                    ),
                    /**
                     * 차종/톤수
                     */
                    Row(
                      children: [
                        /**
                         * 차종
                         */
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      "차종",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize16, Colors.black,
                                          font_weight: FontWeight.w500)
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                    child: Text(
                                      "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_03),
                                    ),
                                  )
                                ],
                              ),
                              InkWell(
                                  onTap: () async {
                                    openCodeBottomSheet(context,"차종선택",Const.CAR_TYPE_CD,mCarTypeList.value,selectItem);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                      decoration: BoxDecoration(
                                        color: widget.mData.carTypeCode == null || widget.mData.carTypeCode?.isEmpty == true ? Colors.white : renew_main_color2,
                                        border: Border.all(color: widget.mData.carTypeCode == null || widget.mData.carTypeCode?.isEmpty == true ?  Colors.red : renew_main_color2, width: 1)  ,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                            widget.mData.carTypeName == null || widget.mData.carTypeName?.isEmpty == true ? "차종선택" : widget.mData.carTypeName!,
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, widget.mData.carTypeCode == null || widget.mData.carTypeCode?.isEmpty == true ? light_gray21 : Colors.white , font_weight: FontWeight.w600),
                                          ),
                                  )
                              )
                            ]
                          )
                        ),
                        /**
                         * 톤수
                         */
                        Expanded(
                          flex: 1,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        "톤수",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, Colors.black,
                                            font_weight: FontWeight.w500)
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                      child: Text(
                                        "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12, text_color_03),
                                      ),
                                    )
                                  ],
                                ),
                                InkWell(
                                    onTap: () async {
                                      openCodeBottomSheet(context,"톤수선택",Const.CAR_TON_CD,mCarTonList.value,selectItem);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                                      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                      decoration: BoxDecoration(
                                        color: widget.mData.carTonCode == null || widget.mData.carTonCode?.isEmpty == true ? Colors.white : renew_main_color2,
                                        border: Border.all(color: widget.mData.carTonCode == null || widget.mData.carTonCode?.isEmpty == true ?  Colors.red : renew_main_color2, width: 1)  ,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.mData.carTonName == null || widget.mData.carTonName?.isEmpty == true ? "톤수선택" : widget.mData.carTonName!,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, widget.mData.carTonCode == null || widget.mData.carTonCode?.isEmpty == true ? light_gray21 : Colors.white , font_weight: FontWeight.w600),
                                      ),
                                    )
                                )
                              ]
                          )
                        )
                      ]
                    ),
                    /**
                     * 화물정보
                     */
                    Row(
                      children: [
                        Text(
                            "화물정보",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                        color: Colors.white,
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          controller: goodsNameController,
                          maxLines: null,
                          decoration: goodsNameController.text.isNotEmpty
                              ? InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                goodsNameController.clear();
                              },
                              icon: Icon(
                                Icons.clear,
                                size: 18.h,
                                color: Colors.black,
                              ),
                            ),
                          ) : InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                            hintText: "화물 정보를 입력해주세요.",
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: rpa_btn_cancle, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: rpa_btn_cancle, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: rpa_btn_cancle, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(5)
                            ),
                          ),
                          onChanged: (value){
                            setState(() {
                              if(value.length == 0) {
                                widget.mData.goodsName = "";
                              }else{
                                widget.mData.goodsName = value;
                              }
                            });
                          },
                        )
                    ),
                    /**
                     * 운송품목
                     */
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "운송품목",
                              style: CustomStyle.CustomFont(
                                  styleFontSize16, Colors.black,
                                  font_weight: FontWeight.w500)
                          ),
                          InkWell(
                              onTap: () async {
                                openCodeBottomSheet(context,Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"",Const.ITEM_CD,mCargoInfoList.value,selectItem);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                decoration: BoxDecoration(
                                  color: widget.mData.itemCode == null || widget.mData.itemCode?.isEmpty == true ? Colors.white : renew_main_color2,
                                  border: Border.all(color: widget.mData.itemCode == null || widget.mData.itemCode?.isEmpty == true ?  Colors.white : renew_main_color2, width: 1)  ,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.mData.itemCode == null || widget.mData.itemCode?.isEmpty == true ? Strings.of(context)?.get("select_info")??"Not Found" : widget.mData.itemName!,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize12, widget.mData.itemCode == null || widget.mData.itemCode?.isEmpty == true ? light_gray21 : Colors.white , font_weight: FontWeight.w600),
                                ),
                              )
                          )
                        ]
                    ),

                    /**
                     * 적재중량
                     */

                    Row(
                      children: [
                        /**
                         * 적재 중량
                         */
                        Expanded(
                          flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                    "적재중량",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize16, Colors.black,
                                        font_weight: FontWeight.w500)
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: TextField(
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.number,
                                      controller: cargoWgtController,
                                      maxLines: null,
                                      decoration: cargoWgtController.text.isNotEmpty
                                          ? InputDecoration(
                                        counterText: '',
                                        suffix: Text(
                                          "TON",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ) : InputDecoration(
                                        counterText: '',
                                        suffix: Text(
                                          "TON",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize11, text_color_01),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                                        hintText: "",
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(1.0.w)),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(0.5))
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(1.0.w)),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                      onChanged: (value){
                                        setState(() {
                                          if(value.length == 0) {
                                            widget.mData.goodsWeight = "";
                                          }else{
                                            widget.mData.goodsWeight = value;
                                          }
                                        });
                                      },
                                    )
                                ),
                              ]
                            )
                        ),
                        /**
                         * 적재수량
                         */
                        Expanded(
                          flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "적재수량",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize16, Colors.black,
                                          font_weight: FontWeight.w500)
                                  ),
                                  Row(
                                      children :[
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5)
                                                ),
                                                child: TextField(
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                                  textAlign: TextAlign.start,
                                                  keyboardType: TextInputType.number,
                                                  controller: goodsQtyController,
                                                  maxLines: null,
                                                  decoration: goodsQtyController.text.isNotEmpty
                                                      ? InputDecoration(
                                                    counterText: '',
                                                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    disabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                  ) : InputDecoration(
                                                    counterText: '',
                                                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                                                    hintText: "",
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(1.0.w)),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    disabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(0.5))
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: light_gray24, width: CustomStyle.getWidth(1.0.w)),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                  ),
                                                  onChanged: (value){
                                                    setState(() {
                                                      if(value.length == 0) {
                                                        widget.mData.goodsQty = "";
                                                      }else{
                                                        widget.mData.goodsQty = value;
                                                      }
                                                    });
                                                  },
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: InkWell(
                                                onTap: () async {
                                                  openCodeBottomSheet(context,"${Strings.of(context)?.get("order_cargo_info_qty")} ${Strings.of(context)?.get("order_cargo_info_unit")}",Const.QTY_UNIT_CD,mQtyUnitList.value,selectItem);
                                                },
                                                child: Container(
                                                  height: CustomStyle.getHeight(43),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10),left: CustomStyle.getWidth(5)),
                                                  decoration: BoxDecoration(
                                                    color: widget.mData.qtyUnitCode == null || widget.mData.qtyUnitCode?.isEmpty == true ? Colors.white : renew_main_color2,
                                                    border: Border.all(color: widget.mData.qtyUnitCode == null || widget.mData.qtyUnitCode?.isEmpty == true ?  Colors.white : renew_main_color2, width: 1)  ,
                                                      borderRadius: BorderRadius.circular(5)
                                                  ),
                                                  child: Text(
                                                    "${widget.mData.qtyUnitCode?.isNotEmpty == true ? widget.mData.qtyUnitName : "${Strings.of(context)?.get("order_cargo_info_unit")??"Not Found"}"}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize10, widget.mData.qtyUnitCode == null || widget.mData.qtyUnitCode?.isEmpty == true ? light_gray21 : Colors.white , font_weight: FontWeight.w600),
                                                  ),
                                                )
                                            )
                                        )
                                      ]
                                  )
                                ]
                            )
                          )
                        )
                      ]
                    ),

                    /**
                     * 상차방법
                     */
                    Row(
                      children: [
                        Text(
                            "상차방법",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: mWayTypeList.length,
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .35),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 10, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            var item = mWayTypeList[index];
                            return InkWell(
                                onTap: () async {
                                  setState(() {
                                    widget.mData.sWayCode = item.code;
                                    widget.mData.sWayName = item.codeName;
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: widget.mData.sWayCode == item.code ? renew_main_color2 : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.codeName,
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, widget.mData.sWayCode == item.code ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                        ),
                                        widget.mData.sWayCode == item.code ?
                                        Image.asset(
                                          "assets/image/ic_check_off.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: Colors.white,
                                        ) : const SizedBox(),
                                      ],
                                    )
                                )
                            );
                          }
                      ),
                    ),
                    /**
                     * 하차방법
                     */
                    Row(
                      children: [
                        Text(
                            "하차방법",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: mWayTypeList.length,
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .35),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 10, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            var item = mWayTypeList[index];
                            return InkWell(
                                onTap: () async {
                                  setState(() {
                                    widget.mData.eWayCode = item.code;
                                    widget.mData.eWayName = item.codeName;
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: widget.mData.eWayCode == item.code ? renew_main_color2 : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.codeName,
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, widget.mData.eWayCode == item.code ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                        ),
                                        widget.mData.eWayCode == item.code ?
                                        Image.asset(
                                          "assets/image/ic_check_off.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: Colors.white,
                                        ) : const SizedBox(),
                                      ],
                                    )
                                )
                            );
                          }
                      ),
                    ),
                    /**
                     * 혼적여부
                     */
                    Row(
                      children: [
                        Text(
                            "혼적여부",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children : [
                        InkWell(
                            onTap: () async {
                              setState(() {
                                widget.mData.mixYn = "N";
                              });
                            },
                            child: Container(
                                width: CustomStyle.getWidth(80),
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                decoration: BoxDecoration(
                                  color: widget.mData.mixYn == "N" ? renew_main_color2 : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "독차",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, widget.mData.mixYn == "N" ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                    ),
                                    widget.mData.mixYn == "N" ?
                                    Image.asset(
                                      "assets/image/ic_check_off.png",
                                      width: CustomStyle.getWidth(10.0),
                                      height: CustomStyle.getHeight(10.0),
                                      color: Colors.white,
                                    ) : const SizedBox(),
                                  ],
                                )
                            )
                        ),
                        InkWell(
                            onTap: () async {
                              setState(() {
                                widget.mData.mixYn = "Y";
                              });
                            },
                            child: Container(
                                width: CustomStyle.getWidth(80),
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10),top: CustomStyle.getHeight(10), left: CustomStyle.getWidth(10)),
                                decoration: BoxDecoration(
                                  color: widget.mData.mixYn == "Y" ? renew_main_color2 : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "혼적",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, widget.mData.mixYn == "Y" ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                    ),
                                    widget.mData.mixYn == "Y" ?
                                    Image.asset(
                                      "assets/image/ic_check_off.png",
                                      width: CustomStyle.getWidth(10.0),
                                      height: CustomStyle.getHeight(10.0),
                                      color: Colors.white,
                                    ) : const SizedBox(),
                                  ],
                                )
                            )
                        )
                      ]
                    ),
                    /**
                     * 왕복여부
                     */
                    Row(
                      children: [
                        Text(
                            "왕복여부",
                            style: CustomStyle.CustomFont(
                                styleFontSize16, Colors.black,
                                font_weight: FontWeight.w500)
                        ),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          child: Text(
                            "${Strings.of(context)?.get("essential") ?? "Not Found"}",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    ),
                    Row(
                        children : [
                          InkWell(
                              onTap: () async {
                                setState(() {
                                  widget.mData.returnYn = "N";
                                });
                              },
                              child: Container(
                                  width: CustomStyle.getWidth(80),
                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                  decoration: BoxDecoration(
                                    color: widget.mData.returnYn == "N" ? renew_main_color2 : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "편도",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, widget.mData.returnYn == "N" ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                      ),
                                      widget.mData.returnYn == "N" ?
                                      Image.asset(
                                        "assets/image/ic_check_off.png",
                                        width: CustomStyle.getWidth(10.0),
                                        height: CustomStyle.getHeight(10.0),
                                        color: Colors.white,
                                      ) : const SizedBox(),
                                    ],
                                  )
                              )
                          ),
                          InkWell(
                              onTap: () async {
                                setState(() {
                                  widget.mData.returnYn = "Y";
                                });
                              },
                              child: Container(
                                  width: CustomStyle.getWidth(80),
                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10),top: CustomStyle.getHeight(10), left: CustomStyle.getWidth(10)),
                                  decoration: BoxDecoration(
                                    color: widget.mData.returnYn == "Y" ? renew_main_color2 : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "왕복",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, widget.mData.returnYn == "Y" ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                                      ),
                                      widget.mData.returnYn == "Y" ?
                                      Image.asset(
                                        "assets/image/ic_check_off.png",
                                        width: CustomStyle.getWidth(10.0),
                                        height: CustomStyle.getHeight(10.0),
                                        color: Colors.white,
                                      ) : const SizedBox(),
                                    ],
                                  )
                              )
                          )
                        ]
                    )
                  ]
              )
          )
      );
    });
  }
}

/**
 * 운임 정보
 */
class MainPageContentComponent4 extends StatefulWidget {
  final BuildContext context;
  final String title;
  final OrderModel mData;
  final MotionTabBarController tabController;
  String? code;
  String? flag;

  MainPageContentComponent4({Key? key,required this.context,required this.mData,required this.title,required this.tabController,this.code,this.flag}):super(key:key);

  _MainPageContentComponent4State createState() => _MainPageContentComponent4State();
}
class _MainPageContentComponent4State extends State<MainPageContentComponent4> with TickerProviderStateMixin {

  static const String CHARGE_TYPE_01 = "01"; // 인수증
  static const String CHARGE_TYPE_02 = "02"; // 선/착불
  static const String CHARGE_TYPE_03 = "03"; // 차주발행
  static const String CHARGE_TYPE_04 = "04"; // 선불
  static const String CHARGE_TYPE_05 = "05"; // 착불

  static const String UNIT_PRICE_TYPE_01 = "01";
  static const String UNIT_PRICE_TYPE_02 = "02";

  final controller = Get.find<App>();
  ProgressDialog? pr;

  final tvUnitPriceType01 = false.obs;
  final tvUnitPriceType02 = false.obs;
  final llUnitPrice = false.obs;
  final etUnitPrice = false.obs;

  late TabController _tabController;
  final mTabCode = "01".obs;
  final chargeCheck = "".obs;
  final tvTotal = "".obs;
  final m24Call = "N".obs; // 24시콜 Command
  final mHwaMull = "N".obs; // 화물맨 Command
  final mOneCall = "N".obs; // 원콜 Command
  final mHwaMullFlag = false.obs; // 화물맨 LinkFlag 값 설정 시 안 꺼지기
  final tv24Call = false.obs;
  final tvHwaMull = true.obs;
  final tvOneCall = true.obs;
  final mRpaSalary = "".obs;

  late TextEditingController unitPriceController;
  late TextEditingController sellChargeController;
  late TextEditingController sellFeeController;
  late TextEditingController sellWeightController;

  late TextEditingController sellWayPointChargeController;
  late TextEditingController sellWayPointMemoController;
  late TextEditingController sellStayChargeController;
  late TextEditingController sellStayMemoController;
  late TextEditingController sellHandWorkChargeController;
  late TextEditingController sellHandWorkMemoController;
  late TextEditingController sellRoundChargeController;
  late TextEditingController sellRoundMemoController;
  late TextEditingController sellOtherAddChargeController;
  late TextEditingController sellOtherAddMemoController;

  late TextEditingController rpaValueController;

  final sellWayPointMemoChk = false.obs;
  final sellStayMemoChk = false.obs;
  final sellHandWorkMemoChk = false.obs;
  final sellRoundMemoChk = false.obs;
  final sellAddMemoChk = false.obs;

  Future<void> display24Call() async {
    if(m24Call.value == "N") {
      m24Call.value = "Y";
      widget.mData.call24Cargo = "Y";
    }else{
      m24Call.value = "N";
      widget.mData.call24Cargo = "Y";
    }
  }

  Future<void> displayOneCall() async {
    if(mOneCall.value == "N") {
      mOneCall.value = "Y";
      widget.mData.oneCargo = "Y";
    }else{
      mOneCall.value = "N";
      widget.mData.oneCargo = "N";
    }
  }

  Future<void> displayHwaMull() async {
    if(mHwaMull.value == "N") {
      mHwaMull.value = "Y";
      widget.mData.manCargo = "Y";
      tvHwaMull.value = true;
    }else{
      if(mHwaMullFlag.value) {
        mHwaMull.value == "Y";
        widget.mData.manCargo = "Y";
        mHwaMullFlag.value = false; // 지속적으로 On 되어 있는것이 On/Off로 전환 - 2023-09-04
      }else{
        mHwaMull.value = "N";
        widget.mData.manCargo = "N";
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
        initialIndex: 0
    );
    _tabController.addListener(_handleTabSelection);

    unitPriceController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.unitPrice));
    sellChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellCharge));
    sellFeeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellFee));
    sellWeightController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellWeight));

    sellWayPointChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellWayPointCharge));
    sellWayPointMemoController = TextEditingController(text:widget.mData.sellWayPointMemo??"");
    sellStayChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellStayCharge));
    sellStayMemoController = TextEditingController(text: widget.mData.sellStayMemo??"");
    sellHandWorkChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellHandWorkCharge));
    sellHandWorkMemoController = TextEditingController(text: widget.mData.sellHandWorkMemo??"");
    sellRoundChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellRoundCharge));
    sellRoundMemoController = TextEditingController(text: widget.mData.sellRoundMemo??"");
    sellOtherAddChargeController = TextEditingController(text: Util.getInCodeCommaWon(widget.mData.sellOtherAddCharge));
    sellOtherAddMemoController = TextEditingController(text: widget.mData.sellOtherAddMemo??"");

    rpaValueController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      if(widget.mData.chargeType == null) {
        widget.mData.chargeType = CHARGE_TYPE_01;
        widget.mData.chargeTypeName = "인수증";
      }
      if(widget.mData.unitPrice == null) {
        widget.mData.unitPriceType = UNIT_PRICE_TYPE_01;
        widget.mData.unitPriceTypeName = "대당단가";
      }
      if(widget.mData.sellWayPointMemo?.isNotEmpty == true && widget.mData.sellWayPointMemo != null) sellWayPointMemoChk.value = true;
      if(widget.mData.sellStayMemo?.isNotEmpty == true && widget.mData.sellStayMemo != null) sellStayMemoChk.value = true;
      if(widget.mData.sellHandWorkMemo?.isNotEmpty == true && widget.mData.sellHandWorkMemo != null) sellHandWorkMemoChk.value = true;
      if(widget.mData.sellRoundMemo?.isNotEmpty == true && widget.mData.sellRoundMemo != null) sellRoundMemoChk.value = true;
      if(widget.mData.sellOtherAddMemo?.isNotEmpty == true && widget.mData.sellOtherAddMemo != null) sellAddMemoChk.value = true;

      if(widget.flag != null && widget.flag?.isNotEmpty == true) {
        String? rpaSell = "0";
        if (widget.mData.call24Cargo == "Y") {
          rpaSell = widget.mData.call24Charge?.isEmpty == true || widget.mData.call24Charge == null ? "0" : widget.mData.call24Charge;
        } else if (widget.mData.oneCargo == "Y") {
          rpaSell = widget.mData.oneCharge?.isEmpty == true || widget.mData.oneCharge == null ? "0" : widget.mData.oneCharge;
        } else if (widget.mData.manCargo == "Y") {
          rpaSell = widget.mData.manCharge?.isEmpty == true || widget.mData.manCharge == null ? "0" : widget.mData.manCharge;
        }
        mRpaSalary.value = rpaSell!;
        rpaValueController.text = Util.getInCodeCommaWon(rpaSell);
      }

      await setTotal();
      await getRpaLinkFlag();
    });

  }

  @override
  void dispose() {
    super.dispose();
    unitPriceController.dispose();
    sellChargeController.dispose();
    sellFeeController.dispose();
    sellWeightController.dispose();
    sellWayPointChargeController.dispose();
    sellWayPointMemoController.dispose();
    sellStayChargeController.dispose();
    sellStayMemoController.dispose();
    sellHandWorkChargeController.dispose();
    sellHandWorkMemoController.dispose();
    sellRoundChargeController.dispose();
    sellRoundMemoController.dispose();
    sellOtherAddChargeController.dispose();
    sellOtherAddMemoController.dispose();
    rpaValueController.dispose();
  }

  Future<void> setTotal() async {
    int sellCharge =  widget.mData.sellCharge?.isEmpty == true || widget.mData.sellCharge == null ? 0 : int.parse(widget.mData.sellCharge!);
    int sellFee = widget.mData.sellFee?.isEmpty == true || widget.mData.sellFee == null ? 0 : int.parse(widget.mData.sellFee!);
    int sellWayPointCharge = widget.mData.sellWayPointCharge?.isEmpty == true || widget.mData.sellWayPointCharge == null ? 0 : int.parse(widget.mData.sellWayPointCharge!);
    int sellStayCharge = widget.mData.sellStayCharge?.isEmpty == true || widget.mData.sellStayCharge == null ? 0 : int.parse(widget.mData.sellStayCharge!);
    int sellHandWorkCharge = widget.mData.sellHandWorkCharge?.isEmpty == true || widget.mData.sellHandWorkCharge == null ? 0 : int.parse(widget.mData.sellHandWorkCharge!);
    int sellRoundCharge = widget.mData.sellRoundCharge?.isEmpty == true || widget.mData.sellRoundCharge == null ? 0 : int.parse(widget.mData.sellRoundCharge!);
    int sellOtherAddCharge = widget.mData.sellOtherAddCharge?.isEmpty == true || widget.mData.sellOtherAddCharge == null ? 0 : int.parse(widget.mData.sellOtherAddCharge!);

    int total = sellCharge + sellWayPointCharge + sellStayCharge + sellHandWorkCharge + sellRoundCharge + sellOtherAddCharge - sellFee;
    tvTotal.value = total.toString();

  }

  Future<void> getRpaLinkFlag() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getLinkFlag(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getRpaLinkFlag() Regist _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<RpaFlagModel> itemsList = list.map((i) => RpaFlagModel.fromJSON(i)).toList();
            if (itemsList.length != 0) {
              tv24Call.value = false;
              tvHwaMull.value = false;
              tvOneCall.value = false;

              for (var i = 0; i < itemsList.length; i++) {
                if (itemsList[i].linkCd == Const.CALL_24_KEY_NAME) {
                  m24Call.value = "N";
                  widget.mData.call24Cargo = "N";
                  tv24Call.value = true;
                } else if (itemsList[i].linkCd == Const.ONE_CALL_KEY_NAME) {
                  mOneCall.value = "N";
                  widget.mData.oneCargo = "N";
                  tvOneCall.value = true;
                } else if (itemsList[i].linkCd == Const.HWA_MULL_KEY_NAME) {
                  if (itemsList[i].linkFlag == "Y") {
                    mHwaMull.value = "Y";
                    widget.mData.manCargo = "Y";
                    tvHwaMull.value = true;
                    mHwaMullFlag.value = true;
                  } else {
                    mHwaMull.value = "N";
                    widget.mData.manCargo = "N";
                    tvHwaMull.value = true;
                    mHwaMullFlag.value = false;
                  }
                }
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
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getRpaLinkFlag() RegVersion Error => ${res?.statusCode} // ${res
              ?.statusMessage}");
          break;
        default:
          print("getRpaLinkFlag() RegVersion getOrder Default => ");
          break;
      }
    });
  }

  Future<void> _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _tabController.index;
      switch(selectedTabIndex) {
        case 0 :
          mTabCode.value = "01";
          break;
        case 1 :
          mTabCode.value = "02";
          break;
      }
    }
  }

  Future<String> makeCharge() async {
    if(widget.mData.sellWeight?.isEmpty == true) return "0";
    double unit = double.parse(widget.mData.sellWeight??"0");
    int price = int.parse(widget.mData.unitPrice?.isEmpty == true || widget.mData.unitPrice == null ? "0" : widget.mData.unitPrice!);
    return (unit * price).floor().toInt().toString();
  }

  Future<bool> validation() async {
    if(widget.mData.sellCharge.toString().trim().isEmpty) {
      Util.toast("${Strings.of(context)?.get("order_charge_info_sell_charge_hint")??"Not Found"}");
      return false;
    } else if(m24Call.value == "Y" || mOneCall.value == "Y" || mHwaMull.value == "Y"){
      if(mRpaSalary.value == "0" || mRpaSalary.value?.isEmpty == true || mRpaSalary.value == null) {
        Util.toast("정보망전송 청구금액을 입력해주세요.");
        return false;
      }
    }
    return true;
  }

  /**
   * Widget Start
   **/
  Widget customTabBarWidget() {
    return Container(
      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
        ),
        child: TabBar(
          tabs: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: const Text(
               "운임",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: const Text(
                "추가운임",
                textAlign: TextAlign.center,
              ),
            )
          ],
          indicator: BoxDecoration(
              color: renew_main_color2,
              borderRadius: mTabCode.value == "01" ? const BorderRadius.only(topLeft: Radius.circular(10)) : const BorderRadius.only(topRight: Radius.circular(10))
          ),
          labelColor: Colors.white,
          labelStyle: CustomStyle.CustomFont(styleFontSize14,renew_main_color2, font_weight: FontWeight.w700),
          overlayColor: MaterialStatePropertyAll(Colors.blue.shade100),
          unselectedLabelColor: text_color_03,
          unselectedLabelStyle: CustomStyle.CustomFont(styleFontSize12,text_color_03, font_weight: FontWeight.w400),
          controller: _tabController,
        )
    );
  }

  Widget tabBarViewWidget() {
    return Container(
      height: CustomStyle.getHeight(900),
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          tabBarValueWidget("01"),
          tabBarValueWidget("02"),
        ],
      )
    );
  }

  Widget tabBarValueWidget(String? tabValue) {
    Widget _widget = chargeFragment();
    switch(tabValue) {
      case "01" :
        _widget = chargeFragment();
        break;
      case "02" :
        _widget = addChargeFragment();
        break;
    }
    return _widget;
  }

  Widget chargeFragment() {
    return Container(
      padding: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10),bottom: CustomStyle.getHeight(40)),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))
        ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "결제방법",
                style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
            ),
            Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  InkWell(
                    onTap: (){
                      setState(() {
                        widget.mData.chargeType = CHARGE_TYPE_01;
                        widget.mData.chargeTypeName = "인수증";
                        widget.mData.sellFee = "0";
                        setTotal();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(50),
                                  color: widget.mData.chargeType == CHARGE_TYPE_01 ? renew_main_color2 : light_gray24
                              ),
                            child: Image.asset(
                              "assets/image/ic_bill.png",
                              width: CustomStyle.getWidth(40.0),
                              height: CustomStyle.getHeight(40.0),
                              color: widget.mData.chargeType == CHARGE_TYPE_01 ? Colors.white : light_gray21
                            )
                          ),
                          Container(
                            margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                            child: Text(
                              "인수증",
                              style: CustomStyle.CustomFont(styleFontSize14, widget.mData.chargeType == CHARGE_TYPE_01 ? renew_main_color2 : Colors.black),
                            )
                          )
                        ]
                      )
                    )
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        widget.mData.chargeType = CHARGE_TYPE_04;
                        widget.mData.chargeTypeName = "선불";
                      });
                    },
                    child: Container(
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                    child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius:BorderRadius.circular(50),
                                color: widget.mData.chargeType == CHARGE_TYPE_04 ? renew_main_color2 : light_gray24
                            ),
                            child: Image.asset(
                                "assets/image/ic_start_pay.png",
                                width: CustomStyle.getWidth(40.0),
                                height: CustomStyle.getHeight(40.0),
                                color: widget.mData.chargeType == CHARGE_TYPE_04 ? Colors.white : light_gray21
                            )
                          ),
                          Container(
                              margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                              child: Text(
                                "선불",
                                style: CustomStyle.CustomFont(styleFontSize14, widget.mData.chargeType == CHARGE_TYPE_04 ? renew_main_color2 : Colors.black),
                              )
                          )
                        ]
                      )
                    )
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        widget.mData.chargeType = CHARGE_TYPE_05;
                        widget.mData.chargeTypeName = "착불";
                      });
                    },
                    child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(50),
                                  color: widget.mData.chargeType == CHARGE_TYPE_05 ? renew_main_color2 : light_gray24
                              ),
                              child: Image.asset(
                              "assets/image/ic_end_pay.png",
                              width: CustomStyle.getWidth(40.0),
                              height: CustomStyle.getHeight(40.0),
                              color: widget.mData.chargeType == CHARGE_TYPE_05 ? Colors.white : light_gray21
                            )
                          ),
                          Container(
                              margin: EdgeInsets.only(top:CustomStyle.getHeight(5)),
                              child: Text(
                                "착불",
                                style: CustomStyle.CustomFont(styleFontSize14, widget.mData.chargeType == CHARGE_TYPE_05 ? renew_main_color2 : Colors.black),
                              )
                          )
                        ]
                    )
                  ),
                ]
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
              child: Text(
                  "단가구분",
                  style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
              )
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        widget.mData.unitPriceType = UNIT_PRICE_TYPE_01;
                        widget.mData.unitPriceTypeName = "대당단가";
                        tvUnitPriceType01.value = true;
                        tvUnitPriceType02.value = false;
                        llUnitPrice.value = false;
                        etUnitPrice.value = false;
                        widget.mData.unitPrice = "0";
                        widget.mData.sellCharge = "0";
                        sellChargeController.text = "0";
                        setTotal();
                      });
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        decoration: BoxDecoration(
                          color:  widget.mData.unitPriceType == UNIT_PRICE_TYPE_01 ? renew_main_color2 : light_gray24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "대당단가",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, widget.mData.unitPriceType == UNIT_PRICE_TYPE_01 ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                            ),
                            widget.mData.unitPriceType == UNIT_PRICE_TYPE_01 ?
                            Image.asset(
                              "assets/image/ic_check_off.png",
                              width: CustomStyle.getWidth(10.0),
                              height: CustomStyle.getHeight(10.0),
                              color: Colors.white,
                            ) : const SizedBox(),
                          ],
                        )
                    )
                  )
                ),
                InkWell(
                    onTap: (){
                      setState(() {
                        widget.mData.unitPriceType = UNIT_PRICE_TYPE_02;
                        widget.mData.unitPriceTypeName = "톤당단가";
                        tvUnitPriceType01.value = false;
                        tvUnitPriceType02.value = true;
                        llUnitPrice.value = true;
                        etUnitPrice.value = true;
                        widget.mData.unitPrice = "0";
                        unitPriceController.text = "0";
                        widget.mData.sellCharge = "0";
                        sellChargeController.text = "0";
                        setTotal();
                      });
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        decoration: BoxDecoration(
                          color:  widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ? renew_main_color2 : light_gray24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "톤당단가",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ? Colors.white : Colors.black, font_weight: FontWeight.w600),
                            ),
                            widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ?
                            Image.asset(
                              "assets/image/ic_check_off.png",
                              width: CustomStyle.getWidth(10.0),
                              height: CustomStyle.getHeight(10.0),
                              color: Colors.white,
                            ) : const SizedBox(),
                          ],
                        )
                    )
                )
              ]
            ),
            /**
             *  톤당단가
             * */
            widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ?
            Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Text(
                  "톤당단가",
                  style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
              )
            ) : const SizedBox(),
            widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ?
          Container(
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                color: Colors.white,
                child: TextField(
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  controller: unitPriceController,
                  maxLines: null,
                  decoration: unitPriceController.text.isNotEmpty
                      ? InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        unitPriceController.text = "0";
                        widget.mData.unitPrice = "0";
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
                      )
                  )
                      : InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                    hintText: "0",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(20)
                    ),
                      suffix: Text(
                        "원",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                  onChanged: (value) async {
                      if(value.length > 0) {
                        unitPriceController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                        widget.mData.unitPrice = unitPriceController.text.replaceAll(",", "");
                      }else{
                        widget.mData.unitPrice = "0";
                        unitPriceController.text = "0";
                      }
                      if(widget.mData.unitPriceType == UNIT_PRICE_TYPE_02) {
                        widget.mData.sellCharge = await makeCharge();
                        sellChargeController.text = Util.getInCodeCommaWon(int.parse(widget.mData.sellCharge!.trim().replaceAll(",", "")).toString());
                      }
                    await setTotal();
                      setState(()  {});
                  },
                )
            ):const SizedBox(),
            /**
             *  기본운임
             * */
            Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(widget.mData.unitPriceType == UNIT_PRICE_TYPE_01 ? 10 : 0)),
                child: Row(
                    children:[
                      Text(
                        "${Strings.of(context)?.get("order_charge_info_sell_charge")}",
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
                      ),
                      Container(
                          padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                          child: Text(
                            "${Strings.of(context)?.get("essential")}",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_03),
                          )
                      )
                    ]
                )
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                color: Colors.white,
                child: TextFormField(
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  controller: sellChargeController,
                  maxLines: null,
                  readOnly: widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ? true : false,
                  decoration: sellChargeController.text.isNotEmpty
                      ? InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffixIcon: widget.mData.unitPriceType == UNIT_PRICE_TYPE_02 ? const SizedBox() : IconButton(
                        onPressed: () {
                          widget.mData.sellCharge = "0";
                          sellChargeController.text = "0";
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
                      )
                  ) : InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                      hintText: "0",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffix: Text(
                        "원",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                  onChanged: (value) async {
                    setState(() {
                      if(value.length > 0) {
                        sellChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                        widget.mData.sellCharge = sellChargeController.text.replaceAll(",", "");
                      }else{
                        widget.mData.sellCharge = "0";
                        sellChargeController.text = "0";
                      }
                    });
                    await setTotal();
                  },
                )
            ),
            /**
             *  수수료
             * */
            widget.mData.chargeType != CHARGE_TYPE_01 ?
            Text(
                "${Strings.of(context)?.get("order_charge_info_sell_fee")}",
                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
            ) : const SizedBox(),
            widget.mData.chargeType != CHARGE_TYPE_01 ?
            Container(
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                color: Colors.white,
                child: TextField(
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  controller: sellFeeController,
                  maxLines: null,
                  decoration: sellFeeController.text.isNotEmpty
                      ? InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          widget.mData.sellFee = "0";
                          sellFeeController.text = "0";
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
                      )
                  ) : InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                      hintText: "0",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffix: Text(
                        "원",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                  onChanged: (value) async {
                    setState(() {
                      if(value.length > 0) {
                        sellFeeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                        widget.mData.sellFee = sellFeeController.text.replaceAll(",", "");
                      }else{
                        widget.mData.sellFee = "0";
                        sellFeeController.text = "0";
                      }
                    });
                    await setTotal();
                  },
                ),
            ) : const SizedBox(),
            /**
             *  청구중량
             * */
            Text(
                "${Strings.of(context)?.get("order_charge_info_sell_wgt")}",
                style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                color: Colors.white,
                child: TextField(
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  controller: sellWeightController,
                  maxLines: null,
                  decoration: sellWeightController.text.isNotEmpty
                      ? InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          widget.mData.sellWeight = "0";
                          sellWeightController.text = "0";
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 18.h,
                          color: Colors.black,
                        ),
                      ),
                      suffix: Text(
                        "TON",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ) : InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                      hintText: "0",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      suffix: Text(
                        "TON",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                  onChanged: (value){
                    setState(() async {

                      if(widget.mData.unitPriceType == UNIT_PRICE_TYPE_02) {
                        if(value.length > 0) {
                          sellWeightController.text = value;
                          widget.mData.sellWeight = value;
                        }else{
                          sellWeightController.text = "";
                          widget.mData.sellWeight = "";
                        }
                          widget.mData.sellCharge = await makeCharge();
                          sellChargeController.text = Util.getInCodeCommaWon(int.parse(widget.mData.sellCharge!.trim().replaceAll(",", "")).toString());
                        await setTotal();
                      }else{
                        if(value.length > 0) {
                          sellWeightController.text = value.replaceFirst(RegExp(r'^0+'), '');
                          widget.mData.sellWeight = sellWeightController.text;

                          /*sellWeightController.text = value;
                    widget.mData.sellWeight = value;*/
                        } else {
                          sellWeightController.text = "";
                          widget.mData.sellWeight = "";
                        }
                      }

                    });
                  },
                )
            ),
            /**
             * 정보망 전송
             */
            Container(
                margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(5)),
                decoration: BoxDecoration(
                  color: light_gray24,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children : [
                      Text(
                          "정보망전송",
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
                      ),
                      Container(
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children : [
                              tv24Call.value ?
                              InkWell(
                                onTap: () async {
                                  await display24Call();
                                },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/image/ic_24.png",
                                        width: CustomStyle.getWidth(42.0),
                                        height: CustomStyle.getHeight(42.0),
                                      ),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/image/btn_check.png",
                                              width: CustomStyle.getWidth(22.0),
                                              height: CustomStyle.getHeight(22.0),
                                              color: m24Call.value == "Y" ? renew_main_color2 : Colors.black,
                                            ),
                                            Text(
                                              "${Strings.of(context)?.get("order_trans_info_rpa_24call")}",
                                              style: CustomStyle.CustomFont(styleFontSize14, m24Call.value == "Y" ? renew_main_color2 : styleBalckCol4),
                                            ),
                                          ]
                                      )
                                    ]
                                  )
                              ) : const SizedBox(),
                              tvHwaMull.value ?
                              InkWell(
                                onTap: () async {
                                  await displayHwaMull();
                                },
                                  child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/image/ic_hwamul.png",
                                          width: CustomStyle.getWidth(42.0),
                                          height: CustomStyle.getHeight(42.0),
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/image/btn_check.png",
                                              width: CustomStyle.getWidth(22.0),
                                              height: CustomStyle.getHeight(22.0),
                                              color: mHwaMull.value == "Y" ? renew_main_color2 : Colors.black,
                                            ),
                                            Text(
                                              "${Strings.of(context)?.get("order_trans_info_rpa_Hwamul")}",
                                              style: CustomStyle.CustomFont(styleFontSize14, mHwaMull.value == "Y" ? renew_main_color2 : styleBalckCol4),
                                            ),
                                          ]
                                        )

                                      ]
                                  )
                              ) : const SizedBox(),
                              tvOneCall.value ?
                              InkWell(
                                onTap: () async {
                                  await displayOneCall();
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/image/ic_one.png",
                                      width: CustomStyle.getWidth(42.0),
                                      height: CustomStyle.getHeight(42.0),
                                      color: mOneCall.value == "Y" ? renew_main_color2 : styleBalckCol4,
                                    ),
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/image/btn_check.png",
                                            width: CustomStyle.getWidth(22.0),
                                            height: CustomStyle.getHeight(22.0),
                                            color: mOneCall.value == "Y" ? renew_main_color2 : Colors.black,
                                          ),
                                          Text(
                                            "원콜",
                                            style: CustomStyle.CustomFont(styleFontSize14, mOneCall.value == "Y" ? renew_main_color2 : styleBalckCol4),
                                          ),
                                        ]
                                    )
                                  ]
                                )
                              ) : const SizedBox(),
                            ]
                        )
                      ),
                      // 운임비용 TextField
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "운임비용",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black)
                            ),
                            Container(
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white
                                ),
                                child: TextField(
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.number,
                                  controller: rpaValueController,
                                  maxLines: null,
                                  decoration: rpaValueController.text.isNotEmpty
                                      ? InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          mRpaSalary.value = "0";
                                          rpaValueController.text = "0";
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
                                      )
                                  ) : InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                                      hintText: "0",
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      suffix: Text(
                                        "원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      )
                                  ),
                                  onChanged: (value){
                                      if(value.length > 0) {
                                        rpaValueController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                        mRpaSalary.value = rpaValueController.text.replaceAll(",", "");
                                      }else{
                                        rpaValueController.text = "0";
                                        mRpaSalary.value = "0";
                                      }
                                      setState(() {});
                                  },
                                )
                            )
                          ]
                      )
                    ]
                )
            )
          ]
      )
    );
  }

  Widget addChargeFragment() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(10)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /**
           * 경유비(청구)
           **/
          Text(
            Strings.of(context)?.get("order_charge_info_way_point_charge")??"경유비(청구)",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                    color: Colors.white,
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.number,
                      controller: sellWayPointChargeController,
                      maxLines: null,
                      decoration: sellWayPointChargeController.text.isNotEmpty
                          ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              widget.mData.sellWayPointCharge = "0";
                              sellWayPointChargeController.text = "0";
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
                          )
                      ) : InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                          hintText: "0",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          suffix: Text(
                            "원",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      ),
                      onChanged: (value) async {
                        setState(()  {
                          if(value.length > 0) {
                            sellWayPointChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                            widget.mData.sellWayPointCharge = sellWayPointChargeController.text.replaceAll(",", "");
                          }else{
                            widget.mData.sellWayPointCharge = "0";
                            sellWayPointChargeController.text = "0";
                          }
                        });
                        await setTotal();
                      },
                    )
                )
              ),
              Expanded(
                flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                      child: Row(
                      children: [
                        Text(
                          "메모 작성",
                          style: CustomStyle.CustomFont(styleFontSize12, Colors.black)
                        ),
                        Checkbox(
                          value: sellWayPointMemoChk.value,
                          checkColor: Colors.white,
                          activeColor: renew_main_color2,
                          onChanged: (value) {
                            setState(() {
                              if(sellWayPointMemoChk.value == false) {
                                widget.mData.sellWayPointMemo = "";
                                sellWayPointMemoController.text = "";
                              }
                              sellWayPointMemoChk.value = value!;
                            });
                          },
                        ),
                      ],
                    )
                  )
              )

            ]
          ),
          /**
           * 경유비 메모
           **/
          sellWayPointMemoChk.value ?
          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Text(
                Strings.of(context)?.get("order_trans_info_way_point_memo")??"경유비 메모",
                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
            )
          ) : const SizedBox(),
          sellWayPointMemoChk.value ?
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
              color: Colors.white,
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: sellWayPointMemoController,
                maxLines: null,
                decoration: sellWayPointChargeController.text.isNotEmpty
                    ? InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        widget.mData.sellWayPointMemo = "";
                        sellWayPointMemoController.text = "";
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 18.h,
                        color: Colors.black,
                      ),
                    ),
                ) : InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                    hintText: "",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                        borderRadius: BorderRadius.circular(5)
                    ),
                ),
                onChanged: (value){
                  setState(() {
                    if(value.length > 0) {
                      widget.mData.sellWayPointMemo = value;
                    }else{
                      widget.mData.sellWayPointMemo = "";
                      sellWayPointMemoController.text = "";
                    }
                  });
                },
              )
          ) : const SizedBox(),
          /**
           * 대기료(청구)
           **/
          Text(
              Strings.of(context)?.get("order_charge_info_stay_charge")??"대기료(청구)",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
          ),
          Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                        color: Colors.white,
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          controller: sellStayChargeController,
                          maxLines: null,
                          decoration: sellStayChargeController.text.isNotEmpty
                              ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  widget.mData.sellStayCharge = "0";
                                  sellStayChargeController.text = "0";
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
                              )
                          ) : InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                              hintText: "0",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffix: Text(
                                "원",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                          ),
                          onChanged: (value) async {
                            setState(() {
                              if(value.length > 0) {
                                sellStayChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                widget.mData.sellStayCharge = sellStayChargeController.text.replaceAll(",", "");
                              }else{
                                widget.mData.sellStayCharge = "0";
                                sellStayChargeController.text = "0";
                              }
                            });
                            await setTotal();
                          },
                        )
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                        child: Row(
                          children: [
                            Text(
                                "메모 작성",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black)
                            ),
                            Checkbox(
                              value: sellStayMemoChk.value,
                              checkColor: Colors.white,
                              activeColor: renew_main_color2,
                              onChanged: (value) {
                                setState(() {
                                  if(sellStayMemoChk.value == false) {
                                    widget.mData.sellStayMemo = "";
                                    sellStayMemoController.text = "";
                                  }
                                  sellStayMemoChk.value = value!;
                                });
                              },
                            ),
                          ],
                        )
                    )
                )

              ]
          ),
          /**
           * 대기표 메모
           **/
          sellStayMemoChk.value ?
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              child: Text(
                  Strings.of(context)?.get("order_trans_info_stay_memo")??"대기료 메모",
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
              )
          ) : const SizedBox(),
          sellStayMemoChk.value ?
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
              color: Colors.white,
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: sellStayMemoController,
                maxLines: null,
                decoration: sellStayMemoController.text.isNotEmpty
                    ? InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.mData.sellStayMemo = "";
                      sellStayMemoController.text = "";
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18.h,
                      color: Colors.black,
                    ),
                  ),
                ) : InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                  hintText: "",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    if(value.length > 0) {
                      widget.mData.sellStayMemo = value;
                    }else{
                      widget.mData.sellStayMemo = "";
                      sellStayMemoController.text = "";
                    }
                  });
                },
              )
          ) : const SizedBox(),
          /**
           * 수작업비(청구)
           **/
          Text(
              Strings.of(context)?.get("order_charge_info_hand_work_charge")??"수작업비(청구)",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
          ),
          Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                        color: Colors.white,
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          controller: sellHandWorkChargeController,
                          maxLines: null,
                          decoration: sellHandWorkChargeController.text.isNotEmpty
                              ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  widget.mData.sellHandWorkCharge = "0";
                                  sellHandWorkChargeController.text = "0";
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
                              )
                          ) : InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                              hintText: "0",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffix: Text(
                                "원",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                          ),
                          onChanged: (value) async {
                            setState(() {
                              if(value.length > 0) {
                                sellHandWorkChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                widget.mData.sellHandWorkCharge = sellHandWorkChargeController.text.replaceAll(",", "");
                              }else{
                                widget.mData.sellHandWorkCharge = "0";
                                sellHandWorkChargeController.text = "0";
                              }
                            });
                            await setTotal();
                          },
                        )
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                        child: Row(
                          children: [
                            Text(
                                "메모 작성",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black)
                            ),
                            Checkbox(
                              value: sellHandWorkMemoChk.value,
                              checkColor: Colors.white,
                              activeColor: renew_main_color2,
                              onChanged: (value) {
                                setState(() {
                                  if(sellHandWorkMemoChk.value == false) {
                                    widget.mData.sellHandWorkMemo = "";
                                    sellHandWorkMemoController.text = "";
                                  }
                                  sellHandWorkMemoChk.value = value!;
                                });
                              },
                            ),
                          ],
                        )
                    )
                )

              ]
          ),
          /**
           * 수작업비 메모
           **/
          sellHandWorkMemoChk.value ?
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              child: Text(
                  Strings.of(context)?.get("order_trans_info_hand_work_memo")??"수작업비 메모",
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
              )
          ) : const SizedBox(),
          sellHandWorkMemoChk.value ?
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
              color: Colors.white,
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: sellHandWorkMemoController,
                maxLines: null,
                decoration: sellStayMemoController.text.isNotEmpty
                    ? InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.mData.sellHandWorkMemo = "";
                      sellHandWorkMemoController.text = "";
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18.h,
                      color: Colors.black,
                    ),
                  ),
                ) : InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                  hintText: "",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    if(value.length > 0) {
                      widget.mData.sellHandWorkMemo = value;
                    }else{
                      widget.mData.sellHandWorkMemo = "";
                      sellHandWorkMemoController.text = "";
                    }
                  });
                },
              )
          ) : const SizedBox(),
          /**
           * 회차료(청구)
           **/
          Text(
              Strings.of(context)?.get("order_charge_info_round_charge")??"회차료(청구)",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
          ),
          Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                        color: Colors.white,
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          controller: sellRoundChargeController,
                          maxLines: null,
                          decoration: sellRoundChargeController.text.isNotEmpty
                              ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  widget.mData.sellRoundCharge = "0";
                                  sellRoundChargeController.text = "0";
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
                              )
                          ) : InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                              hintText: "0",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffix: Text(
                                "원",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                          ),
                          onChanged: (value) async {
                            setState(() {
                              if(value.length > 0) {
                                sellRoundChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                widget.mData.sellRoundCharge = sellRoundChargeController.text.replaceAll(",", "");
                              }else{
                                widget.mData.sellRoundCharge = "0";
                                sellRoundChargeController.text = "0";
                              }
                            });
                            await setTotal();
                          },
                        )
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                        child: Row(
                          children: [
                            Text(
                                "메모 작성",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black)
                            ),
                            Checkbox(
                              value: sellRoundMemoChk.value,
                              checkColor: Colors.white,
                              activeColor: renew_main_color2,
                              onChanged: (value) {
                                setState(() {
                                  if(sellRoundMemoChk.value == false) {
                                    widget.mData.sellRoundMemo = "";
                                    sellRoundMemoController.text = "";
                                  }
                                  sellRoundMemoChk.value = value!;
                                });
                              },
                            ),
                          ],
                        )
                    )
                )

              ]
          ),
          /**
           * 회차료 메모
           **/
          sellRoundMemoChk.value ?
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              child: Text(
                  Strings.of(context)?.get("order_trans_info_round_memo")??"회차료 메모",
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
              )
          ) : const SizedBox(),
          sellRoundMemoChk.value ?
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
              color: Colors.white,
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: sellRoundMemoController,
                maxLines: null,
                decoration: sellRoundMemoController.text.isNotEmpty
                    ? InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.mData.sellRoundMemo = "";
                      sellRoundMemoController.text = "";
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18.h,
                      color: Colors.black,
                    ),
                  ),
                ) : InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                  hintText: "",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    if(value.length > 0) {
                      widget.mData.sellRoundMemo = value;
                    }else{
                      widget.mData.sellRoundMemo = "";
                      sellRoundMemoController.text = "";
                    }
                  });
                },
              )
          ) : const SizedBox(),
          /**
           * 기타추가비(청구)
           **/
          Text(
              Strings.of(context)?.get("order_charge_info_other_add_charge")??"기타추가비(청구)",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
          ),
          Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
                        color: Colors.white,
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          controller: sellOtherAddChargeController,
                          maxLines: null,
                          decoration: sellOtherAddChargeController.text.isNotEmpty
                              ? InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  widget.mData.sellOtherAddCharge = "0";
                                  sellOtherAddChargeController.text = "0";
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
                              )
                          ) : InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                              hintText: "0",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              suffix: Text(
                                "원",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                          ),
                          onChanged: (value) async {
                            setState(() {
                              if(value.length > 0) {
                                sellOtherAddChargeController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                                widget.mData.sellOtherAddCharge = sellOtherAddChargeController.text.replaceAll(",", "");
                              }else{
                                widget.mData.sellOtherAddCharge = "0";
                                sellOtherAddChargeController.text = "0";
                              }
                            });
                            await setTotal();
                          },
                        )
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                        child: Row(
                          children: [
                            Text(
                                "메모 작성",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black)
                            ),
                            Checkbox(
                              value: sellAddMemoChk.value,
                              checkColor: Colors.white,
                              activeColor: renew_main_color2,
                              onChanged: (value) {
                                setState(() {
                                  if(sellAddMemoChk.value == false) {
                                    widget.mData.sellOtherAddMemo = "";
                                    sellOtherAddMemoController.text = "";
                                  }
                                  sellAddMemoChk.value = value!;
                                });
                              },
                            ),
                          ],
                        )
                    )
                )

              ]
          ),
          /**
           * 기타추가비 메모
           **/
          sellAddMemoChk.value ?
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              child: Text(
                  Strings.of(context)?.get("order_trans_info_other_add_memo")??"기타추가비 메모",
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
              )
          ) : const SizedBox(),
          sellAddMemoChk.value ?
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3)),
              color: Colors.white,
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: sellOtherAddMemoController,
                maxLines: null,
                decoration: sellOtherAddMemoController.text.isNotEmpty
                    ? InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.mData.sellOtherAddMemo = "";
                      sellOtherAddMemoController.text = "";
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18.h,
                      color: Colors.black,
                    ),
                  ),
                ) : InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                  hintText: "",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    if(value.length > 0) {
                      widget.mData.sellOtherAddMemo = value;
                    }else{
                      widget.mData.sellOtherAddMemo = "";
                      sellOtherAddMemoController.text = "";
                    }
                  });
                },
              )
          ) : const SizedBox(),
        ]
      )
    );
  }

  /**
   * Widget End
   **/

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Container(
        padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20), vertical: CustomStyle.getHeight(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "운임 정보 설정",
              style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
            ),
            Container(
              margin: EdgeInsets.only(top:CustomStyle.getHeight(10)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "청구운임",
                              style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w600),
                            ),
                            Text(
                              "(소계)",
                              style: CustomStyle.CustomFont(styleFontSize12, light_gray23,font_weight: FontWeight.w600),
                            )
                          ],
                        ),
                        Text(
                          "${Util.getInCodeCommaWon(tvTotal.value.toString())}원",
                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                        )
                      ]
                    ),
                  ),
                  customTabBarWidget(),
                  tabBarViewWidget(),
                ]
              )
            )
          ],
        ),
      )
      );
    });
  }
}

/**
 * 운임 정보
 */
class MainPageContentComponent5 extends StatefulWidget {
  final BuildContext context;
  final String title;
  final OrderModel mData;
  final MotionTabBarController tabController;
  String? code;
  String? flag;

  MainPageContentComponent5({Key? key,required this.context,required this.mData,required this.title,required this.tabController,this.code,this.flag}):super(key:key);

  _MainPageContentComponent5State createState() => _MainPageContentComponent5State();
}
class _MainPageContentComponent5State extends State<MainPageContentComponent5> with TickerProviderStateMixin {

  final tvOrderState = false.obs;
  final tvAllocState = false.obs;
  final llDriverInfo = false.obs;

  late TextEditingController templateTitleController;

  final isStopPointExpanded = [].obs;
  final llStopPointHeader = false.obs;
  final llStopPointList = false.obs;
  final isCargoExpanded = [].obs;
  final isEtcExpanded = [].obs;
  final mStopList = List.empty(growable: true).obs;

  final isRequest = false.obs; // 화주 등록에 따른 Filter -> 상차, 하차지 설정
  final isSAddr = false.obs;
  final isEAddr = false.obs;
  final isCargoInfo = false.obs;
  final isChargeInfo = false.obs;

  final controller = Get.find<App>();

  ProgressDialog? pr;

  /**
   * Function Start
   **/

  @override
  void initState() {
    super.initState();

    templateTitleController = TextEditingController();

    Future.delayed(Duration.zero, () async {

    });
  }

  @override
  void dispose() {
    super.dispose();
    templateTitleController.dispose();
  }

  int chargeTotal(String? chargeFlag) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(widget.mData.sellCharge ?? "0") -
          int.parse(widget.mData.sellFee ?? "0") +
          int.parse(widget.mData.sellWayPointCharge ?? "0") +
          int.parse(widget.mData.sellStayCharge ?? "0") +
          int.parse(widget.mData.sellHandWorkCharge ?? "0") +
          int.parse(widget.mData.sellRoundCharge ?? "0") +
          int.parse(widget.mData.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(widget.mData.buyCharge ?? "0") -
          int.parse(widget.mData.buyFee ?? "0") +
          int.parse(widget.mData.wayPointCharge ?? "0") +
          int.parse(widget.mData.stayCharge ?? "0") +
          int.parse(widget.mData.handWorkCharge ?? "0") +
          int.parse(widget.mData.roundCharge ?? "0") +
          int.parse(widget.mData.otherAddCharge ?? "0");
    }
    return total;
  }

  bool validation(OrderModel mData){

    bool result = true;
    if (mData.sellCustName == null || mData.sellCustName?.isEmpty == true) {
      Util.toast("\'거래처명\'을 선택해주세요.");
      widget.tabController!.index = 0;
      result = false;
    } else if (mData.sellDeptId == null || mData.sellDeptId?.isEmpty == true) {
      Util.toast("\'담당부서\'를 선택해주세요.");
      widget.tabController!.index = 0;
      result = false;
    } else if (mData.sAddr == null || mData.sAddr?.isEmpty == true) {
      Util.toast("\'상차지\'를 선택해주세요.");
      widget.tabController!.index = 1;
      result = false;
    } else if (mData.eAddr == null || mData.eAddr?.isEmpty == true) {
      Util.toast("\'하차지\'를 선택해주세요.");
      widget.tabController!.index = 1;
      result = false;
    } else if (mData.carTypeCode == null || mData.carTypeCode?.isEmpty == true) {
      Util.toast("\'차종\'을 선택해주세요.");
      widget.tabController!.index = 2;
      result = false;
    } else if (mData.carTypeCode == null || mData.carTonCode?.isEmpty == true) {
      Util.toast("\'톤수\'를 선택해주세요.");
      widget.tabController!.index = 2;
      result = false;
    } else if (mData.goodsName == null || mData.goodsName?.isEmpty == true) {
      Util.toast("\'화물정보\'를 입력해주세요.");
      widget.tabController!.index = 2;
      result = false;
    } else if (mData.chargeType == null || mData.chargeType?.isEmpty == true) {
      Util.toast("\'결제방법\'을 선택해주세요.");
      widget.tabController!.index = 3;
      result = false;
    }else if (mData.unitPriceType == null || mData.unitPriceType?.isEmpty == true) {
      Util.toast("\'단가구분\'을 선택해주세요.");
      widget.tabController!.index = 3;
      result = false;
    }
    return result;
  }

  Future<void> regOrder(OrderModel mData) async {
    if(validation(mData)) {
      Logger logger = Logger();
      await pr?.show();
      UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).orderReg(
          user.authorization,
          mData.sellCustName,
          mData.sellCustId,
          mData.sellDeptId,
          mData.sellStaff, mData.sellStaffTel, mData.reqAddr,
          mData.reqAddrDetail,user.custId,user.deptId,mData.inOutSctn,mData.truckTypeCode,
          mData.sComName,mData.sSido,mData.sGungu,mData.sDong,mData.sAddr,mData.sAddrDetail,
          mData.sDate,mData.sStaff,mData.sTel,mData.sMemo,mData.eComName,mData.eSido,
          mData.eGungu,mData.eDong,mData.eAddr,mData.eAddrDetail,mData.eDate,mData.eStaff,
          mData.eTel,mData.eMemo,mData.sLat,mData.sLon,mData.eLat,mData.eLon,
          mData.goodsName,double.parse(mData.goodsWeight??"0.0"),mData.weightUnitCode,mData.goodsQty,mData.qtyUnitCode,
          mData.sWayCode,mData.eWayCode,mData.mixYn,mData.mixSize,mData.returnYn,
          mData.carTonCode,mData.carTypeCode,mData.chargeType,mData.unitPriceType,int.parse(mData.unitPrice??"0"),mData.distance,mData.time,
          mData.reqMemo, mData.driverMemo,mData.itemCode,int.parse(mData.sellCharge??"0"),int.parse(mData.sellFee??"0"),
          mData.orderStopList != null && mData.orderStopList?.isNotEmpty == true ? jsonEncode(mData.orderStopList?.map((e) => e.toJson()).toList()):null,user.userId,user.mobile,
          mData.sellWayPointMemo,mData.sellWayPointCharge,mData.sellStayMemo,mData.sellStayCharge,
          mData.handWorkMemo,mData.sellHandWorkCharge,mData.sellRoundMemo,mData.sellRoundCharge,
          mData.sellOtherAddMemo,mData.sellOtherAddCharge,mData.sellWeight,"N",
          mData.call24Cargo,
          mData.manCargo,
          mData.oneCargo,
          mData.call24Charge,
          mData.manCharge,
          mData.oneCharge
      ).then((it) async {
        await pr?.hide();
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("regOrder() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["result"] == true) {

            UserModel user = await controller.getUserInfo();

            await FirebaseAnalytics.instance.logEvent(
              name: Platform.isAndroid ? "regist_order_aos" : "regist_order_ios",
              parameters: <String, Object> {
                "user_id": user.userId??"",
                "user_custId": user.custId??"",
                "user_deptId": user.deptId??"",
                "reqCustId": mData.sellCustId??"",
                "sellDeptId": mData.sellDeptId??""
              },
            );

            if (mData.call24Cargo == "Y" ||
                mData.manCargo == "Y" || mData.oneCargo == "Y") {
              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid ? "regist_order_rpa_aos" : "regist_order_rpa_ios",
                parameters: {
                  "user_id": user.userId??"",
                  "user_custId": user.custId??"",
                  "user_deptId": user.deptId??"",
                  "reqCustId": mData.sellCustId??"",
                  "sellDeptId": mData.sellDeptId??"",
                  "call24Cargo_Status": mData.call24Cargo??"",
                  "manCargo_Status": mData.manCargo??"",
                  "oneCargo_Status": mData.oneCargo??"",
                  "rpaSalary": mData.call24Charge??"",
                },
              );
            }

            Navigator.of(context).pop({'code': 200});
          }else{
            openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          }
        }
      }).catchError((Object obj) async {
        await pr?.hide();
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("regOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("regOrder() getOrder Default => ");
            break;
        }
      });
    }
  }

  Future<void> regTemplate(String? templateTitle, OrderModel mData) async {
      TemplateModel tModel = convertTempModel(mData);
      Logger logger = Logger();
      if(templateTitle?.isNotEmpty == true && templateTitle != null) {
        await pr?.show();
        UserModel? user = await controller.getUserInfo();
        await DioService.dioClient(header: true).templateReg(
            user.authorization,
            templateTitle,
            tModel.sellCustName,
            tModel.sellCustId,
            tModel.sellDeptName,
            tModel.sellDeptId,
            tModel.sellStaff,
            tModel.sellStaffTel,
            tModel.reqAddr,
            tModel.reqAddrDetail,
            user.custId,
            user.deptId,
            tModel.inOutSctn,
            tModel.inOutSctnName,
            tModel.truckTypeCode,
            tModel.truckTypeName,

            tModel.sComName,
            tModel.sSido,
            tModel.sGungu,
            tModel.sDong,
            tModel.sAddr,
            tModel.sAddrDetail,
            tModel.sDate,
            tModel.sStaff,
            tModel.sTel,
            tModel.sMemo,

            tModel.eComName,
            tModel.eSido,
            tModel.eGungu,
            tModel.eDong,
            tModel.eAddr,
            tModel.eAddrDetail,
            tModel.eDate,
            tModel.eStaff,
            tModel.eTel,
            tModel.eMemo,

            tModel.sLat,
            tModel.sLon,
            tModel.eLat,
            tModel.eLon,

            tModel.goodsName,
            double.parse(tModel.goodsWeight ?? "0"),
            tModel.weightUnitCode,
            tModel.weightUnitName,
            double.parse(tModel.goodsQty ?? "0.0"),
            tModel.qtyUnitCode,
            tModel.qtyUnitName,
            tModel.sWayCode,
            tModel.sWayName,
            tModel.eWayCode,
            tModel.eWayName,
            tModel.mixYn,
            tModel.mixSize,
            tModel.returnYn,
            tModel.carTonCode,
            tModel.carTonName,
            tModel.carTypeCode,
            tModel.carTypeName,
            tModel.chargeType,
            tModel.chargeTypeName,

            tModel.unitPriceType,
            int.parse(tModel.unitPrice ?? "0"),
            tModel.unitPriceTypeName,
            tModel.distance?.toString(),
            tModel.time,
            tModel.reqMemo,
            tModel.driverMemo,
            tModel.itemCode,
            int.parse(tModel.sellCharge ?? "0"),
            int.parse(tModel.sellFee ?? "0"),
            jsonEncode(tModel.templateStopList?.map((e) => e.toJson()).toList()),
            user.userId,
            user.mobile,
            tModel.sellWayPointMemo,
            int.parse(tModel.sellWayPointCharge??"0"),
            tModel.sellStayMemo,
            int.parse(tModel.sellStayCharge??"0"),
            tModel.handWorkMemo,
            int.parse(tModel.sellHandWorkCharge??"0"),
            tModel.sellRoundMemo,
            int.parse(tModel.sellRoundCharge??"0"),
            tModel.sellOtherAddMemo,
            int.parse(tModel.sellOtherAddCharge??"0"),
            tModel.sellWeight,
            "N",
            tModel.call24Cargo,
            tModel.manCargo,
            tModel.oneCargo,
            tModel.call24Charge,
            tModel.manCharge,
            tModel.oneCharge
        ).then((it) async {
          await pr?.hide();
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("regTemplate() _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              UserModel user = await controller.getUserInfo();

              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid ? "regist_template_aos" : "regist_template_ios",
                parameters: <String, Object>{
                  "user_id": user.userId ?? "",
                  "user_custId": user.custId ?? "",
                  "user_deptId": user.deptId ?? "",
                  "reqCustId": tModel.sellCustId ?? "",
                  "sellDeptId": tModel.sellDeptId ?? ""
                },
              );

              Navigator.of(context).pop({'code': 200});
            } else {
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          }else{
            Util.toast("탬플릿 생성중 오류가 발생하였습니다.");
          }
        }).catchError((Object obj) async {
          await pr?.hide();
          switch (obj.runtimeType) {
            case DioError:
            // Here's the sample to get the failed response error code and message
              final res = (obj as DioError).response;
              print("regTemplate() Error => ${res?.statusCode} // ${res?.statusMessage}");
              break;
            default:
              print("regTemplate() getOrder Default => ");
              break;
          }
        });
      }else{
        Util.toast("탬플릿명을 입력해주세요.");
      }
  }

   TemplateModel convertTempModel(OrderModel tModel){
     final covTemplateStopList = <TemplateStopPointModel>[].obs;
    if(tModel.orderStopList != null) {
      for(int i = 0; i < tModel.orderStopList!.length; i++) {
        covTemplateStopList.add(TemplateStopPointModel(
          stopSeq : tModel.orderStopList?[i].stopSeq,
          stopNo : tModel.orderStopList?[i].stopNo,
          eComName : tModel.orderStopList?[i].eComName,
          eAddr : tModel.orderStopList?[i].eAddr,
          eAddrDetail : tModel.orderStopList?[i].eAddrDetail,
          eStaff : tModel.orderStopList?[i].eStaff,
          eTel : tModel.orderStopList?[i].eTel,
          finishYn : tModel.orderStopList?[i].finishYn,
          finishDate : tModel.orderStopList?[i].finishDate,
          beginYn : tModel.orderStopList?[i].beginYn,
          beginDate : tModel.orderStopList?[i].beginDate,
          goodsWeight : tModel.orderStopList?[i].goodsWeight,
          eLat : tModel.orderStopList?[i].eLat,
          eLon : tModel.orderStopList?[i].eLon,
          weightUnitCode : tModel.orderStopList?[i].weightUnitCode,
          goodsQty : tModel.orderStopList?[i].goodsQty,
          qtyUnitCode : tModel.orderStopList?[i].qtyUnitCode,
          qtyUnitName : tModel.orderStopList?[i].qtyUnitName,
          goodsName : tModel.orderStopList?[i].goodsName,
          useYn : tModel.orderStopList?[i].useYn,
          stopSe : tModel.orderStopList?[i].stopSe,
        ));
      }
    }
     TemplateModel tempModel = TemplateModel(
         reqCustId: tModel?.reqCustId??"",
         reqCustName: tModel?.reqCustName??"",
         reqDeptId: tModel?.reqDeptId??"",
         reqDeptName: tModel?.reqDeptName??"",
         reqStaff: tModel?.reqStaff??"",
         reqTel: tModel?.reqTel??"",
         reqAddr: tModel?.reqAddr??"",
         reqAddrDetail: tModel?.reqAddrDetail??"",
         custId: tModel?.custId,
         custName: tModel?.custName,
         deptId: tModel?.deptId,
         deptName: tModel?.deptName,
         inOutSctn: tModel?.inOutSctn,
         inOutSctnName: tModel?.inOutSctnName,
         truckTypeCode: tModel?.truckTypeCode,
         truckTypeName: tModel?.truckTypeName,
         sComName: tModel?.sComName,
         sSido: tModel?.sSido,
         sGungu: tModel?.sGungu,
         sDong: tModel?.sDong,
         sAddr: tModel?.sAddr,
         sAddrDetail: tModel?.sAddrDetail,
         sDate: tModel?.sDate,
         sStaff: tModel?.sStaff,
         sTel: tModel?.sTel,
         sMemo: tModel?.sMemo,
         eComName: tModel?.eComName,
         eSido: tModel?.eSido,
         eGungu: tModel?.eGungu,
         eDong: tModel?.eDong,
         eAddr: tModel?.eAddr,
         eAddrDetail: tModel?.eAddrDetail,
         eDate: tModel?.eDate,
         eStaff: tModel?.eStaff,
         eTel: tModel?.eTel,
         eMemo: tModel?.eMemo,
         sLat: tModel?.sLat,
         sLon: tModel?.sLon,
         eLat: tModel?.eLat,
         eLon: tModel?.eLon,
         goodsName: tModel?.goodsName,
         goodsWeight: tModel?.goodsWeight,
         weightUnitCode: tModel?.weightUnitCode,
         weightUnitName: tModel?.weightUnitName,
         goodsQty: tModel?.goodsQty,
         qtyUnitCode: tModel?.qtyUnitCode,
         qtyUnitName: tModel?.qtyUnitName,
         sWayCode: tModel?.sWayCode,
         sWayName: tModel?.sWayName,
         eWayCode: tModel?.eWayCode,
         eWayName: tModel?.eWayName,
         mixYn: tModel?.mixYn,
         mixSize: tModel?.mixSize,
         returnYn: tModel?.returnYn,
         carTonCode: tModel?.carTonCode,
         carTonName: tModel?.carTonName,
         carTypeCode: tModel?.carTypeCode,
         carTypeName: tModel?.carTypeName,
         chargeType: tModel?.chargeType,
         chargeTypeName: tModel?.chargeTypeName,
         distance: tModel?.distance,
         time: tModel?.time,
         reqMemo: tModel?.reqMemo,
         driverMemo: tModel?.driverMemo,
         itemCode: tModel?.itemCode,
         itemName: tModel?.itemName,
         stopCount: tModel?.stopCount,
         sellCustId: tModel?.sellCustId,
         sellDeptId: tModel?.sellDeptId,
         sellStaff: tModel?.sellStaff,
         sellStaffName: tModel?.sellStaffName,
         sellStaffTel: tModel?.sellStaffTel,
         sellCustName: tModel?.sellCustName,
         sellDeptName: tModel?.sellDeptName,
         sellCharge: tModel?.sellCharge,
         sellFee: tModel?.sellFee,
         sellWeight: tModel?.sellWeight,
         sellWayPointMemo: tModel?.sellWayPointMemo,
         sellWayPointCharge: tModel?.sellWayPointCharge,
         sellStayMemo: tModel?.sellStayMemo,
         sellStayCharge: tModel?.sellStayCharge,
         sellHandWorkMemo: tModel?.sellHandWorkMemo,
         sellHandWorkCharge: tModel?.sellHandWorkCharge,
         sellRoundMemo: tModel?.sellRoundMemo,
         sellRoundCharge: tModel?.sellRoundCharge,
         sellOtherAddMemo: tModel?.sellOtherAddMemo,
         sellOtherAddCharge: tModel?.sellOtherAddCharge,
         custPayType: tModel?.custPayType,
         buyCharge: tModel?.buyCharge,
         buyFee: tModel?.buyFee,
         wayPointMemo: tModel?.wayPointMemo,
         wayPointCharge: tModel?.wayPointCharge,
         stayMemo: tModel?.stayMemo,
         stayCharge: tModel?.stayCharge,
         handWorkMemo: tModel?.handWorkMemo,
         handWorkCharge: tModel?.handWorkCharge,
         roundMemo: tModel?.roundMemo,
         roundCharge: tModel?.roundCharge,
         otherAddMemo: tModel?.otherAddMemo,
         otherAddCharge: tModel?.otherAddCharge,
         unitPrice: tModel?.unitPrice,
         unitPriceType: tModel?.unitPriceType,
         unitPriceTypeName: tModel?.unitPriceTypeName,
         payType: tModel?.payType,
         reqPayYN: tModel?.reqPayYN,
         reqPayDate: tModel?.reqPayDate,
         talkYn: tModel?.talkYn,
         templateStopList: covTemplateStopList.value,
         reqStaffName: tModel?.reqStaffName,
         call24Cargo: tModel?.call24Cargo,
         manCargo: tModel?.manCargo,
         oneCargo: tModel?.oneCargo,
         call24Charge: tModel?.call24Charge,
         manCharge: tModel?.manCharge,
         oneCharge: tModel?.oneCharge
     );

     return tempModel;
  }

  /**
   * Function End
   **/


  /**
   *  Widget Start
   **/

  Widget etcPannelWidget() {

    isEtcExpanded.value = List.filled(1, true);
    return Container(
        margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10)),
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ExpansionPanelList.radio(
                  initialOpenPanelValue: 0,
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
                      body: Container(
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
                                        padding: const EdgeInsets.all(10),
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                        child: Text(
                                          !(widget.mData.driverMemo?.isEmpty == true) ? widget.mData.driverMemo??"-" : "-",
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
                                        padding: const EdgeInsets.all(10),
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                        child: Text(
                                          !(widget.mData.reqMemo?.isEmpty == true) ? widget.mData.reqMemo??"-" : "-",
                                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  )
                                ]
                            )
                        ),
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
                  widget.mData.inOutSctnName??"",
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
                      widget.mData.truckTypeName??"",
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
                      widget.mData.carTonName??"",
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
                      widget.mData.carTypeName??"",
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
                              text: "${widget.mData.goodsName??"-"}",
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
                      widget.mData.itemName??"-",
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
                      "${widget.mData.goodsWeight??"-"} ${widget.mData.weightUnitCode??""}",
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
                      widget.mData.sWayName??"",
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
                      widget.mData.eWayName??"",
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
                      widget.mData.mixYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_mix_y")}":"${Strings.of(context)?.get("order_cargo_info_mix_n")}",
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
                      widget.mData.returnYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_return_y")}":"${Strings.of(context)?.get("order_cargo_info_return_n")}",
                      style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                    )
                  ]
              )
          ),
        ],
      );
  }

  Widget cargoInfoWidget() {
    isCargoExpanded.value = List.filled(1, true);
    return Container(
        margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10)),
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ExpansionPanelList.radio(
                  initialOpenPanelValue: 0,
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
                      body:Container(
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
                      ),
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
                            Text("경유지 ${widget.mData.stopCount}곳",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
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

  Widget orderEtcChargeWidget(String chargeFlag) {
    return Column(
        children: [
          //수수료
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellFee??"0" : widget.mData.buyFee??"0") ?
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
                      " - ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellFee??"0": widget.mData.buyFee??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ):const SizedBox(),
          // 경유비(지불)
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellWayPointCharge??"0" : widget.mData.wayPointCharge??"0") ?
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
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellWayPointCharge??"0": widget.mData.wayPointCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ):const SizedBox(),
          // 대기료(지불)
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellStayCharge??"0" : widget.mData.stayCharge??"0") ?
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
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellStayCharge??"0" : widget.mData.stayCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 수작업비(지불)
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellHandWorkCharge??"0" : widget.mData.handWorkCharge??"0") ?
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
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellHandWorkCharge??"0" : widget.mData.handWorkCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 회차료(지불)
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellRoundCharge??"0" : widget.mData.roundCharge ?? "0") ?
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
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellRoundCharge??"0" : widget.mData.roundCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 기타추가비(지불)
          Util.equalsCharge(chargeFlag == "S" ? widget.mData.sellOtherAddCharge??"0" : widget.mData.otherAddCharge??"0") ?
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
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? widget.mData.sellOtherAddCharge??"0" : widget.mData.otherAddCharge??"0")} 원",
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

  Widget HorizontalDashedDivider() {

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

  Widget templateTitleWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Container(
          color: Colors.white,
          child: TextFormField(
            style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            controller: templateTitleController,
            maxLines: null,
            decoration: templateTitleController.text.isNotEmpty
                ? InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(5)
                ),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(5)
                ),
                suffixIcon:  IconButton(
                  onPressed: () {
                    templateTitleController.text = "";
                  },
                  icon: Icon(
                    Icons.clear,
                    size: 18.h,
                    color: Colors.black,
                  ),
                ),
            ) : InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                hintText: "탬플릿명을 입력해주세요.",
                hintStyle: CustomStyle.CustomFont(styleFontSize14, light_gray23),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(5)
                ),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(5)
                ),
            ),
            onChanged: (value) async {
              setState(() {
              });
            },
          )
      )
    );
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
              padding: tvAllocState.value ? EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15)) : EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(15)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      widget.mData.sellCustName?.isNotEmpty == true?
                      Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          widget.mData.sellCustName??"",
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                        ),
                      ) : const SizedBox(),
                      widget.mData.sellDeptName?.isNotEmpty == true?
                      Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          widget.mData.sellDeptName??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      ) : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ) ,
            widget.mData.sellStaffName != null && widget.mData.sellStaffName?.isNotEmpty == true ?
                Container(
                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5),left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.mData.sellStaffName??"",
                        style: CustomStyle.CustomFont(styleFontSize15, text_color_01),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                        alignment: Alignment.center,
                        child: Text(
                          Util.makePhoneNumber(widget.mData.sellStaffTel) ,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                    ],
                  )
                ) : const SizedBox(),
            HorizontalDashedDivider(),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
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
                        "${Util.getInCodeCommaWon(widget.mData.sellCharge??"0")} 원",
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
          ],
        )
    );
  }

  Widget bodyArea() {
    return Column(
      children: [
         widget.flag != "D" ?
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
            child: Text(
              "탬플릿명",
              style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
            )
        ) : const SizedBox(),
        widget.flag != "D"? templateTitleWidget() : const SizedBox(),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
            child: Text(
              "운임 정보",
              style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
            )
        ),
        orderSellWidget(),
        llDriverInfo.value ?  Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
            child: Text(
              Strings.of(context)?.get("order_detail_sub_title_05")?? "차주 정보_",
              style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
            )
        ) : const SizedBox(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return  SingleChildScrollView(
          child: Container(
            padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20), vertical: CustomStyle.getHeight(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "최종 확인",
                  style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
                ),
                bodyArea(),
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                    width: double.infinity,
                    height: CustomStyle.getHeight(50.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: widget.flag == "M" ? rpa_btn_modify : renew_main_color2,
                        ),
                        onPressed: () async {
                          var data = widget.mData;
                          if(widget.flag == "D") { // 오더 등록
                            await regOrder(widget.mData);
                          }else if(widget.flag == "M") { // 탬플릿 수정

                          }else{ // 탬플릿 생성
                            await regTemplate(templateTitleController.text, widget.mData);
                          }
                        },
                        child:Text(
                          widget.flag == "M" ? "탬플릿 수정" : widget.flag == "D" ? "오더 등록" : "탬플릿 생성",
                          style: CustomStyle.CustomFont(styleFontSize16, Colors.white,font_weight: FontWeight.w800),
                        )
                    )
                )
              ],
            ),
          )
      );
    });
  }
  
}

/**
 * Widget End
 */