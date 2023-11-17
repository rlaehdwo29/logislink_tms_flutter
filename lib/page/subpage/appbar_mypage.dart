import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class AppBarMyPage extends StatefulWidget {
  final void Function(bool?)? onCallback;
  String? code;


  AppBarMyPage({Key? key,this.code,this.onCallback}):super(key: key);

  _AppBarMyPageState createState() => _AppBarMyPageState();
}

class _AppBarMyPageState extends State<AppBarMyPage> {
  final controller = Get.find<App>();
  final editMode = false.obs;
  final mData = UserModel().obs;
  final tempData = UserModel().obs;

  static const String EDIT_BIZ = "edit_biz";
  final bizFocus = false.obs;

  ProgressDialog? pr;

  TextEditingController cargoBoxController = TextEditingController();
  TextEditingController bizNumController = TextEditingController();
  TextEditingController subBizNumController = TextEditingController();
  TextEditingController bizNameController = TextEditingController();
  TextEditingController ceoController = TextEditingController();
  TextEditingController bizAddrDetailController = TextEditingController();
  TextEditingController bizCondController = TextEditingController();
  TextEditingController bizKindController = TextEditingController();
  TextEditingController driverEmailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    cargoBoxController.dispose();
    bizNumController.dispose();
    subBizNumController.dispose();
    bizNameController.dispose();
    ceoController.dispose();
    bizAddrDetailController.dispose();
    bizCondController.dispose();
    bizKindController.dispose();
    driverEmailController.dispose();
  }

  @override
  void initState() {
    super.initState();

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
          return true;
        },
        child: Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: Obx((){
            return AppBar(
                leading: IconButton(
                  onPressed: () async {
                    var app = await controller.getUserInfo();
                if(app != tempData.value) {
                  //await showCanceled();
                }else{
                  Navigator.of(context).pop();
                }

                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.keyboard_arrow_left,size: 32.w,color: styleWhiteCol),
                ),
          );
        })
      ),
      body: //Obx((){
         SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Container(
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
                )
              ],
            )
        )
      //})
    )
    );
  }

}