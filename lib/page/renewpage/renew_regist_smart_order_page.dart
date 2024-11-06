import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';

class RenewRegistSmartOrderPage extends StatefulWidget {

  OrderModel? order_vo;
  String? flag; // R: 오더 등록, CR:오더 복사, M: 오더 수정

  RenewRegistSmartOrderPage({Key? key, this.order_vo, this.flag}):super(key:key);

  _RenewRegistSmartOrderPageState createState() => _RenewRegistSmartOrderPageState();
}

class _RenewRegistSmartOrderPageState extends State<RenewRegistSmartOrderPage> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code': 100});
          return true;
        },
        child: Scaffold(
            backgroundColor: sub_color,
            appBar: AppBar(
              title: Text(
                  "스마트오더",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize16, Colors.black)),
              toolbarHeight: 50.h,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () async {
                    Navigator.of(context).pop({'code': 100});
                },
                color: styleWhiteCol,
                icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
              ),
            ),
            body: SafeArea(
                child: Text(
                    "ㅇㅇㅇ"
                )
            )
        )
    );
  }
}