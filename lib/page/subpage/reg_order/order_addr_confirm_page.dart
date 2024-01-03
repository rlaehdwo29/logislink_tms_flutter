import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class OrderAddrConfirmPage extends StatefulWidget {

  AddrModel addr_vo;

  OrderAddrConfirmPage({Key? key,required this.addr_vo}):super(key:key);

  _OrderAddrConfirmPageState createState() => _OrderAddrConfirmPageState();
}


class _OrderAddrConfirmPageState extends State<OrderAddrConfirmPage> {

  ProgressDialog? pr;

  final mData = AddrModel().obs;

  late TextEditingController staffController;
  late TextEditingController staffTelController;
  late TextEditingController memoController ;

  final staffText = "".obs;
  final staffTelText = "".obs;
  final memoText = "".obs;

  @override
  void initState() {
    super.initState();

    staffController = TextEditingController();
    staffTelController = TextEditingController();
    memoController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      mData.value = widget.addr_vo!;
      await initView();
    });
  }

  @override
  void dispose(){
    super.dispose();
    staffController.dispose();
    staffTelController.dispose();
    memoController.dispose();
  }

  Future<void> initView() async {
    staffController.text = mData.value.staffName??"";
    staffTelController.text = mData.value.staffTel??"";
    memoController.text = mData.value.orderMemo??"";
  }

  Widget headerWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
      child: Row(
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
            padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    child: RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          text: "${mData.value.addrName}",
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        )
                    )
                ),
                Flexible(
                    child: RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          text: "${mData.value.addr}",
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_03),
                        )
                    )
                ),
                Flexible(
                    child: RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          text: "${mData.value.addrDetail}",
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_03),
                        )
                    )
                )
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
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 담당자
                Text(
                  "${Strings.of(context)?.get("order_addr_reg_staff")??"Not Found"}",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                ),
                Container(
                  padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    //height: CustomStyle.getHeight(70.h),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
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
                        mData.value.staffName = value;
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
                    height: CustomStyle.getHeight(70.h),
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.phone,
                      maxLines: null,
                      controller: staffTelController,
                      decoration: staffTelController.text.isNotEmpty
                          ? InputDecoration(
                        counterText: '',
                        hintText: Strings.of(context)?.get("order_addr_reg_tel_hint")??"Not Found",
                        hintStyle:CustomStyle.greyDefFont(),
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
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
                        mData.value.staffTel = value;
                      },
                      maxLength: 50,
                    )
                ),
                // 메모
                Container(
                    padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                    child: Text(
                      "${Strings.of(context)?.get("order_addr_reg_memo")??"Not Found"}",
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                    )
                ),
                Container(
                    padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                    child: TextField(
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      controller: memoController,
                      decoration: memoController.text.isNotEmpty
                          ? InputDecoration(
                        counterText: '',
                        hintText: Strings.of(context)?.get("order_addr_confirm_memo_hint")??"Not Found",
                        hintStyle:CustomStyle.greyDefFont(),
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
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
                            memoController.clear();
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
                        hintText: Strings.of(context)?.get("order_addr_confirm_memo_hint")??"Not Found",
                        hintStyle:CustomStyle.greyDefFont(),
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
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
                        mData.value.orderMemo = value;
                      },
                      maxLength: 50,
                    )
                )
              ]
            )
          ],
        ),
      )
    );
  }

  Future<void> confirm() async {
    Navigator.of(context).pop({'code':200,Const.ADDR_VO:mData.value});
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar: AppBar(
                title: Center(
                  child: Text(
                      Strings.of(context)?.get("order_addr_confirm_title")??"Not Found",
                      style: CustomStyle.appBarTitleFont(styleFontSize16, styleWhiteCol)
                  )
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back,size: 24.h,color: styleWhiteCol),
                ),
              ),
          body: SafeArea(
              child: Obx((){
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
              })
          ),
          bottomNavigationBar: SizedBox(
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
                              decoration: const BoxDecoration(color: main_color),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, size: 20.h, color: styleWhiteCol),
                                    CustomStyle.sizedBoxWidth(5.0.w),
                                    Text(
                                      textAlign: TextAlign.center,
                                      Strings.of(context)?.get("confirm") ??
                                          "Not Found",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize16, styleWhiteCol),
                                    ),
                                  ]
                              )
                          )
                      )
                  ),
                ],
              )),
        )
    );
  }
  
}