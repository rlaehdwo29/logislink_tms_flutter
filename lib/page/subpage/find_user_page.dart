import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class FindUserPage extends StatefulWidget {
  
  _FindUserPageState createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {

  ProgressDialog? pr;
  final controller = Get.find<App>();
  final findId_name = "".obs;
  final findId_phone = "".obs;

  final findPw_id = "".obs;
  final findPw_name = "".obs;
  final findPw_phone = "".obs;

  Future<void> findId() async {
  if(findId_name.isEmpty) {
      Util.toast("이름을 입력해주세요.");
      return;
    }else if(findId_phone.isEmpty) {
      Util.toast("휴대폰 번호를 입력해주세요.");
      return;
    }

    var logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).findId(findId_name.value,findId_phone.value).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("findPw() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(it.response.data["result"] == true) {
          openOkBox(context, it.response.data["msg"], Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }else{
          openOkBox(context, it.response.data["msg"], Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart CheckTermsAgree() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart CheckTermsAgree() error2222 :");
          break;
      }
    });
  }

  Future<void> findPw() async {
    if(findPw_id.isEmpty) {
      Util.toast("아이디를 입력해주세요.");
      return;
    }else if(findPw_name.isEmpty) {
      Util.toast("이름을 입력해주세요.");
      return;
    }else if(findPw_phone.isEmpty) {
      Util.toast("휴대폰 번호를 입력해주세요.");
      return;
    }

    var logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).findPwd(findPw_id.value,findPw_name.value,findPw_phone.value).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
    logger.d("findPw() _response -> ${_response.status} // ${_response.resultMap}");
    if(_response.status == "200") {
       if(it.response.data["result"] == true) {
         openOkBox(context, it.response.data["msg"], Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
       }else{
         openOkBox(context, it.response.data["msg"], Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
       }
    }else{
      openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    }

    }).catchError((Object obj) async {
    await pr?.hide();
    switch (obj.runtimeType) {
    case DioError:
    // Here's the sample to get the failed response error code and message
    final res = (obj as DioError).response;
    logger.e("login_page.dart CheckTermsAgree() error : ${res?.statusCode} -> ${res?.statusMessage}");
    openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    break;
    default:
    logger.e("login_page.dart CheckTermsAgree() error2222 :");
    break;
    }
    });
  }

  Widget findIdWidget() {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
            alignment: Alignment.centerLeft,
            child: Text(
              "이름, 휴대폰 번호로\n아이디를 찾습니다.",
              style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
            )
        ),
        SizedBox(
            height: CustomStyle.getHeight(50.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              onChanged: (value){
                findId_name.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "이름",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )

              ),
            )
        ),
        SizedBox(
            height: CustomStyle.getHeight(50.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              onChanged: (value){
                findId_phone.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "휴대폰 번호",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )
              ),
            )
        ),
        CustomStyle.sizedBoxHeight(10.0),
        InkWell(
            onTap: () async {
              await findId();
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
              height: CustomStyle.getHeight(50.0),
              color: main_color,
              child: Text(
                Strings.of(context)?.get("find_id")??"Not Found",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize16, sub_color),
              ),
            )
        )
      ],
    );
  }

  Widget findPwWidget() {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
            alignment: Alignment.centerLeft,
            child: Text(
              "아이디, 이름, 휴대폰번호로\n비밀번호를 찾습니다.",
              style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
            )
        ),
        SizedBox(
            height: CustomStyle.getHeight(50.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              onChanged: (value){
                findPw_id.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "아이디",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )

              ),
            )
        ),
        SizedBox(
            height: CustomStyle.getHeight(50.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              onChanged: (value){
                findPw_name.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "이름",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )

              ),
            )
        ),
        SizedBox(
            height: CustomStyle.getHeight(50.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              onChanged: (value){
                findPw_phone.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "휴대폰 번호",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )
              ),
            )
        ),
        CustomStyle.sizedBoxHeight(10.0),
        InkWell(
            onTap: () async {
              await findPw();
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
              height: CustomStyle.getHeight(50.0),
              color: main_color,
              child: Text(
                Strings.of(context)?.get("find_pwd")??"Not Found",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize16, sub_color),
              ),
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Scaffold(
      backgroundColor: styleWhiteCol,
      appBar: AppBar(
            title: Text(
                Strings.of(context)?.get("find_user")??"ID / 비밀번호 찾기_",
                style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
            ),
            toolbarHeight: 50.h,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.white),
            ),
          ),
      body: SafeArea(
        child: Container(
          width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
          height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
              child: Column(
              children: [
               findIdWidget(),
                CustomStyle.sizedBoxHeight(30.0),
                CustomStyle.getDivider1(),
                CustomStyle.sizedBoxHeight(30.0),
                findPwWidget()
              ],
            )
          )
        )
      ),
    );
  }
  
}