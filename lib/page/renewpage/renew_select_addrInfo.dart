import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_nomal_addr_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_template_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cargo_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cust_user_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/utils/util.dart';

class RenewSelectAddrinfo extends StatefulWidget {
  OrderModel data;
  String title;

  RenewSelectAddrinfo({Key? key,required this.data, required this.title}):super(key:key);

  @override
  _RenewSelectAddrinfoState createState() => _RenewSelectAddrinfoState();
}
class _RenewSelectAddrinfoState extends State<RenewSelectAddrinfo> {

  final chargeCheck = "".obs;
  final mData = OrderModel().obs;
  final mDataOrderStopList = List.empty(growable: true).obs;

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
      if(widget.data != null) {
        var order = widget.data;
        mData.value = OrderModel(
            reqCustId: order?.reqCustId??"",
            reqCustName: order?.reqCustName??"",
            reqDeptId: order?.reqDeptId??"",
            reqDeptName: order?.reqDeptName??"",
            reqStaff: order?.reqStaff??"",
            reqTel: order?.reqTel??"",
            reqAddr: order?.reqAddr??"",
            reqAddrDetail: order?.reqAddrDetail??"",
            custId: order?.custId,
            custName: order?.custName,
            deptId: order?.deptId,
            deptName: order?.deptName,
            inOutSctn: order?.inOutSctn,
            inOutSctnName: order?.inOutSctnName,
            truckTypeCode: order?.truckTypeCode,
            truckTypeName: order?.truckTypeName,

            sComName: order?.sComName,
            sSido: order?.sSido,
            sGungu: order?.sGungu,
            sDong: order?.sDong,
            sAddr: order?.sAddr,
            sAddrDetail: order?.sAddrDetail,
            sDate: order?.sDate,
            sStaff: order?.sStaff,
            sTel: order?.sTel,
            sMemo: order?.sMemo,
            eComName: order?.eComName,
            eSido: order?.eSido,
            eGungu: order?.eGungu,
            eDong: order?.eDong,
            eAddr: order?.eAddr,
            eAddrDetail: order?.eAddrDetail,
            eDate: order?.eDate,
            eStaff: order?.eStaff,
            eTel: order?.eTel,
            eMemo: order?.eMemo,
            sLat: order?.sLat,
            sLon: order?.sLon,
            eLat: order?.eLat,
            eLon: order?.eLon,
            sTimeFreeYN: order.sTimeFreeYN,
            eTimeFreeYN: order.eTimeFreeYN,
            goodsName: order?.goodsName,
            goodsWeight: order?.goodsWeight,
            weightUnitCode: order?.weightUnitCode,
            weightUnitName: order?.weightUnitName,
            goodsQty: order?.goodsQty,
            qtyUnitCode: order?.qtyUnitCode,
            qtyUnitName: order?.qtyUnitName,
            sWayCode: order?.sWayCode,
            sWayName: order?.sWayName,
            eWayCode: order?.eWayCode,
            eWayName: order?.eWayName,
            mixYn: order?.mixYn,
            mixSize: order?.mixSize,
            returnYn: order?.returnYn,
            carTonCode: order?.carTonCode,
            carTonName: order?.carTonName,
            carTypeCode: order?.carTypeCode,
            carTypeName: order?.carTypeName,
            chargeType: order?.chargeType,
            chargeTypeName: order?.chargeTypeName,
            distance: order?.distance,
            time: order?.time,
            reqMemo: order?.reqMemo,
            driverMemo: order?.driverMemo,
            itemCode: order?.itemCode,
            itemName: order?.itemName,
            regid: order?.regid,
            regdate: order?.regdate,
            stopCount: order?.stopCount,
            sellCustId: order?.sellCustId,
            sellDeptId: order?.sellDeptId,
            sellStaff: order?.sellStaff,
            sellStaffName: order?.sellStaffName,
            sellStaffTel: order?.sellStaffTel,
            sellCustName: order?.sellCustName,
            sellDeptName: order?.sellDeptName,
            sellCharge: order?.sellCharge,
            sellFee: order?.sellFee,
            sellWeight: order?.sellWeight,
            sellWayPointMemo: order?.sellWayPointMemo,
            sellWayPointCharge: order?.sellWayPointCharge,
            sellStayMemo: order?.sellStayMemo,
            sellStayCharge: order?.sellStayCharge,
            sellHandWorkMemo: order?.sellHandWorkMemo,
            sellHandWorkCharge: order?.sellHandWorkCharge,
            sellRoundMemo: order?.sellRoundMemo,
            sellRoundCharge: order?.sellRoundCharge,
            sellOtherAddMemo: order?.sellOtherAddMemo,
            sellOtherAddCharge: order?.sellOtherAddCharge,
            custPayType: order?.custPayType,
            buyCharge: order?.buyCharge,
            buyFee: order?.buyFee,
            wayPointMemo: order?.wayPointMemo,
            wayPointCharge: order?.wayPointCharge,
            stayMemo: order?.stayMemo,
            stayCharge: order?.stayCharge,
            handWorkMemo: order?.handWorkMemo,
            handWorkCharge: order?.handWorkCharge,
            roundMemo: order?.roundMemo,
            roundCharge: order?.roundCharge,
            otherAddMemo: order?.otherAddMemo,
            otherAddCharge: order?.otherAddCharge,
            unitPrice: order?.unitPrice,
            unitPriceType: order?.unitPriceType,
            unitPriceTypeName: order?.unitPriceTypeName,
            payType: order?.payType,
            reqPayYN: order?.reqPayYN,
            reqPayDate: order?.reqPayDate,
            talkYn: order?.talkYn,
            orderStopList: order?.orderStopList,
            reqStaffName: order?.reqStaffName,
            call24Cargo: order?.call24Cargo,
            manCargo: order?.manCargo,
            oneCargo: order?.oneCargo,
            call24Charge: order?.call24Charge,
            manCharge: order?.manCharge,
            oneCharge: order?.oneCharge
        );
        if(order.orderStopList != null && order.orderStopList!.length > 0) {
          for(var item in order.orderStopList!){
            mDataOrderStopList.add(item);
          }
        }
      }
      if(mData.value.sAddr != null && mData.value.sAddr?.isNotEmpty == true) {
        llNonSAddr.value = false;
        llSAddr.value = true;
        isSAddr.value = true;
      }
      if(mData.value.eAddr != null && mData.value.eAddr?.isNotEmpty == true) {
        llNonEAddr.value = false;
        llEAddr.value = true;
        isEAddr.value = true;
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
          mData.value.sComName = OData.sComName;
          mData.value.sSido = OData.sSido;
          mData.value.sGungu = OData.sGungu;
          mData.value.sDong = OData.sDong;
          mData.value.sAddr = OData.sAddr;
          mData.value.sAddrDetail = OData.sAddrDetail;
          mData.value.sStaff = OData.sStaff;
          mData.value.sTel = OData.sTel;
          mData.value.sMemo = OData.sMemo;
          mData.value.sLat = OData.sLat;
          mData.value.sLon = OData.sLon;
          llNonSAddr.value = false;
          llSAddr.value = true;
          isSAddr.value = true;
        });
        break;
      case Const.RESULT_WORK_EADDR :
        OrderModel OData = results[Const.ORDER_VO];
        setState(() {
          mData.value.eComName = OData.eComName;
          mData.value.eSido = OData.eSido;
          mData.value.eGungu = OData.eGungu;
          mData.value.eDong = OData.eDong;
          mData.value.eAddr = OData.eAddr;
          mData.value.eAddrDetail = OData.eAddrDetail;
          mData.value.eStaff = OData.eStaff;
          mData.value.eTel = OData.eTel;
          mData.value.eMemo = OData.eMemo;
          mData.value.eLat = OData.eLat;
          mData.value.eLon = OData.eLon;
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        });
        break;
      case Const.RESULT_WORK_STOP_POINT :
        OrderModel OData = results[Const.ORDER_VO];
        setState(() {
          if(mDataOrderStopList == null) mDataOrderStopList.value = List.empty(growable: true);
          mDataOrderStopList?.addAll(OData.orderStopList??List.empty(growable: true));
        });
        await setStopPoint();
        break;
    }
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

  Future<void> goToRegEAddr() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo: mData.value,code:Const.RESULT_WORK_EADDR)));
    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToRegEAddr() -> ${results[Const.RESULT_WORK]}");
        await setActivityResult(results);
      }
    }
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

  Future<void> setStopPoint() async {
    if(mDataOrderStopList.isEmpty != true && !mDataOrderStopList.isNull ){
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
          mData.value.sStaff = "";
          mData.value.sTel = "";
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
          mData.value.eStaff = "";
          mData.value.eTel = "";
          llNonEAddr.value = false;
          llEAddr.value = true;
          isEAddr.value = true;
        }
      });
    }
  }

  /**
   * 상하차 Function End
   */

  Future<void> goToCustomer() async {
    Map<String, dynamic> results = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) => OrderCustomerPage(sellBuySctn: "01", code:"")
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
      mData.value.sellCustId = data.custId;
      mData.value.sellCustName = data.custName;

      mData.value.sellDeptId = data.deptId;
      mData.value.sellDeptName = data.deptName;

      mData.value.custMngName = data.custMngName;
      mData.value.custMngMemo = data.custMngMemo;

      mData.value.reqAddr = data.bizAddr;
      mData.value.reqAddrDetail = data.bizAddrDetail;
    });
  }

  Future<void> goToCustUser() async {
    if (mData.value.sellCustId != null) {
      Map<String, dynamic> results = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => OrderCustUserPage(
                  mode: MODE.USER,
                  custId: mData.value.sellCustId,
                  deptId: mData.value.sellDeptId)));

      if (results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          await setCustUser(results["custUser"]);
        }
      }
    }
  }

  Future<void> setCustUser(CustUserModel data) async {
    setState(() {
      mData.value.sellStaff = data.userId;
      mData.value.sellStaffTel = data.mobile;
      mData.value.sellStaffName = data.userName;
    });
  }

  /**
   * Widget Start
   */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        backgroundColor: sub_color,
        appBar: AppBar(
          title: Text(
              widget.title,
              style: CustomStyle.appBarTitleFont(styleFontSize16, Colors.white)
          ),
          backgroundColor: renew_main_color2,
          toolbarHeight: 50.h,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop({'code': 100});
            },
            color: styleWhiteCol,
            icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.white),
          ),
          actions: [
            InkWell(
                onTap: () {
                  if(mData.value.orderStopList != null && mData.value.orderStopList!.length > 0) mData.value.orderStopList = List.empty(growable: true);
                  List<StopPointModel> stopList = mDataOrderStopList.value.cast<StopPointModel>();
                  mData.value.orderStopList = stopList;
                  Navigator.of(context).pop({'code': 200, Const.RESULT_WORK: Const.RESULT_WORK_STOP_POINT, Const.ORDER_VO: mData.value});
                },
                child: Container(
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(20)),
                    child: InkWell(
                      child: Text(
                          "저장",
                          style: CustomStyle.appBarTitleFont(
                              styleFontSize16, Colors.white)
                      ),
                    )
                )
            )
          ],
        ),
        body: SafeArea(
            child: Obx(() {
              return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10), vertical: CustomStyle.getHeight(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Expanded(
                            flex: 7,
                              child: InkWell(
                                  onTap: () async {
                                    await goToNomalAddr(Const.RESULT_WORK_SADDR);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: CustomStyle.getHeight(5),
                                        horizontal: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        border: Border.all(color: light_gray23, width: 1)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                                backgroundColor: renew_main_color2,
                                                radius: 30,
                                                child: Text(
                                                  "상차",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white, font_weight: FontWeight.w600),
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
                                                      text: llSAddr.value ? "${mData.value.sComName??"-"}" : "상차지를 선택해주세요.",
                                                      style: CustomStyle.CustomFont(
                                                          llSAddr.value ? styleFontSize16 : styleFontSize14,
                                                          llSAddr.value ? text_color_01 : light_gray23,
                                                          font_weight: llSAddr.value ? FontWeight.w700 : FontWeight.w500),
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
                                                                    flex: 1,
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
                                                                          text: "${mData.value.sAddr}",
                                                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
                                                                      ),
                                                                    )
                                                                ),
                                                              ]
                                                          ),
                                                          mData.value.sAddrDetail != null && mData.value.sAddrDetail?.isEmpty == false ?
                                                          Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Icon(
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
                                                                              text: "${mData.value.sAddrDetail}",
                                                                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
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
                                                                              mData.value.sStaff != null && mData.value.sStaff?.isEmpty == false ?
                                                                              Text(
                                                                                  "${mData.value.sStaff}",
                                                                                  textAlign: TextAlign.start,
                                                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
                                                                              ) : const SizedBox(),
                                                                              mData.value.sTel != null && mData.value.sTel?.isEmpty == false ?
                                                                              Container(
                                                                                  margin: EdgeInsets.only(
                                                                                      left: mData.value.sStaff != null && mData.value.sStaff?.isEmpty == false ?
                                                                                      CustomStyle.getWidth(5) : CustomStyle.getWidth(0)),
                                                                                  child: Text("${Util.makePhoneNumber(mData.value.sTel)}",
                                                                                      textAlign: TextAlign.start,
                                                                                      style: CustomStyle.CustomFont(
                                                                                          styleFontSize15,
                                                                                          Colors.black,
                                                                                          font_weight: FontWeight.w400)
                                                                                  )
                                                                              ) : const SizedBox(),
                                                                            ]
                                                                        )
                                                                    )

                                                                  ]
                                                              )
                                                          ),
                                                          mData.value.sMemo != null && mData.value.sMemo?.isEmpty == false ?
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
                                                                      margin: EdgeInsets.only(
                                                                          top: CustomStyle.getHeight(5)),
                                                                      child: RichText(
                                                                        textAlign: TextAlign.start,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 3,
                                                                        text: TextSpan(
                                                                            text: "${mData.value.sMemo}",
                                                                            style: CustomStyle.CustomFont(
                                                                                styleFontSize14,
                                                                                Colors.black,
                                                                                font_weight: FontWeight.w400)
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
                              )
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  goToRegSAddr();
                                },
                                  child: Container(
                                  alignment: Alignment.center,
                                  height: llSAddr.value ? mData.value.sAddrDetail != null && mData.value.sAddrDetail?.isEmpty == false ? CustomStyle.getHeight(105) : CustomStyle.getHeight(85) : CustomStyle.getHeight(70),
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(3),top: CustomStyle.getHeight(10)),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: light_gray23
                                  ),
                                  child: Icon(
                                    Icons.people,
                                    color: Colors.black,
                                    size: 18.h,
                                  ),
                                )
                              )
                            )
                          ]
                        ),
                        InkWell(
                            onTap: () async {
                                await addStopPoint();
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(15)),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "경유지 추가",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize15, Colors.black,
                                          font_weight: FontWeight.w600),
                                    ),
                                    const Icon(
                                      Icons.add,
                                      size: 21,
                                      color: Colors.black,
                                    )
                                  ],
                                )
                            )),
                        mDataOrderStopList?.isNotEmpty == true ?
                        Container(
                            margin: EdgeInsets.only(
                                bottom: CustomStyle.getHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                    mDataOrderStopList!.length,
                                        (index) {
                                      var item = mDataOrderStopList?[index];
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
                                                          margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                                          decoration: BoxDecoration(
                                                            borderRadius: index == 0 ?
                                                            const BorderRadius.only(
                                                                topLeft: Radius.circular(5),
                                                                topRight: Radius.circular(5)
                                                            ) :
                                                            index + 1 == mDataOrderStopList!.length ? const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)) : BorderRadius.zero,
                                                            color: item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle,
                                                          ),
                                                          child: Stack(
                                                              children: [
                                                                Positioned(
                                                                    top: 15,
                                                                    child: Icon(
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
                                                                            padding: EdgeInsets.symmetric(
                                                                                vertical: CustomStyle.getHeight(3),
                                                                                horizontal: CustomStyle.getWidth(7)),
                                                                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                                                                                border: Border.all(color: text_box_color_01, width: 1.w)
                                                                            ),
                                                                            child: Text("경유지 ${(index + 1)}",
                                                                              style: CustomStyle.CustomFont(styleFontSize10, text_box_color_01),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            padding: EdgeInsets.symmetric(
                                                                                vertical: CustomStyle.getHeight(3),
                                                                                horizontal: CustomStyle.getWidth(7)),
                                                                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(3)),
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                                                                                border: Border.all(color: item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle, width: 1.w)
                                                                            ),
                                                                            child: Text(
                                                                              item?.stopSe == "S" ? "상차" : "하차",
                                                                              style: CustomStyle.CustomFont(styleFontSize10, item?.stopSe == "S" ? renew_main_color2 : rpa_btn_cancle),
                                                                            ),
                                                                          ),
                                                                        ]
                                                                    ),
                                                                    InkWell(
                                                                        onTap: () {
                                                                          mDataOrderStopList?.removeAt(index);
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
                                                                margin: EdgeInsets.only(
                                                                    left: CustomStyle.getWidth(5)),
                                                                child: RichText(
                                                                  textAlign: TextAlign.start,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  text: TextSpan(
                                                                    text: "${item?.eComName}",
                                                                    style: CustomStyle.CustomFont(
                                                                        styleFontSize14,
                                                                        Colors.black,
                                                                        font_weight: FontWeight.w600),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                                child: RichText(
                                                                  textAlign: TextAlign.start,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  text: TextSpan(
                                                                    text: "${item?.eAddr}",
                                                                    style: CustomStyle.CustomFont(
                                                                        styleFontSize12,
                                                                        Colors.black,
                                                                        font_weight: FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ),
                                                              item?.eAddrDetail != null && item?.eAddrDetail?.isNotEmpty == true ?
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    left: CustomStyle.getWidth(5)),
                                                                child: RichText(
                                                                  textAlign: TextAlign.center,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  text: TextSpan(
                                                                    text: "${item?.eAddrDetail}",
                                                                    style: CustomStyle.CustomFont(
                                                                        styleFontSize12,
                                                                        Colors.black,
                                                                        font_weight: FontWeight.w400),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 7,
                              child: InkWell(
                                  onTap: () async {
                                    await goToNomalAddr(Const.RESULT_WORK_EADDR);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: CustomStyle.getHeight(5),
                                        horizontal: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        border: Border.all(color: light_gray23, width: 1)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                                backgroundColor: rpa_btn_cancle,
                                                radius: 30,
                                                child: Text(
                                                  "하차",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white, font_weight: FontWeight.w600),
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
                                                      text: llEAddr.value ? "${mData.value.eComName??"-"}" : "하차지를 선택해주세요.",
                                                      style: CustomStyle.CustomFont(llEAddr.value ? styleFontSize16 : styleFontSize14, llEAddr.value ? text_color_01 : light_gray23, font_weight: llEAddr.value ? FontWeight.w700 : FontWeight.w500),
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
                                                                  flex: 1,
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
                                                                        text: "${mData.value.eAddr}",
                                                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
                                                                    ),
                                                                  )
                                                              ),
                                                            ],
                                                          ),
                                                          mData.value.eAddrDetail != null && mData.value.eAddrDetail?.isEmpty == false ?
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 1,
                                                                  child: Icon(
                                                                    Icons.home_work,
                                                                    size: 21.h,
                                                                    color: light_gray23,
                                                                  )
                                                              ),
                                                              Expanded(
                                                                  flex: 7,
                                                                  child: RichText(
                                                                    text: TextSpan(
                                                                        text: "${mData.value.eAddrDetail}",
                                                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
                                                                    ),
                                                                  )
                                                              )
                                                            ],
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
                                                                        mData.value.eStaff != null && mData.value.eStaff?.isEmpty == false ?
                                                                        Text(
                                                                            "${mData.value.eStaff}",
                                                                            textAlign: TextAlign.start,
                                                                            style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400)
                                                                        ) : const SizedBox(),
                                                                        mData.value.eTel != null && mData.value.eTel?.isEmpty == false ?
                                                                        Container(
                                                                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                                            child: Text(
                                                                                "${Util.makePhoneNumber(mData.value.eTel)}",
                                                                                textAlign: TextAlign.start,
                                                                                style: CustomStyle.CustomFont(styleFontSize15, Colors.black, font_weight: FontWeight.w400)
                                                                            )
                                                                        ) : const SizedBox(),
                                                                      ],
                                                                    )
                                                                )
                                                              ]
                                                          )),
                                                          mData.value.eMemo != null && mData.value.eMemo?.isEmpty == false ?
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
                                                                        text: "${mData.value.eMemo}",
                                                                        style: CustomStyle.CustomFont(
                                                                            styleFontSize14,
                                                                            Colors.black,
                                                                            font_weight: FontWeight.w400)
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
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: (){
                                      goToRegEAddr();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: llEAddr.value ? mData.value.eAddrDetail != null && mData.value.eAddrDetail?.isEmpty == false ? CustomStyle.getHeight(105) : CustomStyle.getHeight(85) : CustomStyle.getHeight(70),
                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3)),
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          color: light_gray23
                                      ),
                                      child: Icon(
                                        Icons.people,
                                        color: Colors.black,
                                        size: 18.h,
                                      ),
                                    )
                                )
                            )
                          ]
                        )

                      ],
                    ),
                  ));
            })
        )
    ));
    }
}