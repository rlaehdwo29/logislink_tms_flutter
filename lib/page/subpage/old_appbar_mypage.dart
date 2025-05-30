import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

import '../../common/config_url.dart';

class OldAppBarMyPage extends StatefulWidget {
  final void Function(bool?)? onCallback;
  String? code;


  OldAppBarMyPage({Key? key,this.code,this.onCallback}):super(key: key);

  _OldAppBarMyPageState createState() => _OldAppBarMyPageState();
}

class _OldAppBarMyPageState extends State<OldAppBarMyPage> {
  final controller = Get.find<App>();
  final editMode = false.obs;
  final mData = UserModel().obs;
  final tempData = UserModel().obs;

  static const String EDIT_BIZ = "edit_biz";
  final bizFocus = false.obs;

  ProgressDialog? pr;

  late TextEditingController etPasswordController;
  late TextEditingController etPasswordConfirmController;

  @override
  void dispose() {
    super.dispose();
    etPasswordController.dispose();
    etPasswordConfirmController.dispose();
  }

  @override
  void initState() {
    super.initState();

    etPasswordController = TextEditingController();
    etPasswordConfirmController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      mData.value = await App().getUserInfo();
    });

    if(widget.code != null) {
      if(widget.code == EDIT_BIZ) {
        editMode.value = true;
        bizFocus.value = true;
      }
    }
  }

  Future<void> showEditPwd() async {
    var _validation = await validation();
    if(_validation) {
      openCommonConfirmBox(
          context,
          "비밀번호를 변경하시겠습니까?",
          Strings.of(context)?.get("cancel") ?? "Not Found",
          Strings.of(context)?.get("confirm") ?? "Not Found",
              () {
            Navigator.of(context).pop(false);
          },
              () async {
            Navigator.of(context).pop(false);
            await editPassword();
          }
      );
    }
  }

  Future<bool> validation() async {
    if(etPasswordController.text.trim().isEmpty == true) {
      Util.toast(Strings.of(context)?.get("my_page_password_hint")??"새 비밀번호를 입력해주세요._");
      return false;
    }
    if(etPasswordConfirmController.text.trim().isEmpty == true) {
      Util.toast(Strings.of(context)?.get("my_page_password_confirm_hint")??"새 비밀번호를 한번 더 확인해주세요._");
      return false;
    }
    if(!(etPasswordController.text.trim() == etPasswordConfirmController.text.trim())) {
      Util.toast("비밀번호가 일치하지 않습니다. 다시 확인해 주세요.");
      return false;
    }
    return true;
  }

  Future<void> editPassword() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).userUpdate(
        user.authorization,
      Util.encryption(etPasswordController.text.trim()),
      user.telnum, user.email, user.mobile
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getRpaLinkFlag() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            await Util.setEventLog(URL_USER_UPDATE, "비밀번호변경");
            Util.toast("비밀번호가 변경되었습니다.");
            etPasswordController.text = "";
            etPasswordConfirmController.text = "";
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getRpaLinkFlag() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getRpaLinkFlag() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getRpaLinkFlag() getOrder Default => ");
          break;
      }
    });
  }

  Widget headerWidget() {
    return Container(
      padding: EdgeInsets.only(top: CustomStyle.getHeight(120.h),left: CustomStyle.getWidth(10.w),bottom: CustomStyle.getHeight(10.h),right: CustomStyle.getWidth(10.w)),
      color: main_color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mData.value.bizName??"",
            style: CustomStyle.CustomFont(styleFontSize22, Colors.white,font_weight: FontWeight.w700),
          ),
          Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0.h)),
              child: Text(
                mData.value.deptName??"",
                style: CustomStyle.CustomFont(styleFontSize20, Colors.white),
              )
          )
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return Container(
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            Strings.of(context)?.get("my_page_name")??"이름_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: text_box_color_02,width: 1.w),
                                borderRadius: BorderRadius.circular(5.w),
                                color: box_body
                            ),
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                            child: Text(
                              mData.value.userName??"",
                              style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            ),
                          )
                        ],
                      )
                  )
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            Strings.of(context)?.get("my_page_tel")??"연락처_",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: text_box_color_02,width: 1.w),
                                borderRadius: BorderRadius.circular(5.w),
                                color: box_body
                            ),
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                            child: Text(
                              Util.makePhoneNumber(mData.value.mobile),
                              style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            ),
                          )
                        ],
                      )
                  )
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                  child: Text(
                    Strings.of(context)?.get("my_page_password")??"비밀번호_",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
                ),
                Container(
                    height: CustomStyle.getHeight(35.h),
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                     alignment: Alignment.centerLeft,
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      controller: etPasswordController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: etPasswordController.text.isNotEmpty
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
                        suffixIcon: IconButton(
                          onPressed: () {
                            etPasswordController.clear();
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                        hintText: Strings.of(context)?.get("my_page_password_hint")??"새 비밀번호를 입력해주세요._",
                        hintStyle:CustomStyle.greyDefFont(),
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
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                    child: Text(
                      Strings.of(context)?.get("my_page_password_confirm")??"비밀번호 확인_",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                ),
                Container(
                    height: CustomStyle.getHeight(35.h),
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      controller: etPasswordConfirmController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: etPasswordConfirmController.text.isNotEmpty
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
                        suffixIcon: IconButton(
                          onPressed: () {
                            etPasswordConfirmController.clear();
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                        hintText: Strings.of(context)?.get("my_page_password_confirm_hint")??"새 비밀번호를 한번 더 확인해주세요._",
                        hintStyle:CustomStyle.greyDefFont(),
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
                )
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await showEditPwd();
            },
            child: Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h)),
              decoration: const BoxDecoration(
                color: main_color
              ),
              child: Text(
                Strings.of(context)?.get("my_page_password_edit")??"비밀번호 변경_",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
              ),
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
          var app = await controller.getUserInfo();
          if(app != tempData.value) {

          }
          if(widget.onCallback != null) {
            widget.onCallback!(true);
          }
          return Future((){
            FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
            return true;
          });
        },
        child: Scaffold(
            backgroundColor: Colors.white,
      appBar: AppBar(
                toolbarHeight: 50.h,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.keyboard_arrow_left,size: 24.h,color: styleWhiteCol),
                ),
          ),
      body: SafeArea(
            child: Obx((){
              return SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    headerWidget(),
                    bodyWidget()
                  ],
                )
              );
            })
        )
    )
    );
  }

}