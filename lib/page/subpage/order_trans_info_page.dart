import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/car_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_customer_page.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class OrderTransInfoPage extends StatefulWidget {

  OrderModel order_vo;
  String? code;

  OrderTransInfoPage({Key? key,required this.order_vo, this.code}):super(key:key);

  _OrderTransInfoPageState createState() => _OrderTransInfoPageState();
}


class _OrderTransInfoPageState extends State<OrderTransInfoPage> {

  ProgressDialog? pr;

  String code = "";
  final orderCarTonCode = "".obs;
  final orderCarTypeCode = "".obs;
  final orderBuyCharge = "".obs;

  final mData = OrderModel().obs;
  final userInfo = UserModel().obs;
  final mCustData = CustomerModel().obs;

  final controller = Get.find<App>();

  static const String TRANS_TYPE_01 = "01";
  static const String TRANS_TYPE_02 = "02";

  bool isOption = false;

  final tvPayType = "".obs;

  final total = 0.obs;
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

  final ivChargeExpand = false.obs;

  late TextEditingController etBuyChargeController;
  late TextEditingController etRegistController;

  @override
  void initState() {
    super.initState();

    etBuyChargeController = TextEditingController();
    etRegistController = TextEditingController();

    Future.delayed(Duration.zero, () async {

      userInfo.value = await controller.getUserInfo();
      if(widget.order_vo != null) {
        mData.value = widget.order_vo!;
      }else{
        mData.value = OrderModel();
      }
      if(widget.code != null) {
        code = widget.code!;
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
  }

  Future<void> initView() async {
    await setTransType();

  }

  Future<void> setTransType() async {
    switch(transType) {
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

        etBuyChargeController.text = orderBuyCharge.value;
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

        etBuyChargeController.text = orderBuyCharge.value;
        etRegistController.text = "";
        mCustData.value = CustomerModel();
        break;
    }
  }

  Future<void> displayChargeInfo() async {
    isCharge.value = !isCharge.value;
    ivChargeExpand.value = isCharge.value;

  }

  Future<void> goToCustomer() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderCustomerPage(sellBuySctn:"02")));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["cust"] != null) {
          await setCustomer(results["cust"]);
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

    //await getUnitChargeComp(user.custId, user.deptId,mData.value.buyCustId, mData.value.buyDeptId);
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
    /*Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CarSearchPage()));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results["car"] != null) {
          await setCar(results["car"]);
        }
      }
    }*/
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
      //  await setPayType("N","미사용");
      }else{
      //  await setPayType(Util.ynToBoolean(data.payType ? "Y" : "N", Util.ynToBoolean(data.payType) ? "사용" : "미사용"));
      }
    }

    String? dncStr = null;
    if(!(data.buyDriverLicenseNumber?.isEmpty == true) && data.buyDriverLicenseNumber != null) {
      try {
        dncStr = await Util.dataEncryption(data.buyDriverLicenseNumber ?? "");
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
        //await showCancleLink();
      }else{
        //await orderAlloc();
      }
    }
  }

  Future<bool> validation() async {
    /*if(transType.value == TRANS_TYPE_01) {
      if(etCustName.text.trim().isEmpty == true) {
        Util.toast(Strings.of(context)?.get("order_trans_info_cust_hint")??"운송사를 지정해주세요._");
        return false;
      }

      if(etKeeper.text.trim().isEmpty == true) {
        Util.toast(Strings.of(context)?.get("order_trans_info_keeper_hint")??"담당자를 지정해주세요._");
        return false;
      }
    }else{
      if(etCarNum.text.trim().isEmpty == true) {
        Util.toast(Strings.of(context)?.get("order_trans_info_driver_hint")??"차량을 지정해주세요._");
        return false;
      }
    }
    if(etBuyCharge.text.trim().isEmpty == true) {
      Util.toast(Strings.of(context)?.get("order_trans_info_charge_hint")??"운임비를 입력해주세요._");
      return false;
    }*/
    return true;
  }

  Widget mainBodyWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20.w)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("order_trans_info_sub_title_01")??"배차_",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              //isOption.value?
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
                        setState(() async {
                          talkYn.value = value;
                        });
                      }
                  )
                ],
              ) //: const SizedBox()
            ],
          ),

        Row(
          children: [
            Expanded(
              flex: 1,
                child: InkWell(
                  onTap: () async {
                    transType.value = TRANS_TYPE_01;
                    await setTransType();
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
        )

        ],
      ),
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
                    Strings.of(context)?.get("order_detail_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(
                        styleFontSize16, styleWhiteCol)
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
              child: //Obx((){
                  Column(
                    children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Strings.of(context)?.get("order_trans_info_total_charge")??"지불운임(소개)",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Text(
                                "${Util.getInCodeCommaWon(total.toString())} 원",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                            ],
                          ),
                        ),
                      CustomStyle.getDivider1(),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            mainBodyWidget()
                          ],
                        ),
                      )
                      ],
                    )
              //})
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
                              //await confirm();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check,
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
                              //await confirm();
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
                              await  openCommonConfirmBox(
                                  context,
                                  "화주 정보 설정값을 초기화 하시겠습니까?",
                                  Strings.of(context)?.get("cancel")??"Not Found",
                                  Strings.of(context)?.get("confirm")??"Not Found",
                                      () {Navigator.of(context).pop(false);},
                                      () async {
                                    Navigator.of(context).pop(false);
                                    //await reset();
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
                ))
        )
    );
  }




}