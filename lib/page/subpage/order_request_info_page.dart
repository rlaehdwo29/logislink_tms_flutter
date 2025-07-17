import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class OrderRequestInfoPage extends StatefulWidget {
  OrderModel? order_vo;

  OrderRequestInfoPage({Key? key, this.order_vo}):super(key:key);

  _OrderRequestInfoPageState createState() => _OrderRequestInfoPageState();
}

class _OrderRequestInfoPageState extends State<OrderRequestInfoPage> {

  ProgressDialog? pr;

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          return true;
        } ,
        child: SafeArea(
            child: Scaffold(
            backgroundColor: sub_color,
            appBar: AppBar(
              title: Text(
                  "화주정보",
                  style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
              ),
              backgroundColor: renew_main_color2,
              toolbarHeight: 50.h,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop({'code':100});
                },
                color: styleWhiteCol,
                icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.white),
              ),
              actions: [
                Container(
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(20)),
                    child: InkWell(
                      child: Text(
                          "저장",
                          style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
                      ),
                    )
                )
              ],
            ),
            body: //Obx(() {
                SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                              child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "거래처명",
                                      style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w600),
                                    ),
                                    Text(
                                      " (필수)",
                                      style: CustomStyle.CustomFont(styleFontSize12, styleGreyCol1, font_weight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10), vertical: CustomStyle.getHeight(10)),
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: styleGreyCol1),
                                    color: Colors.white
                                  ),
                                  child: Text(
                                    "거래처를 선택해주세요."
                                  ),
                                )
                              ],
                            )
                          )
                      )
                  )
                //})
        ))
    );
  }

}