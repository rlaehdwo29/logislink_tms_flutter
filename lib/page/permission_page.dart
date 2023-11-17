import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  const  PermissionPage({Key? key}) : super(key:key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}



class _PermissionPageState extends State<PermissionPage>{
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(    // <-  WillPopScope로 감싼다.
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      "앱 권한 안내",
                      style: CustomStyle.CustomFont(
                          styleFontSize15, text_color_01,
                          font_weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    CustomStyle.sizedBoxHeight(10.0),
                    Text(
                      "선택적 권한은 동의를 받고 있습니다.\n\n동의하지 않아도 서비스 이용이 가능하나\n기능에 제한이 있을 수 있습니다.",
                      style:
                      CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      textAlign: TextAlign.center,
                    ),
                    CustomStyle.sizedBoxHeight(10.0),
                    CustomStyle.getDivider1(),
                    CustomStyle.sizedBoxHeight(10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "선택 접근 권한",
                            style: CustomStyle.CustomFont(
                                styleFontSize13, text_color_01,
                                font_weight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          CustomStyle.sizedBoxHeight(5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomStyle.getWidth(10.0)),
                                child: const Icon(Icons.circle_notifications,
                                    color: Colors.black, size: 24),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "알림",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  Text(
                                    "앱 알림 권한 허용을 허가합니다.",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize11, text_color_02),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CustomStyle.sizedBoxHeight(10.0),
                          CustomStyle.getDivider1(),
                          CustomStyle.sizedBoxHeight(10.0),
                        ]),
                  ],
                ))),
        bottomNavigationBar: InkWell(
          onTap: () async {
            Navigator.of(context).pop({'code': 200});
          },
          child: Container(
            height: 60.0,
            color: main_color,
            padding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Text(
              "확인",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
            ),
          ),
        )
    )
    );
  }
}