import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderCargoInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  OrderCargoInfoPage({Key? key,required this.order_vo,this.code}):super(key:key);

  _OrderCargoInfoPageState createState() => _OrderCargoInfoPageState();
}


class _OrderCargoInfoPageState extends State<OrderCargoInfoPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  late TextEditingController goodsNameController;
  late TextEditingController cargoWgtController;
  late TextEditingController goodsQtyController;

  final mData = OrderModel().obs;
  final code = "".obs;

  final isOption = false.obs;
  final tvTruckType = false.obs;
  final tvCarType = false.obs;
  final tvCarTon = false.obs;
  final tvMixN = false.obs;
  final tvMixY = false.obs;
  final llMixSize = false.obs;
  final tvReturnN = false.obs;
  final tvReturnY = false.obs;

  @override
  void initState() {
    super.initState();

    goodsNameController = TextEditingController();
    cargoWgtController = TextEditingController();
    goodsQtyController = TextEditingController();

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
      if(widget.code != null) code.value = widget.code??"";
      goodsNameController.text = mData.value.goodsName??"";
      cargoWgtController.text = mData.value.goodsWeight??"";
      goodsQtyController.text = mData.value.goodsQty??"";
      await initView();
    });
  }

  @override
  Future<void> initView() async {
    isOption.value = !widget.code.isNull;
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

    await setEnable();

    if(mData.value.mixYn == null){
      mData.value.mixYn = "N";
    }
    await setMixYn();

    if(mData.value.returnYn == null) {
      mData.value.returnYn = "N";
    }
    await setReturnYn();

  }

  @override
  void dispose(){
    super.dispose();
    goodsNameController.dispose();
    cargoWgtController.dispose();
    goodsQtyController.dispose();
  }

  Future<void> setCargoDefault() async {
    mData.value.inOutSctn = "01";
    mData.value.truckTypeCode = "TR";
    mData.value.sWayCode = "지";
    mData.value.eWayCode = "지";
  }

  Future<void> setEnable() async {
    if(mData.value.inOutSctn != null) {
      tvTruckType.value = true;
    }
    if(mData.value.truckTypeCode != null) {
      tvCarType.value = true;
    }
    if(mData.value.carTypeCode != null) {
      tvCarTon.value = true;
    }
  }

  Future<void> selectInOutSctn(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "IN_OUT_SCTN" :
          setState(() {
            mData.value.inOutSctn = codeModel?.code;
            mData.value.inOutSctnName = codeModel?.codeName;
            mData.value.truckTypeCode = null;
            mData.value.truckTypeName = null;
            mData.value.carTypeCode = null;
            mData.value.carTypeName = null;
            mData.value.carTonCode = null;
            mData.value.carTonName = null;
          });
          await setEnable();
          break;
      }
    }
  }

  Future<void> showInOutSctn() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"", codeType: Const.IN_OUT_SCTN, mFilter: "", callback: selectInOutSctn).showDialog();
}

  Future<void> selectTruckType(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "TRUCK_TYPE_CD" :
          setState(() {
            mData.value.truckTypeCode = codeModel?.code;
            mData.value.truckTypeName = codeModel?.codeName;

            mData.value.carTypeCode = null;
            mData.value.carTypeName = null;
            mData.value.carTonCode = null;
            mData.value.carTonName = null;
          });
          await setEnable();
          break;
      }
    }
  }

  Future<void> showTruckType() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_truck_type")??"", codeType: Const.TRUCK_TYPE_CD, mFilter: mData.value.inOutSctn, callback: selectTruckType).showDialog();
  }

  Future<void> selectCarType(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "CAR_TYPE_CD" :
            mData.value.carTypeCode = codeModel?.code;
            mData.value.carTypeName = codeModel?.codeName;
            mData.value.carTonCode = null;
            mData.value.carTonName = null;
          await setEnable();
          break;
      }
      setState(() {});
    }
  }

  Future<void> showCarType() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_car_type")??"", codeType: Const.CAR_TYPE_CD, mFilter: mData.value.truckTypeCode, callback: selectCarType).showDialog();
  }

  Future<void> selectCarTon(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "CAR_TON_CD" :
            mData.value.carTonCode = codeModel?.code;
            mData.value.carTonName = codeModel?.codeName;
          break;
      }
      setState(() {});
    }
  }

  Future<void> showCarTon() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_car_ton")??"", codeType: Const.CAR_TON_CD, mFilter: mData.value.truckTypeCode, callback: selectCarTon).showDialog();
  }

  Future<void> selectItemLvL1(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "ITEM_CD" :
          setState(() {
            mData.value.itemCode = codeModel?.code;
            mData.value.itemName = codeModel?.codeName;
          });
          break;
      }
    }
  }

  Future<void> showItemLvL1() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"", codeType: Const.ITEM_CD, mFilter: "", callback: selectItemLvL1).showDialog();
  }

  Future<void> selectQtyUnit(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "QTY_UNIT_CD" :
          setState(() {
            mData.value.qtyUnitCode = codeModel?.code;
            mData.value.qtyUnitName = codeModel?.codeName;
          });
          break;
      }
    }
  }

  Future<void> showQtyUnit() async {
    ShowCodeDialogWidget(context:context, mTitle: "${Strings.of(context)?.get("order_cargo_info_qty")} ${Strings.of(context)?.get("order_cargo_info_unit")}", codeType: Const.QTY_UNIT_CD, mFilter: "", callback: selectQtyUnit).showDialog();
  }

  Future<void> selectWayOn(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "WAY_TYPE_CD" :
          setState(() {
            mData.value.sWayCode = codeModel?.code;
            mData.value.sWayName = codeModel?.codeName;
          });
          break;
      }
    }
  }

  Future<void> showWayOn() async {
    ShowCodeDialogWidget(context:context, mTitle: "${Strings.of(context)?.get("order_cargo_info_way_on")}", codeType: Const.WAY_TYPE_CD, mFilter: "", callback: selectWayOn).showDialog();
  }

  Future<void> selectWayOff(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "WAY_TYPE_CD" :
          setState(() {
            mData.value.eWayCode = codeModel?.code;
            mData.value.eWayName = codeModel?.codeName;
          });
          break;
      }
    }
  }

  Future<void> showWayOff() async {
    ShowCodeDialogWidget(context:context, mTitle: "${Strings.of(context)?.get("order_cargo_info_way_off")}", codeType: Const.WAY_TYPE_CD, mFilter: "", callback: selectWayOff).showDialog();
  }

  Future<void> selectMixSize(CodeModel? codeModel,String? codeType) async {
    if(codeType != "") {
      switch(codeType) {
        case "MIX_SIZE_CD" :
          setState(() {
            mData.value.mixSize = codeModel?.code;
          });
          break;
      }
    }
  }

  Future<void> showMixSize() async {
    ShowCodeDialogWidget(context:context, mTitle: "${Strings.of(context)?.get("order_cargo_info_mix_size")}", codeType: Const.MIX_SIZE_CD, mFilter: "", callback: selectMixSize).showDialog();
  }

  Future<void> setMixYn() async {
    switch(mData.value.mixYn) {
      case "N" :
        tvMixN.value = true;
        tvMixY.value = false;
        llMixSize.value = false;
        mData.value.mixSize = null;
        break;
      case "Y" :
        tvMixN.value = false;
        tvMixY.value = true;
        llMixSize.value = true;
        break;
    }
  }

  Future<void> setReturnYn() async {
    switch(mData.value.returnYn) {
      case "N" :
        tvReturnN.value = true;
        tvReturnY.value = false;
        break;
      case "Y" :
        tvReturnN.value = false;
        tvReturnY.value = true;
        break;
    }
  }

  Future<bool> validation() async {
    if(mData.value.inOutSctn?.isEmpty == true || mData.value.inOutSctn == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }
    if(mData.value.truckTypeCode?.isEmpty == true || mData.value.truckTypeCode == null) {
      Util.toast("${Strings.of(context)?.get("order_cargo_info_truck_type")??"Not Found"}${Strings.of(context)?.get("valid_fail_01")??"Not Found"}");
      return false;
    }
    if(code.value.isEmpty) {
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

  Future<void> setOptionCargo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOptionCargo(
      user.authorization,"Y",
      mData.value.inOutSctn,mData.value.truckTypeCode,mData.value.carTypeCode, mData.value.carTonCode,
      mData.value.itemCode, mData.value.goodsName, mData.value.goodsWeight, mData.value.sWayCode, mData.value.eWayCode
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("setOptionCargo() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_SETTING_CARGO});
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
          print("setOptionCargo() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setOptionCargo() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showResetDialog() async {
   await openCommonConfirmBox(
        context,
        "화주 정보 설정값을 초기화 하시겠습니까?",
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
    await DioService.dioClient(header: true).setOptionCargo(
        user.authorization,
        "Y",
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("OrderCargoInfoPage reset() _response -> ${_response.status} // ${_response.resultMap}");
      await pr?.hide();
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_SETTING_REQUEST});
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
          print("OrderCargoInfoPage reset() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("OrderCargoInfoPage reset() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> tvConfirm() async {
    var validate = await validation();
    if(validate) {
      Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_WORK_CARGO,Const.ORDER_VO: mData.value});
    }
  }

  Future<void> tvSave() async {
    var validate = await validation();
    if(validate) {
      await setOptionCargo();
    }
  }

  Future<void> tvReset() async {
    await showResetDialog();
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: SafeArea(
            child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar: AppBar(
                title: Text(
                      "화물정보",
                      style: CustomStyle.appBarTitleFont(
                          styleFontSize16, Colors.black)
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
                ),
              ),
          body: Obx((){
                 return SingleChildScrollView(
                     child:Container(
                   padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          // 수출입구분
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                                child:Row(
                                  children: [
                                    Text(
                                      "${Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"Not Found"}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    ),
                                    Container(
                                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                        child: Text(
                                          "${Strings.of(context)?.get("essential")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                        )
                                    )
                                  ],
                                )
                            ),
                            Expanded(
                              flex: 6,
                                child: InkWell(
                                  onTap: () async {
                                    if(tvTruckType.value) await showInOutSctn();
                                  },
                                    child: Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    child: Text(
                                        "${mData.value.inOutSctnName?.isNotEmpty == true? mData.value.inOutSctnName : "${Strings.of(context)?.get("select_info")??"Not Found"}"}",
                                      style: CustomStyle.CustomFont(styleFontSize12, mData.value.inOutSctnName?.isNotEmpty == true ? text_color_01 : light_gray3),
                                      textAlign: TextAlign.center,
                                    ),
                                )
                              )
                            )
                          ],
                        ),
                        //운송 유형
                      Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 4,
                                child:Row(
                                  children: [
                                    Text(
                                      "${Strings.of(context)?.get("order_cargo_info_truck_type")??"Not Found"}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    ),
                                    Container(
                                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                        child: Text(
                                          "${Strings.of(context)?.get("essential")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                        )
                                    )
                                  ],
                                )
                            ),
                            Expanded(
                                flex: 6,
                                child: InkWell(
                                    onTap: () async {
                                      await showTruckType();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                      ),
                                      child: Text(
                                        "${mData.value.truckTypeName?.isNotEmpty == true && mData.value.truckTypeName != null ? mData.value.truckTypeName : "${Strings.of(context)?.get("select_info")??"Not Found"}"}",
                                        style: CustomStyle.CustomFont(styleFontSize12, mData.value.truckTypeName?.isNotEmpty == true && mData.value.truckTypeName != null ? text_color_01 : light_gray3),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                )
                            )
                          ],
                          )
                        ),
                        // 차종/톤수
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child:Row(
                                      children: [
                                        Text(
                                          "${Strings.of(context)?.get("order_cargo_info_car")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                            child: Text(
                                              "${Strings.of(context)?.get("essential")??"Not Found"}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                            )
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  if(tvCarType.value) await showCarType();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.carTypeName?.isNotEmpty == true && mData.value.carTypeName != null? mData.value.carTypeName : "${Strings.of(context)?.get("order_cargo_info_car_type")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.carTypeName?.isNotEmpty == true && mData.value.carTypeName != null ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  if(tvCarTon.value) await showCarTon();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.carTonName?.isNotEmpty == true && mData.value.carTonName != null? mData.value.carTonName : "${Strings.of(context)?.get("order_cargo_info_car_ton")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.carTonName?.isNotEmpty == true && mData.value.carTonName != null ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            ))
                                      ],
                                    )
                                )
                              ],
                            )
                        ),
                        // 화물정보
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child:Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${Strings.of(context)?.get("order_cargo_info_cargo")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                            child: Text(
                                              "${Strings.of(context)?.get("essential")??"Not Found"}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                            )
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                        height: CustomStyle.getHeight(35.h),
                                        child: TextField(
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                          textAlign: TextAlign.start,
                                          keyboardType: TextInputType.text,
                                          controller: goodsNameController,
                                          maxLines: 1,
                                          decoration: goodsNameController.text.isNotEmpty
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
                                                goodsNameController.clear();
                                                mData.value.goodsName = "";
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
                                                borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w))
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                borderRadius: BorderRadius.circular(5.h)
                                            ),
                                          ),
                                          onChanged: (value){
                                            mData.value.goodsName = value;
                                          },
                                          maxLength: 50,
                                        )
                                    )
                                )
                              ],
                            )
                        ),
                        //운송 품목
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"Not Found"}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    ),
                                ),
                                Expanded(
                                    flex: 6,
                                    child: InkWell(
                                        onTap: () async {
                                          await showItemLvL1();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                          ),
                                          child: Text(
                                            "${mData.value.itemName?.isNotEmpty == true ? mData.value.itemName : "${Strings.of(context)?.get("select_info")??"Not Found"}"}",
                                            style: CustomStyle.CustomFont(styleFontSize12, mData.value.itemName?.isNotEmpty == true ? text_color_01 : light_gray3),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                    )
                                )
                              ],
                            )
                        ),
                        //적재 중량
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${Strings.of(context)?.get("order_cargo_info_wgt")??"Not Found"}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                height: CustomStyle.getHeight(35.h),
                                                margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                child: TextField(
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                                  textAlign: TextAlign.start,
                                                  keyboardType: TextInputType.number,
                                                  controller: cargoWgtController,
                                                  maxLines: 1,
                                                  decoration: cargoWgtController.text.isNotEmpty
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
                                                        cargoWgtController.clear();
                                                        mData.value.goodsWeight = "";
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
                                                        borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w))
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: text_color_01, width: CustomStyle.getWidth(0.5.w)),
                                                        borderRadius: BorderRadius.circular(5.h)
                                                    ),
                                                  ),
                                                  onChanged: (value){
                                                    mData.value.goodsWeight = value;
                                                  },
                                                  maxLength: 50,
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.weightUnitCode?.isNotEmpty == true ? mData.value.weightUnitCode : "${Strings.of(context)?.get("order_cargo_info_unit")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.weightUnitCode?.isNotEmpty == true ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            )
                                      ],
                                    )
                                )
                              ],
                            )
                        ),
                        //적재 수량
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${Strings.of(context)?.get("order_cargo_info_qty")??"Not Found"}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                height: CustomStyle.getHeight(35.h),
                                                margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                child: TextField(
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                                  textAlign: TextAlign.start,
                                                  keyboardType: TextInputType.number,
                                                  controller: goodsQtyController,
                                                  maxLines: 1,
                                                  decoration: goodsQtyController.text.isNotEmpty
                                                      ? InputDecoration(
                                                    counterText: '',
                                                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
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
                                                        goodsQtyController.clear();
                                                        mData.value.goodsQty = "";
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
                                                    mData.value.goodsQty = value;
                                                  },
                                                  maxLength: 50,
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  await showQtyUnit();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.qtyUnitCode?.isNotEmpty == true ? mData.value.qtyUnitCode : "${Strings.of(context)?.get("order_cargo_info_unit")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.qtyUnitCode?.isNotEmpty == true ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            ))
                                      ],
                                    )
                                )
                              ],
                            )
                        ),
                        // 상/하차 방법
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child:Row(
                                      children: [
                                        Text(
                                          "${Strings.of(context)?.get("order_cargo_info_way_type")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                            child: Text(
                                              "${Strings.of(context)?.get("essential")??"Not Found"}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                            )
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  await showWayOn();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.sWayName?.isNotEmpty == true ? mData.value.sWayName : "${Strings.of(context)?.get("order_cargo_info_way_on")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.sWayName?.isNotEmpty == true ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  await showWayOff();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${mData.value.eWayName?.isNotEmpty == true ? mData.value.eWayName : "${Strings.of(context)?.get("order_cargo_info_way_off")??"Not Found"}"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, mData.value.eWayName?.isNotEmpty == true ? text_color_01 : light_gray3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            ))
                                      ],
                                    )
                                )
                              ],
                            )
                        ),
                        // 혼적여부
                        !isOption.value ?
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child:Row(
                                      children: [
                                        Text(
                                          "${Strings.of(context)?.get("order_cargo_info_mix_type")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                            child: Text(
                                              "${Strings.of(context)?.get("essential")??"Not Found"}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                            )
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                    mData.value.mixYn = "N";
                                                    await setMixYn();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: tvMixN.value?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                  "${Strings.of(context)?.get("order_cargo_info_mix_n")??"Not Found"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, tvMixN.value ? text_box_color_01 : text_box_color_02),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  mData.value.mixYn = "Y";
                                                  await setMixYn();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: tvMixY.value?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${Strings.of(context)?.get("order_cargo_info_mix_y")??"Not Found"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, tvMixY
                                                        .value?text_box_color_01 : text_box_color_02),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            ))
                                      ],
                                    )
                                )
                              ],
                            )
                        ) : const SizedBox(),
                        //혼적크기
                        llMixSize.value ?
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "${Strings.of(context)?.get("order_cargo_info_mix_size")??"Not Found"}",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                ),
                                Expanded(
                                    flex: 6,
                                    child: InkWell(
                                        onTap: () async {
                                          await showMixSize();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: text_color_01,width: CustomStyle.getWidth(0.5)),
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                          ),
                                          child: Text(
                                            "${mData.value.mixSize?.isNotEmpty == true ? mData.value.mixSize : "${Strings.of(context)?.get("select_info")??"Not Found"}"}",
                                            style: CustomStyle.CustomFont(styleFontSize12, mData.value.mixSize?.isNotEmpty == true ? text_color_01 : light_gray3),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                    )
                                )
                              ],
                            )
                        ) : const SizedBox(),
                        // 왕복여부
                        !isOption.value ?
                        Container(
                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child:Row(
                                      children: [
                                        Text(
                                          "${Strings.of(context)?.get("order_cargo_info_return_type")??"Not Found"}",
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                            child: Text(
                                              "${Strings.of(context)?.get("essential")??"Not Found"}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                            )
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  mData.value.returnYn = "N";
                                                  await setReturnYn();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: tvReturnN.value?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${Strings.of(context)?.get("order_cargo_info_return_n")??"Not Found"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, tvReturnN.value?text_box_color_01 : text_box_color_02),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                    mData.value.returnYn = "Y";
                                                    await setReturnYn();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: tvReturnY.value?text_box_color_01 : text_box_color_02,width: CustomStyle.getWidth(0.5)),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                                  ),
                                                  child: Text(
                                                    "${Strings.of(context)?.get("order_cargo_info_return_y")??"Not Found"}",
                                                    style: CustomStyle.CustomFont(styleFontSize12, tvReturnY.value? text_box_color_01 : text_box_color_02),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                            ))
                                      ],
                                    )
                                )
                              ],
                            )
                        ) : const SizedBox()
                      ],
                    )
                ));
              }),
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
                              await tvConfirm();
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
                              await tvReset();
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
                             await setOptionCargo();
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
        ))
    );
  }

}