import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_link_current_model.dart';
import 'package:logislink_tms_flutter/common/model/order_link_status_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPage extends StatefulWidget {

  OrderModel order_vo;

  LinkPage({Key? key,required this.order_vo}):super(key:key);

  _LinkPageState createState() => _LinkPageState();
}


class _LinkPageState extends State<LinkPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mData = OrderModel().obs;
  final status = OrderLinkStatusModel().obs;
  final list = List.empty(growable: true).obs;

  final m24Call = false.obs;
  final mHwaMull = false.obs;
  final mOneCall = false.obs;
  final mRpaPay = "".obs; // ,처리 안함
  //final rpaPay = "".obs; // ,처리

  final count = 0.obs;

  late TextEditingController etRpaPayController;


  final carRegist = true.obs;
  final modify = true.obs;
  final cancel = true.obs;

  final infoTitle = false.obs;
  final dispatch = false.obs;
  final regist = false.obs;

  final badge = false.obs;

  final llCharge = false.obs;

  final tvRpaTitle = "".obs;
  final rpaDate = "".obs;

  @override
  void initState(){
    super.initState();
    etRpaPayController = TextEditingController();
    mRpaPay.value = "0";

    Future.delayed(Duration.zero, () async {
      await initView();
      await statusLink();
    });
  }

  @override
  void dispose() {
    super.dispose();
    etRpaPayController.dispose();
  }

  Future<void> initView() async {
    if(widget.order_vo != null) {
      mData.value = widget.order_vo!;
    }else{
      mData.value = OrderModel();
    }
  }

  Future<void> statusLink() async{
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).statusNewLink(
        user.authorization,
        mData.value.orderId,
      ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("statusLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              status.value = OrderLinkStatusModel.fromJSON(it.response.data["data"]);
              await currentLink();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("statusLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("statusLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("statusLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> currentLink() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).currentNewLink(
      user.authorization,
      mData.value.orderId,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("currentLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              var mList = _response.resultMap?["data"] as List;
              if(list.length > 0) list.clear();
              if(mList.length > 0) {
                List<OrderLinkCurrentModel> itemsList = mList.map((i) => OrderLinkCurrentModel.fromJSON(i)).toList();
                list.addAll(itemsList);
              }
              for(int i = 0; i < list.length; i++) {
                if(Const.CALL_24_KEY_NAME == list[i].linkCd) {
                  m24Call.value = true;
                }else if(Const.ONE_CALL_KEY_NAME == list[i].linkCd) {
                  mOneCall.value = true;
                } else if(Const.HWA_MULL_KEY_NAME == list[i].linkCd) {
                  mHwaMull.value = true;
                }
              }

              if(status.value.order_id != null) {
                if(!(status.value.call24Status == "E")) {
                  if(m24Call.value == false) {
                    OrderLinkCurrentModel dum24Call = OrderLinkCurrentModel();
                    dum24Call.linkCd = Const.CALL_24_KEY_NAME;
                    list.add(dum24Call);
                  }
                }else{
                  if(m24Call.value) {
                    for(int i = 0; i < list.length; i++) {
                      if(list[i].linkCd == Const.CALL_24_KEY_NAME) {
                        list.removeAt(i);
                      }
                    }
                  }
                }

                if(!(status.value.oneCallStatus == "E")) {
                  if(mOneCall.value == false) {
                    OrderLinkCurrentModel oneCall = OrderLinkCurrentModel();
                    oneCall.linkCd = Const.ONE_CALL_KEY_NAME;
                    list.add(oneCall);
                  }

                }else{
                  if(mOneCall.value) {
                    for(int j = 0; j < list.length; j++) {
                      if(list[j].linkCd == Const.ONE_CALL_KEY_NAME) {
                        list.removeAt(j);
                      }
                    }
                  }
                }

                if(!(status.value.manStatus == "E")) {
                  if(mHwaMull.value == false) {
                    OrderLinkCurrentModel hwaMull = OrderLinkCurrentModel();
                    hwaMull.linkCd = Const.HWA_MULL_KEY_NAME;
                    list.add(hwaMull);
                  }
                }else{
                  if(mHwaMull.value) {
                    for(int k = 0; k < list.length; k++) {
                      if(list[k].linkCd == Const.HWA_MULL_KEY_NAME) {
                        list.removeAt(k);
                      }
                    }
                  }
                }
              list.sort((a,b) => int.parse(a.linkCd).compareTo(int.parse(b.linkCd)));
              }
              await initView();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("currentLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("currentLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("currentLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> registRpa(OrderLinkCurrentModel data) async {
    if(mRpaPay.value == "0" || mRpaPay.value == "" || mRpaPay.value == null) {
      Util.toast("지불운임을 입력해 주세요.");
      return;
    }

    String cd;
    String text = "";

    if(Const.CALL_24_KEY_NAME == data.linkCd) {
      cd = "24Cargo";
      text = "24시콜 정보망에 등록하시겠습니까?";
    }else if(Const.ONE_CALL_KEY_NAME == data.linkCd) {
      cd = "oneCargo";
      text = "원콜 정보망에 등록하시겠습니까?";
    }else if(Const.HWA_MULL_KEY_NAME == data.linkCd) {
      cd = "manCargo";
      text = "화물맨 정보망에 등록하시겠습니까?";
    }else{
      cd = "";
    }

    await openCommonConfirmBox(
        context,
        "금액: ${etRpaPayController.text}원\n$text",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await modLink("N",cd,true);
        }
    );

  }

  Future<void> modLink(String allocChargeYn, String linkCd, bool flag) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).modNewLink(
      user.authorization,
      mData.value.orderId,
      mRpaPay.value,
      mData.value.orderState,
      linkCd,
      allocChargeYn
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("modLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(flag) {
              await statusLink();
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("modLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("modLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("modLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> cancelLink(String? rpaPay,String? linkCd, bool flag) async {
    if(rpaPay == null) count.value--;

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelNewLink(
        user.authorization,
        mData.value.orderId,
        rpaPay,
        "09",
        linkCd
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(flag) {
              await statusLink();
            }else{
              count.value--;
            }
            if(count.value == 1) {
              Navigator.of(context).pop({'code':200,'link':'Y'});
            }
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

  Future<void> confirmLink(OrderLinkCurrentModel data) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).confirmNewLink(
        user.authorization,
        data.orderId,
        data.allocCharge,
        data.linkCd,
        data.carNum,
        data.carType,
        data.carTon,
        data.driverName,
        data.driverTel
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("confirmLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
              count.value--;
              if(count.value == 1) {
                Navigator.of(context).pop({'code':200,'link':'Y'});
              }
          }
        }
      }catch(e) {
        print("confirmLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("confirmLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("confirmLink() getOrder Default => ");
          break;
      }
    });
  }

  Widget topWidget() {
    etRpaPayController.text = Util.getInCodeCommaWon(mRpaPay.value);
      return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
              child: Text(
                Strings.of(context)?.get("send_link_pay")??"지불운임_",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01, font_weight: FontWeight.w700),
              )
            ),
            Container(
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(20.w)),
                height: CustomStyle.getHeight(40.h),
                child: TextFormField(
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  controller: etRpaPayController,
                  maxLines: 1,
                  decoration: etRpaPayController.text.isNotEmpty
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
                    suffix: Text(
                      "원",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        etRpaPayController.clear();
                        mRpaPay.value = "0";
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
                    hintText: Strings.of(context)?.get("send_link_fare_hint"),
                    hintStyle:CustomStyle.greyDefFont(),
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
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
                  onChanged: (value) async {
                    if(value.length > 0) {
                      etRpaPayController.text = Util.getInCodeCommaWon(int.parse(value.trim().replaceAll(",", "")).toString());
                      mRpaPay.value = etRpaPayController.text.replaceAll(",", "");
                    }else{
                      mRpaPay.value = "0";
                      etRpaPayController.text = "0";
                    }
                  },
                  maxLength: 50,
                )
            )
          ],
        )
    );
  }

  Future<void> modifyRpa(OrderLinkCurrentModel data) async {

    if(mRpaPay.isEmpty == true || mRpaPay.value == null) {
      Util.toast("지불운임을 입력해 주세요");
      return;
    }

    String cd = "";
    String textHeader = "";
    String text = "수정하시겠습니까?";

    if(Const.CALL_24_KEY_NAME == data.linkCd) {
      cd = "24Cargo";
      textHeader = "24시콜: ";
    }else if(Const.ONE_CALL_KEY_NAME == data.linkCd) {
      cd = "oneCargo";
      textHeader = "원콜: ";
    }else if(Const.HWA_MULL_KEY_NAME == data.linkCd) {
      cd = "manCargo";
      textHeader = "화물맨: ";
    }else{
      cd = "";
    }

    openCommonConfirmBox(
        context,
        "${textHeader}${etRpaPayController.text}원\n${text}",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await modLink("N", cd, true);
        }
    );

  }

  Future<void> cancelRpa(OrderLinkCurrentModel data) async {
    String? res = data.allocCharge;
    String? cd;
    String? text;

    if(Const.CALL_24_KEY_NAME == data.linkCd) {
      cd = "24Cargo";
      text = "24시콜 정보망 전송 \n\n취소하시겠습니까?";
    }else if(Const.ONE_CALL_KEY_NAME == data.linkCd) {
      cd = "oneCargo";
      text = "원콜 정보망 전송\n\n취소하시겠습니까?";
    }else if(Const.HWA_MULL_KEY_NAME == data.linkCd) {
      cd = "manCargo";
      text = "화물맨 정보망 전송\n\n취소하시겠습니까?";
    }else{
      cd = "";
      text ="";
    }

    openCommonConfirmBox(
        context,
        "${text}",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await cancelLink(res, cd, true);
        }
    );

  }

  Future<void> carConfirmRpa(OrderLinkCurrentModel data) async {
    String textHeader = "${data.carNum}\t\t${data.carType}\t\t${data.carTon}";
    String textSub = "${data.driverName}\t\t${Util.makePhoneNumber(data.driverTel)}";
    String text = "배차 확정 하시겠습니까?";
    String textEtc="(나머지 정보망전송은 취소됩니다)";

    openCommonConfirmBox(
        context,
        "${textHeader}\n${textSub}\n${text}\n${textEtc}",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          count.value++;

          for(var value in list.value) {
            count.value++;
            if(value.linkCd == Const.CALL_24_KEY_NAME) {
              if(value.linkCd == data.linkCd) {
                await confirmLink(data);
              }else{
                await cancelLink(value.allocCharge, "24Cargo",false);
              }
            }
            if(value.linkCd == Const.ONE_CALL_KEY_NAME) {
              if(value.linkCd == data.linkCd) {
                await confirmLink(data);
              }else{
                await cancelLink(value.allocCharge, "oneCargo",false);
              }
            }
            if(value.linkCd == Const.HWA_MULL_KEY_NAME) {
              if(value.linkCd == data.linkCd) {
                await confirmLink(data);
              }else{
                await cancelLink(value.allocCharge, "manCargo",false);
              }
            }
          }

        }
    );
  }

  Widget rpaListWidget(){
    return Container(
      color: main_background,
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
      child: list.isNotEmpty
          ?  ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              return getListItemView(item,index);
            },
          )
      : Container(
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style: CustomStyle.baseFont(),
              )
      )
    );
  }

  Widget getListItemView(OrderLinkCurrentModel item,int position) {

    if(!(item.editDate == "") && item.editDate != null) {
      if(!(item.editDate?.trim() == "")) {
        rpaDate.value = "(${item.editDate})";
      }else{
        if(item.regDate == null) {
          rpaDate.value = "";
        }else{
          rpaDate.value = "(${item.regDate})";
        }
      }
    }else{
      if(item.regDate == null) {
        rpaDate.value = "";
      }else{
        rpaDate.value = "(${item.regDate})";
      }
    }

    if(item.orderId == "" || item.orderId == null || item.linkStat == "D"){
      infoTitle.value = false;
      dispatch.value = false;
      regist.value = true;

      // 추가 확인
      carRegist.value = false;
      modify.value = false;
      cancel.value = false;
      llCharge.value = false;
      rpaDate.value = "";
    }else{
      llCharge.value = true;

      if(item.linkStat == "R") {
        infoTitle.value = true;
        dispatch.value = true;
        regist.value = false;

        carRegist.value = true;
        modify.value = false;
        cancel.value = true;

        badge.value = true;
      }else{
        infoTitle.value = true;
        dispatch.value = false;
        regist.value = false;

        carRegist.value = false;
        modify.value = true;
        cancel.value = true;

        badge.value = false;
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.linkCd == Const.CALL_24_KEY_NAME ? "24시콜" :
                    item.linkCd == Const.ONE_CALL_KEY_NAME ? "원콜" :
                    item.linkCd == Const.HWA_MULL_KEY_NAME ? "화물맨" : "",
                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01, font_weight: FontWeight.w700),
                  ),
                  badge.value?
                  Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(20.w)),
                    margin: EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
                    decoration: BoxDecoration(
                        color: copy_btn,
                        borderRadius: BorderRadius.all(Radius.circular(5.w))
                    ),
                    child: Text(
                      "배차",
                      style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                    )
                  ) : const SizedBox()
                ],
              ),
              Text(
                "${rpaDate.value}",
                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
              )
            ],
          )),
          infoTitle.value?
          Container(
          padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
          child: Text(
            item.jobStat == "F" ? "정보망 전송 성공" :
                item.jobStat == "E" ? "전송 실패: ${item.rpaMsg}" :
                    item.jobStat == "R" ? "정보망 전송 진행 중" :
                        "정보망 전송 대기",
            textAlign: TextAlign.start,
            style: CustomStyle.CustomFont(styleFontSize14, item.jobStat == "F" ? order_state_01 :
            item.jobStat == "E" ? order_state_09 :
            item.jobStat == "R" ? order_state_01 :
            order_state_01),
          )) : const SizedBox(),
          dispatch.value?
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "[배차정보]",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Text(
                        item.carNum??"",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Text(
                        item.carType??"",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                    ),
                    Container(
                      child: Text(
                        item.carTon??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Text(
                        item.driverName??"",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                    ),
                    InkWell(
                      onTap: () async {
                        if(Platform.isAndroid) {
                          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                          AndroidDeviceInfo info = await deviceInfo.androidInfo;
                          if (info.version.sdkInt >= 23) {
                            await FlutterDirectCallerPlugin.callNumber("${item.driverTel}");
                          }else{
                            await launch("tel://${item.driverTel}");
                          }
                        }else{
                          await launch("tel://${item.driverTel}");
                        }
                      },
                      child: Text(
                        Util.makePhoneNumber(item.driverTel),
                        style: CustomStyle.CustomFont(styleFontSize14, addr_type_text),
                      ),
                    )
                  ],
                )
              ],
            ),
          ) : const SizedBox(),
          Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
            child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: llCharge.value? Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          "${Util.getInCodeCommaWon(item.allocCharge)} 원",
                          style: CustomStyle.CustomFont(styleFontSize12, terms_text,font_weight: FontWeight.w600),
                        ),
                      ): const SizedBox()
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        modify.value ? InkWell(
                          onTap: () async {
                            await modifyRpa(item);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: CustomStyle.getWidth(15.w),
                                vertical: CustomStyle.getHeight(5.h)),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                                color: main_color),
                            child: Text(
                              "수정",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(
                                  styleFontSize12, Colors.white),
                            ),
                          ),
                        ) : const SizedBox(),
                        carRegist.value ?
                        InkWell(
                          onTap: () async {
                            await carConfirmRpa(item);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: CustomStyle.getWidth(5.w),
                                vertical: CustomStyle.getHeight(5.h)),
                            margin: EdgeInsets.only(
                                left: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                                color: swipe_edit_btn),
                            child: Text(
                              "배차확정",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(
                                  styleFontSize12, Colors.white),
                            ),
                          ),
                        ) : const SizedBox(),
                        regist.value ?
                        InkWell(
                          onTap: () async {
                            await registRpa(item);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: CustomStyle.getWidth(15.w),
                                vertical: CustomStyle.getHeight(5.h)),
                            margin: EdgeInsets.only(
                                left: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                                color: main_color),
                            child: Text(
                              "등록",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(
                                  styleFontSize12, Colors.white),
                            ),
                          ),
                        ) : const SizedBox(),
                        cancel.value ?
                        InkWell(
                          onTap: () async {
                            await cancelRpa(item);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: CustomStyle.getWidth(15.w),
                                vertical: CustomStyle.getHeight(5.h)),
                            margin: EdgeInsets.only(
                                left: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                                color: sub_btn),
                            child: Text(
                              "취소",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(
                                  styleFontSize12, Colors.white),
                            ),
                          ),
                        ) : const SizedBox(),
                      ],
                    )
                  ),
                ]
            ),
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
        child: SafeArea(
            child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar:AppBar(
                title:  Text(
                    "정보망 전송 목록",
                    style: CustomStyle.appBarTitleFont(
                        styleFontSize16, styleWhiteCol)
                ),
                centerTitle: true,
                toolbarHeight: 50.h,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.white),
                ),
              ),
          body:  Obx((){
           return SingleChildScrollView(
                    child: Column(
                      children: [
                        topWidget(),
                        rpaListWidget()
                      ],
                  )
           );
              })
          ),
        )
    );
  }

}