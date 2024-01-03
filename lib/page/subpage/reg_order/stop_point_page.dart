import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_page.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:phone_call/phone_call.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';

class StopPointPage extends StatefulWidget {

  OrderModel? order_vo;
  String? result_work_stopPoint;
  String? code;

  StopPointPage({Key? key,this.order_vo, this.result_work_stopPoint, this.code}):super(key:key);

  _StopPointPageState createState() => _StopPointPageState();
}


class _StopPointPageState extends State<StopPointPage> {

  ProgressDialog? pr;

  var scrollController = ScrollController();

  final mList = List.empty(growable: true).obs;
  final mData = OrderModel().obs;
  String code = "";

  final addStopPointBtn = false.obs;
  final tvStopSe = "".obs;
  final btStopAdd = false.obs;

  @override
  void initState() {
    super.initState();

    if(widget.code != null && widget.code?.isNotEmpty == true ) {
      code = widget.code!;
      if (widget.result_work_stopPoint != null) {
        mList.addAll(jsonDecode(widget.result_work_stopPoint!));
        btStopAdd.value = false;
      }
    }else{
      if(widget.order_vo != null){
        mData.value = widget.order_vo!;
        if(mData.value.orderId != null) {
          mList.value = mData.value.orderStopList??List.empty(growable: true);
        }
      }
    }
    Future.delayed(Duration.zero, () async {
      await initView();
    });
  }

  Future<void> initView() async {
    if(code == ""){

    }
  }

  Future<void> addStopPoint() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrPage(order_vo:mData.value,code:Const.RESULT_WORK_STOP_POINT)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("addStopPoint() -> ${results[Const.RESULT_WORK]}");
        await addStopPointResult(results);
      }
    }
  }

  Future<void> addStopPointResult(Map<String,dynamic> results) async {
    if(results[Const.ORDER_VO] != null) {
      mData.value = results[Const.ORDER_VO];
      if(mData.value != null) {
        mList.value = mData.value.orderStopList ?? List.empty(growable: true);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget stopPointListWidget() {
    return mList.isNotEmpty
        ? ListView.builder(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      shrinkWrap: true,
      itemCount: mList.length,
      itemBuilder: (context, index) {
        return getListCardView(index);
      },
    )
        : Container(
            alignment: Alignment.center,
            child: Text(
              Strings.of(context)?.get("empty_list") ?? "Not Found",
              style: CustomStyle.baseFont(),
            ));
  }

  Widget getListCardView(int index) {
    var item = mList[index];
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(15.w)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
            color: line, width: 1.w
        ))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 9,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.w)),
                          border: Border.all(color: text_box_color_01,width: 1.w)
                        ),
                        child: Text(
                          "경유지 ${(index+1)}",
                          style: CustomStyle.CustomFont(styleFontSize10, text_box_color_01),
                        ),
                      )
                    ),
                    Expanded(
                      flex: 3,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                            child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: item.eComName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        )
                      )
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      child: Text(
                        item.stopSe == "S" ? "상차" :"하차",
                        style: CustomStyle.CustomFont(styleFontSize14, item.stopSe == "S"? order_state_04 : order_state_09),
                      ),
                    )
                    )
                  ],
                ),
               item.eStaff != null && item.eStaff != "" && item.eTel != null && item.eTel != "" ? Container(
                 padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                 child: Row(
                   children: [
                     Container(
                       padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                       child: Text(
                         item.eStaff,
                         style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                       ),
                     ),
                     InkWell(
                       onTap: () async {
                         if(Platform.isAndroid) {
                           DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                           AndroidDeviceInfo info = await deviceInfo.androidInfo;
                           if (info.version.sdkInt >= 23) {
                             await PhoneCall.calling("${item.eTel}");
                           }else{
                             await launch("tel://${item.eTel}");
                           }
                         }else{
                           await launch("tel://${item.eTel}");
                         }
                       },
                       child: Text(
                         Util.makePhoneNumber(item.eTel),
                         style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                       ),
                     )
                   ],
                 )
               ) : const SizedBox(),
               Container(
                 padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                 child: Text(
                   item.eAddr??"",
                   style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                 ),
               ),
               item.eAddrDetail != null && item.eAddrDetail != "" ? Container(
                 padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                 child: Text(
                   item.eAddrDetail??"",
                   style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                 ),
               ) : const SizedBox()
             ],
           )
          ),
          Expanded(
            flex: 1,
              child: InkWell(
                onTap: (){
                  mList.value.removeAt(index);
                  setState(() {});
                },
                child: Icon(Icons.close, color: text_color_03, size: 24.h),
              )
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
          Navigator.of(context).pop({'code':200,Const.RESULT_WORK: Const.RESULT_WORK_STOP_POINT, Const.ORDER_VO: mData.value});
          return true;
        } ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar: AppBar(
                title: Center(
                  child: Text(
                    "${Strings.of(context)?.get("stop_point_title")??"Not Found"}",
                    style: CustomStyle.appBarTitleFont(styleFontSize16, styleWhiteCol)
                  )
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':200,Const.RESULT_WORK: Const.RESULT_WORK_STOP_POINT, Const.ORDER_VO: mData.value});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back, size: 24.h, color: styleWhiteCol),
                ),
              ),
          body: SafeArea(
              child: Obx((){
                 return SizedBox(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                    child: Stack(
                          children: [
                            stopPointListWidget(),
                            Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                    onTap: () async {
                                      await addStopPoint();
                                    },
                                    child: Icon(
                                      Icons.add_circle,
                                      color: main_btn,
                                      size: 52.h,
                                    )
                                )
                            )
                          ],
                        ),
                );
              })
          )
        )
    );
  }

}