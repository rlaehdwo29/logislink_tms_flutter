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
import 'package:logislink_tms_flutter/page/subpage/car_search_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cust_user_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderTransInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  OrderTransInfoPage({Key? key,required this.order_vo, this.code}):super(key:key);

  _OrderTransInfoPageState createState() => _OrderTransInfoPageState();
}


class _OrderTransInfoPageState extends State<OrderTransInfoPage> {

  ProgressDialog? pr;

  final code = "".obs;
  final orderCarTonCode = "".obs;
  final orderCarTypeCode = "".obs;
  final orderBuyCharge = "".obs;

  final isTransInfoExpanded = [].obs;
  final isEtcExpanded = [].obs;

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

  Future<void> initView() async {
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
    etOtherAddMemoController.text = mData.value.driverMemo??"";
    await setTotal();
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
                mData.value.buyCharge = mOrderOption.value.buyCharge??"0";
                orderBuyCharge.value = mOrderOption.value.buyCharge??"";
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

    int total = buyCharge + wayPointCharge + stayCharge + handWorkCharge + handWorkCharge + roundCharge + otherAddCharge;

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

        etRegistController.text = "";
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
        Util.toast(Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해주세요._");
        return false;
      }

      if(mData.value.buyStaffName?.isEmpty == true || mData.value.buyStaffName == null) {
        Util.toast(Strings.of(context)?.get("order_trans_info_keeper_hint")??"담당자를 지정해주세요._");
        return false;
      }
    }else{
      if(mData.value.carNum?.trim().isEmpty == true || mData.value.carNum?.trim() == null) {
        Util.toast(Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해주세요._");
        return false;
      }
    }
    if(mData.value.buyCharge?.trim().isEmpty == true || mData.value.buyCharge?.trim() == null) {
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
      mData.value.sSido,
      mData.value.sGungu,
      mData.value.sDong,
      mData.value.eSido,
      mData.value.eGungu,
      mData.value.eDong,
      orderCarTonCode.value,
      orderCarTypeCode.value,
      mData.value.sDate,
      mData.value.eDate

    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getUnitChargeComp() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["data"] != null) {
              UnitChargeModel value = UnitChargeModel.fromJSON(it.response.data["data"]);
              mData.value.buyCharge = value.unit_charge;
              etBuyChargeController.text = value.unit_charge??"0";
            }else{
              mData.value.buyCharge = orderBuyCharge.value??"0";
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
                  "user_id": user.userId,
                  "user_custId" : user.custId,
                  "user_deptId": user.deptId,
                  "orderId" : mData.value.orderId,
                  "buyCustId" : mData.value.buyCustId,
                  "buyDeptId" : mData.value.buyDeptId
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
    await DioService.dioClient(header: true).setOptionTrans(
        user.authorization, "Y",mData.value.buyCharge,mData.value.driverMemo
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
                    mData.value.buyCharge = orderBuyCharge.value;
                    await setTotal();
                  },
                child: Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                  margin: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
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
                      mData.value.buyCharge = orderBuyCharge.value;
                      await setTotal();
                    },
                    child: Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
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
                                mData.value.buyCustName?.isEmpty == true || mData.value.buyCustName == null ?
                                Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해 주세요._" : mData.value.buyCustName!,
                                style: CustomStyle.CustomFont(styleFontSize14, mData.value.buyCustName?.isEmpty == true || mData.value.buyCustName == null ? styleDefaultGrey : text_color_01),
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
                                    mData.value.buyStaffName??"",
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
                                  Util.makePhoneNumber(mData.value.buyStaffTel),
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
                                  mData.value.carNum?.isEmpty == true || mData.value.carNum == null ?
                                  Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해 주세요._": mData.value.carNum!,
                                  style: CustomStyle.CustomFont(styleFontSize14,  mData.value.carNum?.isEmpty == true || mData.value.carNum == null ? styleDefaultGrey : text_color_01),
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
                           mData.value.driverName??"",
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
                            Util.makePhoneNumber(mData.value.driverTel),
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
                          mData.value.carTypeName??"",
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
                            Util.makePhoneNumber(mData.value.carTonName),
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
                                  mData.value.buyCharge = "0";
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
                                mData.value.buyCharge = etBuyChargeController.text.replaceAll(",", "");
                              }else{
                                mData.value.buyCharge = "0";
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

  Widget transInfoPannelWidget() {
    isTransInfoExpanded.value = List.filled(1, false);
    return Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return ExpansionPanelList.radio(
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
                                          mData.value.wayPointCharge = int.parse(value.trim()).toString();
                                          etWayPointController.text = int.parse(value.trim()).toString();
                                        }else{
                                          mData.value.wayPointCharge = "0";
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
                                          mData.value.stayCharge = int.parse(value.trim()).toString();
                                          etStayChargeController.text = int.parse(value.trim()).toString();
                                        }else{
                                          mData.value.stayCharge = "0";
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
                                          mData.value.roundCharge = int.parse(value.trim()).toString();
                                          etRoundChargeController.text = int.parse(value.trim()).toString();
                                        }else{
                                          mData.value.roundCharge = "0";
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
                                          mData.value.otherAddCharge = int.parse(value.trim()).toString();
                                          etOtherAddChargeController.text = int.parse(value.trim()).toString();
                                        }else{
                                          mData.value.otherAddCharge = "0";
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
                                        mData.value.driverMemo = value;
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
        );
      }),
    );
  }

  Widget etcPannelWidget() {
    return Column(
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
          //resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_trans_info_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(
                        styleFontSize16, styleWhiteCol)
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
              child: Obx((){
                  return SingleChildScrollView(
                    child: Column(
                    children: [
                      !isOption.value?
                        Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_total_charge")??"지불운임(소계)_",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Text(
                                "${Util.getInCodeCommaWon(tvTotal.value.toString())} 원",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                            ],
                          ),
                        ) : const SizedBox(),
                      CustomStyle.getDivider1(),
                      mainBodyWidget(),
                      !isOption.value ? transInfoPannelWidget() : const SizedBox(),
                      Container(
                        height: 5.h,
                        color: line,
                      ),
                      etcPannelWidget()
                      ],
                    ));
              })
          ),
            bottomNavigationBar: Obx((){
              return SizedBox(
                height: CustomStyle.getHeight(60.0.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //확인 버튼
                    !(isOption.value == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await confirm();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check,
                                          size: 20.h, color: styleWhiteCol),
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
                    (isOption.value == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showResetDialog();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: sub_btn),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh, size: 20.h, color: styleWhiteCol),
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
                    (isOption.value == true)? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await save();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_btn),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_alt, size: 20.h, color: styleWhiteCol),
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
                ));
          })
        )
    );
  }




}