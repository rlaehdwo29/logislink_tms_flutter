import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/rpa_flag_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_nomal_addr_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_select_addrInfo.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_select_cargoInfo.dart';
import 'package:logislink_tms_flutter/page/subpage/order_request_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';

enum Days {TODAY, TOMORROW, CUSTOM}

class RenewGeneralRegistOrderPage extends StatefulWidget {
  OrderModel? order_vo;
  String? flag; // R: 오더 등록, CR:오더 복사, M: 오더 수정

  RenewGeneralRegistOrderPage({Key? key, this.order_vo, this.flag}):super(key:key);

  @override
  _RenewGeneralRegistOrderPageState createState() => _RenewGeneralRegistOrderPageState();
}

class _RenewGeneralRegistOrderPageState extends State<RenewGeneralRegistOrderPage> {

  ProgressDialog? pr;
  final controller = Get.find<App>();
  final mData = OrderModel().obs;

  final isRequest = false.obs; // 화주 등록에 따른 Filter -> 상차, 하차지 설정
  final isSAddr = false.obs;
  final isEAddr = false.obs;

  final llAddStopPoint = false.obs;
  final llStopPoint = false.obs;

  final llNonRequestInfo = false.obs;
  final llRequestInfo = false.obs;

  final llNonSAddr = false.obs;
  final llSAddr = false.obs;

  final llNonEAddr = false.obs;
  final llEAddr = false.obs;

  final llNonChargeInfo = false.obs;
  final llChargeInfo = false.obs;

  final llRpaInfo = false.obs;

  final ChargeCheck = "".obs;

  final sCal = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0).obs;
  final eCal = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0).obs;

  final setSDate = "".obs;
  final setEDate = "".obs;

  final tvAddTotal = 0.obs;
  final mix_yn = false.obs;
  final return_yn = false.obs;
  final buyAmt = "0".obs;
  final insure_charge = "0".obs;
  final insure_total_charge = "0".obs;
  final startTimeChk = true.obs;
  final endTimeChk = true.obs;

  //RPA
  final mHwaMullFlag = false.obs; // 화물맨 LinkFlag 값 설정 시 안 꺼지기
  final mRpaSalary = "".obs;
  final llRpaSection = false.obs;
  final tv24Call = false.obs;
  final tvHwaMull = true.obs;
  final tvOneCall = true.obs;
  final tvRpaTotal = "".obs;

  static const String CHARGE_TYPE_01 = "01"; // 인수증
  static const String CHARGE_TYPE_02 = "02"; // 선/착불
  static const String CHARGE_TYPE_03 = "03"; // 차주발행
  static const String CHARGE_TYPE_04 = "04"; // 선불
  static const String CHARGE_TYPE_05 = "05"; // 착불

  //디폴트 적용단가 구분 코드 : 01(대당단가) / 02(톤당단가) / 03(KM단가) - 참고) TCODE.GCODE='UNIT_PRICE_TYPE'
  static const String UNIT_PRICE_TYPE_01 = "01";
  static const String UNIT_PRICE_TYPE_02 = "02";
  //static const String CHARGE_CAR_TYPE = "01";
  //static const String CHARGE_TON_TYPE = "02";

  final sWayList = List.empty(growable: true).obs;
  final eWayList = List.empty(growable: true).obs;
  final payTypeList = List.empty(growable: true).obs;
  final selectPayTypeModel = CodeModel(code: CHARGE_TYPE_01, codeName: "인수증").obs;
  final unitPriceList = List.empty(growable: true).obs;
  final selectUnitPriceModel = CodeModel(code: UNIT_PRICE_TYPE_01, codeName: "대당단가").obs;

  late TextEditingController cargoWGTController;
  late TextEditingController cargoQTYController;
  late TextEditingController cargoGoodsController;
  late TextEditingController unitPriceController;
  late TextEditingController sellChargeController;
  late TextEditingController sellFeeController;

  // 상/하차방법
  Days s_way = Days.TODAY;
  Days e_way = Days.TODAY;

  final isCargoExpanded = List.filled(1, false).obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarFormat _calendarWeekFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();

    cargoWGTController = TextEditingController();           // 화물중량 TextField
    cargoQTYController = TextEditingController();           // 화물수량 TextField
    cargoGoodsController = TextEditingController();         // 화물정보 TextField
    unitPriceController = TextEditingController();          // 톤당단가 TextField
    sellChargeController = TextEditingController();         // 총운임   TextField
    sellFeeController = TextEditingController();            // 수수료   TextField

    Future.delayed(Duration.zero, () async {

      llRpaInfo.value = false;
      if(widget.order_vo != null) {
        var order = widget.order_vo!;
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
            sTimeFreeYN: order.sTimeFreeYN,
            eTimeFreeYN: order.eTimeFreeYN,
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
            orderStopList: order.orderStopList??List.empty(growable: true),
            reqStaffName: order.reqStaffName,
            call24Cargo: order.call24Cargo,
            manCargo: order.manCargo,
            oneCargo: order.oneCargo,
            call24Charge: order.call24Charge,
            manCharge: order.manCharge,
            oneCharge: order.oneCharge
        );
        await copyData();
      }else{
        mData.value = OrderModel();
        await getOption();
      }
      if(mData.value.goodsWeight == "null") mData.value.goodsWeight = null;
      cargoWGTController.text = mData.value.goodsWeight??"0";
      cargoQTYController.text = mData.value.goodsQty??"0";
      if(mData.value.goodsName == null || mData.value.goodsName?.isEmpty == true || mData.value.goodsName == "null") mData.value.goodsName = ".";
      cargoGoodsController.text = mData.value.goodsName??"";
      unitPriceController.text = mData.value.unitPriceType == UNIT_PRICE_TYPE_02 ? Util.getInCodeCommaWon(mData.value.unitPrice??"0") : "0";
      if(mData.value.sellCharge != null && mData.value.sellCharge?.isEmpty == false) {
        if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
          mData.value.sellCharge = (int.parse(mData.value.sellCharge??" ") / 1000).toInt().toString();
        }else{
          mData.value.sellCharge = int.parse(mData.value.sellCharge??" ").toString();
        }
      }
      sellChargeController.text = Util.getInCodeCommaWon(mData.value.sellCharge??"0");
      sellFeeController.text = mData.value.sellFee == null || mData.value.sellFee?.isEmpty == true || mData.value.sellFee == "0" || mData.value.sellFee == "null" ? "0" : Util.getInCodeCommaWon(int.parse(mData.value.sellFee??"".trim().replaceAll(",", "")).toString());

      await getRpaLinkFlag();
      if(widget.flag == "M") {
        setSDate.value = Util.splitSDateType2(mData.value.sDate);
        setEDate.value = Util.splitEDateType2(mData.value.eDate);

        String? rpaSell = "0";
        if(widget.order_vo?.call24Cargo != "" && widget.order_vo?.call24Cargo != null && widget.order_vo?.call24Cargo != "D") {
          rpaSell = mData.value.call24Charge?.isEmpty == true || mData.value.call24Charge == null ? "0" : mData.value.call24Charge;
        }else if(widget.order_vo?.oneCargo != "" && widget.order_vo?.oneCargo != null && widget.order_vo?.oneCargo != "D") {
          rpaSell = mData.value.oneCharge?.isEmpty == true || mData.value.oneCharge == null ? "0" : mData.value.oneCharge;
        }else if(widget.order_vo?.manCargo != "" && widget.order_vo?.manCargo != null && widget.order_vo?.manCargo != "D") {
          rpaSell = mData.value.manCharge?.isEmpty == true || mData.value.manCharge == null ? "0" : mData.value.manCharge;
        }
        mRpaSalary.value = rpaSell!;
        mix_yn.value = mData.value.mixYn == "Y" ? true : false;
        return_yn.value = mData.value.returnYn == "Y" ? true : false;
      }
      await setTotalCharge();

      List<CodeModel>? mList = await SP.getCodeList(Const.WAY_TYPE_CD);
      sWayList.addAll(mList??List.empty(growable: true));
      eWayList.addAll(mList??List.empty(growable: true));
      payTypeList.add(CodeModel(code: CHARGE_TYPE_01,codeName: "인수증"));
      payTypeList.add(CodeModel(code: CHARGE_TYPE_04,codeName: "선불"));
      payTypeList.add(CodeModel(code: CHARGE_TYPE_05,codeName: "착불"));
      unitPriceList.add(CodeModel(code: UNIT_PRICE_TYPE_01,codeName: "대당단가"));
      unitPriceList.add(CodeModel(code: UNIT_PRICE_TYPE_02,codeName: "톤당단가"));

      if(mData.value.inOutSctn?.isEmpty == true || mData.value.inOutSctn.isNull == true) {
        await setCargoDefault();
      }
      mData.value.inOutSctnName = SP.getCodeName(Const.IN_OUT_SCTN, mData.value.inOutSctn??"");
      mData.value.truckTypeName = SP.getCodeName(Const.TRUCK_TYPE_CD, mData.value.truckTypeCode??"");
      mData.value.carTypeName = SP.getCodeName(Const.CAR_TYPE_CD, mData.value.carTypeCode??"");
      mData.value.carTonName = SP.getCodeName(Const.CAR_TON_CD, mData.value.carTonCode??"");
      mData.value.itemName = SP.getCodeName(Const.ITEM_CD, mData.value.itemCode??"");
      mData.value.sWayName = SP.getCodeName(Const.WAY_TYPE_CD, mData.value.sWayCode??"");
      mData.value.eWayName = SP.getCodeName(Const.WAY_TYPE_CD, mData.value.eWayCode??"");
      mData.value.weightUnitCode = "TON";

        if (mData.value.chargeType == null || mData.value.chargeType?.isEmpty == true) {
          mData.value.chargeType = CHARGE_TYPE_01;
          mData.value.chargeTypeName = "인수증";
        }

      if (mData.value.unitPriceType == "01") {
        mData.value.unitPriceType = UNIT_PRICE_TYPE_01;
        mData.value.unitPriceTypeName = "대당단가";
        mData.value.sellFee = "0";
      } else if (mData.value.unitPriceType == "02") {
        mData.value.unitPriceType = UNIT_PRICE_TYPE_02;
        mData.value.unitPriceTypeName = "톤당단가";
      } else {
        mData.value.unitPriceType = UNIT_PRICE_TYPE_01;
        mData.value.unitPriceTypeName = "대당단가";
      }

    });
  }

  @override
  void dispose() {
    super.dispose();
    cargoWGTController.dispose();
    cargoQTYController.dispose();
    cargoGoodsController.dispose();
    unitPriceController.dispose();
    sellChargeController.dispose();
    sellFeeController.dispose();
  }

  /**
   * Start Widget
   */

  Widget cargoWidget(){
    return Container(
        color: main_color,
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
        child: Row(
            children: [
            Expanded(
            flex: 1,
            child: Text(
              "화주\n정보",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
            )
        ),
        Expanded(
        flex: 8,
        child: Flex(
        direction: Axis.vertical,
        children: List.generate(1, (index) {
          return ExpansionPanelList.radio(
            animationDuration: const Duration(milliseconds: 500),
            expandedHeaderPadding: EdgeInsets.zero,
            elevation: 1,
            expandIconColor: light_gray22,
              children: [
                ExpansionPanelRadio(
                  value: index,
                  backgroundColor: main_color,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: () async {
                                        if(widget.flag != "M") await goToRequestPage();
                                      },
                                    child: Container(
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), right: CustomStyle.getWidth(3)),
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(5)),
                                        color: Colors.white,
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              text: mData.value.sellCustId == null || mData.value.sellCustId?.isEmpty == true ? "거래처명" : mData.value.sellCustName??"",
                                              style: CustomStyle.CustomFont(styleFontSize16, mData.value.sellCustId == null || mData.value.sellCustId?.isEmpty == true ? styleGreyCol1 : Colors.black, font_weight: mData.value.sellCustId == null || mData.value.sellCustId?.isEmpty == true ? FontWeight.w600 : FontWeight.w800),
                                            )
                                        )
                                    ),
                                  )
                              ),
                              Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () async {
                                      if(widget.flag != "M") await goToRequestPage();
                                      },
                                    child: Container(
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(5)),
                                        color: Colors.white,
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              text: mData.value.sellDeptId == null || mData.value.sellDeptId?.isEmpty == true ? "담당부서" : mData.value.sellDeptName??"",
                                              style: CustomStyle.CustomFont(styleFontSize16, mData.value.sellDeptId == null || mData.value.sellDeptId?.isEmpty == true ? styleGreyCol1 : Colors.black, font_weight: mData.value.sellDeptId == null || mData.value.sellDeptId?.isEmpty == true ? FontWeight.w600 : FontWeight.w800),
                                            )
                                        )
                                    ),
                                  )
                              )
                            ],
                        );
                  },
                  body: Obx((){
                    return Container(
                        margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                        child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () async {
                                      if(widget.flag != "M") await goToRequestPage();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), right: CustomStyle.getWidth(3)),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                      color: Colors.white,
                                      child: Text(
                                        mData.value.sellStaff == null || mData.value.sellStaffName?.isEmpty == true ? "담당자" : mData.value.sellStaffName??"",
                                        style: CustomStyle.CustomFont(styleFontSize14, mData.value.sellStaff == null || mData.value.sellStaffName?.isEmpty == true ? styleGreyCol1 : Colors.black, font_weight: mData.value.sellStaff == null || mData.value.sellStaffName?.isEmpty == true ? FontWeight.w600 : FontWeight.w800),
                                      ),
                                    )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () async {
                                      if(widget.flag != "M") await goToRequestPage();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                      color: Colors.white,
                                      child: Text(
                                        mData.value.sellStaffTel == null || mData.value.sellStaffTel?.isEmpty == true ? "연락처" : Util.makeHyphenPhoneNumber(mData.value.sellStaffTel??""),
                                        style: CustomStyle.CustomFont(styleFontSize14, mData.value.sellStaffTel == null || mData.value.sellStaffTel?.isEmpty == true ? styleGreyCol1 : Colors.black, font_weight: mData.value.sellStaffTel == null || mData.value.sellStaffTel?.isEmpty == true ? FontWeight.w600 : FontWeight.w800 ),
                                      ),
                                    )
                                )
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                          width: double.infinity,
                          color: Colors.white,
                          child: Text(
                            mData.value.reqMemo == null || mData.value.reqMemo?.isEmpty == true ? "요청사항" : mData.value.reqMemo??"",
                            style: CustomStyle.CustomFont(styleFontSize14, mData.value.reqMemo == null || mData.value.reqMemo?.isEmpty == true ? styleGreyCol1 : Colors.black, font_weight: mData.value.reqMemo == null || mData.value.reqMemo?.isEmpty == true ? FontWeight.w600 : FontWeight.w800),
                          ),
                        ),

                      ],
                    ));
                  }),
                  canTapOnHeader: true,
                )
              ],
            expansionCallback: (int _index, bool status) {
              isCargoExpanded[index] = !isCargoExpanded[index];
              //for (int i = 0; i < isExpanded.length; i++)
              //  if (i != index) isExpanded[i] = false;
            },
          );
        }
        ),
      ))
    ])
    );
  }

  Widget startWidget(){
    return Container(
        color: renew_main_color2,
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  "상\n차\n지",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                )
            ),
            Expanded(
                flex: 8,
                child: Container(
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: (){
                                    goToNomalAddr(Const.RESULT_WORK_SADDR);
                                  },
                                    child: Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), right: CustomStyle.getWidth(3)),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                    color: Colors.white,
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                        text:llSAddr.value ? mData.value.sComName == null ? "${mData.value.sAddr??""} ${mData.value.sAddrDetail??""}" : "${mData.value.sComName??""}(${mData.value.sAddr??""})" : Strings.of(context)?.get("order_reg_s_addr_hint")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize14, llSAddr.value ? Colors.black : styleGreyCol1, font_weight: FontWeight.w800),
                                      )
                                    ),
                                  )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: (){
                                    goToRegSAddr();
                                  },
                                    child: Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: light_gray22,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: Colors.black,
                                          size: 18.h,
                                        ),
                                        Text(
                                          "주소록",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                        ),
                                      ],
                                    )
                                  )
                                )
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                          title: Text(
                                              "당일",
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                                          ),
                                          dense: true,
                                          horizontalTitleGap:0,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                              value: Days.TODAY,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              groupValue: s_way,
                                              fillColor: MaterialStateProperty.resolveWith((states) {
                                                if (states.contains(MaterialState.selected)) {
                                                  return Colors.black;
                                                }
                                                  return Colors.grey;
                                                }
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  s_way = value!;
                                                  sCal.value = DateTime(DateTime.now().year,DateTime.now().month,s_way == Days.TODAY ? DateTime.now().day : s_way == Days.TOMORROW ? DateTime.now().day : sCal.value.day, startTimeChk.value ? 0 : DateTime.now().hour+1, startTimeChk.value ? 0 : 0);
                                                  mData.value.sDate = Util.getAllDate(sCal.value);
                                                  setSDate.value = Util.splitEDateType2(mData.value.sDate);

                                                  int e_Way_days = DateTime(eCal.value.year,eCal.value.month,eCal.value.day,0,0,0).difference(DateTime(sCal.value.year, sCal.value.month, sCal.value.day,0,0,0)).inDays;
                                                  if(e_Way_days == 0) {
                                                    e_way = Days.TODAY;
                                                  }else if(e_Way_days == 1) {
                                                    e_way = Days.TOMORROW;
                                                  }else{
                                                    e_way = Days.CUSTOM;
                                                  }
                                                });
                                            }
                                        )
                                      )
                                    ),
                                    Expanded(
                                    child: ListTile(
                                        title: Text(
                                            "내일",
                                          style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                                        ),
                                        dense: true,
                                        horizontalTitleGap:0,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Radio(
                                          value: Days.TOMORROW,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          groupValue: s_way,
                                          fillColor: MaterialStateProperty.resolveWith((states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.black;
                                            }
                                              return Colors.grey;
                                            }
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              s_way = value!;
                                              sCal.value = DateTime(DateTime.now().year,DateTime.now().month,s_way == Days.TODAY ? DateTime.now().day : s_way == Days.TOMORROW ? DateTime.now().day+1 : sCal.value.day, startTimeChk.value ? 0 : DateTime.now().hour+1, startTimeChk.value ? 0 : 0);
                                              mData.value.sDate = Util.getAllDate(sCal.value);
                                              setSDate.value = Util.splitEDateType2(mData.value.sDate);
                                              if(eCal.value.isBefore(sCal.value)) {
                                                eCal.value = DateTime(sCal.value.year,sCal.value.month,sCal.value.day,endTimeChk.value ? 23 : DateTime.now().hour+1, endTimeChk.value ? 59 : 0);
                                                mData.value.eDate = Util.getAllDate(eCal.value);
                                                setEDate.value = Util.splitEDateType2(mData.value.eDate);
                                              }
                                            });
                                          }
                                      )
                                    )),
                                  ],
                              ),
                            ),
                            Expanded(
                                flex: 4,
                                child: Row(
                                    children: [
                                      Expanded(
                                          flex: 5,
                                          child: InkWell(
                                            onTap: (){
                                              setState(() {
                                                openDateSheet(context,"S");
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                              color: Colors.white,
                                              child: Text(
                                                setSDate.value,textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                                              ),
                                            ),
                                          )
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Checkbox(
                                                value: startTimeChk.value,
                                                checkColor: Colors.pink,
                                                activeColor: Colors.white,
                                                visualDensity: const VisualDensity(
                                                  horizontal: VisualDensity.minimumDensity,
                                                  vertical: VisualDensity.minimumDensity,
                                                ),
                                                side: const BorderSide(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                onChanged: (value) {
                                                    startTimeChk.value = value!;
                                                    sCal.value = DateTime(sCal.value.year, sCal.value.month, sCal.value.day, startTimeChk.value ? 0 : DateTime.now().hour+1,0);
                                                    mData.value.sDate = Util.getAllDate(sCal.value);
                                                    setSDate.value = Util.splitSDateType2(mData.value.sDate);
                                                    setState(() {});
                                                },
                                              ),
                                              Text(
                                                "시간\n무관",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white, font_weight: FontWeight.w800),
                                              )
                                            ],
                                          )
                                      )
                                    ]
                                )
                            )
                          ],
                        )
                      ],
                    )
                )
            )
          ],
        )
    );
  }

  Widget wayPointWidget(){
    return InkWell(
      onTap: (){
        goToStopAddr();
      },
        child: Container(
          color: sub_btn,
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    "경\n유\n지",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                  )
              ),
              Expanded(
                  flex: 8,
                  child: Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                            color: Colors.white,
                            child: Text(
                              mData.value.orderStopList != null && mData.value.orderStopList!.length > 0 ? "경유지 ${mData.value.orderStopList!.length}곳": "경유지를 선택해주세요.",
                              style: CustomStyle.CustomFont(styleFontSize14, mData.value.orderStopList != null && mData.value.orderStopList!.length > 0 ? Colors.black : styleGreyCol1,font_weight: FontWeight.w800),
                            ),
                          ),
                        ],
                      )
                  )
              )
            ],
          )
      )
    );
  }

  Widget endWidget(){
    return Container(
        color: rpa_btn_cancle,
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  "하\n차\n지",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                )
            ),
            Expanded(
                flex: 8,
                child: Container(
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: (){
                                    goToNomalAddr(Const.RESULT_WORK_EADDR);
                                  },
                                    child: Container(
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), right: CustomStyle.getWidth(3)),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                      color: Colors.white,
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          text:llEAddr.value ? mData.value.eComName == null ? "${mData.value.eAddr??""} ${mData.value.eAddrDetail??""}" : "${mData.value.eComName??""}(${mData.value.eAddr??""})" : Strings.of(context)?.get("order_reg_e_addr_hint")??"Not Found",
                                        style: CustomStyle.CustomFont(styleFontSize14, llEAddr.value ? Colors.black : styleGreyCol1,font_weight: FontWeight.w800),
                                        )
                                      ),
                                  )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: (){
                                    goToRegEAddr();
                                  },
                                    child: Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: light_gray22,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: Colors.black,
                                          size: 18.h,
                                        ),
                                        Text(
                                          "주소록",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                        ),
                                      ],
                                    )
                                ))
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: ListTile(
                                          title: Text(
                                            "당착",
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                                          ),
                                          dense: true,
                                          horizontalTitleGap:0,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                              value: Days.TODAY,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              groupValue: e_way,
                                              fillColor: MaterialStateProperty.resolveWith((states) {
                                                if (states.contains(MaterialState.selected)) {
                                                  return Colors.black;
                                                }
                                                return Colors.grey;
                                              }
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  e_way = value!;
                                                  eCal.value = DateTime(eCal.value.year,eCal.value.month,e_way == Days.TODAY ? sCal.value.day : e_way == Days.TOMORROW ? eCal.value.day : eCal.value.day, endTimeChk.value ? 23 : DateTime.now().hour+1, endTimeChk.value ? 59 : 0);
                                                  mData.value.eDate = Util.getAllDate(eCal.value);
                                                  setEDate.value = Util.splitEDateType2(mData.value.eDate);

                                                });
                                              }
                                          )
                                      )
                                  ),
                                  Expanded(
                                      child: ListTile(
                                          title: Text(
                                            "익착",
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                                          ),
                                          dense: true,
                                          horizontalTitleGap:0,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                              value: Days.TOMORROW,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              groupValue: e_way,
                                              fillColor: MaterialStateProperty.resolveWith((states) {
                                                if (states.contains(MaterialState.selected)) {
                                                  return Colors.black;
                                                }
                                                return Colors.grey;
                                              }
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  e_way = value!;
                                                  eCal.value = DateTime(eCal.value.year,eCal.value.month,e_way == Days.TODAY ? eCal.value.day : e_way == Days.TOMORROW ? eCal.value.day+1 : eCal.value.day, endTimeChk.value ? 23 : DateTime.now().hour+1, endTimeChk.value ? 59 : 0);
                                                  mData.value.eDate = Util.getAllDate(eCal.value);
                                                  setEDate.value = Util.splitEDateType2(mData.value.eDate);
                                                });
                                              }
                                          )
                                      )
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: InkWell(
                                      onTap: (){
                                        setState(() {
                                          e_way = Days.CUSTOM;
                                          openDateSheet(context,"E");
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5), bottom: CustomStyle.getHeight(5), left: CustomStyle.getWidth(3)),
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(5)),
                                        color: Colors.white,
                                        child: Text(
                                          setEDate.value,textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                                        ),
                                      ),
                                    )
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: endTimeChk.value,
                                          checkColor: Colors.pink,
                                          activeColor: Colors.white,
                                          visualDensity: const VisualDensity(
                                            horizontal: VisualDensity.minimumDensity,
                                            vertical: VisualDensity.minimumDensity,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          onChanged: (value) {
                                            if(endTimeChk.value == true) {
                                              setEDate.value = Util.splitEDateType2(mData.value.eDate);
                                            }
                                              endTimeChk.value = value!;
                                              eCal.value = DateTime(eCal.value.year, eCal.value.month, eCal.value.day, endTimeChk.value ? 23 : DateTime.now().hour+1,endTimeChk.value ? 59 : 0);
                                              mData.value.eDate = Util.getAllDate(eCal.value);
                                              setEDate.value = Util.splitSDateType2(mData.value.eDate);
                                            setState(() {});
                                          },
                                        ),
                                        Text(
                                          "시간\n무관",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white, font_weight: FontWeight.w800),
                                        )
                                      ],
                                    )
                                  )
                                ]
                              )
                            )
                          ],
                        )
                      ],
                    )
                )
            )
          ],
        )
    );
  }

  Widget bodyWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          // 차종, 톤 Select Page
          InkWell(
              onTap: () {
                goToSelectCarInfo(
                    CodeModel(
                        code: mData.value.carTypeCode,
                        codeName: mData.value.carTypeName),
                    CodeModel(
                        code: mData.value.carTonCode,
                        codeName: mData.value.carTonName));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xff1AB2D4), width: 1)
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                                  mData.value.carTypeCode == null || mData.value.carTypeCode?.isEmpty == true ? "차종" : mData.value.carTypeName??"" ?? "${mData.value.carTypeCode??""}",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800),
                                )
                    ),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () {
                              goToSelectCarInfo(
                                  CodeModel(
                                      code: mData.value.carTypeCode,
                                      codeName: mData.value.carTypeName),
                                  CodeModel(
                                      code: mData.value.carTonCode,
                                      codeName: mData.value.carTonName));
                            },
                            child: Text(
                                  mData.value.carTonCode == null || mData.value.carTonCode?.isEmpty == true ? "톤" : mData.value.carTonName ?? "",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800),
                                )
                        )
                    )
                  ]
                )
              )
          ),
            // 상차방법, 하차방법 DropDown
          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7)),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xff1AB2D4), width: 1)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                                  child: DropdownButton<CodeModel>(
                                    alignment: Alignment.center,
                                    isDense: true,
                                    items: sWayList.map((data) {
                                      return DropdownMenuItem<CodeModel>(
                                        value: data,
                                        child: Text(
                                          data.codeName,
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight:FontWeight.w800),
                                        ),
                                      );
                                    }).toList(),
                                    value: sWayList?.firstWhere(
                                          (element) => element.code == mData.value.sWayCode,
                                      orElse: () => null,
                                    ),
                                    onChanged: (CodeModel? value) {
                                      setState(() {
                                        if(value != null) {
                                          mData.value.sWayCode = value.code;
                                          mData.value.sWayName = value.codeName;
                                        }
                                      });
                                    },
                                    underline: const SizedBox(),
                                  )
                              )
                        ),
                        Expanded(
                            flex: 1,
                            child: Center(
                                    child: DropdownButton<CodeModel>(
                                      alignment: Alignment.center,
                                      isDense: true,
                                      items: eWayList.map((data) {
                                        return DropdownMenuItem<CodeModel>(
                                          value: data,
                                          child: Text(
                                            data.codeName,
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight:FontWeight.w800),
                                          ),
                                        );
                                      }).toList(),
                                      value: eWayList?.firstWhere(
                                            (element) => element.code == mData.value.eWayCode,
                                        orElse: () => null,
                                      ),
                                      onChanged: (CodeModel? value) {
                                        setState(() {
                                          if(value != null) {
                                            mData.value.eWayCode = value.code;
                                            mData.value.eWayName = value.codeName;
                                          }
                                        });
                                      },
                                      underline: const SizedBox(),
                                    )
                                )
                        )
                      ],
                    )
                ),
              ],
            ),
          ),
          // 지불방식, 단가타입 DropDown
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7)),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xff1AB2D4), width: 1)
                                ),
                                child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        DropdownButton<CodeModel>(
                                          alignment: Alignment.center,
                                          isDense: true,
                                          items: payTypeList.map((data) {
                                            return DropdownMenuItem<CodeModel>(
                                              value: data,
                                              child: Text(
                                                data.codeName,
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                                              ),
                                            );
                                          }).toList(),
                                          value: payTypeList?.firstWhere(
                                                (element) => element.code == mData.value.chargeType,
                                            orElse: () => null,
                                          ),
                                          onChanged: (CodeModel? value) {
                                            setState(() {
                                              if(value != null) {
                                                mData.value.chargeType = value.code;
                                                mData.value.chargeTypeName = value.codeName;
                                                if(mData.value.chargeType == CHARGE_TYPE_01) {
                                                  sellFeeController.text = "0";
                                                  mData.value.sellFee = "0";
                                                  setTotalCharge();
                                                }
                                              }
                                            });
                                          },
                                          underline: const SizedBox(),
                                        ),
                                        // 톤당단가 / 대당단가
                                        DropdownButton<CodeModel>(
                                          alignment: Alignment.center,
                                          isDense: true,
                                          items: unitPriceList.map((data) {
                                            return DropdownMenuItem<CodeModel>(
                                              value: data,
                                              child: Text(
                                                data.codeName,
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                                              ),
                                            );
                                          }).toList(),
                                          value: unitPriceList?.firstWhere(
                                                (element) => element.code == mData.value.unitPriceType,
                                            orElse: () => null,
                                          ),
                                          onChanged: (CodeModel? value) {
                                            setState(() {
                                              if(value != null) {
                                                mData.value.unitPriceType = value.code;
                                                mData.value.unitPriceTypeName = value.codeName;
                                                if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
                                                  mData.value.unitPrice = "0";
                                                  unitPriceController.text = "0";
                                                  mData.value.sellCharge = "0";
                                                  sellChargeController.text = "0";
                                                }else{
                                                  mData.value.unitPrice = "0";
                                                  unitPriceController.text = "0";
                                                  mData.value.sellCharge = "0";
                                                  sellChargeController.text = "0";
                                                }
                                              }
                                              setTotalCharge();
                                            });
                                          },
                                          underline: const SizedBox(),
                                        )
                                      ],
                                    )
                                )
                            )
                        )
                      ],
                    )
                ),
                Expanded(
                  flex: 4,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: mix_yn.value,
                              checkColor: Colors.white,
                              activeColor: Colors.pink,
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              side: const BorderSide(
                                color: Colors.pink,
                                width: 2,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  mix_yn.value = value!;
                                  mData.value.mixYn = mix_yn.value ? "Y":"N";
                                });
                              },
                            ),
                            Text(
                              "혼적",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w800),
                            )
                          ],
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: return_yn.value,
                              checkColor: Colors.white,
                              activeColor: Colors.pink,
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              side: const BorderSide(
                                color: Colors.pink,
                                width: 2,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  return_yn.value = value!;
                                  mData.value.returnYn = return_yn.value ? "Y" : "N";
                                });
                              },
                            ),
                            Text(
                              "왕복",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w800),
                            )
                          ],
                        )
                    ),
                  ],
                ))
              ],
            ),
          ),
          // 화물중량, 화물수량
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    flex: 6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                              height: CustomStyle.getHeight(50),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                              child: TextField(
                                style: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                                textAlign: TextAlign.right,
                                inputFormatters: [DecimalInputFormatter()],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onTap: (){
                                  cargoWGTController.selection = TextSelection.fromPosition(TextPosition(offset: cargoWGTController.text.length));
                                },
                                controller: cargoWGTController,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixStyle: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                                  suffixText: "TON",
                                  prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                                  prefixText: "화물중량",
                                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                    borderRadius: BorderRadius.all(Radius.zero),
                                  ),
                                  disabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                      borderRadius: BorderRadius.all(Radius.zero)
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                      borderRadius: BorderRadius.all(Radius.zero)
                                  ),
                                ),
                                onChanged: (value) async {
                                  if(value.isEmpty) {
                                    cargoWGTController.text = "0";
                                  }else{
                                    if (value.startsWith("0") && value.length > 1 && !value.startsWith("0.")) {
                                      cargoWGTController.text = value.replaceFirst(RegExp(r'^0+'), '');
                                    }
                                  }
                                  cargoWGTController.selection = TextSelection.fromPosition(TextPosition(offset: cargoWGTController.text.length));
                                  mData.value.goodsWeight = cargoWGTController.text;

                                  if(mData.value.unitPriceType == UNIT_PRICE_TYPE_02) {
                                    double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
                                    sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
                                    mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
                                    setTotalCharge();
                                  }
                                },
                                maxLength: 5,
                              )
                          )
                        ),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: (){
                                  if(mData.value.carTonCode == null || mData.value.carTonCode?.isEmpty == true) {
                                    Util.toast("차량 톤수를 선택해주세요.");
                                  }else{
                                    var numberString = mData.value.carTonName?.replaceAll(new RegExp(r'[^0-9.]'),'');
                                    var numberParse = double.parse(numberString!);
                                    var maxWeight = numberParse + (numberParse*0.1);
                                    cargoWGTController.text = maxWeight.toString();
                                    mData.value.goodsWeight = cargoWGTController.text;

                                    if(mData.value.unitPriceType == UNIT_PRICE_TYPE_02) {
                                      double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
                                      sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
                                      mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
                                      setTotalCharge();
                                    }

                                  }
                                },
                                child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(right: CustomStyle.getWidth(2)),
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                color: rpa_btn_modify,
                                child: Text(
                                  "최대",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white, font_weight: FontWeight.w800),
                                )
                            )
                          )
                        )
                      ],
                    )
                ),
                Expanded(
                    flex: 4,
                    child:  Container(
                        height: CustomStyle.getHeight(50),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                          textAlign: TextAlign.right,
                          inputFormatters: [DecimalInputFormatter()],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: cargoQTYController,
                          onTap: (){
                            cargoQTYController.selection = TextSelection.fromPosition(TextPosition(offset: cargoQTYController.text.length));
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            suffixText: "개",
                            suffixStyle: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                            prefixText: "화물수량",
                            prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                              borderRadius: BorderRadius.all(Radius.zero),
                            ),
                            disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                borderRadius: BorderRadius.all(Radius.zero)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                borderRadius: BorderRadius.all(Radius.zero)
                            ),
                          ),
                          onChanged: (value) async {
                            if(value.isEmpty) {
                              cargoQTYController.text = "0";
                            }else{
                              cargoQTYController.text = value.replaceFirst(RegExp(r'^0+'), '');
                            }
                            cargoQTYController.selection = TextSelection.fromPosition(TextPosition(offset: cargoQTYController.text.length));
                            mData.value.goodsQty = cargoQTYController.text;
                          },
                          maxLength: 5,
                        )
                    )
                ),
              ],
            ),
          ),
          // 화물정보
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    width: double.infinity,
                    height: CustomStyle.getHeight(50),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.text,
                      controller: cargoGoodsController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                        prefixText: "화물정보 ",
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                        disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                            borderRadius: BorderRadius.all(Radius.zero)
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                            borderRadius: BorderRadius.all(Radius.zero)
                        ),
                      ),
                      onChanged: (value) async {
                        mData.value.goodsName = value;
                      },
                      maxLength: 200,
                    )
                )
              ),
            ],
          ),
          // 톤당단가 / 대당단가
          mData.value.unitPriceType == UNIT_PRICE_TYPE_02 ?
          SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                          height: CustomStyle.getHeight(50),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(2)),
                          child: TextField(
                            style: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            controller: unitPriceController,
                            onTap: (){
                              unitPriceController.selection = TextSelection.fromPosition(TextPosition(offset: unitPriceController.text.length));
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              suffixText: "원",
                              suffixStyle: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                              prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                              prefixText: "톤당단가",
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                borderRadius: BorderRadius.all(Radius.zero),
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                  borderRadius: BorderRadius.all(Radius.zero)
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                  borderRadius: BorderRadius.all(Radius.zero)
                              ),
                            ),
                            onChanged: (value) async {
                              if(value.isEmpty) {
                                unitPriceController.text = "0";
                                mData.value.unitPrice = "0";
                              }else{
                                unitPriceController.text = Util.getInCodeCommaWon(int.parse(value.replaceAll(',','')).toString());
                                mData.value.unitPrice = value.replaceAll(',','');
                                double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
                                sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
                                mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
                              }

                              unitPriceController.selection = TextSelection.fromPosition(TextPosition(offset: unitPriceController.text.length));

                              setState(() {
                                setTotalCharge();
                              });
                            },
                            maxLength: 200,
                          )
                      )
                  ),
                  Expanded(
                      flex: 2,
                      child:Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                  height: CustomStyle.getHeight(40),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(2)),
                                  decoration: const BoxDecoration(
                                      color: rpa_btn_cancle,
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: InkWell(
                                      onTap:(){
                                        unitPriceController.text = unitPriceController.text == "" || unitPriceController.text == " " ? "5" : Util.getInCodeCommaWon((int.parse(unitPriceController.text.replaceAll(',','')) + 5000).toString());
                                        mData.value.unitPrice = unitPriceController.text.length > 0 ? unitPriceController.text.replaceAll(',', '') : "0";

                                        double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
                                        sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
                                        mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
                                        setTotalCharge();
                                      },
                                      child: Text(
                                        "+ 5천원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w800),
                                      )
                                  )
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  height: CustomStyle.getHeight(40),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(2)),
                                  decoration: const BoxDecoration(
                                      color: renew_main_color2,
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: InkWell(
                                      onTap:(){
                                        unitPriceController.text = unitPriceController.text == "" || unitPriceController.text == " " || int.parse(unitPriceController.text.replaceAll(',','')) <= 0 ? " " : Util.getInCodeCommaWon((int.parse(unitPriceController.text.replaceAll(',','')) - 5000).toString());
                                        mData.value.unitPrice = unitPriceController.text.length > 0 ? unitPriceController.text.replaceAll(',','') : "0";

                                        double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
                                        sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
                                        mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
                                        setTotalCharge();
                                      },
                                      child: Text(
                                        "- 5천원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w800),
                                      )
                                  )
                              )
                          )
                        ],
                      )
                  ),
                ],
              )
          ) : const SizedBox(),
          // 총운임
          SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                      child: Container(
                          height: CustomStyle.getHeight(50),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: TextField(
                            style: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            controller: sellChargeController,
                            onTap: (){
                              sellChargeController.selection = TextSelection.fromPosition(TextPosition(offset: sellChargeController.text.length));
                            },
                            readOnly: mData.value.unitPriceType == UNIT_PRICE_TYPE_02 ? true : false,
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? Colors.white : light_gray19,
                              suffixText: mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? ",000원" : "원",
                              suffixStyle: CustomStyle.CustomFont(styleFontSize18, light_gray21, font_weight: FontWeight.w800),
                              prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                              prefixText: "청구운임",
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                borderRadius: BorderRadius.all(Radius.zero),
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                  borderRadius: BorderRadius.all(Radius.zero)
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                                  borderRadius: BorderRadius.all(Radius.zero)
                              ),
                            ),
                            onChanged: (value) async {
                              if(value.isEmpty) {
                                sellChargeController.text = "";
                                mData.value.sellCharge = "";
                              }else{
                                //sellChargeController.text = value.replaceFirst(RegExp(r'^0+'), '');
                                sellChargeController.text = Util.getInCodeCommaWon(int.parse(value.replaceAll(',','')).toString());
                                mData.value.sellCharge = value.replaceAll(',','');
                              }
                              sellChargeController.selection = TextSelection.fromPosition(TextPosition(offset: sellChargeController.text.length));

                              setState(() {
                                setTotalCharge();
                              });
                            },
                            maxLength: 200,
                          )
                      )
                  ),
                  Expanded(
                      flex: 2,
                      child:Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                                  height: CustomStyle.getHeight(40),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(2)),
                                  decoration: BoxDecoration(
                                      color: mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? rpa_btn_cancle : light_gray19,
                                      borderRadius: const BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: InkWell(
                                      onTap:(){
                                        if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
                                          sellChargeController.text = sellChargeController.text == "" || sellChargeController.text == " " ? "5" : Util.getInCodeCommaWon((int.parse(sellChargeController.text.replaceAll(',', '')) + 5).toString());
                                          mData.value.sellCharge = sellChargeController.text.length > 0 ? sellChargeController.text : "0";
                                          setTotalCharge();
                                        }
                                      },
                                      child: Text(
                                        "+ 5천원",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w800),
                                      )
                                )
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                height: CustomStyle.getHeight(40),
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(2)),
                                decoration: BoxDecoration(
                                    color: mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? renew_main_color2 : light_gray19,
                                    borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: InkWell(
                                    onTap:(){
                                      if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
                                        sellChargeController.text = sellChargeController.text == "" || sellChargeController.text == " " || int.parse(sellChargeController.text) <= 0 ? " " : Util.getInCodeCommaWon((int.parse(sellChargeController.text.replaceAll(',','')) - 5).toString());
                                        mData.value.sellCharge = sellChargeController.text.length > 0 ? sellChargeController.text : "0";
                                        setTotalCharge();
                                      }
                                    },
                                    child: Text(
                                      "- 5천원",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w800),
                                    )
                              )
                            )
                          )
                        ],
                      )
                  ),
                ],
              )
          ),
          // 추가운임 / 차주운임
           Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: (){
                            openAddChargeDialog(context);
                          },
                          child: Container(
                              height: CustomStyle.getHeight(40),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(2)),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xff1AB2D4), width: 1)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "추가운임",
                                    textAlign: TextAlign.left,
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        child: Text(
                                          "${Util.getInCodeCommaWon(tvAddTotal.value.toString())} 원",
                                          textAlign: TextAlign.left,
                                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: styleGreyCol1,
                                        size: 18.h,
                                      )
                                    ],
                                  )
                                ],
                              )
                          )
                      ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          height: CustomStyle.getHeight(40),
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7), horizontal: CustomStyle.getWidth(3)),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xff1AB2D4), width: 1)
                          ),
                          child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "청구(소계)",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                  ),
                                  Obx(() =>
                                    Text(
                                      "${Util.getInCodeCommaWon(buyAmt.value)}원",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize18, Colors.blueGrey,font_weight: FontWeight.w800),
                                    )
                                  )
                                ],
                          )
                      )
                  ),
                ],
              ),
          // 산재(지불액), 화주부담
          /*Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8), horizontal: CustomStyle.getWidth(5)),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xff1AB2D4), width: 1)
              ),
              child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text(
                                "송금할 운임(부가세포함): ",
                                textAlign: TextAlign.left,
                                style: CustomStyle.CustomFont(styleFontSize12, light_gray21, font_weight: FontWeight.w800),
                              ),
                              Text(
                                "${Util.getInCodeCommaWon(insure_total_charge.value)}원",
                                textAlign: TextAlign.left,
                                style: CustomStyle.CustomFont(styleFontSize12, light_gray21, font_weight: FontWeight.w800),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "산재차주부담: ",
                                textAlign: TextAlign.left,
                                style: CustomStyle.CustomFont(styleFontSize12, light_gray21, font_weight: FontWeight.w800),
                              ),
                              Text(
                                "${Util.getInCodeCommaWon(insure_charge.value)}원",
                                textAlign: TextAlign.left,
                                style: CustomStyle.CustomFont(styleFontSize12, light_gray21, font_weight: FontWeight.w800),
                              ),
                            ],
                          )
                        ],
                      )
          ),*/
          // 정보망전송
          InkWell(
            onTap: (){
              openRpaDialog(context);
            },
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8), horizontal: CustomStyle.getWidth(5)),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xff1AB2D4), width: 1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "정보망전송",
                      textAlign: TextAlign.left,
                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                    ),
                    Row(
                      children: [
                        tv24Call.value ?
                        widget.order_vo?.call24Cargo != "" && widget.order_vo?.call24Cargo != null && widget.order_vo?.call24Cargo != "N" && widget.order_vo?.call24Cargo != "D" ?
                            Icon(Icons.check_circle,
                                size: 18.h,
                                color: renew_main_color2)
                          : const SizedBox()
                        : const SizedBox(),
                        tv24Call.value ?
                        widget.order_vo?.call24Cargo != "" && widget.order_vo?.call24Cargo != null && widget.order_vo?.call24Cargo != "N" && widget.order_vo?.call24Cargo != "D" ?
                            Container(
                              margin: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                              child: Text(
                                "24시",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w600),
                              )
                            ) : const SizedBox()
                        : const SizedBox(),
                        tvHwaMull.value ?
                        widget.order_vo?.manCargo != "" && widget.order_vo?.manCargo != null && widget.order_vo?.manCargo != "N" && widget.order_vo?.manCargo != "D" ?
                            Icon(Icons.check_circle,
                              size: 18.h,
                              color: renew_main_color2)
                          : const SizedBox()
                        : const SizedBox(),
                        tvHwaMull.value ?
                        widget.order_vo?.manCargo != "" && widget.order_vo?.manCargo != null && widget.order_vo?.manCargo != "N" && widget.order_vo?.manCargo != "D" ?
                            Container(
                                margin: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                                child: Text(
                                  "화물맨",
                                  style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w600),
                                )
                            )
                          :const SizedBox()
                        : const SizedBox(),
                        tvOneCall.value ?
                        widget.order_vo?.oneCargo != "" && widget.order_vo?.oneCargo != null && widget.order_vo?.oneCargo != "N" && widget.order_vo?.oneCargo != "D" ?
                            Icon(Icons.check_circle,
                              size: 18.h,
                              color: renew_main_color2)
                          : const SizedBox()
                        : const SizedBox(),
                        tvOneCall.value ?
                        widget.order_vo?.oneCargo != "" && widget.order_vo?.oneCargo != null && widget.order_vo?.oneCargo != "N" && widget.order_vo?.oneCargo != "D" ?
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3)),
                                child: Text(
                                  "원콜",
                                  style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w600),
                                )
                            )
                          : const SizedBox()
                        : const SizedBox(),
                        Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                          child: Row(
                            children: [
                              Text(
                                "${Util.getInCodeCommaWon(mRpaSalary.value)}원",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w800),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                child: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: styleGreyCol1,
                                  size: 18.h,
                                )
                              )
                            ],
                          )
                        )
                      ],
                    )
                  ],
                )
            )
          ),
          // 수수료
          Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize18, rpa_btn_cancle, font_weight: FontWeight.w800),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                readOnly: mData.value.chargeType == CHARGE_TYPE_01 ? true : false,
                controller: sellFeeController,
                onTap: (){
                  sellFeeController.selection = TextSelection.fromPosition(TextPosition(offset: sellFeeController.text.length));
                },
                maxLines: 1,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: mData.value.chargeType == CHARGE_TYPE_01 ? light_gray19 : Colors.white,
                  suffixText: "원",
                  suffixStyle: CustomStyle.CustomFont(styleFontSize18, rpa_btn_cancle, font_weight: FontWeight.w800),
                  prefixStyle: CustomStyle.CustomFont(styleFontSize12, Colors.black, font_weight: FontWeight.w800),
                  prefixText: "수수료",
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                      borderRadius: BorderRadius.all(Radius.zero)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff1AB2D4), width: 1),
                      borderRadius: BorderRadius.all(Radius.zero)
                  ),
                ),
                onChanged: (value) async {
                  sellFeeController.text = value == "" ? "0" : Util.getInCodeCommaWon(int.parse(value.replaceAll(',','')).toString());
                  mData.value.sellFee = value.replaceAll(',','');
                  setState(() {
                    setTotalCharge();
                  });
                },
                maxLength: 200,
              )
          )
        ],
      )
    );
  }

  Future<void> openDateSheet(BuildContext context,String type) {
    final temp_focusDate = DateTime.parse(type == "S" ? mData.value.sDate! : mData.value.eDate!).obs;
    final temp_selectMode = true.obs;
    final temp_timeChk = type == "S" ? startTimeChk.value.obs : endTimeChk.value.obs;
    final temp_date = DateTime.parse(type == "S" ? mData.value.sDate! : mData.value.eDate!).obs;

    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: "${type == "S" ? "상" : "하"}차 일시",
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FractionallySizedBox(
                    widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
                    heightFactor: 0.70,
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.symmetric(
                            horizontal: CustomStyle.getWidth(15)),
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(10),
                            left: CustomStyle.getWidth(10),
                            top: CustomStyle.getHeight(10)),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.white
                        ),
                        child: Obx(() => SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                          bottom: CustomStyle.getHeight(15)),
                                      child: Text("${type == "S" ? "상" : "하"}차 날짜를 선택해주세요.",
                                          style: CustomStyle.CustomFont(
                                              styleFontSize20, Colors.black,
                                              font_weight: FontWeight.w800)
                                      )
                                  ),
                                  Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: light_gray24,
                                                  width: 2
                                              )
                                          )
                                      ),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children : [
                                            Container(
                                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${type == "S" ? "상" : "하"}차일",
                                                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w600),
                                                      ),
                                                      Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              "시간무관",
                                                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                                                            ),
                                                            Checkbox(
                                                              value: temp_timeChk.value,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  temp_timeChk.value = value!;
                                                                  temp_date.value = DateTime(temp_date.value.year, temp_date.value.month, temp_date.value.day, temp_timeChk.value ? type == "S" ? 0 : 23 : DateTime.now().hour+1, temp_timeChk.value ? type == "S" ? 0 : 59 : 0);
                                                                });
                                                              },
                                                            ),
                                                          ]
                                                      )
                                                    ]
                                                )
                                            ),
                                            InkWell(
                                                onTap: (){
                                                  temp_selectMode.value = !temp_selectMode.value;
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
                                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Colors.white,
                                                        border: Border.all(color: light_gray23,width: 2)
                                                    ),
                                                    child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${Util.getAllDate1(temp_date.value)}",
                                                            style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w800),
                                                          ),
                                                          Icon(Icons.calendar_today,color: temp_selectMode.value ? renew_main_color2 : light_gray23,size: 24.r)
                                                        ]
                                                    )
                                                )
                                            ),

                                          ]
                                      )
                                  ),
                                  temp_selectMode.value ?
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: light_gray23,width: 2),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: TableCalendar(
                                        rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(45.h),
                                        locale: 'ko_KR',
                                        focusedDay: temp_focusDate.value,
                                        firstDay: type == "S" ? DateTime.utc(DateTime.now().year-50,DateTime.now().month, DateTime.now().day) : DateTime.utc(sCal.value.year,sCal.value.month, sCal.value.day),
                                        lastDay: DateTime.utc(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day),
                                        daysOfWeekHeight: 32 * MediaQuery.of(context).textScaleFactor,
                                        headerVisible: false,
                                        headerStyle: HeaderStyle(
                                          // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                          formatButtonVisible: false,
                                          // 달력 타이틀을 센터로
                                          titleCentered: true,
                                          // 말 그대로 타이틀 텍스트 스타일링
                                          titleTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                          rightChevronIcon: Icon(Icons.chevron_right, size: 26.h),
                                          leftChevronIcon: Icon(Icons.chevron_left, size: 26.h),
                                        ),
                                        calendarStyle: CalendarStyle(
                                          tablePadding: EdgeInsets.symmetric( horizontal: CustomStyle.getWidth(5.w)),
                                          outsideTextStyle: CustomStyle.CustomFont(styleFontSize12, line),
                                          // 오늘 날짜에 하이라이팅의 유무
                                          isTodayHighlighted: false,
                                          // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                          defaultDecoration: const BoxDecoration(color: Colors.white,),
                                          // 캘린더의 주말 배경 스타일링
                                          weekendDecoration: const BoxDecoration(color: Colors.white,),
                                          // 선택한 날짜 배경 스타일링
                                          selectedDecoration: BoxDecoration(
                                              color: const Color(0xFF50C8FF),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFF50C8FF), width: 1.w)
                                          ),
                                          defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                          weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red, font_weight: FontWeight.w600),
                                          selectedTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                          // startDay, endDay 사이의 글자 조정
                                          withinRangeTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black),

                                          // startDay, endDay 사이의 모양 조정
                                          withinRangeDecoration: const BoxDecoration(),
                                        ),
                                        selectedDayPredicate: (day) {
                                          return isSameDay(temp_date.value, day);
                                        },
                                        calendarFormat: _calendarWeekFormat,
                                        onDaySelected: (selectedDay, focusedDay) {
                                          if(type != "S") {
                                            if(parseIntDate(Util.getAllDate(sCal.value)) > parseIntDate(Util.getTextDate(selectedDay))) {
                                              return Util.toast(Strings.of(context)?.get("order_reg_day_date_fail"));
                                            }
                                          }
                                          if (!isSameDay(temp_date.value, selectedDay)) {
                                            setState(() {
                                              temp_date.value = DateTime(selectedDay.year,selectedDay.month,selectedDay.day,temp_date.value.hour,temp_date.value.minute,0);
                                              temp_focusDate.value = focusedDay;
                                              _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                            });
                                          }
                                        },
                                        onFormatChanged: (format) {
                                          if (_calendarWeekFormat != format) {
                                            setState(() {
                                              _calendarWeekFormat = format;
                                            });
                                          }
                                        },
                                        onPageChanged: (focusedDay) {
                                          temp_focusDate.value = focusedDay;
                                        },
                                      )
                                  ) : const SizedBox(),
                                  !temp_timeChk.value ?
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                                      margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: light_gray23, width: 2)
                                      ),
                                      child: TimePickerSpinner(
                                        is24HourMode: true,
                                        normalTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                        highlightedTextStyle: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
                                        time: DateTime(temp_date.value.year,temp_date.value.month, temp_date.value.day,temp_date.value.hour,temp_date.value.minute),
                                        spacing: 50,
                                        itemHeight: 30,
                                        isForce2Digits: true,
                                        minutesInterval: 30,
                                        onTimeChange: (time) {
                                          setState((){
                                            temp_date.value = DateTime(temp_date.value.year,temp_date.value.month, temp_date.value.day, time.hour,time.minute,0);
                                          });
                                        },
                                      )
                                  ) : const SizedBox(),
                                  InkWell(
                                      onTap: () {
                                        if(type == "S") {
                                          startTimeChk.value = temp_timeChk.value;
                                          //상차지
                                          sCal.value = DateTime(temp_date.value.year, temp_date.value.month, temp_date.value.day, temp_date.value.hour,temp_date.value.minute,0);
                                          mData.value.sDate = Util.getAllDate(sCal.value);
                                          int s_Way_days = DateTime(sCal.value.year,sCal.value.month,sCal.value.day,0,0,0).difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,0,0,0)).inDays;
                                          if(s_Way_days == 0) {
                                            s_way = Days.TODAY;
                                          }else if(s_Way_days == 1) {
                                            s_way = Days.TOMORROW;
                                          }else{
                                            s_way = Days.CUSTOM;
                                          }
                                          setSDate.value = Util.splitSDateType2(mData.value.sDate);

                                          //하차지
                                          if(eCal.value.isBefore(sCal.value)) {
                                            eCal.value = DateTime(sCal.value.year, sCal.value.month, e_way == Days.TOMORROW ? sCal.value.day + 1 : sCal.value.day, endTimeChk.value ? 23 : DateTime.now().hour + 1, endTimeChk.value ? 59 : 0);
                                          } else {
                                            if(e_way == Days.TOMORROW) eCal.value =  DateTime(eCal.value.year, eCal.value.month, e_way == Days.TOMORROW ? sCal.value.day + 1 : sCal.value.day, endTimeChk.value ? 23 : DateTime.now().hour + 1, endTimeChk.value ? 59 : 0);
                                          }
                                            mData.value.eDate = Util.getAllDate(eCal.value);
                                          int e_Way_days = DateTime(eCal.value.year,eCal.value.month,eCal.value.day,0,0,0).difference(DateTime(sCal.value.year, sCal.value.month, sCal.value.day,0,0,0)).inDays;
                                          if(e_Way_days == 0) {
                                            e_way = Days.TODAY;
                                          }else if(e_Way_days == 1) {
                                            e_way = Days.TOMORROW;
                                          }else{
                                            e_way = Days.CUSTOM;
                                          }
                                            setEDate.value = Util.splitEDateType2(mData.value.eDate);
                                        }else{
                                          endTimeChk.value = temp_timeChk.value;
                                          eCal.value = DateTime(temp_date.value.year, temp_date.value.month, temp_date.value.day, temp_date.value.hour,temp_date.value.minute,0);
                                          mData.value.eDate = Util.getAllDate(eCal.value);
                                          setEDate.value = Util.splitSDateType2(mData.value.eDate);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Center(
                                          child: Container(
                                            margin: EdgeInsets.only(top: CustomStyle.getHeight(15)),
                                            width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                            height: CustomStyle.getHeight(50),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              "적용",
                                              style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                            ),
                                          )
                                      )
                                  )
                                ])
                        )
                        )
                    )
                );
              });
        });
  }

  Future<void> openRpaDialog(BuildContext context) async {

    final SelectNumber = "0".obs;
    SelectNumber.value = mRpaSalary.value;
    final temp_24Call = widget.order_vo?.call24Cargo != "" && widget.order_vo?.call24Cargo != null && widget.order_vo?.call24Cargo != "N" && widget.order_vo?.call24Cargo != "D" ? true.obs : false.obs;
    final temp_hwa = widget.order_vo?.manCargo != "" && widget.order_vo?.manCargo != null && widget.order_vo?.manCargo != "N" && widget.order_vo?.manCargo != "D" ? true.obs : false.obs;
    final temp_one = widget.order_vo?.oneCargo != "" && widget.order_vo?.oneCargo != null && widget.order_vo?.oneCargo != "N" && widget.order_vo?.oneCargo != "D" ? true.obs : false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.80,
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
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              child: Text(
                                "사용할 \"정보망전송\"을 선택하고\n금액을 등록해주세요.",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),
                              )
                          )
                        ]
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                        child: Obx(() =>Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children : [
                              tv24Call.value ?
                              InkWell(
                                  onTap: () async {
                                    temp_24Call.value = !temp_24Call.value;
                                  },
                                  child: Container(
                                      width: CustomStyle.getWidth(80),
                                      height: CustomStyle.getHeight(40),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: temp_24Call.value ? renew_main_color2 : light_gray21, width: 2),
                                        borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons.check,
                                                size: 18.h, color: temp_24Call.value ? renew_main_color2 : light_gray21
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                              child: Text(
                                                "${Strings.of(context)?.get("order_trans_info_rpa_24call")}",
                                                style: CustomStyle.CustomFont(styleFontSize14, temp_24Call.value? renew_main_color2 : styleBalckCol4,font_weight: FontWeight.w800),
                                              )
                                            ),
                                          ]
                                      )
                                  )
                              ) : const SizedBox(),
                              tvHwaMull.value ?
                              InkWell(
                                  onTap: () async {
                                    temp_hwa.value = !temp_hwa.value;
                                  },
                                  child: Container(
                                      width: CustomStyle.getWidth(80),
                                      height: CustomStyle.getHeight(40),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: temp_hwa.value ? renew_main_color2 : light_gray21, width: 2),
                                          borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons.check,
                                                size: 18.h, color: temp_hwa.value ? renew_main_color2 : light_gray21
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                                child: Text(
                                                  "${Strings.of(context)?.get("order_trans_info_rpa_Hwamul")}",
                                                  style: CustomStyle.CustomFont(styleFontSize14, temp_hwa.value ? renew_main_color2 : styleBalckCol4,font_weight: FontWeight.w800),
                                              )
                                            ),
                                          ]
                                      )
                                  )
                              ) : const SizedBox(),
                              tvOneCall.value ?
                              InkWell(
                                  onTap: () async {
                                    temp_one.value = !temp_one.value;
                                  },
                                  child: Container(
                                      width: CustomStyle.getWidth(80),
                                      height: CustomStyle.getHeight(40),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: temp_one.value  ? renew_main_color2 : light_gray21, width: 2),
                                          borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons.check,
                                                size: 18.h, color: temp_one.value ? renew_main_color2 : light_gray21
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                                child:Text(
                                                  "원콜",
                                                  style: CustomStyle.CustomFont(styleFontSize14, temp_one.value ? renew_main_color2 : styleBalckCol4,font_weight: FontWeight.w800),
                                              )
                                            ),
                                          ]
                                      )
                                  )
                              ) : const SizedBox(),
                            ]
                        )
                        )
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                        child: Obx(() => Text(
                          "${Util.getInCodeCommaWon(SelectNumber.value)} 원",
                          style: CustomStyle.CustomFont(styleFontSize28, Colors.black, font_weight: FontWeight.w600),
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

                              if(int.parse(SelectNumber.value) >= 20000){
                                String? rpaSell = "0";
                                if(temp_24Call.value) {
                                  mData.value.call24Cargo = "Y";
                                  mData.value.call24Charge = SelectNumber.value;
                                  rpaSell = SelectNumber.value;
                                }else{
                                  mData.value.call24Cargo = "N";
                                  mData.value.call24Charge = "0";
                                }
                                if(temp_hwa.value) {
                                  mData.value.manCargo = "Y";
                                  mData.value.manCharge = SelectNumber.value;
                                  rpaSell = SelectNumber.value;
                                }else{
                                  mData.value.manCargo = "N";
                                  mData.value.manCharge = "0";
                                }
                                if(temp_one.value) {
                                  mData.value.oneCargo = "Y";
                                  mData.value.oneCharge = SelectNumber.value;
                                  rpaSell = SelectNumber.value;
                                }else{
                                  mData.value.oneCargo = "N";
                                  mData.value.oneCharge = "0";
                                }
                                mRpaSalary.value = rpaSell;
                                Navigator.of(context).pop();
                                setState(() {});
                              }else{
                                Util.toast("최소\"정보망전송\" 금액은\n20,000원이상입니다.");
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

  Future<void> openAddChargeDialog(BuildContext context) async {

    TextEditingController sellWayPointChargeController = TextEditingController(text: Util.getInCodeCommaWon(mData.value.sellWayPointCharge));
    TextEditingController sellWayPointMemoController = TextEditingController(text:mData.value.sellWayPointMemo??"");
    TextEditingController sellStayChargeController = TextEditingController(text: Util.getInCodeCommaWon(mData.value.sellStayCharge));
    TextEditingController sellStayMemoController = TextEditingController(text: mData.value.sellStayMemo??"");
    TextEditingController sellHandWorkChargeController = TextEditingController(text: Util.getInCodeCommaWon(mData.value.sellHandWorkCharge));
    TextEditingController sellHandWorkMemoController = TextEditingController(text: mData.value.sellHandWorkMemo??"");
    TextEditingController sellRoundChargeController = TextEditingController(text: Util.getInCodeCommaWon(mData.value.sellRoundCharge));
    TextEditingController sellRoundMemoController = TextEditingController(text: mData.value.sellRoundMemo??"");
    TextEditingController sellOtherAddChargeController = TextEditingController(text: Util.getInCodeCommaWon(mData.value.sellOtherAddCharge));
    TextEditingController sellOtherAddMemoController = TextEditingController(text: mData.value.sellOtherAddMemo??"");

    final sellWayPointMemoChk = false.obs;
    final sellStayMemoChk = false.obs;
    final sellHandWorkMemoChk = false.obs;
    final sellRoundMemoChk = false.obs;
    final sellAddMemoChk = false.obs;

    if(mData.value.sellWayPointMemo?.isNotEmpty == true && mData.value.sellWayPointMemo != null) sellWayPointMemoChk.value = true;
    if(mData.value.sellStayMemo?.isNotEmpty == true && mData.value.sellStayMemo != null) sellStayMemoChk.value = true;
    if(mData.value.sellHandWorkMemo?.isNotEmpty == true && mData.value.sellHandWorkMemo != null) sellHandWorkMemoChk.value = true;
    if(mData.value.sellRoundMemo?.isNotEmpty == true && mData.value.sellRoundMemo != null) sellRoundMemoChk.value = true;
    if(mData.value.sellOtherAddMemo?.isNotEmpty == true && mData.value.sellOtherAddMemo != null) sellAddMemoChk.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.80,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
                child: Container(
                padding: EdgeInsets.only(left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10), bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
                        padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: light_gray21,
                              width: 2
                            )
                          )
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                      child: Text(
                                        "추가운임을\n작성해주세요.",
                                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w600),
                                      )
                                  )
                                ]
                            ),
                            Container(
                                height: CustomStyle.getHeight(30),
                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: rpa_btn_regist,
                                ),
                                child: TextButton(
                                    onPressed: () async {
                                      mData.value.sellWayPointCharge = sellWayPointChargeController.text.replaceAll(",","");
                                      if(sellWayPointMemoChk.value == false) {
                                        mData.value.sellWayPointMemo = "";
                                      }else{
                                        mData.value.sellWayPointMemo = sellWayPointMemoController.text;
                                      }
                                      mData.value.sellStayCharge = sellStayChargeController.text.replaceAll(",","");
                                      if(sellStayMemoChk.value == false) {
                                        mData.value.sellStayMemo = "";
                                      }else{
                                        mData.value.sellStayMemo = sellStayMemoController.text;
                                      }
                                      mData.value.sellHandWorkCharge = sellHandWorkChargeController.text.replaceAll(",","");
                                      if(sellHandWorkMemoChk.value == false) {
                                        mData.value.sellHandWorkMemo = "";
                                      }else{
                                        mData.value.sellHandWorkMemo = sellHandWorkMemoController.text;
                                      }
                                      mData.value.sellRoundCharge = sellRoundChargeController.text.replaceAll(",","");
                                      if(sellRoundMemoChk.value == false) {
                                        mData.value.sellRoundMemo = "";
                                      }else{
                                        mData.value.sellRoundMemo = sellRoundMemoController.text;
                                      }
                                      mData.value.sellOtherAddCharge = sellOtherAddChargeController.text.replaceAll(",","");
                                      if(sellAddMemoChk.value == false) {
                                        mData.value.sellOtherAddMemo = "";
                                      }else{
                                        mData.value.sellOtherAddMemo = sellOtherAddMemoController.text;
                                      }
                                      await setTotalCharge();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "등록",
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                                    )
                                )
                            )
                          ],
                        )
                      ),

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
                                          }else{
                                            sellWayPointChargeController.text = "0";
                                          }
                                        });
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
                                        Obx(() =>
                                          Checkbox(
                                            value: sellWayPointMemoChk.value,
                                            checkColor: Colors.white,
                                            activeColor: renew_main_color2,
                                            onChanged: (value) {
                                              setState(() {
                                                if(sellWayPointMemoChk.value == false) {
                                                  sellWayPointMemoController.text = "";
                                                }
                                                sellWayPointMemoChk.value = value!;
                                              });
                                            },
                                          )
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
                      Obx(() =>
                        sellWayPointMemoChk.value ?
                        Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_way_point_memo")??"경유비 메모",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
                            )
                        ) : const SizedBox()
                      ),
                      Obx(() =>
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
                              },
                            )
                        ) : const SizedBox()
                      ),
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
                                          }else{
                                            sellStayChargeController.text = "0";
                                          }
                                        });
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
                                        Obx(() =>
                                          Checkbox(
                                            value: sellStayMemoChk.value,
                                            checkColor: Colors.white,
                                            activeColor: renew_main_color2,
                                            onChanged: (value) {
                                              setState(() {
                                                if(sellStayMemoChk.value == false) {
                                                  sellStayMemoController.text = "";
                                                }
                                                sellStayMemoChk.value = value!;
                                              });
                                            },
                                          )
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
                      Obx(() =>
                        sellStayMemoChk.value ?
                        Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_stay_memo")??"대기료 메모",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
                            )
                        ) : const SizedBox()
                      ),
                      Obx(() =>
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

                              },
                            )
                        ) : const SizedBox()
                      ),
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
                                          }else{
                                            sellHandWorkChargeController.text = "0";
                                          }
                                        });
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
                                        Obx(() =>
                                          Checkbox(
                                            value: sellHandWorkMemoChk.value,
                                            checkColor: Colors.white,
                                            activeColor: renew_main_color2,
                                            onChanged: (value) {
                                              setState(() {
                                                if(sellHandWorkMemoChk.value == false) {
                                                  sellHandWorkMemoController.text = "";
                                                }
                                                sellHandWorkMemoChk.value = value!;
                                              });
                                            },
                                          )
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
                      Obx(() =>
                        sellHandWorkMemoChk.value ?
                        Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_hand_work_memo")??"수작업비 메모",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
                            )
                        ) : const SizedBox()
                      ),
                      Obx(() =>
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

                              },
                            )
                        ) : const SizedBox()
                      ),
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
                                          }else{
                                            sellRoundChargeController.text = "0";
                                          }
                                        });
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
                                        Obx(() =>
                                          Checkbox(
                                            value: sellRoundMemoChk.value,
                                            checkColor: Colors.white,
                                            activeColor: renew_main_color2,
                                            onChanged: (value) {
                                              setState(() {
                                                if(sellRoundMemoChk.value == false) {
                                                  sellRoundMemoController.text = "";
                                                }
                                                sellRoundMemoChk.value = value!;
                                              });
                                            },
                                          )
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
                      Obx(() =>
                        sellRoundMemoChk.value ?
                        Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_round_memo")??"회차료 메모",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
                            )
                        ) : const SizedBox()
                      ),
                      Obx(() =>
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

                              },
                            )
                        ) : const SizedBox()
                      ),
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
                                          }else{
                                            sellOtherAddChargeController.text = "0";
                                          }
                                        });
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
                                        Obx(() =>
                                          Checkbox(
                                            value: sellAddMemoChk.value,
                                            checkColor: Colors.white,
                                            activeColor: renew_main_color2,
                                            onChanged: (value) {
                                              setState(() {
                                                if(sellAddMemoChk.value == false) {
                                                  sellOtherAddMemoController.text = "";
                                                }
                                                sellAddMemoChk.value = value!;
                                              });
                                            },
                                          )
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
                      Obx(() =>
                        sellAddMemoChk.value ?
                        Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                            child: Text(
                                Strings.of(context)?.get("order_trans_info_other_add_memo")??"기타추가비 메모",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w500)
                            )
                        ) : const SizedBox()
                      ),
                      Obx(() =>
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

                              },
                            )
                        ) : const SizedBox()
                      ),
                    ]
                )
            ))
        );
      },
    );
  }

  /**
   * End Widget
   */

  /**
   * Start Function
   */
  Future goToSelectCarInfo(CodeModel? cargoModel, CodeModel? carTonModel) async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RenewSelectCargoinfo(carTypeModel: cargoModel, carTonModel: carTonModel), pageAnimationType: LeftToRightTransition()));

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        mData.value.carTypeCode = results["cargo"].code;
        mData.value.carTypeName = results["cargo"].codeName;
        mData.value.carTonCode = results["carTon"].code;
        mData.value.carTonName = results["carTon"].codeName;
        mData.value.goodsWeight = "0";
        cargoWGTController.text = "0";

        if(mData.value.unitPriceType == UNIT_PRICE_TYPE_02) {
          double result = double.parse((int.parse(mData.value.unitPrice??"0") * double.parse(mData.value.goodsWeight??"0.0")).toStringAsFixed(2));
          sellChargeController.text = Util.getInCodeCommaWon(result.toInt().toString());
          mData.value.sellCharge = sellChargeController.text.replaceAll(',','');
          setTotalCharge();
        }
      }
      setState(() {});
    }
  }

  Future goToRequestPage() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderRequestInfoPage(order_vo:mData.value)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        setActivityResult(results);
      }
    }
  }

  Future<void> getInsure() async {

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getInsure(buyAmt.value == "" || buyAmt.value == null ? 0 : int.parse(buyAmt.value), Util.getTextDate(DateTime.now())).then((it) async {
      try {
        ReturnMap response = DioService.dioResponse(it);
        logger.d("getInsure() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          if (response.resultMap?["result"] == true) {
              insure_charge.value = response.resultMap?["insure"].toString()??"0";
          } else {
            openOkBox(context, "${response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getInsure() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getInsure() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getInsure() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setTotalCharge() async {
    var sellCharge = 0;
    var sellFee = 0;
    if(sellChargeController.text != "" && sellChargeController.text != " " && sellChargeController.text != "0") {
      double result = double.parse(sellChargeController.text.replaceAll(',', ''));
      if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
        sellCharge = (result * 1000).toInt();
      }else{
        sellCharge = (result).toInt();
      }
    }
    tvAddTotal.value = await setAddTotal();
    buyAmt.value = (sellCharge + tvAddTotal.value).toString();

    /*if(sellFeeController.text != "" && sellFeeController.text != " " && sellFeeController.text != "0") {
      sellFee = int.parse(sellFeeController.text.replaceAll(',', ''));
    }
    tvAddTotal.value = await setAddTotal();
    buyAmt.value = (sellCharge - sellFee + tvAddTotal.value).toString();
    await getInsure();
    insure_total_charge.value = (int.parse(buyAmt.value) - int.parse(insure_charge.value)).toString();*/
  }

  Future<int> setAddTotal() async {
    int wayPointCharge = mData.value.sellWayPointCharge?.isEmpty == true || mData.value.sellWayPointCharge == null ? 0 : int.parse(mData.value.sellWayPointCharge!);
    int stayCharge = mData.value.sellStayCharge?.isEmpty == true || mData.value.sellStayCharge == null ? 0 : int.parse(mData.value.sellStayCharge!);
    int handWorkCharge = mData.value.sellHandWorkCharge?.isEmpty == true || mData.value.sellHandWorkCharge == null ? 0 : int.parse(mData.value.sellHandWorkCharge!);
    int roundCharge = mData.value.sellRoundCharge?.isEmpty == true || mData.value.sellRoundCharge == null ? 0 : int.parse(mData.value.sellRoundCharge!);
    int otherAddCharge = mData.value.sellOtherAddCharge?.isEmpty == true || mData.value.sellOtherAddCharge == null ? 0 : int.parse(mData.value.sellOtherAddCharge!);

    int total =  wayPointCharge + stayCharge + handWorkCharge + roundCharge + otherAddCharge;
    return total;
  }

  Future<void> goToRegSAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo: mData.value, code:Const.RESULT_WORK_SADDR)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegSAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
  }

  Future<void> goToNomalAddr(String type) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewNomalAddrPage(type : type, callback: selectNomalAddrCallback)));
  }

  Future<void> goToRegEAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:mData.value,code:Const.RESULT_WORK_EADDR)));
    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegEAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
  }

  Future<void> setActivityResult(Map<String,dynamic> results)async {
    switch(results[Const.RESULT_WORK]) {
      case Const.RESULT_WORK_SADDR :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        });
        break;
      case Const.RESULT_WORK_EADDR :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        });
        break;

      case Const.RESULT_WORK_STOP_POINT :
        setState(() {
          mData.value = results[Const.ORDER_VO];
          if(mData.value.sAddr != null && mData.value.sAddr != "") {
            llNonSAddr.value = false;
            llSAddr.value = true;
            isSAddr.value = true;
          }
          if(mData.value.eAddr != null && mData.value.eAddr != "") {
            llNonEAddr.value = false;
            llEAddr.value = true;
            isEAddr.value = true;
          }
        });
        await setStopPoint();
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

      case Const.RESULT_WORK_CARGO :
        setState(() {
          mData.value = results[Const.ORDER_VO];
        });
        break;
    }
  }

  Future<void> copyData() async {

    if(mData.value.stopCount != 0) {
      await getStopPoint();
    }

    llNonRequestInfo.value = false;
    llRequestInfo.value = true;

    llNonSAddr.value = false;
    llSAddr.value = true;

    llNonEAddr.value = false;
    llEAddr.value = true;

    llNonChargeInfo.value = false;
    llChargeInfo.value = true;

    isRequest.value = true;
    isSAddr.value = true;
    isEAddr.value = true;

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
      int s_Way_days = DateTime(sCal.value.year,sCal.value.month,sCal.value.day,0,0,0).difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,0,0,0)).inDays;
      int e_Way_days = DateTime(eCal.value.year,eCal.value.month,eCal.value.day,0,0,0).difference(DateTime(sCal.value.year, sCal.value.month, sCal.value.day,0,0,0)).inDays;
      if(s_Way_days == 0) {
        s_way = Days.TODAY;
      }else if(s_Way_days == 1) {
        s_way = Days.TOMORROW;
      }else{
        s_way = Days.CUSTOM;
      }
      if(e_Way_days == 0) {
        e_way = Days.TODAY;
      }else if(e_Way_days == 1) {
        e_way = Days.TOMORROW;
      }else{
        e_way = Days.CUSTOM;
      }
      if(mData.value.sTimeFreeYN == "Y")  {
        startTimeChk.value = true;
      }else{
        startTimeChk.value = false;
      }
      if(mData.value.eTimeFreeYN == "Y"){
        endTimeChk.value = true;
      } else {
        endTimeChk.value = false;
      }
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

  Future<void> setStopPoint() async {
    if(mData.value.orderStopList?.isEmpty != true && !mData.value.orderStopList.isNull ){
      llAddStopPoint.value = false;
      llStopPoint.value = true;
    }else{
      llAddStopPoint.value = true;
      llStopPoint.value = false;
    }
  }

  Future<void> copySetDate() async {
    sCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,startTimeChk.value ? 0 : DateTime.now().hour+1,0);
    String CopyStartCal = Util.getAllDate(sCal.value);
    DateTime mScal = DateTime.now();
    try {
      mScal = DateTime.parse(mData.value.sDate!);
    }catch(e) {
      e.printError();
    }
    // 출발 시간 비교
    if(mScal.isAfter(sCal.value)) {
      setSDate.value = Util.splitSDateType2(mData.value.sDate);
    }else{
      setSDate.value = Util.splitEDateType2(CopyStartCal);
      mData.value.sDate = CopyStartCal;
    }

    eCal.value = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,endTimeChk.value ? 0 : DateTime.now().hour+1,0);
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
                mData.value.carTypeName = SP.getCodeName(Const.CAR_TYPE_CD, mData.value.carTypeCode??"");
                mData.value.carTonName = SP.getCodeName(Const.CAR_TON_CD, mData.value.carTonCode??"");
                await setOption();
                await getUnitChargeCnt();
              }else{
                mData.value.buyCharge = "0";
                mData.value.unitPrice = "0";
                mData.value.sellCharge = "0";
                await setDate();
              }
            } catch (e) {
              print(e);
            }
          } else {
            mData.value.buyCharge = "0";
            mData.value.unitPrice = "0";
            mData.value.sellCharge = "0";
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

    if(!(mData.value.sellCustId?.isEmpty == true || mData.value.sellCustId == null)){
      llNonRequestInfo.value = false;
      llRequestInfo.value = true;
      isRequest.value = true;
    }
    if(!(mData.value.sComName?.isEmpty == true || mData.value.sComName == null)) {
      llNonSAddr.value = false;
      llSAddr.value = true;
      isSAddr.value = true;
    }
    if(mData.value.mixYn == null || mData.value.mixYn?.isEmpty == true) mData.value.mixYn = "N";
    if(mData.value.returnYn == null || mData.value.returnYn?.isEmpty == true) mData.value.returnYn = "N";

    await setDate();
  }

  Future<void> setDate() async {
      sCal.value = DateTime(DateTime.now().year,DateTime.now().month,s_way == Days.TODAY ? DateTime.now().day : s_way == Days.TOMORROW ? DateTime.now().day+1 : DateTime.now().day, startTimeChk.value ? 0 : DateTime.now().hour+1,0);
      mData.value.sDate = Util.getAllDate(sCal.value);
      if(eCal.value.isBefore(sCal.value)) eCal.value = DateTime(sCal.value.year,sCal.value.month,sCal.value.day,endTimeChk.value ? 23 : DateTime.now().hour+1, endTimeChk.value ? 59 : 0);
      else eCal.value = DateTime(eCal.value.year,eCal.value.month,e_way == Days.TODAY ? eCal.value.day : e_way == Days.TOMORROW ? eCal.value.day+1 : eCal.value.day, endTimeChk.value ? 23 : eCal.value.hour+1, endTimeChk.value ? 59 : 0);
      mData.value.eDate = Util.getAllDate(eCal.value);

      setSDate.value = Util.splitSDateType2(mData.value.sDate);
      setEDate.value = Util.splitEDateType2(mData.value.eDate);
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

  int parseIntDate(String date) {
    return int.parse(Util.mergeDate(date));
  }

  int parseIntDate2(String date) {
    return int.parse(Util.mergeAllDate(date));
  }

  int parseIntTime(String time){
    return int.parse(Util.mergeTime(time));
  }

  void selectNomalAddrCallback(String type, KakaoModel? kakao, {String? jibun}) {
    if(kakao != null) {
      setState(() {
        if(type == Const.RESULT_WORK_SADDR) {
          mData.value.sAddr = kakao.address_name;
          mData.value.sSido = kakao.region_1depth_name;
          mData.value.sGungu = kakao.region_2depth_name;
          mData.value.sDong = kakao.region_3depth_name;
          mData.value.sComName = null;
          mData.value.sLat = double.parse(kakao.y??"0");
          mData.value.sLon = double.parse(kakao.x??"0");
          if(jibun != null || jibun != "") {
            mData.value.sAddrDetail = jibun;
          }
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        }else if(type == Const.RESULT_WORK_EADDR) {
          mData.value.eAddr = kakao.address_name;
          mData.value.eSido = kakao.region_1depth_name;
          mData.value.eGungu = kakao.region_2depth_name;
          mData.value.eDong = kakao.region_3depth_name;
          mData.value.eComName = null;
          mData.value.eLat = double.parse(kakao.y??"0");
          mData.value.eLon = double.parse(kakao.x??"0");
          if(jibun != null || jibun != "") {
            mData.value.eAddrDetail = jibun;
          }
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        }
      });
    }
  }

  Future<void> goToStopAddr() async {
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewSelectAddrinfo(data: mData.value, title: "경유지 선택")));
      if(results["code"] == 200) {
        print("goToStopAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
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
              llRpaSection.value = true;
              tv24Call.value = false;
              tvHwaMull.value = false;
              tvOneCall.value = false;

              for (var i = 0; i < itemsList.length; i++) {
                if (itemsList[i].linkCd == Const.CALL_24_KEY_NAME) {
                  mData.value.call24Cargo = "N";
                  tv24Call.value = true;
                } else if (itemsList[i].linkCd == Const.ONE_CALL_KEY_NAME) {
                  mData.value.oneCargo = "N";
                  tvOneCall.value = true;
                } else if (itemsList[i].linkCd == Const.HWA_MULL_KEY_NAME) {
                  if (itemsList[i].linkFlag == "Y") {
                    mData.value.manCargo = "Y";
                    tvHwaMull.value = true;
                    mHwaMullFlag.value = true;
                  } else {
                    mData.value.manCargo = "N";
                    tvHwaMull.value = true;
                    mHwaMullFlag.value = false;
                  }
                }
              }
            } else {
              llRpaSection.value = false;
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
    if(await validation()) {
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
          mData.value.carTonCode,mData.value.carTypeCode,mData.value.chargeType,mData.value.unitPriceType,int.parse(mData.value.unitPrice??"0"),mData.value.distance,startTimeChk.value? "Y" : "N",endTimeChk.value?"Y":"N",mData.value.time,
          mData.value.reqMemo, mData.value.driverMemo,mData.value.itemCode,mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? int.parse(mData.value.sellCharge??"0")*1000 : int.parse(mData.value.sellCharge??"0"),int.parse(mData.value.sellFee == null || mData.value.sellFee?.isEmpty == true || mData.value.sellFee == "null" ? "0" : mData.value.sellFee!),
          mData.value.orderStopList != null && mData.value.orderStopList?.isNotEmpty == true ? jsonEncode(mData.value.orderStopList?.map((e) => e.toJson()).toList()):null,user.userId,user.mobile,
          mData.value.sellWayPointMemo,mData.value.sellWayPointCharge,mData.value.sellStayMemo,mData.value.sellStayCharge,
          mData.value.sellHandWorkMemo,mData.value.sellHandWorkCharge,mData.value.sellRoundMemo,mData.value.sellRoundCharge,
          mData.value.sellOtherAddMemo,mData.value.sellOtherAddCharge,mData.value.goodsWeight,"N",
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

            var user = await controller.getUserInfo();

            await FirebaseAnalytics.instance.logEvent(
              name: Platform.isAndroid
                  ? "regist_order_aos"
                  : "regist_order_ios",
              parameters: {
                "user_id": user.userId??"",
                "user_custId": user.custId??"",
                "user_deptId": user.deptId??"",
                "reqCustId": mData.value.sellCustId??"",
                "sellDeptId": mData.value.sellDeptId??""
              },
            );

            if (mData.value.call24Cargo == "Y" ||
                mData.value.manCargo == "Y" || mData.value.oneCargo == "Y") {
              await FirebaseAnalytics.instance.logEvent(
                name: Platform.isAndroid
                    ? "regist_order_rpa_aos"
                    : "regist_order_rpa_ios",
                parameters: {
                  "user_id": user.userId??"",
                  "user_custId": user.custId??"",
                  "user_deptId": user.deptId??"",
                  "reqCustId": mData.value.sellCustId??"",
                  "sellDeptId": mData.value.sellDeptId??"",
                  "call24Cargo_Status": mData.value.call24Cargo??"",
                  "manCargo_Status": mData.value.manCargo??"",
                  "oneCargo_Status": mData.value.oneCargo??"",
                  "rpaSalary": mData.value.call24Charge??"",
                },
              );
            }

            Navigator.of(context).pop({'code': 200, 'allocId': _response.resultMap?["msg"]});
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
    if(await validation()) {
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
          mData.value.eTel,mData.value.eMemo,mData.value.sLat,mData.value.sLon,mData.value.eLat,mData.value.eLon,mData.value.orderState,
          mData.value.goodsName,double.parse(mData.value.goodsWeight??"0.0"),mData.value.weightUnitCode,mData.value.goodsQty,mData.value.qtyUnitCode,
          mData.value.sWayCode,mData.value.eWayCode,mData.value.mixYn,mData.value.mixSize,mData.value.returnYn,
          mData.value.carTonCode,mData.value.carTypeCode,mData.value.chargeType,mData.value.unitPriceType,int.parse(mData.value.unitPrice??"0"), mData.value.distance, startTimeChk.value ? "Y" : "N", endTimeChk.value ? "Y" : "N", mData.value.time,
          mData.value.reqMemo, mData.value.driverMemo,mData.value.itemCode,mData.value.unitPriceType == UNIT_PRICE_TYPE_01 ? int.parse(mData.value.sellCharge??"0")*1000 : int.parse(mData.value.sellCharge??"0"),int.parse(mData.value.sellFee == null || mData.value.sellFee?.isEmpty == true || mData.value.sellFee == "null" ? "0" : mData.value.sellFee!),
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

  Future<bool> validation() async {
    bool isCargoInfo = await carGoValidation();
    bool isChargeInfo = await chargeValidation();

    return isRequest.value && isSAddr.value && isEAddr.value && isCargoInfo && isChargeInfo;
  }

  Future<Map<String,dynamic>> siGunGuValidation() async {
    bool _result = true;
    String msg = "";
    Map<String,dynamic> resultMap = Map<String,dynamic>();
    if(mData.value.sSido == null || mData.value.sSido == "") {
      _result = false;
      msg = "상차지 \"시/도\"를 선택해주세요.";
    }else if(mData.value.sGungu == null || mData.value.sGungu == "") {
      _result = false;
      msg = "상차지 \"군/구\"를 선택해주세요.";
    }else if(mData.value.sDong == null || mData.value.sDong == "") {
      _result = false;
      msg = "상차지 \"동\"을 선택해주세요.";
    }else if(mData.value.eSido == null || mData.value.eSido == "") {
      _result = false;
      msg = "하차지 \"시/도\"를 선택해주세요.";
    }else if(mData.value.eGungu == null || mData.value.eGungu == "") {
      _result = false;
      msg = "하차지 \"군/구\"를 선택해주세요.";
    }else if(mData.value.eDong == null || mData.value.eDong == "") {
      _result = false;
      msg = "하차지 \"동\"을 선택해주세요.";
    }
    resultMap = {"result" : _result, "msg": msg};
    return  resultMap;
  }

  Future<bool> carGoValidation() async {
    if(mData.value.inOutSctn?.isEmpty == true || mData.value.inOutSctn == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }
    if(mData.value.truckTypeCode?.isEmpty == true || mData.value.truckTypeCode == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_truck_type")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }

      if(mData.value.carTypeCode?.isEmpty == true || mData.value.carTypeCode == null) {
        Util.toast("${Strings.of(context)?.get("order_cargo_info_car_type")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
        return false;
      }
      if(mData.value.carTonCode?.isEmpty == true || mData.value.carTonCode == null) {
        Util.toast("${Strings.of(context)?.get("order_cargo_info_car_ton")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
        return false;
      }
      if(mData.value.goodsName?.isEmpty == true || mData.value.goodsName == null) {
        Util.toast("${Strings.of(context)?.get("order_cargo_info_cargo")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
        return false;
      }

    if(mData.value.sWayCode?.isEmpty == true || mData.value.sWayCode == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_way_type")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }
    if(mData.value.eWayCode?.isEmpty == true || mData.value.eWayCode == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_way_type")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }
    return true;
  }

  Future<bool> chargeValidation() async {
    if(mData.value.call24Cargo == "Y" || mData.value.manCargo == "Y" || mData.value.oneCargo == "Y") {
      if(int.parse(mRpaSalary.value) < 20000) {
        return false;
      }
    }

    return true;
  }

  Future<void> setCargoDefault() async {
    mData.value.inOutSctn = "01";
    mData.value.truckTypeCode = "TR";
    mData.value.sWayCode = "지";
    mData.value.eWayCode = "지";
  }

  /**
   * End Function
   */

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
        },
        child: Scaffold(
          backgroundColor: sub_color,
          appBar: AppBar(
            title: Text(
                widget.flag == "M" ? Strings.of(context)?.get("order_detail_order_modify")??"오더수정_" : Strings.of(context)?.get("order_reg_title")??"오더 등록_",
                style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
            ),
            backgroundColor: renew_main_color2,
            toolbarHeight: 50.h,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () async {
                Navigator.of(context).pop({'code':100});
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.white),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: CustomStyle.getWidth(20)),
                child: InkWell(
                  onTap: () async {
                    if(mData.value.call24Cargo == "Y") {
                      /*Map<String,dynamic> result = await siGunGuValidation();
                      if(result["result"]) {
                        if (int.parse(mData.value.call24Charge ?? "0") < 20000) {
                          return Util.toast("정보망 전송(24시콜) 시 지불운임은 20,000원이상입니다.");
                        }
                      }else{
                        return Util.toast(result["msg"]);
                      }*/
                      if (int.parse(mData.value.call24Charge ?? "0") < 20000) {
                        return Util.toast("정보망 전송(24시콜) 시 지불운임은 20,000원이상입니다.");
                      }
                    }
                    if(mData.value.oneCargo == "Y") {
                      /*Map<String,dynamic> result = await siGunGuValidation();
                      if(result["result"]) {
                        if(int.parse(mData.value.oneCharge??"0") < 20000){
                          return Util.toast("정보망 전송(원콜) 시 지불운임은 20,000원이상입니다.");
                        }
                      }else{
                        return Util.toast(result["msg"]);
                      }*/
                      if(int.parse(mData.value.oneCharge??"0") < 20000){
                        return Util.toast("정보망 전송(원콜) 시 지불운임은 20,000원이상입니다.");
                      }
                    }
                    if(mData.value.manCargo == "Y") {
                      /*Map<String,dynamic> result = await siGunGuValidation();
                      if(result["result"]) {
                        if (int.parse(mData.value.manCharge ?? "0") < 20000) {
                          return Util.toast("정보망 전송(화물맨) 시 지불운임은 20,000원이상입니다.");
                        }
                      } else {
                        return Util.toast(result["msg"]);
                      }*/
                      if (int.parse(mData.value.manCharge ?? "0") < 20000) {
                        return Util.toast("정보망 전송(화물맨) 시 지불운임은 20,000원이상입니다.");
                      }
                    }
                    if(mData.value.carTonName == null || mData.value.carTonName == ""){
                      return Util.toast("톤수를 입력해주세요.");
                    }else{
                      var numberString = mData.value.carTonName?.replaceAll(new RegExp(r'[^0-9.]'),'');
                      var numberParse = double.parse(numberString!);
                      var maxWeight = numberParse + (numberParse*0.1);
                      if(double.parse(mData.value.goodsWeight??"0.0") > maxWeight) {
                        return Util.toast("입력하신 \"화물중량이 최대 화물중량을 넘을 수 없습니다.\"");
                      }
                    }
                    if(widget.flag == "M") {
                      await showModiOrder();
                    }else{
                      await showRegOrder();
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(15)),
                      child: Text(
                      widget.flag == "M" ? "수정" : "저장",
                     style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
                    )
                  ),
                )
              )
            ],
          ),
          body: SafeArea(
              child: Obx(() {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                        child: Column(
                          children: [
                            cargoWidget(),
                            startWidget(),
                            wayPointWidget(),
                            endWidget(),
                            bodyWidget()
                          ],
                        )
                    )
                );
              })
          )
        )
    );
  }

}

class DecimalInputFormatter  extends TextInputFormatter {
  final RegExp _regex = RegExp(r'^\d*\.?\d{0,1}$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class NoDecimalFormatter extends TextInputFormatter {
  final RegExp _regex =  RegExp(r'^\d*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}