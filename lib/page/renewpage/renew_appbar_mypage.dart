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
import 'package:logislink_tms_flutter/common/model/user_rpa_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class RenewAppBarMyPage extends StatefulWidget {
  final void Function(bool?)? onCallback;
  String? code;
  String? call24Yn;


  RenewAppBarMyPage({Key? key,this.code,this.call24Yn, this.onCallback}):super(key: key);

  _RenewAppBarMyPageState createState() => _RenewAppBarMyPageState();
}

class _RenewAppBarMyPageState extends State<RenewAppBarMyPage> {
  final controller = Get.find<App>();
  final editMode = false.obs;
  final mData = UserModel().obs;
  final tempData = UserModel().obs;
  final mUserRpaData = UserRpaModel().obs;

  final api24Data = <String, dynamic>{}.obs;

  static const String EDIT_BIZ = "edit_biz";
  final bizFocus = false.obs;

  ProgressDialog? pr;

  late TextEditingController etPasswordController;
  late TextEditingController etPasswordConfirmController;

  late TextEditingController et24CallIdController;
  late TextEditingController et24CallPwController;
  late TextEditingController etHwaIdController;
  late TextEditingController etHwaPwController;
  late TextEditingController etOneCallIdController;
  late TextEditingController etOneCallPwController;

  @override
  void dispose() {
    super.dispose();
    etPasswordController.dispose();
    etPasswordConfirmController.dispose();

    et24CallIdController.dispose();
    et24CallPwController.dispose();
    etHwaIdController.dispose();
    etHwaPwController.dispose();
    etOneCallIdController.dispose();
    etOneCallPwController.dispose();
  }

  @override
  void initState() {
    super.initState();

    etPasswordController = TextEditingController();
    etPasswordConfirmController = TextEditingController();

    et24CallIdController = TextEditingController();
    et24CallPwController = TextEditingController();
    etHwaIdController = TextEditingController();
    etHwaPwController = TextEditingController();
    etOneCallIdController = TextEditingController();
    etOneCallPwController = TextEditingController();


    Future.delayed(Duration.zero, () async {
      mData.value = await App().getUserInfo();
      await getUserRpa();
    });

    if(widget.code != null) {
      if(widget.code == EDIT_BIZ) {
        editMode.value = true;
        bizFocus.value = true;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    });

  }

  // Function

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

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  bool validationRpaEdit() {
    var result = false;

    if(et24CallIdController.text != mUserRpaData.value.link24Id) {
      result = true;
    }else if(et24CallPwController.text != mUserRpaData.value.link24Pass) {
      result = true;
    }else if(etHwaIdController.text != mUserRpaData.value.man24Id) {
      result = true;
    }else if(etHwaPwController.text != mUserRpaData.value.man24Pass) {
      result = true;
    }else if(etOneCallIdController.text != mUserRpaData.value.one24Id) {
      result = true;
    }else if(etOneCallPwController.text != mUserRpaData.value.one24Pass) {
      result = true;
    }
    return result;
  }

  Future<void> editMyInfo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();

    if(etPasswordController.text == '' || etPasswordController.text == null) {
      if(validationRpaEdit()) {
        await updateRpaInfo();
      }else{
        Util.toast("변경할 사항이 없습니다.");
      }
    }else{
      await DioService.dioClient(header: true).userUpdate(
          user.authorization,
          Util.encryption(etPasswordController.text.trim()),
          user.telnum, user.email, user.mobile
      ).then((it) async {
        try {
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("editMyInfo() _response -> ${_response.status} // ${_response.resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              etPasswordController.text = "";
              etPasswordConfirmController.text = "";
              if(validationRpaEdit()) {
                await updateRpaInfo();
              }else{
                Navigator.of(context).pop(false);
                Util.toast("비밀번호가 수정되었습니다.");
              }
            } else {
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          }
        }catch(e) {
          print("editMyInfo() Exeption =>$e");
        }
      }).catchError((Object obj){
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("editMyInfo() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("editMyInfo() getOrder Default => ");
            break;
        }
      });
    }

  }

  Future<void> updateRpaInfo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();

    await DioService.dioClient(header: true).userRpaInfoUpdate(
        user.authorization,
        widget.call24Yn,
        et24CallIdController.text,
        et24CallPwController.text,
        etHwaIdController.text,
        etHwaPwController.text,
        etOneCallIdController.text,
        etOneCallPwController.text
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("updateRpaInfo() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.toast("정보가 수정되었습니다.");
            Navigator.of(context).pop(false);
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("updateRpaInfo() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("updateRpaInfo() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("updateRpaInfo() getOrder Default => ");
          break;
      }
    });
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

  Future<void> getUserRpa() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).rpaLinkInfo(user.authorization,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getUserRpa() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            UserRpaModel userRpaInfo = UserRpaModel.fromJSON(it.response.data["data"]);
            if (userRpaInfo != null) {
             mUserRpaData.value = userRpaInfo;
            } else {
             mUserRpaData.value = UserRpaModel();
            }
            et24CallIdController.text = mUserRpaData.value.link24Id??"";
            et24CallPwController.text = mUserRpaData.value.link24Pass??"";
            etHwaIdController.text = mUserRpaData.value.man24Id??"";
            etHwaPwController.text = mUserRpaData.value.man24Pass??"";
            etOneCallIdController.text = mUserRpaData.value.one24Id??"";
            etOneCallPwController.text = mUserRpaData.value.one24Pass??"";
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
              Navigator.of(context).pop(false);
            });
          }
        }
      }catch(e) {
        print("getUserRpa() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getUserRpa() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUserRpa() getOrder Default => ");
          break;
      }
    });
  }

  // Widget

  Widget headerWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(20)),
      alignment: Alignment.center,
      color: renew_main_color2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/image/ic_logo.png",
                    color: Colors.black,
                    fit: BoxFit.contain,
                  )
              )
          ),
          Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0.h)),
              child: Text(
                mData.value.bizName??"",
                style: CustomStyle.CustomFont(styleFontSize22, Colors.white,font_weight: FontWeight.w700),
              )
          ),
          Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0.h)),
              child: Text(
                "[ ${mData.value.deptName??""} ]",
                style: CustomStyle.CustomFont(styleFontSize20, Colors.white),
              )
          )
        ],
      ),
    );
  }

  Widget bodyWidget() {

    return Container(
      color: light_gray24,
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          Strings.of(context)?.get("my_page_name")??"이름_",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        )
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: box_body
                          ),
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),

                          child: Text(
                            mData.value.userName??"",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                          ),
                        )
                      )
                    ],
                  )
              ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                        Strings.of(context)?.get("id")??"아이디_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: box_body
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),
                        child: Text(
                          mData.value.userId??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        ),
                      )
                  )
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                          Strings.of(context)?.get("my_page_password")??"비밀번호_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
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
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
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
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: Strings.of(context)?.get("my_page_password_hint")??"새 비밀번호를 입력해주세요._",
                              hintStyle:CustomStyle.greyDefFont(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                            onChanged: (value){
                            },
                            maxLength: 50,
                          )
                      )
                  )
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                        Strings.of(context)?.get("my_page_password_confirm")??"비밀번호 확인_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
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
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
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
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: Strings.of(context)?.get("my_page_password_confirm_hint")??"새 비밀번호를 한번 더 확인해주세요._",
                              hintStyle:CustomStyle.greyDefFont(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                            onChanged: (value){
                            },
                            maxLength: 50,
                          )
                      )
                  )
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "이메일",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: box_body
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),
                        child: Text(
                          mData.value.email??"",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        ),
                      )
                  )
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                        Strings.of(context)?.get("my_page_tel")??"연락처_",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: box_body
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w),vertical: CustomStyle.getHeight(10.h)),
                        child: Text(
                          Util.makePhoneNumber(mData.value.mobile),
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        ),
                      )
                  )
                ],
              )
          ),

          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
            height: CustomStyle.getHeight(1),
            color: light_gray15,
          ),
          widget.call24Yn == "Y" ?
          Container(
            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "24시콜",
                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                    ),
                    (mUserRpaData.value.link24Id != null && mUserRpaData.value.link24Id?.isNotEmpty == true) && (mUserRpaData.value.link24Pass != null && mUserRpaData.value.link24Pass?.isNotEmpty == true) ?
                    Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                            child: Icon(
                                Icons.check_circle,
                                size: 22.h, color: renew_main_color2
                            )
                          ),
                          Text(
                            "등록완료",
                            style: CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w600),
                          )
                        ]
                      ) :  Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                              child: Icon(
                                  Icons.warning_amber,
                                  size: 22.h, color: rpa_btn_cancle
                              )
                          ),
                          Text(
                            "등록필요",
                            style: CustomStyle.CustomFont(styleFontSize14, rpa_btn_cancle,font_weight: FontWeight.w600),
                          )
                        ]
                    )
                  ]
                ),
                Container(
                    height: CustomStyle.getHeight(35.h),
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      controller: et24CallIdController,
                      maxLines: 1,
                      decoration: et24CallIdController.text.isNotEmpty
                          ? InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            et24CallIdController.clear();
                            et24CallIdController.text = '';
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "24시콜 아이디를 입력해주세요.",
                        hintStyle:CustomStyle.greyDefFont(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                      onChanged: (value){
                      },
                      maxLength: 50,
                    )
                ),
                Container(
                    height: CustomStyle.getHeight(35.h),
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.visiblePassword,
                      controller: et24CallPwController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: et24CallPwController.text.isNotEmpty
                          ? InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            et24CallPwController.clear();
                            et24CallPwController.text = '';
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "24시콜 비밀번호를 입력해주세요.",
                        hintStyle:CustomStyle.greyDefFont(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                      onChanged: (value){
                      },
                      maxLength: 50,
                    )
                )
              ],
            )
          ) : const SizedBox(),
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "화물맨",
                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                        ),
                        (mUserRpaData.value.man24Id != null && mUserRpaData.value.man24Id?.isNotEmpty == true) && (mUserRpaData.value.man24Pass != null && mUserRpaData.value.man24Pass?.isNotEmpty == true) ?
                        Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                                  child: Icon(
                                      Icons.check_circle,
                                      size: 22.h, color: renew_main_color2
                                  )
                              ),
                              Text(
                                "등록완료",
                                style: CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w600),
                              )
                            ]
                        ) : Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                                  child: Icon(
                                      Icons.warning_amber,
                                      size: 22.h, color: rpa_btn_cancle
                                  )
                              ),
                              Text(
                                "등록필요",
                                style: CustomStyle.CustomFont(styleFontSize14, rpa_btn_cancle,font_weight: FontWeight.w600),
                              )
                            ]
                        )
                      ]
                  ),
                  Container(
                      height: CustomStyle.getHeight(35.h),
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.visiblePassword,
                        controller: etHwaIdController,
                        maxLines: 1,
                        decoration: etHwaIdController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              etHwaIdController.clear();
                              etHwaIdController.text = '';
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
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "화물맨 아이디를 입력해주세요.",
                          hintStyle:CustomStyle.greyDefFont(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        onChanged: (value){
                        },
                        maxLength: 50,
                      )
                  ),
                  Container(
                      height: CustomStyle.getHeight(35.h),
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.visiblePassword,
                        controller: etHwaPwController,
                        obscureText: true,
                        maxLines: 1,
                        decoration: etHwaPwController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              etHwaPwController.clear();
                              etHwaPwController.text = '';
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
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "화물맨 비밀번호를 입력해주세요.",
                          hintStyle:CustomStyle.greyDefFont(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        onChanged: (value){
                        },
                        maxLength: 50,
                      )
                  )
                ],
              )
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "원콜",
                          style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w700),
                        ),
                        (mUserRpaData.value.one24Id != null && mUserRpaData.value.one24Id?.isNotEmpty == true) && (mUserRpaData.value.one24Pass != null && mUserRpaData.value.one24Pass?.isNotEmpty == true) ?
                        Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                                  child: Icon(
                                      Icons.check_circle,
                                      size: 22.h, color: renew_main_color2
                                  )
                              ),
                              Text(
                                "등록완료",
                                style: CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w600),
                              )
                            ]
                        ) : Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(3)),
                                  child: Icon(
                                      Icons.warning_amber,
                                      size: 22.h, color: rpa_btn_cancle
                                  )
                              ),
                              Text(
                                "등록필요",
                                style: CustomStyle.CustomFont(styleFontSize14, rpa_btn_cancle,font_weight: FontWeight.w600),
                              )
                            ]
                        )
                      ]
                  ),
                  Container(
                      height: CustomStyle.getHeight(35.h),
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.visiblePassword,
                        controller: etOneCallIdController,
                        maxLines: 1,
                        decoration: etOneCallIdController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              etOneCallIdController.clear();
                              etOneCallIdController.text = '';
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
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "원콜 아이디를 입력해주세요.",
                          hintStyle:CustomStyle.greyDefFont(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        onChanged: (value){
                        },
                        maxLength: 50,
                      )
                  ),
                  Container(
                      height: CustomStyle.getHeight(35.h),
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w),top: CustomStyle.getHeight(5)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.visiblePassword,
                        controller: etOneCallPwController,
                        obscureText: true,
                        maxLines: 1,
                        decoration: etOneCallPwController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              etOneCallPwController.clear();
                              etOneCallPwController.text = '';
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
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "원콜 비밀번호를 입력해주세요.",
                          hintStyle:CustomStyle.greyDefFont(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        onChanged: (value){
                        },
                        maxLength: 50,
                      )
                  )
                ],
              )
          )
        ],
      )
    );
  }

  Widget bottomWidget() {
    return Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
            color: light_gray24,
            child: InkWell(
                onTap: () async {
                  var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                  if(guest) {
                    showGuestDialog();
                    return;
                  }

                  openCommonConfirmBox(
                      context,
                      "내 정보를 수정하시겠습니까?",
                      Strings.of(context)?.get("cancel")??"Not Found",
                      Strings.of(context)?.get("confirm")??"Not Found",
                          () {Navigator.of(context).pop(false);},
                          () async {
                        Navigator.of(context).pop(false);
                        await editMyInfo();
                      }
                  );
                },
                child: Container(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.7,
                    height: CustomStyle.getHeight(50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_alt, size: 28.h, color: styleWhiteCol),
                          CustomStyle.sizedBoxWidth(5.0.w),
                          Text(
                            textAlign: TextAlign.center,
                            Strings.of(context)?.get("save") ?? "_저장",
                            style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                          ),
                        ]
                    )
                )
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

            /*var result = await showCanceled();
            if (result == true) {
              return true;
            } else {
              return false;
            }*/
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
                  icon: Icon(Icons.keyboard_arrow_left,size: 24.h,color: Colors.black),
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
                      bodyWidget(),
                      bottomWidget()
                    ],
                )
              );
            })
        )
    )
    );
  }

}