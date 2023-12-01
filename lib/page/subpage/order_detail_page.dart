import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/car_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/link_page.dart';
import 'package:logislink_tms_flutter/page/subpage/order_trans_info_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:phone_call/phone_call.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class OrderDetailPage extends StatefulWidget {

  OrderModel? order_vo;
  String? code;
  int? position;

  OrderDetailPage({Key? key,this.order_vo, this.code, this.position}):super(key:key);

  _OrderDetailPageState createState() => _OrderDetailPageState();
}


class _OrderDetailPageState extends State<OrderDetailPage> {

  ProgressDialog? pr;

  final mData = OrderModel().obs;

  final controller = Get.find<App>();

  final tvOrderCancel = false.obs;
  final tvReOrder = false.obs;
  final tvAlloc = false.obs;
  final tvAllocCancel = false.obs;
  final tvAllocReg = false.obs;

  final tvOrderState = false.obs;
  final tvAllocState = false.obs;
  final llDriverInfo = false.obs;

  final llStopPointHeader = false.obs;
  final llBottom = false.obs;
  final mRpaUseYn = "".obs;
  final mLinkState = false.obs;
  final tvSendLink = false.obs;
  final tvReceipt = false.obs;

  final isStopPointExpanded = [].obs;
  final isCargoExpanded = [].obs;
  final isEtcExpanded = [].obs;

  late TextEditingController etCarNumController;
  late TextEditingController etDriverNameController;
  late TextEditingController etTelController;
  late TextEditingController etCarTypeController;
  late TextEditingController etCarTonController;

  @override
  void initState() {
    super.initState();

    etCarNumController = TextEditingController();
    etDriverNameController = TextEditingController();
    etTelController = TextEditingController();
    etCarTypeController = TextEditingController();
    etCarTonController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      await initView();
    });

  }

  @override
  void dispose() {
    super.dispose();
    etCarNumController.dispose();
    etDriverNameController.dispose();
    etTelController.dispose();
    etCarTypeController.dispose();
    etCarTonController.dispose();
  }

  Future<void> setOrderState() async {
    if(mData.value.orderState == "09") {
      tvOrderState.value = true;
      tvAllocState.value = false;
      llDriverInfo.value = false;
    }else{
      if(mData.value.driverState != null) {
        tvOrderState.value = false;
        tvAllocState.value = false;
        llDriverInfo.value = true;
      }else{
        tvOrderState.value = false;
        tvAllocState.value = true;
        llDriverInfo.value = false;
      }
    }
  }

  Future<void> _setOrderState(String state) async {
    // 재 오더 시
    // 정보망 전송 까지 다시 보내는것으로 처리
    // Junghwan.Hwang - 2023-08-22

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).stateOrder(
        user.authorization,
        mData.value.orderId,
        state,
        mData.value.call24Cargo,
        mData.value.oneCargo,
        mData.value.manCargo,
        mData.value.call24Charge,
        mData.value.oneCharge,
        mData.value.manCharge
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("_setOrderState() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("오더가 접수되었습니다.");
            await getOrderDetail(mData.value.sellAllocId);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("_setOrderState() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("_setOrderState() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("_setOrderState() getOrder Default => ");
          break;
      }
    });

  }

  Future<void> setAllocState() async {
    llBottom.value = true;
    await setVisibilitySendLink(false);
    print("응애옹애 = >${mData.value.allocState}");
    switch(mData.value.allocState) {
      case "00" :
        if(mData.value.orderState == "09") {
          tvReOrder.value = true;
          await setVisibilitySendLink(false);
          tvOrderCancel.value = false;
          tvAlloc.value = false;
        }else{
          tvReOrder.value = false;
          await setVisibilitySendLink(true);
          tvOrderCancel.value = true;
          tvAlloc.value = true;
        }
        tvAllocCancel.value = false;
        tvAllocReg.value = false;
        break;
      case "01" :
      case "20" :
        if(mData.value.buyLinkYn == "Y") {
          await setVisibilitySendLink(true);
        }
        // 배차, 취소요청
        tvReOrder.value = false;
        tvOrderCancel.value = false;

        tvAlloc.value = false;
        tvAllocCancel.value = true;
        tvAllocReg.value = false;
        break;

      case "04":
      case "05":
      case "12":
      case "21":
        //출발, 도착, 입차, 취소
        llBottom.value = false;
        break;
      case "10":
        //운송사지정
        tvReOrder.value = false;
        tvOrderCancel.value = false;

        if(mData.value.orderState == "00") {
          tvAlloc.value = false;
          tvAllocCancel.value = true;
          tvAllocReg.value = true;
        }else if(mData.value.orderState == "01") {
          tvAlloc.value = false;
          tvAllocCancel.value = true;
          tvAllocReg.value = false;
        }else{
          llBottom.value = false;
        }
        break;
      case "11":
      case "13":
      case "23":
      case "24":
      case "25":
        await setVisibilitySendLink(true);

        // 정보망접수, 정보망접수 완료, 배차실패(화물맨), 배차대기(화물맨), 정보망오류
      if(mData.value.orderState == "00" || mData.value.orderState =="01"){
        tvReOrder.value = false;
        tvOrderCancel.value  = false;
        tvAlloc.value = true;

        tvAllocCancel.value = false;
        tvOrderCancel.value = true;
        tvAllocReg.value = false;
      }else{
        llBottom.value = false;
      }
      break;
    }
  }

  Future<void> cancelLink() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelLink(
      user.authorization,
      mData.value.orderId,
      mData.value.allocId,
      "CANCELALLOC",
      mData.value.linkType,
      "01"
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("정보망 배차가 취소되었습니다.");
            await getOrderDetail(mData.value.sellAllocId??"");
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
    }).catchError((Object obj){
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

  Future showAllocReg() async {
    etCarNumController.text = "";
    etDriverNameController.text = "";
    etTelController.text = "";
    etCarTypeController.text = "";
    etCarTonController.text = "";

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context ){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))
                    ),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(5.0)),
                        decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                        child: Text(
                          '${Strings.of(context)?.get("order_detail_vehicle_dispatch")}',
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                        )
                    ),
                    content: Obx((){
                      return SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 차량번호(필수)
                                Container(
                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(15.h),left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                  child: Row(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(left: CustomStyle.getWidth(20.w), right: CustomStyle.getWidth(20.w), bottom: CustomStyle.getHeight(10.h), top: CustomStyle.getWidth(20.h)),
                                          child: Text(
                                            Strings.of(context)?.get("order_detail_car_num")??"차랑변호_",
                                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                          )
                                      ),
                                      Text(
                                        Strings.of(context)?.get("essential")??"(필수_)",
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                      )
                                    ],
                                  )
                                ),
                                Container(
                                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                    height: CustomStyle.getHeight(35.h),
                                    child: TextField(
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      controller: etCarNumController,
                                      maxLines: 1,
                                      decoration: etCarNumController.text.isNotEmpty
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
                                            etCarNumController.clear();
                                          },
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                          : InputDecoration(
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
                                      ),
                                      onChanged: (value){
                                      },
                                      maxLength: 50,
                                    )
                                ),
                                // 성명/연락처
                                Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    Strings.of(context)?.get("order_detail_driver_name")??"성명_",
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                    child: Text(
                                                      Strings.of(context)?.get("essential")??"(필수_)",
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                    )
                                                  )
                                                ],
                                              )
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                                height: CustomStyle.getHeight(35.h),
                                                child: TextField(
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                  textAlign: TextAlign.start,
                                                  keyboardType: TextInputType.text,
                                                  controller: etDriverNameController,
                                                  maxLines: 1,
                                                  decoration: etDriverNameController.text.isNotEmpty
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
                                                        etDriverNameController.clear();
                                                      },
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        size: 18,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                                      : InputDecoration(
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
                                                  ),
                                                  onChanged: (value){
                                                  },
                                                  maxLength: 50,
                                                )
                                            ),
                                          ],
                                        )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_driver_tel")??"연락처_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                                  height: CustomStyle.getHeight(35.h),
                                                  child: TextField(
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                    textAlign: TextAlign.start,
                                                    keyboardType: TextInputType.phone,
                                                    controller: etTelController,
                                                    maxLines: 1,
                                                    decoration: etDriverNameController.text.isNotEmpty
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
                                                          etDriverNameController.clear();
                                                        },
                                                        icon: const Icon(
                                                          Icons.clear,
                                                          size: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                        : InputDecoration(
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
                                                    ),
                                                    onChanged: (value){
                                                    },
                                                    maxLength: 50,
                                                  )
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                // 차종 / 톤급
                                Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(20.w),right: CustomStyle.getWidth(20.w)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_type_code")??"차종_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: text_color_01,width: 0.5.w),
                                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                ),
                                                child: Text(
                                                  "차종입니다..",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_ton_code")??"톤급_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: text_color_01,width: 0.5.w),
                                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                ),
                                                child: Text(
                                                  "톤급입니다..",
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: CustomStyle.getHeight(60.h),
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(20.h)),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: Container(
                                                    color: sub_btn,
                                                    child: Text(
                                                      Strings.of(context)?.get(
                                                          "cancel") ?? "취소_",
                                                      style: CustomStyle
                                                          .CustomFont(
                                                          styleFontSize16,
                                                          Colors.white),
                                                    )
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  var validation = await allocRegValid();
                                                  if(validation){
                                                    if(!(Util.regexCarNumber(etCarNumController.text.trim()))) {
                                                      Util.toast("차량번호를 확인해 주세요.");
                                                    }else{
                                                      CarModel car = CarModel();
                                                      car.carNum = etCarNumController.text.trim();
                                                      car.driverName = etDriverNameController.text.trim();
                                                      car.mobile = etTelController.text.trim();
                                                      await setAllocReg(car);
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                    color: main_btn,
                                                    child: Text(
                                                      Strings.of(context)?.get(
                                                          "confirm") ?? "확인_",
                                                      style: CustomStyle
                                                          .CustomFont(
                                                          styleFontSize16,
                                                          Colors.white),
                                                    )
                                                )
                                            )
                                        )
                                      ],
                                  ),
                                )

                              ]
                          )
                      );
                    })
                );
              }
          );
        }
    );
  }

  Future<bool> allocRegValid() async {
    if(etCarNumController.text.trim().isEmpty) {
      Util.toast("차량번호를 입력해주세요.");
      return false;
    }
    if(etDriverNameController.text.trim().isEmpty) {
      Util.toast("파주성명을 입력해 주세요.");
      return false;
    }
    if(etTelController.text.trim().isEmpty) {
      Util.toast("연락처를 입력해 주세요.");
      return false;
    }
    return true;
  }

  Future<void> setAllocReg(CarModel car) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).orderAllocReg(
      user.authorization,
      mData.value.orderId,
      mData.value.buyCustId,
      mData.value.buyDeptId,
      mData.value.buyStaff,
      mData.value.buyStaffTel,
      car.vehicId,
      car.driverId,
      car.carNum,
      mData.value.carTonCode,
      mData.value.carTypeCode,
      car.driverName,
      car.mobile
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("setOrderCancel() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            await getOrderDetail(mData.value.sellAllocId);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("setOrderCancel() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setOrderCancel() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setOrderCancel() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getOrderDetail(String? allocId) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderDetail(
        user.authorization,
        mData.value.orderId,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("setOrderCancel() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              try {
                var list = _response.resultMap?["data"] as List;
                List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
                if(itemsList.length > 0){
                  mData.value = itemsList[0];
                  //await rpaUseYn();
                }else{
                  openOkBox(context,"삭제되었더나 완료된 오더입니다.", Strings.of(context)?.get("confirm")??"Not Found", () { Navigator.of(context).pop(false);});
                }
              } catch (e) {
                print(e);
              }
            }else{
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("setOrderCancel() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setOrderCancel() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setOrderCancel() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setVisibilitySendLink(bool val) async {
    if(mRpaUseYn.value == "Y") {
      if(mLinkState.value) {
        // 정보망 전송 버튼 활성화, 비활성화
        // 수정 메뉴 정하기 전까지 일단 활성화 하지 말 것
        tvSendLink.value = val? true : false;
      }else{
        tvSendLink.value = false;
      }
    }else{
      tvSendLink.value = false;
    }
  }

  Future<void> showDriverState() async {
    if(mData.value.allocState == "05") {
      return;
    }
    ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_detail_driver_state_edit")??"", codeType: Const.DRIVER_STATE, mFilter: "", callback: selectDriverState).showDialog();
  }

  void selectDriverState(CodeModel? codeModel,String? codeType) {
    if(codeType != ""){
      switch(codeType) {
        case 'DRIVER_STATE':
          if(codeModel?.code == "21") {
            if(!(mData.value.allocState == "01")) {
              Util.toast("운행이 시작된 후엔 취소할 수 없습니다.");
              return;
            }
          }
          setAllocState();
          break;
      }
      setState(() {});
    }
  }

  Future<void> goToSendLink() async {
    if(mData.value.carTonName == "톤") {
      if(Util.checkTonOver(mData.value.carTonName??"0톤".split("톤")[0], mData.value.goodsWeight??"0.0")){
        Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LinkPage(order_vo: mData.value)));

        if(results != null && results.containsKey("code")) {
          if (results["code"] == 200) {
            if(results["link"] != null) {
              if(results["link"] == "Y") {
                Navigator.of(context).pop(false);
              }
            }
          }
        }
      }else{
        Util.toast("과적은 정보망에 전송할 수 없습니다.");
      }
    }else{
      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LinkPage(order_vo: mData.value)));

      if(results != null && results.containsKey("code")) {
        if (results["code"] == 200) {
          if(results["link"] != null) {
            if(results["link"] == "Y") {
              Navigator.of(context).pop(false);
            }
          }
        }
      }
    }
  }

  Future<void> goToReceipt() async {
    //await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ReceiptPage(order_vo: mData.value)));
  }

  Future<void> initView() async {
    if(widget.order_vo != null) {
      mData.value = widget.order_vo!;
    }else{
      mData.value = OrderModel();
    }
    await setOrderState();
    await setAllocState();

    if(mData.value.stopCount != 0) {
      llStopPointHeader.value = true;
    }else{
      llStopPointHeader.value = false;
    }

    if(!(mData.value.receiptYn == "N")) {
      tvReceipt.value = true;
    }else{
      tvReceipt.value = false;
    }
  }

  Widget topWidget() {
    return Column(
      children: [
        // 접수
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(10.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
             tvOrderState.value ?
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        mData.value.orderStateName??"접수",
                        style: CustomStyle.CustomFont(styleFontSize14, order_state_01,font_weight: FontWeight.w700),
                      )
                  )
              ) : const SizedBox(),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: Text(
                      mData.value.sellCustName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: Text(
                      mData.value.sellDeptName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ),
              Expanded(
                  flex: 4,
                  child: Text(
                    "${Util.getInCodeCommaWon(mData.value.sellCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                  )
              ),
            ],
          ),
        ) ,
        // 운송사 접수
        tvAllocState.value ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        mData.value.allocStateName??"운송사접수",
                        style: CustomStyle.CustomFont(styleFontSize14, order_state_01,font_weight: FontWeight.w700),
                      )
                  )
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: Text(
                      mData.value.linkName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: Text(
                      mData.value.buyCustName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: Text(
                      mData.value.buyDeptName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    "${Util.getInCodeCommaWon(mData.value.buyCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 경유비(지불)
        Util.equalsCharge(mData.value.wayPointCharge??"0")?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_way_point_charge")??"경유지_(지불)",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: mData.value.wayPointMemo??"경유지 메모",
                          style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        )
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(mData.value.wayPointCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ):const SizedBox(),
        // 대기료(지불)
        Util.equalsCharge(mData.value.stayCharge??"0") ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_stay_charge")??"대기료_(지불)",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: mData.value.stayMemo??"대기료 메모",
                          style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        )
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(mData.value.wayPointCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 수작업비(지불)
        Util.equalsCharge(mData.value.handWorkCharge??"0") ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_hand_work_charge")??"수작업비_(지불)",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: mData.value.handWorkMemo??"수작업비 메모",
                          style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        )
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(mData.value.handWorkCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 회차료(지불)
        Util.equalsCharge(mData.value.roundCharge ?? "0") ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_round_charge")??"회차료_(지불)",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: mData.value.roundMemo??"회차료 메모",
                          style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        )
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(mData.value.roundCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        // 기타추가비(지불)
        Util.equalsCharge(mData.value.otherAddCharge??"0") ?
        Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w), right: CustomStyle.getWidth(10.w), top: CustomStyle.getHeight(5.h),bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                      child: Text(
                        Strings.of(context)?.get("order_trans_info_other_add_charge")??"기타추가비_(지불)",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      )
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: mData.value.otherAddMemo??"기타추가비 메모",
                          style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        )
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    " + ${Util.getInCodeCommaWon(mData.value.roundCharge??"0")}원",
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
            ],
          ),
        ) : const SizedBox(),
        Container(
          height: CustomStyle.getHeight(5.h),
          color: line,
        )
      ],
    );
  }

  Widget driverInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("order_detail_sub_title_05")?? "차주_정보",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              tvReceipt.value?
              InkWell(
                  onTap: () async {
                    await goToReceipt();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                    decoration: BoxDecoration(
                        border: Border.all(color: order_state_01,width: 1.w),
                        borderRadius: BorderRadius.all(Radius.circular(5.w))
                    ),
                    child: Text(
                      "인수증 확인",
                      style: CustomStyle.CustomFont(styleFontSize12, order_state_01),
                    ),
                  )
              ):const SizedBox()
            ],
          ),
        ),
        CustomStyle.getDivider1(),
        Container(
          padding: EdgeInsets.all(10.w),
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              InkWell(
                  onTap: (){

                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: order_state_01,
                            width: 1.w
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5.w))
                    ),
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                    child: Text(
                      mData.value.driverStateName??"출발",
                      style: CustomStyle.CustomFont(styleFontSize12, order_state_01),
                    ),
                  )
              )
            ],
          ),
        ),
        CustomStyle.getDivider1(),
        Container(
          padding: EdgeInsets.all(10.w),
          child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                          child: Row(
                            children: [
                              Text(
                                mData.value.driverName == null ?"" : "${mData.value.driverName} 차주님",
                                style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
                              ),
                              InkWell(
                                  onTap: () async {
                                    if(Platform.isAndroid) {
                                      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                      AndroidDeviceInfo info = await deviceInfo.androidInfo;
                                      if (info.version.sdkInt >= 23) {
                                        await PhoneCall.calling("${mData.value.driverTel}");
                                      }else{
                                        await launch("tel://${mData.value.driverTel}");
                                      }
                                    }else{
                                      await launch("tel://${mData.value.driverTel}");
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                    child: Text(
                                      Util.makePhoneNumber(mData.value.driverTel),
                                      style: CustomStyle.CustomFont(styleFontSize14, addr_type_text),
                                    ),
                                  )
                              )
                            ],
                          )
                      ),
                      Text(
                        mData.value.carNum??"",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                    ],
                  )
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap:(){

                    } ,
                    child: Icon(Icons.location_on,size: 40.h,color: swipe_edit_btn)
                  ),
                )
              ],
            )
        ),
        CustomStyle.getDivider1(),
              //입차
              mData.value.enterDate != null ?
              Container(
                padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h), top: CustomStyle.getHeight(10.h), right: CustomStyle.getWidth(10.w), left: CustomStyle.getWidth(10.w)),
                child:  Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_reg_enter")??"입차",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        child: Text(
                          mData.value.enterDate??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                  ],
                )
              ) : const SizedBox(),
              // 출발
              mData.value.startDate != null ?
              Container(
                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h), top: CustomStyle.getHeight(5.h), right: CustomStyle.getWidth(10.w), left: CustomStyle.getWidth(10.w)),
                  child:  Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("order_reg_start")??"출발",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          child: Text(
                            mData.value.startDate??"",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ) : const SizedBox(),
              // 도착
              mData.value.finishDate != null ?
              Container(
                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10.h), top: CustomStyle.getHeight(5.h), right: CustomStyle.getWidth(10.w), left: CustomStyle.getWidth(10.w)),
                  child:  Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("order_reg_end")??"도착",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          child: Text(
                            mData.value.finishDate??"",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ) : const SizedBox(),
        Container(
          height: CustomStyle.getHeight(5.h),
          color: line,
        )
      ],
    );
  }

  Widget transInfoWidget() {
    return Container(
      alignment: Alignment.centerLeft,
        child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("order_detail_sub_title_01")??"",
                  style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
                ),
                //tvSendLink.value ?
                InkWell(
                    onTap: () async {
                      await goToSendLink();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                      decoration: BoxDecoration(
                          border: Border.all(color: order_state_01,width: 1.w),
                          borderRadius: BorderRadius.all(Radius.circular(5.w))
                      ),
                      child: Text(
                        "정보망",
                        style: CustomStyle.CustomFont(styleFontSize12, order_state_01),
                      ),
                    )
                ) //: const SizedBox()
              ],
            )
          ),
          CustomStyle.getDivider1(),
          Container(
            padding: EdgeInsets.all(10.w),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                    height: 250.h,
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.0.h)),
                    padding: EdgeInsets.all(5.0.h),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: light_gray1
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${Util.splitSDate(mData.value.sDate)} 상차",
                            style: CustomStyle.CustomFont(styleFontSize14, text_box_color_01),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                            alignment: Alignment.center,
                            child: Text(
                              mData.value.sComName??"",
                              style: CustomStyle.CustomFont(
                                  styleFontSize16, text_color_01,
                                  font_weight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w),right: CustomStyle.getWidth(10.w), bottom: CustomStyle.getHeight(5.h)),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              mData.value.sStaff??"",
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, text_color_02,
                                  font_weight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w),right: CustomStyle.getWidth(10.w), bottom: CustomStyle.getHeight(10.h)),
                            alignment: Alignment.centerLeft,
                          child: !(mData.value.sStaff?.isEmpty == true) || !(mData.value.sTel?.isEmpty == true)?
                          InkWell(
                            onTap: (){

                            },
                              child: Text(
                              Util.makePhoneNumber(mData.value.sTel),
                              style: CustomStyle.CustomFont(styleFontSize14, addr_type_text)
                          )) : const SizedBox()),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                            child: Text(
                              mData.value.sAddr??"",
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, text_color_02,
                                  font_weight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            )
                          ),
                          !(mData.value.sAddrDetail?.isEmpty == true) ?
                          Container(
                            alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                            child: Text(
                              mData.value.sAddrDetail??"",
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, text_color_02,
                                  font_weight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            )
                          ) : const SizedBox(),
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              !(mData.value.sMemo?.isEmpty == true) ? mData.value.sMemo??"-" : "-",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            ),
                          )
                        ])),
              ),
              Expanded(
                flex: 1,
                child: Icon(Icons.arrow_right_alt,size: 21.w,color: const Color(0xff6d7780)),
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                      height: 250.h,
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(5.0.h)),
                      padding: EdgeInsets.all(5.0.h),
                      decoration: const BoxDecoration(
                          borderRadius:  BorderRadius.all(Radius.circular(10)),
                          color: light_gray1
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${Util.splitSDate(mData.value.eDate)} 상차",
                              style: CustomStyle.CustomFont(styleFontSize14, text_box_color_01),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
                                alignment: Alignment.center,
                                child: Text(
                                  mData.value.eComName??"",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, text_color_01,
                                      font_weight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                )
                            ),
                            Container(
                                padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w),right: CustomStyle.getWidth(10.w), bottom: CustomStyle.getHeight(5.h)),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  mData.value.eStaff??"",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, text_color_02,
                                      font_weight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                )
                            ),
                            Container(
                                padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w),right: CustomStyle.getWidth(10.w), bottom: CustomStyle.getHeight(10.h)),
                                alignment: Alignment.centerLeft,
                                child: !(mData.value.eStaff?.isEmpty == true) || !(mData.value.eTel?.isEmpty == true)?
                                InkWell(
                                    onTap: (){

                                    },
                                    child: Text(
                                        Util.makePhoneNumber(mData.value.eTel),
                                        style: CustomStyle.CustomFont(styleFontSize14, addr_type_text)
                                    )) : const SizedBox()),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                child: Text(
                                  mData.value.eAddr??"",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, text_color_02,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                )
                            ),
                            !(mData.value.eAddrDetail?.isEmpty == true) ?
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                child: Text(
                                  mData.value.eAddrDetail??"",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, text_color_02,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                )
                            ) : const SizedBox(),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                !(mData.value.eMemo?.isEmpty == true) ? mData.value.eMemo??"-" : "-",
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                            )
                          ]
                      )
                  )
                )
              ],
            )
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                Icon(Icons.more_vert, size: 24.w, color: text_color_02),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                  child: Text(
                    Util.makeDistance(mData.value.distance),
                    style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                  ),
                ),
                Text(
                  Util.makeTime(mData.value.time??0),
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                )
              ],
            )
          ),
          Container(
            height: CustomStyle.getHeight(5.h),
            color: line,
          )
        ],
      )
    );
  }

  Widget stopPointPannelWidget() {
    isStopPointExpanded.value = List.filled(1, false);
    return Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          initialOpenPanelValue: 0,
          children: [
            ExpansionPanelRadio(
              value: index,
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(40.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("경유지 정보",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
                      ],
                    ));
              },
              body: Obx((){
                return Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(20.w)),
                    color: Colors.white,
                    child: Row(
                        children : [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                                    child: Text(
                                      "경유지",
                                      style: CustomStyle.CustomFont(styleFontSize12, text_box_color_01),
                                    )
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                    child: Text(
                                      mData.value.eComName??"",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    )
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                    child: Text(
                                      "상차",
                                      style: CustomStyle.CustomFont(styleFontSize14, order_state_04),
                                    ),
                                  )
                                ],
                              ),
                              !(mData.value.eStaff?.isEmpty == true) || !(mData.value.eTel?.isEmpty == true) ?
                              Row(
                                children: [
                                  Text(
                                    mData.value.eStaff??"",
                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                  ),
                                  InkWell(
                                    child: Container(
                                      padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                                      child: Text(
                                        Util.makePhoneNumber(mData.value.eTel),
                                        style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                                      ),
                                    ),
                                  )
                                ],
                              ) : const SizedBox(),
                              !(mData.value.eAddrDetail?.isEmpty == true)?
                              Text(
                                mData.value.eAddr??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ) : const SizedBox(),
                              !(mData.value.eAddrDetail?.isEmpty == true) ?
                                  Text(
                                    mData.value.eAddrDetail??"",
                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                  ) : const SizedBox()
                            ],
                          )
                        ]
                    )
                );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isStopPointExpanded[index] = !isStopPointExpanded[index];
          },
        );
      }),
    );
  }

  Widget cargoInfoWidget() {
    isCargoExpanded.value = List.filled(1, false);
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
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(40.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("화물 정보",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
                      ],
                    ));
              },
              body: Obx((){
              return Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: line,
                      width: 1.w
                    )
                  )
                ),
                child: Column(
                  children: [
                    // 첫번째줄
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                border: Border.all(color: line, width: 1.w)
                            ),
                            child: Text(
                                Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"수출입구분_",
                              style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            ),
                          )
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                          decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: line, width: 1.w
                                ),
                                right: BorderSide(
                                    color: line, width: 1.w
                                ),
                                top: BorderSide(
                                    color: line, width: 1.w
                                ),
                              )
                          ),
                          child: Text(
                              mData.value.inOutSctnName??"",
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                          ),
                        )
                      ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    top: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_truck_type")??"운송유형_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    top: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.truckTypeName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    ),
                    // 두번째줄
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    left: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_car_ton")??"톤수_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.carTonName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_car_type")??"차종_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.carTypeName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    ),
                    // 세번째줄
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    left: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_cargo")??"화물정보_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.goodsName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    ),
                    // 네번째줄
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    left: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"운송품목_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.itemName??"-",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_wgt")??"적재중량_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                "${mData.value.goodsWeight} ${mData.value.weightUnitCode}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    ),
                    // 다섯번째줄
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    left: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_way_on")??"상차방법_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.sWayName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_way_off")??"하차방법_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.eWayName??"",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    ),
                    // 여섯번째줄
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    left: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_mix_type")??"혼적여부_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.mixYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_mix_y")}":"${Strings.of(context)?.get("order_cargo_info_mix_n")}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                Strings.of(context)?.get("order_cargo_info_return_type")??"왕복여부_",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                    right: BorderSide(
                                        color: line, width: 1.w
                                    ),
                                  )
                              ),
                              child: Text(
                                mData.value.returnYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_return_y")}":"${Strings.of(context)?.get("order_cargo_info_return_n")}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                            )
                        )
                      ],
                    )
                  ],
                )
              );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isCargoExpanded[index] = !isCargoExpanded[index];
          },
        );
      }),
    );
  }

  Widget etcPannelWidget() {

    isEtcExpanded.value = List.filled(1, false);
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
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(40.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("기타",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
                      ],
                    ));
              },
              body: Obx((){
                return Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(20.w)),
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
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              ),
                              Container(
                                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 50.w,
                                height: CustomStyle.getHeight(80.h),
                                padding: EdgeInsets.all(10.w),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: line, width: 1.w),
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Text(
                                  !(mData.value.driverMemo?.isEmpty == true) ? mData.value.driverMemo??"-" : "-",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                child: Text(
                                  Strings.of(context)?.get("order_request_info_reg_memo")??"요청사항_",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                )
                              ),
                              Container(
                                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 50.w,
                                height: CustomStyle.getHeight(80.h),
                                padding: EdgeInsets.all(10.w),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                decoration: BoxDecoration(
                                    border: Border.all(color: line, width: 1.w),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Text(
                                  !(mData.value.reqMemo?.isEmpty == true) ? mData.value.reqMemo??"-" : "-",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                ),
                              )
                            ],
                          )
                        ]
                    )
                );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isEtcExpanded[index] = !isEtcExpanded[index];
          },
        );
      }),
    );
  }

  Future<void> setOrderCancel(String state) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelOrder(
      user.authorization,
      mData.value.orderId,
      state,
      mData.value.call24Cargo,
      mData.value.oneCargo,
      mData.value.manCargo,
      mData.value.call24Charge,
      mData.value.oneCharge,
      mData.value.manCharge
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("setOrderCancel() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("오더가 취소되었습니다.");
            //await getOr
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("setOrderCancel() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setOrderCancel() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setOrderCancel() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> showOrderCancel() async {
      openCommonConfirmBox(
          context,
          "오더를 취소하시겠습니까?",
          Strings.of(context)?.get("cancel")??"Not Found",
          Strings.of(context)?.get("confirm")??"Not Found",
              () {Navigator.of(context).pop(false);},
              () async {
            Navigator.of(context).pop(false);
            await setOrderCancel("09");
          }
      );
  }

  Future<void> showReOrder() async {
    openCommonConfirmBox(
        context,
        "오더를 접수하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await _setOrderState("00");
        }
    );
  }

  Future<void> goToAlloc() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderTransInfoPage(order_vo: mData.value)));

    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        Util.toast("배차가 완료되었습니다.");
        await getOrderDetail(mData.value.sellAllocId);
      }
    }
  }

  Future<void> showAllocCancel() async {
    openCommonConfirmBox(
        context,
        mData.value.buyLinkYn == "Y" ? "정보망 배차를 취소하시겠습니까?" : "배차를 취소하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          if(mData.value.buyLinkYn == "Y") {
            await cancelLink();
          }else{
            await _setOrderState("00");
          }
        }
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
              child: Obx((){
                return SingleChildScrollView(
                    child: Column(
                      children: [
                        topWidget(),
                        llDriverInfo.value ? driverInfoWidget() : const SizedBox(),
                        transInfoWidget(), // 배차 정보
                        llStopPointHeader.value ? stopPointPannelWidget() : const SizedBox(),
                        cargoInfoWidget(), // 화물 정보
                        Container(
                          height: 5.h,
                          color: line,
                        ),
                        etcPannelWidget()
                      ],
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
                    tvOrderCancel.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showOrderCancel();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: sub_btn),
                                child: Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("order_detail_order_cancel")??"Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      )
                            )
                        )
                    ):const SizedBox(),
                    tvReOrder.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showReOrder();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_re_order")??"Not Found",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                    //tvAlloc.value ?
                    Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await goToAlloc();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc")??"Not Found",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) ,//: const SizedBox(),
                    tvAllocCancel.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showAllocCancel();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: sub_btn),
                                child:Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc_cancel")??"Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                    tvAllocReg.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showAllocReg();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: main_color),
                                child:Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_detail_alloc_reg")??"Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                ),
                            )
                        )
                    ) : const SizedBox(),
                  ],
                ));
          }),
        )
    );
  }

}