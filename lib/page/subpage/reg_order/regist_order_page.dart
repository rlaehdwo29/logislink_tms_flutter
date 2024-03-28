import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/order_request_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cargo_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_charge_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_reg_day_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/recent_order_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/stop_point_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class RegistOrderPage extends StatefulWidget {

  OrderModel? order_vo;
  String? flag; // R: 오더 등록, CR:오더 복사, M: 오더 수정

  RegistOrderPage({Key? key, this.order_vo, this.flag}):super(key:key);

  _RegistOrderPageState createState() => _RegistOrderPageState();
}

class _RegistOrderPageState extends State<RegistOrderPage> {

  ProgressDialog? pr;

  final controller = Get.find<App>();

  final isRequest = false.obs; // 화주 등록에 따른 Filter -> 상차, 하차지 설정
  final isSAddr = false.obs;
  final isEAddr = false.obs;
  final isCargoInfo = false.obs;
  final isChargeInfo = false.obs;

  final llAddStopPoint = false.obs;
  final llStopPoint = false.obs;

  final llNonRequestInfo = false.obs;
  final llRequestInfo = false.obs;

  final llNonSAddr = false.obs;
  final llSAddr = false.obs;

  final llNonEAddr = false.obs;
  final llEAddr = false.obs;

  final llNonCargoInfo = false.obs;
  final llCargoInfo = false.obs;

  final llNonChargeInfo = false.obs;
  final llChargeInfo = false.obs;

  final llRpaInfo = false.obs;


  final ChargeCheck = "".obs;
  final mBuyChargeDummy = "".obs;
  final mUnitPriceDummy = "".obs;
  final mSellChargeDummy = "".obs;
  final m24CallYn = "".obs;
  final mHwamullYn = "".obs;
  final mOnecallYn = "".obs;
  final mRpaSalary = "".obs;


  final mData = OrderModel().obs;

  final sCal = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0).obs;
  final eCal = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0).obs;

  final setSDate = "".obs;
  final setEDate = "".obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {

      llRpaInfo.value = false;
      if(widget.order_vo != null) {
        mData.value = widget.order_vo!;
        await copyData();
      }else{
        mData.value = OrderModel();
        await getOption();
      }

      if(widget.flag == "M") {
        setSDate.value = Util.splitSDate(mData.value.sDate);
        setEDate.value = Util.splitSDate(mData.value.eDate);
      }

    });
  }

  Widget calendar_st_en_widget() {
    return Container(
        padding: EdgeInsets.all(10.0.w),
        margin: EdgeInsets.only(bottom: 20.0.h),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: InkWell(
            onTap: () async {
              await goToRegDay();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "상차",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_01),
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
                        child: Text(
                          setSDate.value,
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_02),
                        ))
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "하차",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_01),
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
                        child: Text(
                          setEDate.value,
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_02),
                        ))
                  ],
                )
              ],
            )));
  }

  Future<void> setDate() async {

    if(widget.flag != "M") {
      sCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0);
      mData.value.sDate = Util.getAllDate(sCal.value);
      eCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0);
      mData.value.eDate = Util.getAllDate(eCal.value);
      setSDate.value = Util.splitSDate(mData.value.sDate);
      setEDate.value = Util.splitSDate(mData.value.eDate);
    }
  }

  Future<void> copySetDate() async {
    sCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0);
    String CopyStartCal = Util.getAllDate(sCal.value);
    DateTime mScal = DateTime.now();
    try {
      mScal = DateTime.parse(mData.value.sDate!);
    }catch(e) {
      e.printError();
    }
    // 출발 시간 비교
    if(mScal.isAfter(sCal.value)) {
      setSDate.value = Util.splitSDate(mData.value.sDate);
    }else{
      setSDate.value = Util.splitSDate(CopyStartCal);
      mData.value.sDate = CopyStartCal;
    }

    eCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0);
    String CopyEndCal = Util.getAllDate(eCal.value);
    DateTime mEcal = DateTime.now();
    try {
      mEcal = DateTime.parse(mData.value.eDate!);
    }catch(e) {
      e.printError();
    }
    // 도착 시간 비교
    if(mEcal.isAfter(eCal.value)) {
      setEDate.value = Util.splitSDate(mData.value.eDate);
    }else{
      setEDate.value = Util.splitSDate(CopyEndCal);
      mData.value.eDate = CopyEndCal;
    }

  }

  Future<void> goToRegDay() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderRegDayPage(order_vo:mData.value,sCal:sCal.value,eCal:eCal.value)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        switch(results[Const.RESULT_WORK]){
          case Const.RESULT_WORK_DAY:
            sCal.value = results["sCal"] as DateTime;
            eCal.value = results["eCal"] as DateTime;
            mData.value.sDate =  results["sDate"] as String;
            mData.value.eDate = results["eDate"] as String;
            setSDate.value = Util.splitSDate(mData.value.sDate);
            setEDate.value = Util.splitSDate(mData.value.eDate);
            break;
        }
      }
    }
  }

  Future<void> goToRequestInfo() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderRequestInfoPage(order_vo:mData.value,)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        setActivityResult(results);
      }
    }
  }

  Future<void> goToRecentOrder() async {
    if (isRequest.value) {
      Map<String, dynamic> results = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => RecentOrderPage(
                  custId: mData.value.sellCustId,
                  deptId: mData.value.sellDeptId)));

      if (results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          switch (results[Const.RESULT_WORK]) {
            case Const.RESULT_WORK_RECENT_ORDER:
              mData.value = results[Const.ORDER_VO];
              await copyData();
              break;
          }
        }
      }
    } else {
      Util.toast(Strings.of(context)?.get("order_reg_request_info_hint") ?? "Not Found");
    }
  }

  Future<void> setActivityResult(Map<String,dynamic> results)async {
    switch(results[Const.RESULT_WORK]) {
      case Const.RESULT_WORK_DAY :
        setState(() {
          sCal.value = results["sCal"] as DateTime;
          eCal.value = results["eCal"] as DateTime;
          mData.value.sDate =  results["sDate"] as String;
          mData.value.eDate = results["eDate"] as String;
          setSDate.value = Util.splitSDate(mData.value.sDate);
          setEDate.value = Util.splitSDate(mData.value.eDate);
        });
        break;
      case Const.RESULT_WORK_RECENT_ORDER :
        setState(() {
          mData.value = results[Const.ORDER_VO];
        });
        await copyData();
        break;
      case Const.RESULT_WORK_REQUEST :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          ChargeCheck.value = results[Const.UNIT_CHARGE_CNT];
          llNonRequestInfo.value = false;
          llRequestInfo.value = true;
          isRequest.value = true;
        });
        break;
      case Const.RESULT_WORK_SADDR :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        });
        if(isEAddr.value) {
          await goToCargoInfo();
        }else{
          await goToRegEAddr();
        }
        break;
      case Const.RESULT_WORK_EADDR :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        });
        if(isSAddr.value) {
          await goToCargoInfo();
        }else{
          await goToRegSAddr();
        }
        break;
      case Const.RESULT_WORK_STOP_POINT :
        setState(() {
          mData.value = results[Const.ORDER_VO];
        });
        await setStopPoint();
        break;
      case Const.RESULT_WORK_CARGO :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          llNonCargoInfo.value = false;
          llCargoInfo.value = true;
          isCargoInfo.value = true;
        });
        await goToChargeInfo();
        break;
      case Const.RESULT_WORK_CHARGE :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          m24CallYn.value = results[Const.RPA_24CALL_YN];
          mHwamullYn.value = results[Const.RPA_HWAMULL_YN];
          mOnecallYn.value = results[Const.RPA_ONECALL_YN];
          mRpaSalary.value = results[Const.RPA_SALARY];
          llNonChargeInfo.value = false;
          llChargeInfo.value = true;
          llRpaInfo.value = false;
          isChargeInfo.value = true;
        });
        break;
    }
  }

  Future<void> setStopPoint() async {
    if(mData.value.orderStopList?.isEmpty != true && !mData.value.orderStopList.isNull ){
      llAddStopPoint.value = false;
      llStopPoint.value = true;
    }else{
      llAddStopPoint.value = true;
      llStopPoint.value = false;
    }
  }

  Future<void> addStopPoint() async {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:mData.value,code:Const.RESULT_WORK_STOP_POINT)));

      if(results != null && results.containsKey("code")){
        if(results["code"] == 200) {
          print("addStopPoint() -> ${results[Const.RESULT_WORK]}");
          await setActivityResult(results);
        }
      }
  }

  Future<void> getStopPoint() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getStopPoint(
        user.authorization,
        mData.value.orderId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              List<StopPointModel> tempList = list.map((i) => StopPointModel.fromJSON(i)).toList();
              List<StopPointModel> realList = List.empty(growable: true);
              for (StopPointModel data in tempList) {
                // data.stopSeq = null; 2024.03.20 Kim DongJae 수정
                realList.add(data);
              }
              mData.value.orderStopList = realList;
              await setStopPoint();
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
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

  Future<void> goToStopPoint() async {
    //if(isRequest.value) {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => StopPointPage(order_vo:mData.value)));
      if(results != null && results.containsKey("code")){
        if(results["code"] == 200) {
          print("goToRegSAddr() -> ${results[Const.RESULT_WORK]}");
          await setActivityResult(results);
        }
        setState(() {});
      }
    //}else{
    //  Util.toast(Strings.of(context)?.get("order_reg_request_info_hint")??"Not Found");
    //}
  }

  Future<void> goToRegSAddr() async {
    //if(isRequest.value) {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:mData.value, code:Const.RESULT_WORK_SADDR)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegSAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }

    //}else{
    //  Util.toast(Strings.of(context)?.get("order_reg_request_info_hint")??"Not Found");
    //}
  }

  Future<void> goToRegEAddr() async {
    //if(isRequest.value) {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:mData.value,code:Const.RESULT_WORK_EADDR)));
      if(results != null && results.containsKey("code")){
        if(results["code"] == 200) {
          print("goToRegEAddr() -> ${results[Const.RESULT_WORK]}");
          await setActivityResult(results);
        }
      }
      //}else{
      //Util.toast(Strings.of(context)?.get("order_reg_request_info_hint")??"Not Found");
    //}
  }

  Future<void> goToCargoInfo() async {
    if(isSAddr.value && isEAddr.value) {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCargoInfoPage(order_vo:mData.value)));
      if(results["code"] == 200) {
        print("goToCargoInfo() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }else{
      Util.toast(Strings.of(context)?.get("order_reg_addr_hint")??"Not Found");
    }
  }

  Future<void> goToChargeInfo() async {
    if(isCargoInfo.value) {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderChargeInfoPage(order_vo:mData.value,flag:widget.flag, unit_charge_cnt:ChargeCheck.value,unit_buy_charge_local: mData.value.buyCharge??"0", unit_price_local: mUnitPriceDummy.value, unit_sell_charge_local: mSellChargeDummy.value)));
      if(results["code"] == 200) {
        print("goToChargeInfo() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }else{
      Util.toast(Strings.of(context)?.get("order_reg_cargo_info_hint")??"Not Found");
    }
  }

  Widget requestInfoWidget() {
    return Container(
        padding: EdgeInsets.all(10.0.h),
        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(20.0.h)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0.w)),
            color: Colors.white),
        child: InkWell(
            onTap: () async {
              if(widget.flag != "M") await goToRequestInfo();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Strings.of(context)?.get("order_reg_request_info") ??
                      "Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Text(
                  llRequestInfo.value ? "${mData.value.sellCustName} ${mData.value.sellDeptName}" : Strings.of(context)?.get("order_reg_request_info_hint") ?? "Not Found",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                )
              ],
            )));
  }

  Widget writeInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 화주 정보
        InkWell(
          onTap: () async {
            await goToRecentOrder();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0.h)),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0),topRight: Radius.circular(10.0)),
              color: line
            ),
            alignment: Alignment.center,
            child: Text(
              Strings.of(context)?.get("order_reg_recent_order")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_02),
            ),
          )
        ),
        // 상차지 정보 입력
        InkWell(
          onTap: () async {
            await goToRegSAddr();
          },
            child: Column(
                children: [
              Container(
                padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      color: main_btn,
                      margin: EdgeInsets.only(left: 5.w, right: 10.w),
                    ),
                    Text(
                        llSAddr.value ? "${mData.value.sComName}" : "상차지 정보 입력",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_01),
                    )
                  ],
                ),
              ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.h),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          color: Colors.white,
                          margin: EdgeInsets.only(left: 5.w, right: 10.w),
                        ),
                        Text(
                          llSAddr.value ? "${mData.value.sAddr}" : Strings.of(context)?.get("order_reg_s_addr_hint")??"Not Found",
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_03),
                        )
                      ],
                    ),
                  ),
            ])
        ),
        // 경유지 추가
        InkWell(
          onTap: () async {
            if(mData.value.orderStopList?.length == 0 || mData.value.orderStopList?.length == null) {
              await addStopPoint();
            }else{
              await goToStopPoint();
            }
          },
          child: Container(
            padding: EdgeInsets.only(top:10.h , bottom: 10.h,right: 10.w),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 5.w, right: 10.w),
                    ),
                    Text(
                      mData.value.orderStopList?.length == 0 || mData.value.orderStopList?.length == null ? "경유지 추가" : "경유지 ${mData.value.orderStopList?.length}곳",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_02),
                    ),
                  ],
                ),
                mData.value.orderStopList?.length == 0 || mData.value.orderStopList?.length == null ? Icon(Icons.add_circle_outline, size: 21.h, color: Colors.black): Icon(Icons.keyboard_arrow_right_outlined, size: 21.h, color: Colors.black)
              ],
            ),
          ),
        ),
        // 하차지 정보 입력
        InkWell(
            onTap: () async {
              await goToRegEAddr();
            },
            child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          color: main_btn,
                          margin: EdgeInsets.only(left: 5.w, right: 10.w),
                        ),
                        Text(
                          llEAddr.value ? "${mData.value.eComName}":"하차지 정보 입력",
                          style: CustomStyle.CustomFont(
                              styleFontSize14, text_color_01),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.h),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          color: Colors.white,
                          margin: EdgeInsets.only(left: 5.w, right: 10.w),
                        ),
                        Text(
                          llEAddr.value ? "${mData.value.eAddr}" : Strings.of(context)?.get("order_reg_e_addr_hint")??"Not Found",
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_03),
                        )
                      ],
                    ),
                  ),
                ])
        ),
        CustomStyle.getDivider1(),
        // 화물 정보
        InkWell(
          onTap: () async {
            await goToCargoInfo();
          },
          child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 5.w, right: 10.w),
                      ),
                      Text(
                        Strings.of(context)?.get("order_reg_cargo_info")??"Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize14, text_color_01),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 5.w, right: 10.w),
                      ),
                      llCargoInfo.value ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.start,
                            children: [
                              Text(
                                mData.value.goodsName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                                child: Text(
                                  mData.value.goodsWeight??"",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                ),
                              ),
                              Text(
                                mData.value.weightUnitCode??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                mData.value.carTonName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                child: Text(
                                  mData.value.carTypeName??"",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                )
                              )
                            ],
                          )
                        ],
                      ):
                      Text(
                        Strings.of(context)?.get("order_reg_cargo_info_hint")??"Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize12, text_color_03),
                      )
                    ],
                  ),
                ),
              ]),
        ),
        CustomStyle.getDivider1(),
        // 운임 정보
        InkWell(
          onTap: () async {
            await goToChargeInfo();
          },
          child: Row(children: [
            Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 5.w, right: 10.w),
                      ),
                      Text(
                        Strings.of(context)?.get("order_reg_charge_info")??"Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize14, text_color_01),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 5.w, right: 10.w),
                      ),
                      Text(
                        llChargeInfo.value ? "${Util.getInCodeCommaWon(mData.value.sellCharge)}원 / ${mData.value.chargeTypeName}":Strings.of(context)?.get("order_reg_charge_info_hint")??"Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize12, text_color_03),
                      )
                    ],
                  ),
                ),
              ])),
            llRpaInfo.value? Expanded(
              flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  child: Text(
                    Strings.of(context)?.get("order_reg_rpa_warning")??"Not Found",
                    style: CustomStyle.CustomFont(styleFontSize8, text_color_07),
                    textAlign: TextAlign.center,
                  )
                )
            ):const SizedBox()
          ])
        )
      ],
    );
  }

  Future<void> copyData() async {
    bool checkflag = false;
    if(widget.flag != "M") {
      if (!(mData.value.call24Cargo == "") && mData.value.call24Charge != null) {
        mData.value.call24Cargo = "N";
        checkflag = true;
      }

      if (!(mData.value.oneCargo == "") && mData.value.oneCargo != null) {
        mData.value.oneCargo = "N";
        checkflag = true;
      }

      if (!(mData.value.manCargo == "") && mData.value.manCargo != null) {
        mData.value.manCargo = "Y";
        checkflag = true;
      }
    }
    if(mData.value.stopCount != 0) {
      await getStopPoint();
    }

    llNonRequestInfo.value = false;
    llRequestInfo.value = true;

    llNonSAddr.value = false;
    llSAddr.value = true;

    llNonEAddr.value = false;
    llEAddr.value = true;

    llNonCargoInfo.value = false;
    llCargoInfo.value = true;

    llNonChargeInfo.value = false;
    llChargeInfo.value = true;

    isRequest.value = true;
    isSAddr.value = true;
    isEAddr.value = true;
    isCargoInfo.value = true;
    isChargeInfo.value = true;

    // Insert
    await getUnitChargeCnt();

    if(widget.flag != "M") await copySetDate();
    else {
      if(mData.value.sDate?.isNotEmpty == true || mData.value.sDate != null) {
        var ssDate = DateTime.parse(mData.value.sDate!);
        sCal.value = DateTime(ssDate.year, ssDate.month, ssDate.day, ssDate.hour, ssDate.minute);
      }else{
        sCal.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1, 0);
      }
      if(mData.value.eDate?.isNotEmpty == true || mData.value.eDate != null) {
        var eeDate = DateTime.parse(mData.value.eDate!);
        eCal.value = DateTime(eeDate.year, eeDate.month, eeDate.day, eeDate.hour, eeDate.minute);
      }else{
        eCal.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1, 0);
      }
      mData.value.sDate = Util.getAllDate(sCal.value);
      mData.value.eDate = Util.getAllDate(eCal.value);
    }

    if(checkflag) {
      llRpaInfo.value = true;
    }

  }

  Future<void> getUnitChargeCnt() async {
    if(mData.value.sellCustId == null || mData.value.sellDeptId == null || mData.value.sellCustId == "" || mData.value.sellDeptId == ""){
      return;
    }
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await DioService.dioClient(header: true).getTmsUnitCnt(
        user.authorization,
        user.custId,
        user.deptId,
        mData.value.sellCustId,
        mData.value.sellDeptId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getUnitChargeCnt() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
          if (_response.resultMap?["msg"] == "Y") {
            ChargeCheck.value = "Y";
          } else {
            ChargeCheck.value = "N";
          }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getUnitChargeCnt() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeCnt() getOrder Default => ");
          break;
      }
    });

  }

  Future<void> showRegOrder() async {
    openCommonConfirmBox(
            context,
            "오더를 등록하시겠습니까?",
            Strings.of(context)?.get("no") ?? "Error!!",
            Strings.of(context)?.get("yes") ?? "Error!!",
                () {Navigator.of(context).pop(false);},
                () async {
              Navigator.of(context).pop(false);
              await regOrder();
            }
        );
  }

  Future<void> showModiOrder() async {
    openCommonConfirmBox(
        context,
        "오더를 수정하시겠습니까?",
        Strings.of(context)?.get("no") ?? "Error!!",
        Strings.of(context)?.get("yes") ?? "Error!!",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await modOrder();
        }
    );
  }

  Future<void> regOrder() async {
    if(validation()) {
      Logger logger = Logger();
      await pr?.show();
      UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).orderReg(
          user.authorization,
          mData.value.sellCustName,
          mData.value.sellCustId,
          mData.value.sellDeptId,
          mData.value.sellStaff, mData.value.sellStaffTel, mData.value.reqAddr,
          mData.value.reqAddrDetail,user.custId,user.deptId,mData.value.inOutSctn,mData.value.truckTypeCode,
          mData.value.sComName,mData.value.sSido,mData.value.sGungu,mData.value.sDong,mData.value.sAddr,mData.value.sAddrDetail,
          mData.value.sDate,mData.value.sStaff,mData.value.sTel,mData.value.sMemo,mData.value.eComName,mData.value.eSido,
          mData.value.eGungu,mData.value.eDong,mData.value.eAddr,mData.value.eAddrDetail,mData.value.eDate,mData.value.eStaff,
          mData.value.eTel,mData.value.eMemo,mData.value.sLat,mData.value.sLon,mData.value.eLat,mData.value.eLon,
          mData.value.goodsName,double.parse(mData.value.goodsWeight??"0.0"),mData.value.weightUnitCode,mData.value.goodsQty,mData.value.qtyUnitCode,
          mData.value.sWayCode,mData.value.eWayCode,mData.value.mixYn,mData.value.mixSize,mData.value.returnYn,
          mData.value.carTonCode,mData.value.carTypeCode,mData.value.chargeType,mData.value.unitPriceType,int.parse(mData.value.unitPrice??"0"),mData.value.distance,mData.value.time,
          mData.value.reqMemo, mData.value.driverMemo,mData.value.itemCode,int.parse(mData.value.sellCharge??"0"),int.parse(mData.value.sellFee??"0"),
          mData.value.orderStopList != null && mData.value.orderStopList?.isNotEmpty == true ? jsonEncode(mData.value.orderStopList?.map((e) => e.toJson()).toList()):null,user.userId,user.mobile,
          mData.value.sellWayPointMemo,mData.value.sellWayPointCharge,mData.value.sellStayMemo,mData.value.sellStayCharge,
          mData.value.handWorkMemo,mData.value.sellHandWorkCharge,mData.value.sellRoundMemo,mData.value.sellRoundCharge,
          mData.value.sellOtherAddMemo,mData.value.sellOtherAddCharge,mData.value.sellWeight,"N",
          mData.value.call24Cargo,
          mData.value.manCargo,
          mData.value.oneCargo,
          mData.value.call24Charge,
          mData.value.manCharge,
          mData.value.oneCharge

      ).then((it) async {
        await pr?.hide();
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("regOrder() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["result"] == true) {

            /*var user = await controller.getUserInfo();

            await FirebaseAnalytics.instance.logEvent(
              name: Platform.isAndroid ? "regist_order_aos" : "regist_order_ios",
              parameters: {
                "user_id": user.userId,
                "user_custId" : user.custId,
                "user_deptId": user.deptId,
                "reqCustId" : mData.value.sellCustId,
                "sellDeptId" : mData.value.sellDeptId
              },
            );

            if(mData.value.call24Cargo == "Y" || mData.value.manCargo == "Y" || mData.value.oneCargo == "Y"){
              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid ? "regist_order_rpa_aos" : "regist_order_rpa_ios",
                parameters: {
                  "user_id": user.userId,
                  "user_custId" : user.custId,
                  "user_deptId": user.deptId,
                  "reqCustId" : mData.value.sellCustId,
                  "sellDeptId" : mData.value.sellDeptId,
                  "call24Cargo_Status" : mData.value.call24Cargo,
                  "manCargo_Status" : mData.value.manCargo,
                  "oneCharge_Status" : mData.value.oneCharge,
                  "rpaSalary" : mData.value.call24Charge,
                },
              );
            }*/

            Navigator.of(context).pop({'code':200,'allocId':_response.resultMap?["msg"]});
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
    }else{
      Util.toast(Strings.of(context)?.get("order_reg_hint")??"Not Found");
    }
  }

  Future<void> modOrder() async {
    if(validation()) {
      Logger logger = Logger();
      await pr?.show();
      UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).orderMod(
          user.authorization,
          mData.value.orderId,
          mData.value.sellCustName,
          mData.value.sellCustId,
          mData.value.sellDeptId,
          mData.value.sellStaff, mData.value.sellStaffTel, mData.value.reqAddr,
          mData.value.reqAddrDetail,user.custId,user.deptId,mData.value.inOutSctn,mData.value.truckTypeCode,
          mData.value.sComName,mData.value.sSido,mData.value.sGungu,mData.value.sDong,mData.value.sAddr,mData.value.sAddrDetail,
          mData.value.sDate,mData.value.sStaff,mData.value.sTel,mData.value.sMemo,mData.value.eComName,mData.value.eSido,
          mData.value.eGungu,mData.value.eDong,mData.value.eAddr,mData.value.eAddrDetail,mData.value.eDate,mData.value.eStaff,
          mData.value.eTel,mData.value.eMemo,mData.value.sLat,mData.value.sLon,mData.value.eLat,mData.value.eLon,
          mData.value.goodsName,double.parse(mData.value.goodsWeight??"0.0"),mData.value.weightUnitCode,mData.value.goodsQty,mData.value.qtyUnitCode,
          mData.value.sWayCode,mData.value.eWayCode,mData.value.mixYn,mData.value.mixSize,mData.value.returnYn,
          mData.value.carTonCode,mData.value.carTypeCode,mData.value.chargeType,mData.value.unitPriceType,int.parse(mData.value.unitPrice??"0"), mData.value.distance,mData.value.time,
          mData.value.reqMemo, mData.value.driverMemo,mData.value.itemCode,int.parse(mData.value.sellCharge??"0"),int.parse(mData.value.sellFee??"0"),
          mData.value.orderStopList != null && mData.value.orderStopList?.isNotEmpty == true ? jsonEncode(mData.value.orderStopList?.map((e) => e.toJson()).toList()):null,user.userId,user.mobile,
          mData.value.sellWayPointMemo,mData.value.sellWayPointCharge,mData.value.sellStayMemo,mData.value.sellStayCharge,
          mData.value.sellHandWorkMemo,mData.value.sellHandWorkCharge,mData.value.sellRoundMemo,mData.value.sellRoundCharge,
          mData.value.sellOtherAddMemo,mData.value.sellOtherAddCharge,mData.value.sellWeight,"N",
          mData.value.call24Cargo,
          mData.value.manCargo,
          mData.value.oneCargo,
          mData.value.call24Charge,
          mData.value.manCharge,
          mData.value.oneCharge

      ).then((it) async {
        await pr?.hide();
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("modOrder() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["result"] == true) {
            Navigator.of(context).pop({'code':200,'allocId':_response.resultMap?["msg"]});
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
            print("modOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("modOrder() getOrder Default => ");
            break;
        }
      });
    }else{
      Util.toast(Strings.of(context)?.get("order_reg_hint")??"Not Found");
    }
  }

  bool validation(){
    return isRequest.value && isSAddr.value && isEAddr.value && isCargoInfo.value && isChargeInfo.value;
  }

  Future<void> getOption() async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await DioService.dioClient(header: true).getOption(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOption() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            try {
              var list = _response.resultMap?["data"] as List;
              if(list != null && list.length > 0){
               OrderModel? order = OrderModel.fromJSON(list[0]);
               mData.value = order;
               mBuyChargeDummy.value = mData.value.buyCharge.toString();
               mUnitPriceDummy.value = mData.value.unitPrice.toString();
               mSellChargeDummy.value = mData.value.sellCharge.toString();
               await setOption();
               await getUnitChargeCnt();
              }else{
                mBuyChargeDummy.value = "0";
                mUnitPriceDummy.value = "0";
                mSellChargeDummy.value = "0";
                await setDate();
              }
            } catch (e) {
              print(e);
            }
          } else {
            mBuyChargeDummy.value = "0";
            mUnitPriceDummy.value = "0";
            mSellChargeDummy.value = "0";
            await setDate();
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
          print("getOption() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOption() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setOption() async {
    if(!(mData.value.sellCustId?.isEmpty == true)){
      llNonRequestInfo.value = false;
      llRequestInfo.value = true;
      isRequest.value = true;
    }
    if(!(mData.value.sComName?.isEmpty == true)) {
      llNonSAddr.value = false;
      llSAddr.value = true;
      isSAddr.value = true;
    }
    await setDate();
  }

  Future<bool?> showExit() async {
    var result = false;
    await openCommonConfirmBox(
        context,
        "현재 화면을 닫으시면 입력된 데이터가 모두 초기화 됩니다.\n정말 닫으시겠습니까?",
        Strings.of(context)?.get("no") ?? "Not Found",
        Strings.of(context)?.get("yes") ?? "Not Found",
            () {
            Navigator.of(context).pop(false);
            result = false;
          },
            () async {
          Navigator.of(context).pop(false);
          result = true;
        }
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          var result = await showExit();
          if(result == true) {
            Navigator.of(context).pop({'code':100});
            return true;
          }else{
            return false;
          }
        } ,
        child: Scaffold(
      backgroundColor: sub_color,
      appBar: AppBar(
            title: Text(
                widget.flag == "M" ? Strings.of(context)?.get("order_detail_order_modify")??"오더수정_" : Strings.of(context)?.get("order_reg_title")??"오더 등록_",
                style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
            ),
            toolbarHeight: 50.h,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () async {
                var result = await showExit();
                if(result == true) {
                  Navigator.of(context).pop({'code':100});
                }
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back, size: 24.h, color: styleWhiteCol),
            ),
          ),
      body: SafeArea(
          child: Obx((){
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      calendar_st_en_widget(),
                      requestInfoWidget(),
                      writeInfoWidget()
                    ],
                  )
              )
          );
        })
      ),
      bottomNavigationBar: SizedBox(
          height: CustomStyle.getHeight(60.0.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () async {
                        if(widget.flag == "M") {
                          await showModiOrder();
                        }else{
                          await showRegOrder();
                        }
                      },
                      child: Container(
                          height: CustomStyle.getHeight(60.0.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: main_color),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.flag == "M" ? Icon(Icons.edit, size: 20.h, color: styleWhiteCol): Icon(Icons.app_registration_rounded, size: 20.h, color: styleWhiteCol),
                                CustomStyle.sizedBoxWidth(5.0.w),
                                Text(
                                  textAlign: TextAlign.center,
                                  widget.flag == "M" ? Strings.of(context)?.get("edit_btn") ?? "수정하기_" : Strings.of(context)?.get("reg_btn") ?? "등록하기_",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, styleWhiteCol),
                                ),
                              ]
                          )
                      )
                  )
              ),
            ],
          )),
    )
    );
  }

}