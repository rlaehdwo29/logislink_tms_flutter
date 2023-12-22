import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/unit_charge_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_cust_user_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:logislink_tms_flutter/widget/show_select_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderRequestInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  OrderRequestInfoPage({Key? key, required this.order_vo,this.code}):super(key:key);

  _OrderRequestInfoPageState createState() => _OrderRequestInfoPageState();
}

class _OrderRequestInfoPageState extends State<OrderRequestInfoPage> {

  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mData = OrderModel().obs;
  final code = "".obs;

  final mUserList = List.empty(growable: true).obs;

  final ChargeCheck = "".obs;

  final isOption = false.obs;
  final etRegMemo = "".obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if(widget.order_vo == null) {
        mData.value = OrderModel();
      }else{
        mData.value = widget.order_vo;
      }
      if(widget.code == null) {
        code.value = "";
      }else{
        code.value = widget.code!;
      }

      ChargeCheck.value = "";

      await initView();
    });

  }

  Future<void> initView() async {
    isOption.value = !(widget.code?.isEmpty??true);
  }

  Future<void> goToCustomer() async {
    Map<String, dynamic> results = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) => OrderCustomerPage(
                sellBuySctn: "01",
                code: code.value)
        )
    );

    if (results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        bool res = results["nonCust"]??false;
        if(res) {
          ChargeCheck.value = "N";
        }
        await setCustomer(results["cust"]);
        setState(() {});
      }
    }
  }

  Future<void> setCustomer(CustomerModel data) async {
    mData.value.sellCustId = data.custId;
    mData.value.sellCustName = data.custName;

    mData.value.sellDeptId = data.deptId;
    mData.value.sellDeptName = data.deptName;

    mData.value.custMngName = data.custMngName;
    mData.value.custMngMemo = data.custMngMemo;

    mData.value.reqAddr = data.bizAddr;
    mData.value.reqAddrDetail = data.bizAddrDetail;

    await getCustUser();
    await getUnitChargeCnt();
    await getUnitChargeData();

  }

  Future<void> getUnitChargeCnt() async {
    if(mData.value.sellCustId == null || mData.value.sellDeptId == null || mData.value.sellCustId == "" || mData.value.sellDeptId == ""){
      return;
    }

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
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
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["msg"] == "Y") {
            ChargeCheck.value = "Y";
          }else{
            mData.value.sellCharge = "0";
            ChargeCheck.value = "N";
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
          print("getUnitChargeCnt() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeCnt() getOrder Default => ");
          break;
      }
    });

  }

  bool validation() {
    if(mData.value.sellCustName.isNull == true || mData.value.sellCustName?.trim().isEmpty == true) {
      Util.toast("거래처를 지정해주세요.");
      return false;
    }
    return true;
  }

  bool validate() {
    bool result = true;
    if(ChargeCheck.value == "N" || ChargeCheck.value == ""){
    //단가표 적용 유무
      result = false;
    }

    if(mData.value.chargeType == "" || mData.value.chargeType == null) {
      result = false;
    }

    if(mData.value.sellCustId == "" || mData.value.sellCustId == null) {
      result = false;
    }

    if(mData.value.sellDeptId == "" || mData.value.sellDeptId == null) {
      result = false;
    }

    if(mData.value.sSido == "" || mData.value.sSido == null) {
      result = false;
    }

    if(mData.value.sGungu == "" || mData.value.sGungu == null) {
      result = false;
    }

    if(mData.value.sDong == "" || mData.value.sDong == null) {
      result = false;
    }

    if(mData.value.eSido == "" || mData.value.eSido == null) {
      result = false;
    }

    if(mData.value.eGungu == "" || mData.value.eGungu == null) {
      result = false;
    }

    if(mData.value.eDong == "" || mData.value.eDong == null) {
      result = false;
    }

    if(mData.value.carTonCode == "" || mData.value.carTonCode == null) {
      result = false;
    }

    if(mData.value.carTypeCode == "" || mData.value.carTypeCode == null) {
      result = false;
    }

    if(mData.value.sDate == "" || mData.value.sDate == null) {
      result = false;
    }

    if(mData.value.eDate == "" || mData.value.eDate == null) {
      result = false;
    }

    return result;

  }

  Future<void> getUnitChargeData() async {
    if(validate() == false) {
      return;
    }

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTmsUnitCharge(
        user.authorization,
        mData.value.chargeType,
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
      logger.d("getUnitChargeData() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            UnitChargeModel value = _response.resultMap?["data"];
            mData.value.sellCharge = value.unit_charge??"0";
          }else{
            mData.value.sellCharge = "0";
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
          print("getUnitChargeData() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUnitChargeData() getOrder Default => ");
          break;
      }
    });

}

Future<void> getCustUser() async {
    if(mData.value.sellCustId == null || mData.value.sellDeptId == null || mData.value.sellCustId == "" || mData.value.sellDeptId == "") {
      // #1 신규 거래처 등록인 경우 거래처 담당자가 없는경우
      // 없으므로 그냥 초기화 처리 진행
      await setCustUser(CustUserModel());
    }

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCustUser(
        user.authorization,
        mData.value.sellCustId,
        mData.value.sellDeptId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mUserList.length > 0) mUserList.clear();
            if(list.length > 0) {
              List<CustUserModel> itemsList = list.map((i) => CustUserModel.fromJSON(i)).toList();
              mUserList.addAll(itemsList);
              if(mUserList.length == 1) {
                setCustUser(mUserList.value[0]);
              }else{
                setCustUser(CustUserModel());
              }
            }
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
          print("getCustUser() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCustUser() getOrder Default => ");
          break;
      }
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
    mData.value.sellStaff = data.userId;
    mData.value.sellStaffTel = data.mobile;
    mData.value.sellStaffName = data.userName;
  }

  void selectItem(CodeModel? codeModel,String? codeType) {
    print("dddddddd=>${codeModel?.code} // ${codeModel?.codeName} // $codeType");
    if(codeType != "") {
      switch (codeType) {
        case 'CAR_TON_CD' :
          mData.value.carTonCode = codeModel?.code;
          mData.value.carTonName = codeModel?.codeName;
          break;
        case 'CAR_TYPE_CD':
          mData.value.carTypeCode = codeModel?.code;
          mData.value.carTypeName = codeModel?.codeName;
          break;
      }
    }
    setState(() {});
  }

  Future<void> oriCarType() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_request_info_car_type_name")??"", codeType: Const.CAR_TYPE_CD, mFilter: mData.value.truckTypeCode, callback: selectItem).showDialog();
  }

  Future<void> oriCarTon() async {
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_request_info_car_ton_name")??"", codeType: Const.CAR_TON_CD, mFilter: mData.value.truckTypeCode, callback: selectItem).showDialog();
  }

  Widget requestInfoBody () {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20.w),vertical: CustomStyle.getHeight(10.h)),
        child: Column(
          children: [
            // 거래처명
            Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                child: Row(
                children: [
                  Text(
                    Strings.of(context)?.get("order_request_info_cust")??"Not Found",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                  Text(
                    Strings.of(context)?.get("essential")??"Not Found",
                    style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                  )
                ],
              )
            ),
            Container(
                height: CustomStyle.getHeight(40.h),
                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h)),
                decoration: BoxDecoration(
                    border: Border.all(color: text_box_color_02),
                  borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                ),
                child:  InkWell(
                onTap: () async {
                  await goToCustomer();
                },
                child :Row(
                  children: [
                    Expanded(
                      flex: 9,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                          child: Text(
                            mData.value.sellCustName != null && mData.value.sellCustName?.isEmpty != true? mData.value.sellCustName??"" : Strings.of(context)?.get("order_request_info_cust_hint")??"Not Found",
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.search, size: 24.h, color: const Color(0xffa7a7a7),
                        )
                    )
                  ],
                )
            )
          ),
          // 담당부서
            Container(
                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                child: Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_request_info_dept")??"Not Found",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                    Text(
                      Strings.of(context)?.get("essential")??"Not Found",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                    )
                  ],
                )
            ),
            Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h)),
              height: CustomStyle.getHeight(40.h),
              decoration: BoxDecoration(
                  border: Border.all(color: text_box_color_02),
                  borderRadius: BorderRadius.all(Radius.circular(5.0.h))),
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: CustomStyle.getWidth(10.w)),
                              child: Text(
                                mData.value.sellDeptName ?? "",
                                style: CustomStyle.CustomFont(
                                    styleFontSize12, text_color_01),
                              )))
                    ],
                  ))),
          // 담당자 / 연락처
            Container(
                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h)),
                child: Row(
              children: [
                // 담당자
                Expanded(
                  flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.0.w)),
                        child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Strings.of(context)?.get("order_request_info_staff")??"Not Found",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                    ),
                    InkWell(
                        onTap: () async {
                          await goToCustUser();
                        },
                        child : Container(
                            height: CustomStyle.getHeight(40.h),
                            decoration: BoxDecoration(
                                border: Border.all(color: text_box_color_02),
                                borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                        child: Text(
                                          "담당자 지정",
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_04),
                                        )
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.search, size: 24.h, color: const Color(0xffa7a7a7),
                                    )
                                )

                              ],
                            )
                        )
                    )
                  ]))
                ),
                // 연락처
                    Expanded(
                      flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3.0.w)),
                            child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Strings.of(context)?.get("order_request_info_staff_tel")??"Not Found",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      ),
                      Container(
                              height: CustomStyle.getHeight(40.h),
                              decoration: BoxDecoration(
                                  border: Border.all(color: text_box_color_02),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0.h)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                      child: Text(
                                        Util.makePhoneNumber(mData.value.sellStaffTel),
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  )
                                ],
                              )
                          )
                    ]))
                    ),
              ])),
            // 거래처등급 / 거래처등급사유
            !(isOption == true) ? Container(
                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h)),
            child: Row(
                children: [
                  // 거래처등급
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(right: CustomStyle.getWidth(3.0.w)),
                          child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Strings.of(context)?.get("order_request_info_cust_mng_name")??"Not Found",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                ),
                                Container(
                                        height: CustomStyle.getHeight(40.h),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: text_box_color_02),
                                            borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                                child: Text(
                                                  mData.value.custMngName??"",
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                )
                                            )
                                          ],
                                        )
                                    )
                              ]))
                  ),
                  // 거래처 등급사유
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3.0.w)),
                          child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Strings.of(context)?.get("order_request_info_cust_mng_memo")??"Not Found",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                ),
                               Container(
                                        height: CustomStyle.getHeight(40.h),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: text_box_color_02),
                                            borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                                child: Text(
                                                  mData.value.custMngMemo??"",
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                )
                                            )
                                          ],
                                        )
                                    )
                              ]))
                  ),
                ])):const SizedBox(),
            // 차종 / 톤급
            !(isOption == true) ? Container(
                margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h)),
                child: Row(
                children: [
                  // 차종
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(right: CustomStyle.getWidth(3.0.w)),
                          child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Strings.of(context)?.get("order_request_info_car_type_name")??"Not Found",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                ),
                                InkWell(
                                    onTap: () async {
                                      await oriCarType();
                                    },
                                    child : Container(
                                        height: CustomStyle.getHeight(40.h),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: text_box_color_02),
                                            borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                                child: Text(
                                                  mData.value.carTypeName??"",
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                )
                                            )
                                          ],
                                        )
                                    )
                                )
                              ]))
                  ),
                  // 톤급
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(left: CustomStyle.getWidth(3.0.w)),
                          child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Strings.of(context)?.get("order_request_info_car_ton_name")??"Not Found",
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                ),
                                InkWell(
                                    onTap: () async {
                                      await oriCarTon();
                                    },
                                    child : Container(
                                        height: CustomStyle.getHeight(40.h),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: text_box_color_02),
                                            borderRadius: BorderRadius.all(Radius.circular(5.0.h))
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                                child: Text(
                                                  mData.value.carTonName??"",
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                )
                                            )
                                          ],
                                        )
                                    )
                                )
                              ]))
                  ),
                ])):const SizedBox(),
          ])
    );
  }

  Widget requestEtcBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
          child:Text(
            Strings.of(context)?.get("order_request_info_sub_title_02")??"Not Found",
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          )
        ),
          CustomStyle.getDivider1(),
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
            child: Text(
              Strings.of(context)?.get("order_request_info_reg_memo")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            )
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
          child: TextField(
            style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            onChanged: (value){
              etRegMemo.value = value;
            },
            decoration: InputDecoration(
                counterText: '',
                hintText: Strings.of(context)?.get("order_request_info_reg_memo_hint")??"Not Found",
                hintStyle:CustomStyle.greyDefFont(),
                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(10.h)
                ),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                    borderRadius: BorderRadius.circular(10.h)
                ),
            ),
          ))
      ],
    );
  }

  Future<void> confirm() async {
    if(validation()) {
      Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_WORK_REQUEST,Const.ORDER_VO:mData.value,Const.UNIT_CHARGE_CNT:ChargeCheck.value});
    }
  }

  Future<void> save() async {
    if(validation()) {
      await pr?.show();
      Logger logger = Logger();
      UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).setOptionRequest(
          user.authorization,
          "Y",
          mData.value.sellCustId,
          mData.value.sellDeptId,
          mData.value.sellStaff,
          mData.value.sellStaffTel,
          mData.value.reqAddr,
          mData.value.reqAddrDetail,
          mData.value.reqMemo
      ).then((it) async {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("save() _response -> ${_response.status} // ${_response.resultMap}");
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
            print("save() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("save() getOrder Default => ");
            break;
        }
      });
    }
  }

  Future<void> reset() async {
    await pr?.show();
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOptionRequest(
        user.authorization,
        "Y",
        null,
        null,
        null,
        null,
        null,
        null,
        null
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("reset() _response -> ${_response.status} // ${_response.resultMap}");
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
          print("reset() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("reset() getOrder Default => ");
          break;
      }
    });
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
          backgroundColor: sub_color,
            resizeToAvoidBottomInset:false,
          appBar:PreferredSize(
              preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
              child: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_request_info_title")??"Not Found",
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
                return SizedBox(
                    child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(20.w)),
                              child: Text(
                                Strings.of(context)?.get("order_request_info_sub_title_01")??"Not Found",
                                style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w600)
                              ),
                            ),
                            CustomStyle.getDivider1(),
                            requestInfoBody(),
                            Container(
                              height: 5.h,
                              color: order_reg_line
                            ),
                            requestEtcBody()
                          ],
                        )
                    )
                );
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
                  (isOption.value == true)? Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            await confirm();
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
                  (isOption.value == true)? Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            await  openCommonConfirmBox(
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
              ));
          }),
        )
    );
  }
  
}