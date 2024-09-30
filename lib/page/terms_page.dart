import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../provider/dio_service.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key:key);

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {

  final allcheck = false.obs;


  final checkBoxArrayList = [false,false,false,false,false].obs;

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, () async {
      await SP.putBool(Const.KEY_TERMS, false);
      openOkBox(context,"${Strings.of(context)?.get("private_permission_failed")??"Not Found"}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void btnCheck() {
    bool allChecked = true;
    for(var i = 0; i < checkBoxArrayList.value.length; i++) {
      if(checkBoxArrayList.value[i] == false) {
        allChecked = false;
      }
    }
    allcheck.value = allChecked;
    setState(() {});
  }

  Future<void> insertTermsAgree() async {
    String? m_Number = "";
    String? m_Nece = "N";
    String? m_Sel = "N";

    if(checkBoxArrayList.value[0] == true && checkBoxArrayList.value[1] == true && checkBoxArrayList.value[2] == true && checkBoxArrayList.value[3] && checkBoxArrayList.value[4]){
      m_Nece = "Y";
    }else{
      m_Nece = "N";
    }
    var app = await App().getUserInfo();
    Logger logger = Logger();
    await DioService.dioClient(header: true).insertTermsAgree(app.authorization, m_Number,"",m_Nece,m_Sel,"1.0").then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("insertTermsAgree() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {

        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("insertTermsAgree() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("insertTermsAgree() Error Default => ");
          break;
      }
    });

  }

  Widget termsBtnWidget() {
    return Column(
      children: [
        InkWell(
          onTap: (){
            allcheck.value = !allcheck.value;
            for(var i = 0; i < checkBoxArrayList.value.length; i++) {
              checkBoxArrayList.value[i] = allcheck.value;
            }
            btnCheck();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: CustomStyle.getHeight(54.0),
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                  child: Icon(allcheck.value?Icons.check_circle:Icons.check_circle_outline_outlined,size: 24.h,color: allcheck.value?main_color:text_color_03)
                )
              ),
              Expanded(
                flex: 12,
                child: Text(
                  Strings.of(context)?.get("terms_menu_all")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize13, allcheck.value?const Color(0xff313342):text_color_03),
                )
              )
            ],
          )
        ),
        Container(
          decoration: CustomStyle.customBoxDeco(Colors.white,radius: 0,border_color: text_color_03),
          child: Column(
            children: [
              // 1
                SizedBox(
                  height: CustomStyle.getHeight(54.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 12,
                          child: InkWell(
                            onTap: (){
                              checkBoxArrayList.value[0] = !checkBoxArrayList.value[0];
                              btnCheck();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child:Container(
                                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                        child: Icon(checkBoxArrayList.value[0]?Icons.check_circle:Icons.check_circle_outline_outlined,size: 24.h,color: checkBoxArrayList.value[0]?main_color:text_color_03)
                                    )
                                ),
                                Expanded(
                                    flex: 10,
                                    child: Text(
                                      Strings.of(context)?.get("terms_menu1")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize13, checkBoxArrayList.value[0]?const Color(0xff313342):text_color_03),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () async {
                            var url = Uri.parse(URL_AGREE_TERMS);
                            if (await canLaunchUrl(url)) {
                            launchUrl(url);
                            }
                          },
                            child: Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(14.0.w)),
                            child: Icon(Icons.keyboard_arrow_right_outlined,size: 28.h,color: text_color_03)
                          )
                        )
                      ),
                    ],
                  )
                ),
              //2
              SizedBox(
                  height: CustomStyle.getHeight(54.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 12,
                          child: InkWell(
                            onTap: (){
                              checkBoxArrayList.value[1] = !checkBoxArrayList.value[1];
                              btnCheck();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child:Container(
                                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                        child: Icon(checkBoxArrayList.value[1]?Icons.check_circle:Icons.check_circle_outline_outlined,size: 28.h,color: checkBoxArrayList.value[1]?main_color:text_color_03)
                                    )
                                ),
                                Expanded(
                                    flex: 10,
                                    child: Text(
                                      Strings.of(context)?.get("terms_menu2")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize13, checkBoxArrayList.value[1]?const Color(0xff313342):text_color_03),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              var url = Uri.parse(URL_PRIVACY_TERMS);
                              if (await canLaunchUrl(url)) {
                              launchUrl(url);
                              }
                            },
                              child: Container(
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(14.0.w)),
                              child: Icon(Icons.keyboard_arrow_right_outlined,size: 28.h,color: text_color_03)
                          )
                        )
                      ),
                    ],
                  )
              ),
              //3
              SizedBox(
                  height: CustomStyle.getHeight(54.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 12,
                          child: InkWell(
                            onTap: (){
                              checkBoxArrayList.value[2] = !checkBoxArrayList.value[2];
                              btnCheck();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child:Container(
                                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                        child: Icon(checkBoxArrayList.value[2]?Icons.check_circle:Icons.check_circle_outline_outlined,size: 28.h,color: checkBoxArrayList.value[2]?main_color:text_color_03)
                                    )
                                ),
                                Expanded(
                                    flex: 10,
                                    child: Text(
                                      Strings.of(context)?.get("terms_menu3")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize13, checkBoxArrayList.value[2]?const Color(0xff313342):text_color_03),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                var url = Uri.parse(URL_PRIVATE_INFO_TERMS);
                                if (await canLaunchUrl(url)) {
                                launchUrl(url);
                                }
                              },
                                child: Container(
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(14.0.w)),
                                child: Icon(Icons.keyboard_arrow_right_outlined,size: 28.h,color: text_color_03)
                            )
                         )
                      ),
                    ],
                  )
              ),
              //4
              SizedBox(
                  height: CustomStyle.getHeight(54.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 12,
                          child: InkWell(
                            onTap: (){
                              checkBoxArrayList.value[3] = !checkBoxArrayList.value[3];
                              btnCheck();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child:Container(
                                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                        child: Icon(checkBoxArrayList.value[3]?Icons.check_circle:Icons.check_circle_outline_outlined,size: 28.h,color: checkBoxArrayList.value[3]?main_color:text_color_03)
                                    )
                                ),
                                Expanded(
                                    flex: 10,
                                    child: Text(
                                      Strings.of(context)?.get("terms_menu4")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize13, checkBoxArrayList.value[3]?const Color(0xff313342):text_color_03),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                var url = Uri.parse(URL_DATA_SECURE_TERMS);
                                if (await canLaunchUrl(url)) {
                                launchUrl(url);
                                }
                              },
                                child: Container(
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(14.0.w)),
                                child: Icon(Icons.keyboard_arrow_right_outlined,size: 28.h,color: text_color_03)
                            )
                         )
                      ),
                    ],
                  )
              ),
              //5
              SizedBox(
                  height: CustomStyle.getHeight(54.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 12,
                          child: InkWell(
                            onTap: () {
                              checkBoxArrayList.value[4] = !checkBoxArrayList.value[4];
                              btnCheck();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child:Container(
                                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                        child: Icon(checkBoxArrayList.value[4]?Icons.check_circle:Icons.check_circle_outline_outlined,size: 28.h,color: checkBoxArrayList.value[4]?main_color:text_color_03)
                                    )
                                ),
                                Expanded(
                                    flex: 10,
                                    child: Text(
                                      Strings.of(context)?.get("terms_menu5")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize13, checkBoxArrayList.value[4]?const Color(0xff313342):text_color_03),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      Expanded(
                          flex: 2,
                          child: InkWell(
                              onTap: () async {
                                var url = Uri.parse(URL_MARKETING_TERMS);
                                if (await canLaunchUrl(url)) {
                                launchUrl(url);
                                }
                              },
                              child: Container(
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(14.0.w)),
                              child: Icon(Icons.keyboard_arrow_right_outlined,size: 28.h,color: text_color_03)
                          )
                        )
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
    final width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
              child: Obx((){
                return Container(
                  width: width,
                  height: height,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/image/ic_top_logo.png"),
                      CustomStyle.sizedBoxHeight(50.0),
                      Text(
                        Strings.of(context)?.get("popup_permission_body4")??"Not Found",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                        textAlign: TextAlign.center,
                      ),
                      CustomStyle.sizedBoxHeight(20.0),
                      termsBtnWidget()
                    ],
                  )
              );
          })
        ),
      bottomNavigationBar: SizedBox(
          height: CustomStyle.getHeight(60.0),
          child: Obx((){
            return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Expanded(
                flex: 1,
                child: InkWell(
                onTap: () async {
              if(allcheck.value) {
                await insertTermsAgree();
                await SP.putBool(Const.KEY_TERMS, true);
                Navigator.of(context).pop({'code': 200});
              }
            },
            child: Container(
            height: CustomStyle.getHeight(60.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: allcheck.value?main_color:text_color_03
            ),
            child:Text(
              textAlign: TextAlign.center,
              Strings.of(context)?.get("confirm")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize16, allcheck.value?styleWhiteCol:light_gray2),
                          ),
                      )
                  )
              ),
            ],
          );
        })
      )
    );
  }

}
