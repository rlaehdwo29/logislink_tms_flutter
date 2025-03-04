import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/template_model.dart';
import 'package:logislink_tms_flutter/common/model/template_stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/page/renewpage/create_template_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class TemplateManageDetailPage extends StatefulWidget {

  TemplateModel item;

  TemplateManageDetailPage({Key? key,required this.item}):super(key:key);

  _TemplateManageDetailPageState createState() => _TemplateManageDetailPageState();
}

class _TemplateManageDetailPageState extends State<TemplateManageDetailPage> {

  final mData = TemplateModel().obs;
  final tvOrderState = false.obs;
  final tvAllocState = false.obs;
  final llDriverInfo = false.obs;

  final isStopPointExpanded = [].obs;
  final llStopPointHeader = false.obs;
  final llStopPointList = false.obs;
  final isCargoExpanded = [].obs;
  final isEtcExpanded = [].obs;
  final mStopList = List.empty(growable: true).obs;

  final controller = Get.find<App>();

/**
 * Start Function
 */

  int chargeTotal(String? chargeFlag) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(mData.value.sellCharge ?? "0") -
          int.parse(mData.value.sellFee ?? "0") +
          int.parse(mData.value.sellWayPointCharge ?? "0") +
          int.parse(mData.value.sellStayCharge ?? "0") +
          int.parse(mData.value.sellHandWorkCharge ?? "0") +
          int.parse(mData.value.sellRoundCharge ?? "0") +
          int.parse(mData.value.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(mData.value.buyCharge ?? "0") -
          int.parse(mData.value.sellFee ?? "0") +
          int.parse(mData.value.wayPointCharge ?? "0") +
          int.parse(mData.value.stayCharge ?? "0") +
          int.parse(mData.value.handWorkCharge ?? "0") +
          int.parse(mData.value.roundCharge ?? "0") +
          int.parse(mData.value.otherAddCharge ?? "0") -
          int.parse(mData.value.sellFee ?? "0");
    }
    return total;
  }

  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      mData.value = widget.item;
      await getTemplateStopList();
      if(mStopList.length > 0) {
        mStopList.clear();
      }else{
        mStopList.addAll(widget.item.templateStopList!);
      }
      if(mData.value.stopCount != 0) {
        llStopPointHeader.value = true;
        llStopPointList.value = true;
      }else{
        llStopPointHeader.value = false;
        llStopPointList.value = false;
      }
    });

  }

  Future<void> getTemplateDetail() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTemplateDetail(
        user.authorization,
        mData.value.templateId
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getTemplateDetail() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              TemplateModel template = TemplateModel.fromJSON(it.response.data["data"][0]);
              mData.value = template;
            }
          }
        }
      }catch(e) {
        print("getTemplateDetail() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTemplateDetail() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getTemplateDetail() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> delTemplateList() async {
    var select_template_list = List.empty(growable: true);
    select_template_list.add(mData.value);
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).templateDel(
        user.authorization,
        jsonEncode(select_template_list.map((e) => e.toJson()).toList())
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("delTemplateList() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("\"${mData.value.templateTitle}\" 탬플릿이 삭제되었습니다.");
            Navigator.of(context).pop({'code' : 300});
          } else {
            Util.toast("${_response.resultMap?["msg"]}");
          }
        }
      }catch(e) {
        print("delTemplateList() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("delTemplateList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("delTemplateList() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getTemplateStopList() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTemplateStopList(user.authorization,widget.item?.templateId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getTemplateStopList() Regist _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<TemplateStopPointModel> itemsList = list.map((i) => TemplateStopPointModel.fromJSON(i)).toList();
            if (itemsList.length != 0) {
              if(widget.item?.templateStopList?.isNotEmpty == true || widget.item?.templateStopList != null) widget.item?.templateStopList?.clear();
              widget.item?.templateStopList?.addAll(itemsList);
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
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTemplateStopList() RegVersion Error => ${res?.statusCode} // ${res
              ?.statusMessage}");
          break;
        default:
          print("getTemplateStopList() RegVersion getOrder Default => ");
          break;
      }
    });
  }

/**
 * End Function
 */



/**
 * Start Widget
 */

  Widget etcPannelWidget() {

    isEtcExpanded.value = List.filled(1, false);
    return Container(
        margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10)),
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ExpansionPanelList.radio(
                  animationDuration: const Duration(milliseconds: 500),
                  expandedHeaderPadding: EdgeInsets.zero,
                  elevation: 0,
                  children: [
                    ExpansionPanelRadio(
                      value: index,
                      backgroundColor: Colors.white,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(5.w)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(isExpanded ? "접기" : "펼치기",style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w700))
                              ],
                            )
                        );
                      },
                      body: Obx((){
                        return Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
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
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w500),
                                      ),
                                      Container(
                                        width: App().isTablet(context) ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(80) : MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(50),
                                        padding: const EdgeInsets.all(10),
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                        child: Text(
                                          !(mData.value.driverMemo?.isEmpty == true) ? mData.value.driverMemo??"-" : "-",
                                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                          child: Text(
                                            Strings.of(context)?.get("order_request_info_reg_memo")??"요청사항_",
                                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w500),
                                          )
                                      ),
                                      Container(
                                        width: App().isTablet(context) ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(80) : MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - CustomStyle.getWidth(50),
                                        padding: const EdgeInsets.all(10),
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                        child: Text(
                                          !(mData.value.reqMemo?.isEmpty == true) ? mData.value.reqMemo??"-" : "-",
                                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
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
                )
            );
          }),
        )
    );
  }

  Widget cargoInfoPannel() {
    return Obx(() {
      return Column(
      children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("order_cargo_info_in_out_sctn")??"수출입구분_",
                style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
              ),
              Text(
                mData.value.inOutSctnName??"",
                style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
              )
            ]
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_truck_type")??"운송유형_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.truckTypeName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_car_ton")??"톤수_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.carTonName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_car_type")??"차종_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.carTypeName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(15)),
                      child: Text(
                        Strings.of(context)?.get("order_cargo_info_cargo")??"화물정보_",
                        style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                      )
                  ),
                  Flexible(
                      child: RichText(
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: "${mData.value.goodsName}",
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                          )
                      )
                  ),
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_item_lvl_1")??"운송품목_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.itemName??"-",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_wgt")??"적재중량_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    "${mData.value.goodsWeight} ${mData.value.weightUnitCode}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_way_on")??"상차방법_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.sWayName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_way_off")??"하차방법_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.eWayName??"",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_mix_type")??"혼적여부_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.mixYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_mix_y")}":"${Strings.of(context)?.get("order_cargo_info_mix_n")}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.of(context)?.get("order_cargo_info_return_type")??"왕복여부_",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w500),
                  ),
                  Text(
                    mData.value.returnYn == "Y"?"${Strings.of(context)?.get("order_cargo_info_return_y")}":"${Strings.of(context)?.get("order_cargo_info_return_n")}",
                    style: CustomStyle.CustomFont(styleFontSize13, text_color_01,font_weight: FontWeight.w300),
                  )
                ]
            )
        ),
      ],
    );
    });
  }

  Widget cargoInfoWidget() {
    isCargoExpanded.value = List.filled(1, false);
    return Container(
        margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(10), top: CustomStyle.getHeight(10)),
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ExpansionPanelList.radio(
                  animationDuration: const Duration(milliseconds: 500),
                  expandedHeaderPadding: EdgeInsets.zero,
                  elevation: 0,
                  children: [
                    ExpansionPanelRadio(
                      value: index,
                      backgroundColor: Colors.white,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(isExpanded ? "접기" : "펼치기",style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w700))
                              ],
                            )
                        );
                      },
                      body:Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: line,
                                        width: 1.w
                                    )
                                )
                            ),
                            child: cargoInfoPannel()
                        ),
                      canTapOnHeader: true,
                    )
                  ],
                  expansionCallback: (int _index, bool status) {
                    isCargoExpanded[index] = !isCargoExpanded[index];
                  },
                )
            );
          }),
        ));
  }

  Widget stopPointItems(int index) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
        decoration: BoxDecoration(
          color: styleGreyCol3,
          border: Border(bottom: BorderSide(color: line, width: 1.w)),
        ),
        child: Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                border: Border.all(color: text_box_color_01,width: 1.w),
                                borderRadius: BorderRadius.all(Radius.circular(5.w))
                            ),
                            child: Text(
                              "경유지 ${index + 1}",
                              style: CustomStyle.CustomFont(styleFontSize12, text_box_color_01),
                            )
                        )
                    ),
                    Expanded(
                        flex: 5,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                            child: Text(
                              mStopList.value[index].eComName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        )
                    ),
                    Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(3.w)),
                          alignment: Alignment.centerRight,
                          child: Text(
                            mStopList.value[index].stopSe == "S" ? "상차" : "하자",
                            style: CustomStyle.CustomFont(styleFontSize14, mStopList.value[index].stopSe == "S" ? order_state_04 : order_state_09),
                          ),
                        )
                    )
                  ],
                ),
                !(mStopList.value[index].eStaff?.isEmpty == true) || !(mStopList.value[index].eTel?.isEmpty == true) ?
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    child: Row(
                      children: [
                        Text(
                          mStopList.value[index].eStaff??"",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        ),
                        InkWell(
                          onTap: () async {
                            if(Platform.isAndroid) {
                              DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                              AndroidDeviceInfo info = await deviceInfo.androidInfo;
                              if (info.version.sdkInt >= 23) {
                                await FlutterDirectCallerPlugin.callNumber("${mStopList.value[index].eTel}");
                              }else{
                                await launch("tel://${mStopList.value[index].eTel}");
                              }
                            }else{
                              await launch("tel://${mStopList.value[index].eTel}");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                            child: Text(
                              Util.makePhoneNumber(mStopList.value[index].eTel),
                              style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                            ),
                          ),
                        )
                      ],
                    )
                ): const SizedBox(),
                !(mStopList.value[index].eAddrDetail?.isEmpty == true)?
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    child: Text(
                      mStopList.value[index].eAddr??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    )
                ) : const SizedBox(),
                !(mStopList.value[index].eAddrDetail?.isEmpty == true) ?
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    child: Text(
                      mStopList.value[index].eAddrDetail??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                    )
                ): const SizedBox()
              ],
            )
        )
    );
  }

  Widget stopPointPannelWidget() {
    isStopPointExpanded.value = List.filled(1, false);
    return Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line,
                      width: 5.w
                  ),
                )
            ),
            child: ExpansionPanelList.radio(
              animationDuration: const Duration(milliseconds: 500),
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 0,
              children: [
                ExpansionPanelRadio(
                  value: index,
                  backgroundColor: Colors.white,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(5.h)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("경유지 ${mData.value.stopCount}곳",style: CustomStyle.CustomFont(styleFontSize16, text_color_01))
                          ],
                        )
                    );
                  },
                  body: llStopPointList.value ?
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: line,
                                width: 1.w
                            ),
                          )
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            mStopList.length,
                                (index) {
                              return stopPointItems(index);
                            },
                          ))) : const SizedBox(),
                  canTapOnHeader: true,
                )
              ],
              expansionCallback: (int _index, bool status) {
                isStopPointExpanded[index] = !isStopPointExpanded[index];
              },
            ));
      }),
    );
  }

  Widget orderEtcChargeWidget(String chargeFlag) {
    return Column(
        children: [
          //수수료
          Util.equalsCharge(chargeFlag == "S" ? mData.value.buyFee??"0" : mData.value.sellFee??"0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          textAlign: TextAlign.left,
                          Strings.of(context)?.get("order_charge_info_sell_fee")??"수수료_()" ,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      " - ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.buyFee??"0": mData.value.sellFee??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ):const SizedBox(),
          // 경유비(지불)
          Util.equalsCharge(chargeFlag == "S" ? mData.value.sellWayPointCharge??"0" : mData.value.wayPointCharge??"0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          textAlign: TextAlign.left,
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_way_point_charge" : "order_trans_info_way_point_charge")??"경유지_()" ,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellWayPointCharge??"0": mData.value.wayPointCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ):const SizedBox(),
          // 대기료(지불)
          Util.equalsCharge(chargeFlag == "S" ? mData.value.sellStayCharge??"0" : mData.value.stayCharge??"0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_stay_charge" : "order_trans_info_stay_charge")??"대기료_()" ,
                          textAlign: TextAlign.left,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellStayCharge??"0" : mData.value.stayCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 수작업비(지불)
          Util.equalsCharge(chargeFlag == "S" ? mData.value.sellHandWorkCharge??"0" : mData.value.handWorkCharge??"0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                        child: Text(
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_hand_work_charge" : "order_trans_info_hand_work_charge")??"수작업비_()",
                          textAlign: TextAlign.left,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Text(
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellHandWorkCharge??"0" : mData.value.handWorkCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 회차료(지불)
          Util.equalsCharge(chargeFlag == "S" ? mData.value.sellRoundCharge??"0" : mData.value.roundCharge ?? "0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_round_charge" : "order_trans_info_round_charge")??"회차료_()",
                          textAlign: TextAlign.left,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellRoundCharge??"0" : mData.value.roundCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          // 기타추가비(청구/지불)
          Util.equalsCharge(chargeFlag == "S" ? mData.value.sellOtherAddCharge??"0" : mData.value.otherAddCharge??"0") ?
          Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            padding: EdgeInsets.only(right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
            child: Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                        child: Text(
                          Strings.of(context)?.get(chargeFlag == "S" ? "order_charge_info_other_add_charge" : "order_trans_info_other_add_charge")??"기타추가비_()",
                          textAlign: TextAlign.left,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      " + ${Util.getInCodeCommaWon(chargeFlag == "S" ? mData.value.sellOtherAddCharge??"0" : mData.value.otherAddCharge??"0")} 원",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
              ],
            ),
          ) : const SizedBox(),
          Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              height: CustomStyle.getHeight(1),
              color: light_gray19
          ),
        ]
    );
  }

  Widget HorizontalDashedDivider() {

    return Padding(
        padding: EdgeInsets.only(top: CustomStyle.getHeight(0),bottom: CustomStyle.getHeight(0)),
        child: Container(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final dashCount = App().isTablet(context) ? (constraints.constrainWidth().toInt() / 15.0).floor() : (constraints.constrainWidth().toInt() / 8.0).floor();
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                        width: CustomStyle.getWidth(3),
                        height:  CustomStyle.getHeight(1),
                        child: const DecoratedBox(
                            decoration: BoxDecoration(color: light_gray18)
                        )
                    );
                  }),
                );
              },
            )
        )
    );
  }

  Widget orderSaddrEaddr() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(10)),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5),left: CustomStyle.getWidth(15),right: CustomStyle.getWidth(15)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Util.ynToBoolean(mData.value.payType)?
                Text(
                  "빠른지급",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.red,font_weight: FontWeight.w700),
                ) : const SizedBox()
              ],
            )
        ),
              Column(
              children:[
    Container(
    margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Expanded(
              flex: 4,
              child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding:const EdgeInsets.all(3),
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                  decoration: const BoxDecoration(
                                      color: renew_main_color2,
                                      shape: BoxShape.circle
                                  ),
                                  child: Text("상",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                              ),
                            ]
                        ),
                        Flexible(
                            child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign:TextAlign.center,
                                text: TextSpan(
                                  text: mData.value.sComName??"",
                                  style:  CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                )
                            )
                        ),
                        CustomStyle.sizedBoxHeight(5.0.h),
                        Flexible(
                            child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign:TextAlign.center,
                                text: TextSpan(
                                  text: mData.value.sAddr??"",
                                  style: CustomStyle.CustomFont(styleFontSize11, main_color),
                                )
                            )
                        ),
                      ]
                  )
              ),
            ),
            Expanded(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/image/ic_arrow.png",
                        width: CustomStyle.getWidth(32.0),
                        height: CustomStyle.getHeight(32.0),
                        color: const Color(0xffC7CBDE),
                      ),
                      Text(
                        "${Util.makeDistance(mData.value.distance)}",
                        style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                      ),
                      Text(
                        "${Util.makeTime(mData.value.time??0)}",
                        style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                      )
                    ]
                )
            ),
            Expanded(
                flex: 4,
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:  BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    padding:const EdgeInsets.all(3),
                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                    decoration: const BoxDecoration(
                                        color: rpa_btn_cancle,
                                        shape: BoxShape.circle
                                    ),
                                    child: Text("하",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                ),
                              ]
                          ),
                          Flexible(
                              child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text:
                                    mData.value.eComName ?? "",
                                    style: CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                  )
                              )
                          ),
                          CustomStyle.sizedBoxHeight(5.h),
                          Flexible(
                              child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: mData.value.eAddr??"",
                                      style:CustomStyle.CustomFont(styleFontSize11, main_color)
                                  )
                              )
                          ),
                        ]
                    )
                )
            )
              ],
            )
        )
      ]),
    ])
    );
  }

  Widget orderSellWidget() {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding:  tvAllocState.value ? EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15)) : EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(15)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      mData.value.sellCustName?.isNotEmpty == true?
                      Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          mData.value.sellCustName??"",
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                        ),
                      ) : const SizedBox(),
                      mData.value.sellDeptName?.isNotEmpty == true?
                      Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                        child: Text(
                          mData.value.sellDeptName??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      ) : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ) ,
            HorizontalDashedDivider(),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                          child: Text(
                            textAlign: TextAlign.left,
                            "청구운임",
                            style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          )
                      )
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        "${Util.getInCodeCommaWon(mData.value.sellCharge??"0")} 원",
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                ],
              ),
            ),
            orderEtcChargeWidget("S"),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              padding: EdgeInsets.only(left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5),bottom: CustomStyle.getHeight(10)),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                          child: Text(
                            textAlign: TextAlign.left,
                            "청구운임(소계)",
                            style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                          )
                      )
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        "${Util.getInCodeCommaWon(chargeTotal("S").toString())} 원",
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                      )
                  ),
                ],
              ),
            ),
            HorizontalDashedDivider(),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              padding: EdgeInsets.only(top: CustomStyle.getHeight(10), right: CustomStyle.getWidth(5),left: CustomStyle.getWidth(5)),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                          child: Text(
                            "지불운임",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                  ) ,
                  Expanded(
                      flex: 2,
                      child: Text(
                        "${Util.getInCodeCommaWon(mData.value.buyCharge??"0")} 원",
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      )
                  ),
                ],
              ),
            ),
            orderEtcChargeWidget("T"),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
              padding: EdgeInsets.only(left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5),bottom: CustomStyle.getHeight(10)),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                          child: Text(
                            textAlign: TextAlign.left,
                            "지불운임(소계)",
                            style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                          )
                      )
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        "${Util.getInCodeCommaWon(chargeTotal("T").toString())} 원",
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                      )
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return Future((){
            Navigator.of(context).pop({'code':300});
            return true;
          });
        } ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: light_gray24,
          appBar: AppBar(
            title: Obx(() => Text(
                "${mData.value.templateTitle}",
                style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.black)
            )),
            actions: [
              InkWell(
                  onTap: () async {
                    openCommonConfirmBox(
                        context,
                        "${mData.value.templateTitle} 탬플릿을 삭제하시겠습니까?",
                        Strings.of(context)?.get("cancel")??"Not Found",
                        Strings.of(context)?.get("confirm")??"Not Found",
                            () {Navigator.of(context).pop();},
                            () async {
                          Navigator.of(context).pop();
                          await delTemplateList();
                        }
                    );
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(10)),
                      width: CustomStyle.getWidth(70),
                      decoration: const BoxDecoration(
                          color: rpa_btn_cancle,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "삭제",
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                      )
                  )
              )
            ],
            leading:
            IconButton(
              onPressed: () async {
                Navigator.of(context).pop({'code':300});
              },
              color: styleWhiteCol,
              icon: Image.asset(
                "assets/image/ic_arrow_left.png",
                width: CustomStyle.getWidth(28.0),
                height: CustomStyle.getHeight(28.0),
                color: Colors.black,
              ),
            ),
            toolbarHeight: 50.h,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
              child: Obx((){
                return SizedBox(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                  child: Text(
                                    "상/하차 정보",
                                    style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              orderSaddrEaddr(),
                              llStopPointHeader.value ? stopPointPannelWidget() : const SizedBox(),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                  child: Text(
                                    "운임 정보",
                                    style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              orderSellWidget(),
                              llDriverInfo.value ?  Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                  child: Text(
                                    Strings.of(context)?.get("order_detail_sub_title_05")?? "차주 정보_",
                                    style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ) : const SizedBox(),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                  child: Text(
                                    "화물 정보",
                                    style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              cargoInfoWidget(), // 화물 정보
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                  child: Text(
                                    "기타",
                                    style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              etcPannelWidget()
                            ],
                          ),
                        ),
                      ],
                    ));
              })
          ),
          bottomNavigationBar: Container(
                height: CustomStyle.getHeight(50),
                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 탬플릿 수정하기
                    Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              Map<String, dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: CreateTemplatePage(flag: "M",tModel: mData.value), pageAnimationType: LeftToRightTransition()));

                              if (results != null && results.containsKey("code")) {
                                if (results["code"] == 200) {
                                  Util.toast("탬플릿이 수정되었습니다.");
                                  await getTemplateDetail();
                                }
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(40)),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: rpa_btn_modify,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                "수정하기",
                                style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol, font_weight: FontWeight.w700),
                              ),
                            )
                        )
                    )
                  ],
                ))
        )
    );
  }

/**
 *  End Widget
 */

}