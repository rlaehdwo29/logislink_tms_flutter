import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class StopPointConfirmPage extends StatefulWidget {

  StopPointModel result_work_stopPoint;
  String code;

  StopPointConfirmPage({Key? key,required this.result_work_stopPoint, required this.code}):super(key:key);

  _StopPointConfirmPageState createState() => _StopPointConfirmPageState();
}


class _StopPointConfirmPageState extends State<StopPointConfirmPage> {

  ProgressDialog? pr;

  final mData = StopPointModel().obs;

  late TextEditingController staffController;
  late TextEditingController staffTelController;
  late TextEditingController cargoInfoController ;
  late TextEditingController goodWeightController ;
  late TextEditingController goodQtyController ;

  final staffText = "".obs;
  final staffTelText = "".obs;
  final memoText = "".obs;

  static const STOP_TYPE_01 = "S";
  static const STOP_TYPE_02 = "E";

  static const MAX_COUNT = 20;

  final mTitle = "".obs;
  final tvConfirm = "".obs;

  final selectStopType01 = false.obs;
  final selectStopType02 = false.obs;

  @override
  void initState() {
    super.initState();

    staffController = TextEditingController();
    staffTelController = TextEditingController();
    cargoInfoController = TextEditingController();
    goodWeightController = TextEditingController();
    goodQtyController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      mData.value = widget.result_work_stopPoint!;
      await initView();
    });
  }

  @override
  void dispose(){
    super.dispose();
    staffController.dispose();
    staffTelController.dispose();
    cargoInfoController.dispose();
    goodWeightController.dispose();
    goodQtyController.dispose();
  }

  Future<void> initView() async {

    staffController.text = mData.value.eStaff??"";
    staffTelController.text = mData.value.eTel??"";
    cargoInfoController.text = mData.value.goodsName??"";
    goodWeightController.text = mData.value.goodsWeight??"";
    goodQtyController.text = mData.value.goodsQty??"";

    if(widget.code == "confirm") {
      mTitle.value = Strings.of(context)?.get("stop_point_confirm_title_01")??"Not Found";
      tvConfirm.value = Strings.of(context)?.get("confirm")??"Not Found";
    }else{
      mTitle.value = Strings.of(context)?.get("stop_point_confirm_title_02")??"Not Found";
      tvConfirm.value = Strings.of(context)?.get("edit")??"Not Found";
    }

    if(mData.value.stopSe == null || mData.value.stopSe?.isEmpty == true) {
      mData.value.stopSe = STOP_TYPE_01;
    }
    await setStopType();
  }

  void selectItem(CodeModel? codeModel,String? codeType) {
    if(codeType != "") {
      switch (codeType) {
        case 'QTY_UNIT_CD' :
          mData.value.qtyUnitCode = codeModel?.code;
          mData.value.qtyUnitName = codeModel?.codeName;
          break;
      }
    }
    setState(() {});
  }

  Future<void> setStopType() async {
    if(STOP_TYPE_01 == mData.value.stopSe) {
      selectStopType01.value = true;
      selectStopType02.value = false;
    }else{
      selectStopType01.value = false;
      selectStopType02.value = true;
    }
  }

  Widget headerWidget() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(20.h),horizontal: CustomStyle.getWidth(20.w)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child:Icon(
                  Icons.house_outlined,
                  color: text_color_01,
                  size: 28.h,
                )
            ),
            Expanded(
                flex: 9,
                child: Container(
                    height: 60.h,
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(20.w)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        mData.value.eComName?.isNotEmpty == true ? Flexible(
                            child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  text: "${mData.value.eComName}",
                                  style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
                                )
                            )
                        ): const SizedBox(),
                        mData.value.eAddr?.isNotEmpty == true ? Flexible(
                            child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  text: "${mData.value.eAddr}",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_03),
                                )
                            )
                        ) : const SizedBox(),
                        mData.value.eAddrDetail?.isNotEmpty == true? Flexible(
                            child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  text: "${mData.value.eAddrDetail}",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_03),
                                )
                            )
                        ):const SizedBox()
                      ],
                    )
                )
            )
          ],
        )
    );
  }

  Widget bodyWidget() {
    return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(20.w)),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 상차지 하차지 Button
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
                                    mData.value.stopSe = STOP_TYPE_01;
                                    await setStopType();
                                  },
                                  child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h),bottom: CustomStyle.getHeight(10.h)),
                                margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                decoration: BoxDecoration(
                                    border: Border.all(color: selectStopType01.value ? renew_main_color2 : text_box_color_02, width: 1.0.w),
                                  borderRadius: BorderRadius.all(Radius.circular(5.w))
                                ),
                              child: Text(
                                //"상차지",
                                "\'상차\'할거에요",
                                style: CustomStyle.CustomFont(styleFontSize14, selectStopType01.value ? renew_main_color2 : text_box_color_02),
                                ),
                              )
                            )
                          ),
                         Expanded(
                             child: InkWell(
                                 onTap: () async {
                                   mData.value.stopSe = STOP_TYPE_02;
                                   await setStopType();
                                 },
                                 child: Container(
                               alignment: Alignment.center,
                               padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h),bottom: CustomStyle.getHeight(10.h)),
                               margin: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                               decoration: BoxDecoration(
                                   border: Border.all(color: selectStopType02.value ? rpa_btn_cancle : text_box_color_02, width: 1.0.w),
                                   borderRadius: BorderRadius.all(Radius.circular(5.w))
                               ),
                               child: Text(
                                 //"하차지",
                                 "\'하차\'할거에요",
                                 style: CustomStyle.CustomFont(styleFontSize14, selectStopType02.value ? rpa_btn_cancle : text_box_color_02),
                               ),
                             )
                           )
                          )
                        ],
                      )
                    ),

                    // 담당자
                    Container(
                      padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                      child: Text(
                        "${Strings.of(context)?.get("order_addr_reg_staff")??"Not Found"}",
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                      )
                    ),
                    Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                        height: CustomStyle.getHeight(45.h),
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          controller: staffController,
                          maxLines: null,
                          decoration: staffController.text.isNotEmpty
                              ? InputDecoration(
                            counterText: '',
                            hintText: Strings.of(context)?.get("order_addr_reg_staff_hint")??"Not Found",
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                staffController.clear();
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
                            hintText: Strings.of(context)?.get("order_addr_reg_staff_hint")??"Not Found",
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                          ),
                          onChanged: (value){
                            mData.value.eStaff = value;
                          },
                          maxLength: 50,
                        )
                    ),
                    // 담당자 연락처
                    Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                        child: Text(
                          "${Strings.of(context)?.get("order_addr_reg_tel")??"Not Found"}",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        )
                    ),
                    Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                        height: CustomStyle.getHeight(45.h),
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          controller: staffTelController,
                          decoration: staffTelController.text.isNotEmpty
                              ? InputDecoration(
                            counterText: '',
                            hintText: Strings.of(context)?.get("order_addr_reg_tel_hint")??"Not Found",
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                staffTelController.clear();
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
                            hintText: Strings.of(context)?.get("order_addr_reg_tel_hint")??"Not Found",
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                          ),
                          onChanged: (value){
                            mData.value.eTel = value;
                          },
                          maxLength: 50,
                        )
                    ),
                    // 화물정보
                    Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                        child: Text(
                          "화물정보",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                        )
                    ),
                    Container(
                        padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                        height: CustomStyle.getHeight(45.h),
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          controller: cargoInfoController,
                          decoration: cargoInfoController.text.isNotEmpty
                              ? InputDecoration(
                            counterText: '',
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                cargoInfoController.clear();
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
                            hintStyle:CustomStyle.greyDefFont(),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                borderRadius: BorderRadius.circular(10.h)
                            ),
                          ),
                          onChanged: (value){
                            mData.value.goodsName = value;
                          },
                          maxLength: 50,
                        )
                    ),
                    // 중량/중량단위 Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 중량
                    Expanded(
                        flex: 1,
                        child: Container(
                        padding: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              padding: EdgeInsets.only(
                                  top: CustomStyle.getHeight(10.h)),
                              child: Text(
                                "중량",
                                style: CustomStyle.CustomFont(
                                    styleFontSize14, text_color_01,
                                    font_weight: FontWeight.w700),
                              )),
                          Container(
                              padding: EdgeInsets.only(
                                  top: CustomStyle.getHeight(5.h)),
                              height: CustomStyle.getHeight(45.h),
                              child: TextField(
                                style: CustomStyle.CustomFont(
                                    styleFontSize14, Colors.black),
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                maxLines: null,
                                controller: goodWeightController,
                                decoration: goodWeightController.text.isNotEmpty
                                    ? InputDecoration(
                                        counterText: '',
                                        hintStyle: CustomStyle.greyDefFont(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: CustomStyle.getWidth(15.0),
                                            vertical: CustomStyle.getHeight(5.0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: text_box_color_02,
                                                width: CustomStyle.getWidth(
                                                    1.0.w)),
                                            borderRadius:
                                                BorderRadius.circular(10.h)),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: line,
                                                width:
                                                    CustomStyle.getWidth(0.5))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: text_box_color_02,
                                                width: CustomStyle.getWidth(
                                                    1.0.w)),
                                            borderRadius:
                                                BorderRadius.circular(10.h)),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            goodWeightController.clear();
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
                                        hintStyle: CustomStyle.greyDefFont(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                CustomStyle.getWidth(15.0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: text_box_color_02,
                                                width: CustomStyle.getWidth(
                                                    1.0.w)),
                                            borderRadius:
                                                BorderRadius.circular(10.h)),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: line,
                                                width:
                                                    CustomStyle.getWidth(0.5))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: text_box_color_02,
                                                width: CustomStyle.getWidth(
                                                    1.0.w)),
                                            borderRadius:
                                                BorderRadius.circular(10.h)),
                                      ),
                                onChanged: (value) {
                                  mData.value.goodsWeight = value;
                                },
                                maxLength: 50,
                              ))
                        ]))),
                      //중량단위
                      Expanded(
                          flex: 1,
                          child: Container(
                          padding: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Container(
                                padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h),bottom: CustomStyle.getHeight(5.h)),
                                child: Text(
                                  "중량단위",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, text_color_01,
                                      font_weight: FontWeight.w700),
                                )),
                            Container(
                              alignment: Alignment.center,
                                padding: EdgeInsets.only(left: CustomStyle.getWidth(15.w),right: CustomStyle.getWidth(15.w)),
                                height: CustomStyle.getHeight(40.h),
                                decoration: BoxDecoration(
                                  border: Border.all(color: text_box_color_02,width: 1.0.w),
                                  borderRadius: BorderRadius.all(Radius.circular(10.w))
                                ),
                                child: Text(
                                  "${Strings.of(context)?.get("ton")??"Not Found"}",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                )
                            )
                          ])))
                  ]),
                    // 수량/수량단위 Row
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 수량
                          Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: CustomStyle.getHeight(10.h)),
                                            child: Text(
                                              "수량",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize14, text_color_01,
                                                  font_weight: FontWeight.w700),
                                            )),
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: CustomStyle.getHeight(5.h)),
                                            height: CustomStyle.getHeight(45.h),
                                            child: TextField(
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize14, Colors.black),
                                              textAlign: TextAlign.start,
                                              keyboardType: TextInputType.number,
                                              maxLines: null,
                                              controller: goodQtyController,
                                              decoration: goodQtyController.text.isNotEmpty
                                                  ? InputDecoration(
                                                counterText: '',
                                                hintStyle: CustomStyle.greyDefFont(),
                                                contentPadding: EdgeInsets.symmetric(
                                                    horizontal: CustomStyle.getWidth(15.0),
                                                    vertical: CustomStyle.getHeight(5.0)),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: text_box_color_02,
                                                        width: CustomStyle.getWidth(
                                                            1.0.w)),
                                                    borderRadius:
                                                    BorderRadius.circular(10.h)),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: line,
                                                        width:
                                                        CustomStyle.getWidth(0.5))),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: text_box_color_02,
                                                        width: CustomStyle.getWidth(
                                                            1.0.w)),
                                                    borderRadius:
                                                    BorderRadius.circular(10.h)),
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    goodQtyController.clear();
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
                                                hintStyle: CustomStyle.greyDefFont(),
                                                contentPadding: EdgeInsets.symmetric(
                                                    horizontal:
                                                    CustomStyle.getWidth(15.0)),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: text_box_color_02,
                                                        width: CustomStyle.getWidth(
                                                            1.0.w)),
                                                    borderRadius:
                                                    BorderRadius.circular(10.h)),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: line,
                                                        width:
                                                        CustomStyle.getWidth(0.5))),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: text_box_color_02,
                                                        width: CustomStyle.getWidth(
                                                            1.0.w)),
                                                    borderRadius:
                                                    BorderRadius.circular(10.h)),
                                              ),
                                              onChanged: (value) {
                                                mData.value.goodsQty = value;
                                              },
                                              maxLength: 50,
                                            ))
                                      ]))),
                          //중량단위
                          Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(3.w)),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h),bottom: CustomStyle.getHeight(5.h)),
                                            child: Text(
                                              "수량단위",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize14, text_color_01,
                                                  font_weight: FontWeight.w700),
                                            )),
                                        InkWell(
                                          onTap: (){
                                            ShowCodeDialogWidget(context:context, mTitle: "수량단위", codeType: Const.QTY_UNIT_CD, mFilter: "", callback: selectItem).showDialog();
                                          },
                                          child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(left: CustomStyle.getWidth(15.w),right: CustomStyle.getWidth(15.w)),
                                              height: CustomStyle.getHeight(40.h),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: text_box_color_02,width: 1.0.w),
                                                  borderRadius: BorderRadius.all(Radius.circular(10.w))
                                              ),
                                              child: Text(
                                                mData.value.qtyUnitName??"",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                              )
                                          )
                                        )
                                      ])))
                        ])
                ]
              )
        )
    );
  }

  Future<void> confirm() async {
    Navigator.of(context).pop({'code':200,Const.RESULT_WORK_STOP_POINT:mData.value});
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar: AppBar(
                title: Obx((){
                  return Text(
                    mTitle.value,
                    style: CustomStyle.appBarTitleFont(
                        styleFontSize16, Colors.black)
                  );
                }),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon:  Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
                ),
              ),
          body: Obx((){
                return SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        headerWidget(),
                        CustomStyle.getDivider1(),
                        bodyWidget()
                      ],
                    )
                );
              }),
          bottomNavigationBar: Obx((){
            return SizedBox(
              height: CustomStyle.getHeight(60.0.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            await confirm();
                          },
                          child: Container(
                              height: CustomStyle.getHeight(60.0.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: renew_main_color2),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, size: 20.h, color: styleWhiteCol),
                                    CustomStyle.sizedBoxWidth(5.0.w),
                                    Text(
                                      textAlign: TextAlign.center,
                                      tvConfirm.value,
                                      style: CustomStyle.CustomFont(
                                          styleFontSize16, styleWhiteCol),
                                    ),
                                  ])
                          )
                      )
                  ),
                ],
              ));
          }),
        ))
    );
  }

}