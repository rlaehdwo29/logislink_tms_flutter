import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/rpa_flag_model.dart';
import 'package:logislink_tms_flutter/common/model/unit_charge_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderChargeInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String unit_charge_cnt;
  String unit_buy_charge_local;
  String unit_price_local;
  String unit_sell_charge_local;
  String? code;

  OrderChargeInfoPage({Key? key,required this.order_vo,required this.unit_charge_cnt, required this.unit_buy_charge_local, required this.unit_price_local, required this.unit_sell_charge_local, this.code}):super(key:key);

  _OrderChargeInfoPageState createState() => _OrderChargeInfoPageState();
}

class _OrderChargeInfoPageState extends State<OrderChargeInfoPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  static const String CHARGE_TYPE_01 = "01"; // 인수증
  static const String CHARGE_TYPE_02 = "02"; // 선/착불
  static const String CHARGE_TYPE_03 = "03"; // 차주발행
  static const String CHARGE_TYPE_04 = "04"; // 선불
  static const String CHARGE_TYPE_05 = "05"; // 착불

  static const String UNIT_PRICE_TYPE_01 = "01";
  static const String UNIT_PRICE_TYPE_02 = "02";

  //디폴트 적용단가 구분 코드 : 01(대당단가) / 02(톤당단가) / 03(KM단가) - 참고) TCODE.GCODE='UNIT_PRICE_TYPE'
  static const String CHARGE_CAR_TYPE = "01";
  static const String CHARGE_TON_TYPE = "02";

  bool isOption = false;
  String code = "";
  final mData = OrderModel().obs;
  final isCharge = false.obs;
  final isRpa = false.obs;

  final ChargeCheck = "".obs;
  final mBuyChargeDummy = "".obs; // 기본 설정 값 : Buy Charge
  final mUnitPriceDummy = "".obs; // 기본 설정 값 : Unit Price
  final mSellChargeDummy = "".obs; // 기본 설정 값 : Sell Charge
  final rBuyCharge = "".obs;  // 통신 설정 값 : Buy Charge
  final rUnitPrice = "".obs;  // 통신 설정 값 : Unit Price
  final rSellCharge = "".obs; // 통신 설정 값 :" Sell Charge
  final m24Call = "N".obs; // 24시콜 Command
  final mHwaMull = "N".obs; // 화물맨 Command
  final mHwaMullFlag = false.obs; // 화물맨 LinkFlag 값 설정 시 안 꺼지기
  final mOneCall = "N".obs; // 원콜 Command
  final mRpaSalary = "".obs;

  final llRpaSection = false.obs;

  final tv24Call = false.obs;
  final tvHwaMull = false.obs;
  final tvOneCall = false.obs;
  final tvTotal = "".obs;

  final tvChargeType01 = false.obs;
  final tvChargeType04 = false.obs;
  final tvChargeType05 = false.obs;
  final llSellFee = false.obs;
  final etSellFee = false.obs;

  final tvUnitPriceType01 = false.obs;
  final tvUnitPriceType02 = false.obs;
  final llUnitPrice = false.obs;
  final etUnitPrice = false.obs;

  final etSellCharge = "".obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {

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
      if(widget.code != null || widget.code?.isEmpty == true ) code = widget.code??"";
      mBuyChargeDummy.value = widget.unit_buy_charge_local;
      mUnitPriceDummy.value = widget.unit_price_local;
      mSellChargeDummy.value = widget.unit_sell_charge_local;

      rBuyCharge.value = widget.unit_buy_charge_local;
      rUnitPrice.value = widget.unit_price_local;
      rSellCharge.value = widget.unit_sell_charge_local;

      ChargeCheck.value = widget.unit_charge_cnt;
      mHwaMullFlag.value = false;

      if(ChargeCheck.value == "Y") {
        await getUnitChargeCar();
      }else{
        if(Const.RESULT_SETTING_CHARGE == code) {
          mData.value.unitPrice = mUnitPriceDummy.value;
        }else{
          mData.value.sellCharge = mSellChargeDummy.value;
          mData.value.unitPrice = mUnitPriceDummy.value;
        }
      }
      await getRpaLinkFlag();
      await initView();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initView() async {
    isOption = !widget.code.isNull;

    if(!(code == null || code.isEmpty == true)) {
      llRpaSection.value = false;
    }
    if(code == null || code.isEmpty == true) {
      if(mData.value.chargeType == null || mData.value.chargeType?.isEmpty == true) {
        mData.value.chargeType = CHARGE_TYPE_01;
        mData.value.chargeTypeName = "인수증";
      }
      await setChargeType();
    }
    if(mData.value.unitPriceType == "01") {
      mData.value.unitPriceType = UNIT_PRICE_TYPE_01;
      mData.value.unitPriceTypeName = "대당단가";
    }else if(mData.value.unitPriceType == "02") {
      mData.value.unitPriceType = UNIT_PRICE_TYPE_02;
      mData.value.unitPriceTypeName = "톤당단가";
    }else {
      mData.value.unitPriceType = UNIT_PRICE_TYPE_01;
      mData.value.unitPriceTypeName = "대당단가";
    }
    await setUnitPriceType(false);

  }

  Future<void> getRpaLinkFlag() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getLinkFlag(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getRpaLinkFlag() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<RpaFlagModel> itemsList = list.map((i) => RpaFlagModel.fromJSON(i)).toList();
            if(itemsList.length != 0) {
              llRpaSection.value = true;
              tv24Call.value = false;
              tvHwaMull.value = false;
              tvOneCall.value = false;

              for(var i = 0; i < itemsList.length; i++) {
                if(itemsList[i].linkCd == Const.CALL_24_KEY_NAME) {
                  m24Call.value = "N";
                  mData.value.call24Cargo = "N";
                  tv24Call.value = true;
                }else if(itemsList[i].linkCd == Const.ONE_CALL_KEY_NAME) {
                  mOneCall.value = "N";
                  mData.value.oneCargo = "N";
                  tvOneCall.value = true;
                }else if(itemsList[i].linkCd == Const.HWA_MULL_KEY_NAME) {
                  if(itemsList[i].linkFlag == "Y") {
                    mHwaMull.value = "Y";
                    mData.value.manCargo = "Y";
                    tvHwaMull.value = true;
                    mHwaMullFlag.value = true;
                  }else{
                    mHwaMull.value = "N";
                    mData.value.manCargo = "N";
                    tvHwaMull.value = false;
                    mHwaMullFlag.value = false;
                  }
                }
              }
            }else{
              llRpaSection.value = false;
            }
            await initView();
          }
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
          print("getRpaLinkFlag() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getRpaLinkFlag() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setTotal() async {
    int sellCharge =  mData.value.sellCharge?.isEmpty == true || mData.value.sellCharge == null ? 0 : int.parse(mData.value.sellCharge!);
    int sellFee = mData.value.sellFee?.isEmpty == true || mData.value.sellFee == null ? 0 : int.parse(mData.value.sellFee!);
    int sellWayPointCharge = mData.value.sellWayPointCharge?.isEmpty == true || mData.value.sellWayPointCharge == null ? 0 : int.parse(mData.value.sellWayPointCharge!);
    int sellStayCharge = mData.value.sellStayCharge?.isEmpty == true || mData.value.sellStayCharge == null ? 0 : int.parse(mData.value.sellStayCharge!);
    int sellHandWorkCharge = mData.value.sellHandWorkCharge?.isEmpty == true || mData.value.sellHandWorkCharge == null ? 0 : int.parse(mData.value.sellHandWorkCharge!);
    int sellRoundCharge = mData.value.sellRoundCharge?.isEmpty == true || mData.value.sellRoundCharge == null ? 0 : int.parse(mData.value.sellRoundCharge!);
    int sellOtherAddCharge = mData.value.sellOtherAddCharge?.isEmpty == true || mData.value.sellOtherAddCharge == null ? 0 : int.parse(mData.value.sellOtherAddCharge!);

    int total = sellCharge + sellWayPointCharge + sellStayCharge + sellHandWorkCharge + sellRoundCharge + sellOtherAddCharge - sellFee;

    tvTotal.value = Util.getInCodeCommaWon(total.toString());

  }

  Future<String> makeCharge() async {
    if(mData.value.sellWeight?.isEmpty == true) return "0";
    double unit = double.parse(mData.value.sellWeight??"0.0");
    int price = int.parse(mData.value.unitPrice??"0");
    return (unit * price).floor().toInt().toString();
  }

  Future<void> setChargeType() async {
    if(mData.value.chargeType == CHARGE_TYPE_01) {
      tvChargeType01.value = true;
      tvChargeType04.value = false;
      tvChargeType05.value = false;
      llSellFee.value = false;
      etSellFee.value = false;

      mData.value.sellFee = "0";
    } else if(mData.value.chargeType == CHARGE_TYPE_04) {
      tvChargeType01.value = false;
      tvChargeType04.value= true;
      tvChargeType05.value = false;
      llSellFee.value = true;
      etSellFee.value = true;
    }else if(mData.value.chargeType == CHARGE_TYPE_05) {
      tvChargeType01.value = false;
      tvChargeType04.value = false;
      tvChargeType05.value = true;
      llSellFee.value = true;
      etSellFee.value = true;
    }
  }

  Future<void> setUnitPriceType(bool isFirst) async {
    print("응애옹에 =>${isFirst} // ${mData.value.unitPriceType}");
    if(mData.value.unitPriceType == UNIT_PRICE_TYPE_01) {
      tvUnitPriceType01.value = true;
      tvUnitPriceType02.value = false;
      llUnitPrice.value = false;
      etUnitPrice.value = false;

      if(!isFirst) {
        if(Const.RESULT_SETTING_CHARGE == code){
          mData.value.unitPrice = rUnitPrice.value;
          mData.value.sellCharge = rSellCharge.value;
          mData.value.buyCharge = rBuyCharge.value;
        }else{
          mData.value.unitPrice = "0";
          mData.value.sellCharge = rSellCharge.value;
        }
      }
      mData.value.sellWeight = "";

    }else{
      tvUnitPriceType01.value = false;
      tvUnitPriceType02.value = true;
      llUnitPrice.value = true;
      etUnitPrice.value = true;
      if(!isFirst) {
        if(Const.RESULT_SETTING_CHARGE == code) {
          mData.value.unitPrice = rUnitPrice.value;
          mData.value.sellCharge = rSellCharge.value;
          mData.value.buyCharge = rBuyCharge.value;
          mData.value.sellWeight = mData.value.goodsWeight;
        }else{
          mData.value.sellCharge = "";
          mData.value.unitPrice = rUnitPrice.value;
          mData.value.sellWeight = mData.value.goodsWeight;
        }
      }
    }
  }

  Future<void> displayChargeInfo() async {
    isCharge.value = !isCharge.value;
  }

  Future<void> displayRpaInfo() async {
    isRpa.value = !isRpa.value;
  }

  Future<void> display24Call() async {
    if(m24Call.value == "N") {
      m24Call.value = "Y";
      mData.value.call24Cargo = "Y";
      tv24Call.value = true;
    }else{
      m24Call.value = "N";
      mData.value.call24Cargo = "Y";
      tv24Call.value = false;
    }
  }

  Future<void> displayOneCall() async {
    if(mOneCall.value == "N") {
      mOneCall.value = "Y";
      mData.value.oneCargo = "Y";
      tvOneCall.value = true;
    }else{
      mOneCall.value = "N";
      mData.value.oneCargo = "YN";
      tvOneCall.value = false;
    }
  }

  Future<void> displayHwaMull() async {
    if(mHwaMull.value == "N") {
      mHwaMull.value = "Y";
      mData.value.manCargo = "Y";
      tvHwaMull.value = true;
    }else{
      if(mHwaMullFlag.value) {
        mHwaMull.value == "Y";
        mData.value.manCargo = "Y";
        tvHwaMull.value = true;
        mHwaMullFlag.value = false; // 지속적으로 On 되어 있는것이 On/Off로 전환 - 2023-09-04
      }else{
        mHwaMull.value = "N";
        mData.value.manCargo = "N";
        tvHwaMull.value = false;
      }
    }
  }

  Future<void> confirm() async {
    var result = await validation();
    if(result) {
      mData.value.call24Cargo = mRpaSalary.value;
      mData.value.oneCharge = mRpaSalary.value;
      mData.value.manCharge = mRpaSalary.value;

      Navigator.of(context).pop({
        'code':200,
        Const.RESULT_WORK : Const.RESULT_WORK_CHARGE,
        Const.ORDER_VO : mData.value,
        Const.RPA_24CALL_YN : m24Call.value,
        Const.RPA_HWAMULL_YN : mHwaMull.value,
        Const.RPA_ONECALL_YN : mOneCall.value,
        Const.RPA_SALARY : mRpaSalary.value
      });
    }
  }

  Future<void> getUnitChargeCar() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTmsUnitCharge(
        user.authorization,
        CHARGE_CAR_TYPE,
        mData.value.sellCustId,
        mData.value.sellDeptId,
        mData.value.sSido,
        mData.value.sGungu,
        mData.value.sDong,
        mData.value.eSido,
        mData.value.eGungu,
        mData.value.eDong,
        mData.value.carTonCode,
        mData.value.carTypeCode,
        mData.value.sDate,
        mData.value.eDate
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getUnitChargeCar() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            UnitChargeModel value = _response.resultMap?["data"];
            mData.value.sellCharge = value.unit_charge;
            rSellCharge.value = value.unit_charge??"";
          }else{
            mData.value.sellCharge = mSellChargeDummy.value;
            rSellCharge.value = mSellChargeDummy.value;
          }
          await getUnitChargeTon();
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
          print("getUnitChargeCar() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeCar() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getUnitChargeTon() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTmsUnitCharge(
        user.authorization,
        CHARGE_TON_TYPE,
        mData.value.sellCustId,
        mData.value.sellDeptId,
        mData.value.sSido,
        mData.value.sGungu,
        mData.value.sDong,
        mData.value.eSido,
        mData.value.eGungu,
        mData.value.eDong,
        mData.value.carTonCode,
        mData.value.carTypeCode,
        mData.value.sDate,
        mData.value.eDate
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getUnitChargeTon() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            UnitChargeModel value = _response.resultMap?["data"];
            mData.value.unitPrice = value.unit_charge;
            rUnitPrice.value = value.unit_charge??"";
          }else{
            mData.value.unitPrice = mUnitPriceDummy.value;
            rUnitPrice.value = mUnitPriceDummy.value;
          }
          await initView();
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
          print("getUnitChargeTon() ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeTon() getOrder Default => ");
          break;
      }
    });
  }

  Future<bool> validation() async {
    if(mData.value.sellCharge.toString().trim().isEmpty) {
      Util.toast("${Strings.of(context)?.get("order_charge_info_sell_charge_hint")??"Not Found"}");
      return false;
    }
    return true;
  }

  Future<void> save() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOptionCharge(
        user.authorization,"Y",mData.value.unitPriceType, mData.value.sellCharge, mData.value.unitPrice
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("OrderChargoInfoPage save() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_SETTING_CHARGE});
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
          print("OrderChargoInfoPage save() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("OrderChargoInfoPage save() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showResetDialog() async {
    await openCommonConfirmBox(
        context,
        "운임 정보 설정값을 초기화 하시겠습니까?",
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
    await DioService.dioClient(header: true).setOptionCharge(
        user.authorization,
        "Y",
        null,null,null
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("OrderChargoInfoPage reset() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_SETTING_CHARGE});
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
          print("OrderChargoInfoPage reset() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("OrderChargoInfoPage reset() getOrder Default => ");
          break;
      }
    });
  }

  Widget bodyWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
          child: Text(
            "${Strings.of(context)?.get("order_charge_info_sub_title")}",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          )
        ),
        // 인수증/선불/착불
        Row(
          children: [
            Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () async {
                      mData.value.chargeType = CHARGE_TYPE_01;
                      mData.value.chargeTypeName = "인수증";
                      await setChargeType();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: tvChargeType01.value ?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Text(
                        "${Strings.of(context)?.get("order_trans_info_charge_type_01")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize12, tvChargeType01.value ?text_box_color_01 : text_box_color_02),
                        textAlign: TextAlign.center,
                      ),
                    )
                )),
            Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () async {
                      mData.value.chargeType = CHARGE_TYPE_04;
                      mData.value.chargeTypeName = "선불";
                      await setChargeType();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: tvChargeType04.value ?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Text(
                        "${Strings.of(context)?.get("order_trans_info_charge_type_04")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize12, tvChargeType04.value ?text_box_color_01 : text_box_color_02),
                        textAlign: TextAlign.center,
                      ),
                    )
                )),
            Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () async {
                      mData.value.chargeType = CHARGE_TYPE_05;
                      mData.value.chargeTypeName = "착불";
                      await setChargeType();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: tvChargeType05.value ?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Text(
                        "${Strings.of(context)?.get("order_trans_info_charge_type_05")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize12, tvChargeType05.value ?text_box_color_01 : text_box_color_02),
                        textAlign: TextAlign.center,
                      ),
                    )
                )),
          ],
        ),
        // 대당단가/톤당단가
    Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () async {
                      mData.value.unitPriceType = UNIT_PRICE_TYPE_01;
                      mData.value.unitPriceTypeName = "대당단가";
                      await setUnitPriceType(false);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: tvUnitPriceType01.value ?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Text(
                        "${Strings.of(context)?.get("order_trans_info_unit_price_type_01")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize12, tvUnitPriceType01.value ?text_box_color_01 : text_box_color_02),
                        textAlign: TextAlign.center,
                      ),
                    )
                )),
            Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () async {
                      mData.value.unitPriceType = UNIT_PRICE_TYPE_02;
                      mData.value.unitPriceTypeName = "톤당단가";
                      await setUnitPriceType(false);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: tvUnitPriceType02.value ?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Text(
                        "${Strings.of(context)?.get("order_trans_info_unit_price_type_02")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize12, tvUnitPriceType02.value ?text_box_color_01 : text_box_color_02),
                        textAlign: TextAlign.center,
                      ),
                    )
                )
              )
            ],
          )
        ),
        //톤당단가
        Text(
          "${Strings.of(context)?.get("order_charge_info_unit_price")}",
          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
          child: ,
        )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar:PreferredSize(
              preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
              child: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_charge_info_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: const Icon(Icons.arrow_back),
                ),
              )
          ),
          body: SafeArea(
              child: Obx((){
                return Column(
                  children: [
                    !isOption ? Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:BorderSide(
                                color: line,
                                width: CustomStyle.getWidth(1.0)
                            )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${Strings.of(context)?.get("order_charge_info_total_charge")}",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Text(
                            "${Util.getInCodeCommaWon(tvTotal.value.toString())}원",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                        ],
                      ),
                    ) : const SizedBox(),
                    SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            bodyWidget(),
                            //expanedWidget()
                          ],
                        )
                      )
                  ],
                );
              })
          ),
            bottomNavigationBar: SizedBox(
                height: CustomStyle.getHeight(60.0.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //확인 버튼
                    !(isOption == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              //await tvConfirm();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check,
                                          size: 20, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("confirm") ??
                                            "Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ]
                                )
                            )
                        )
                    ):const SizedBox(),
                    //초기화 버튼
                    (isOption == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              //await tvReset();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: sub_btn),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.refresh, size: 20, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("reset") ??
                                            "Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ]
                                )
                            )
                        )
                    ):const SizedBox(),
                    // 저장 버튼
                    (isOption == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              //await setOptionCargo();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_btn),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save_alt, size: 20, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("save") ??
                                            "Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ]
                                )
                            )
                        )
                    ):const SizedBox(),
                  ],
                ))
        )
    );
  }

}