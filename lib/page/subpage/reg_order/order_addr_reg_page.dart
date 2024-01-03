import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/addr_search_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderAddrRegPage extends StatefulWidget {

  AddrModel? addr_vo;
  String? code;
  int? position;

  OrderAddrRegPage({Key? key,this.addr_vo, this.code, this.position}):super(key:key);

  _OrderAddrRegPageState createState() => _OrderAddrRegPageState();
}


class _OrderAddrRegPageState extends State<OrderAddrRegPage> {

  ProgressDialog? pr;
  final controller = Get.find<App>();

  final mData = AddrModel().obs;

  final mTitle = "".obs;
  final tvReg = true.obs;
  final tvInput = true.obs;
  final tvEdit = true.obs;

  String code = "";
  int? position = 0;

  late TextEditingController addrNameController;
  late TextEditingController addrController;
  late TextEditingController addrDetailController;
  late TextEditingController staffNameController;
  late TextEditingController staffTelController;
  late TextEditingController orderMemoController;

  @override
  void initState() {
    super.initState();

    addrNameController = TextEditingController();
    addrDetailController = TextEditingController();
    staffNameController = TextEditingController();
    staffTelController = TextEditingController();
    orderMemoController = TextEditingController();

    Future.delayed(Duration.zero, () async {
      if(widget.code != null) code = widget.code!;
      if(widget.position != null) position = widget.position;
      await initView();
    });
  }

  void selectAddrCallback(KakaoModel? kakao) {
    if(kakao != null) {
      setState(() {
        mData.value.addr = kakao.address_name;
        mData.value.sido = kakao.region_1depth_name;
        mData.value.gungu = kakao.region_2depth_name;
        mData.value.dong = kakao.region_3depth_name;
        mData.value.lat = kakao.y;
        mData.value.lon = kakao.x;
      });
    }
  }

  Future<void> initView() async {
    if(widget.addr_vo != null) {
      mData.value = widget.addr_vo!;
      tvReg.value = false;
      tvInput.value = false;
      mTitle.value = Strings.of(context)?.get("order_addr_edit_title")??"Not Found";
    }else{
      mData.value = AddrModel();
      tvEdit.value = false;
      if(code != "") {
        tvReg.value = false;
        mTitle.value = Strings.of(context)?.get("order_addr_input_title")??"Not Found";
      }else{
        tvInput.value = false;
        mTitle.value = Strings.of(context)?.get("order_addr_reg_title")??"Not Found";
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    addrNameController.dispose();
    addrDetailController.dispose();
    staffNameController.dispose();
    staffTelController.dispose();
    orderMemoController.dispose();
  }

  Future<void> goToAddrSearch() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddrSearchPage(callback: selectAddrCallback)));
  }

  Future<void> inputAddr() async {
    var result = await validation();
    if(result) {
      Navigator.of(context).pop({'code':200,Const.ADDR_VO:mData.value});
    }
  }

  Future<void> regAddr() async {
    var result = await validation();
    if(result) {
      Logger logger = Logger();
      UserModel? user = await controller.getUserInfo();
      await DioService.dioClient(header: true).regAddr(
          user.authorization, 0,
          mData.value.addrName, mData.value.addr,
          mData.value.addrDetail, mData.value.lat, mData.value.lon,
          mData.value.staffName, mData.value.staffTel,
          mData.value.orderMemo, mData.value.sido, mData.value.gungu, mData.value.dong
      ).then((it) async {
        try {
          ReturnMap _response = DioService.dioResponse(it);
          logger.d("regAddr() _response -> ${_response.status} // ${_response
              .resultMap}");
          if (_response.status == "200") {
            if (_response.resultMap?["result"] == true) {
              Util.toast("${Strings.of(context)?.get("order_addr_reg_title")}${Strings.of(context)?.get("reg_success")}");
              Navigator.of(context).pop({'code':200});
            } else {
              openOkBox(context, "${_response.resultMap?["msg"]}",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
          }
        }catch(e) {
          print("regAddr() Exeption =>$e");
        }
      }).catchError((Object obj){
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("regAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("regAddr() getOrder Default => ");
            break;
        }
      });
    }
  }

  Future<void> editAddr() async {
    var result = await validation();
      if(result) {
        Logger logger = Logger();
        UserModel? user = await controller.getUserInfo();
        await DioService.dioClient(header: true).regAddr(
            user.authorization, 0,
            mData.value.addrName, mData.value.addr,
            mData.value.addrDetail, mData.value.lat, mData.value.lon,
            mData.value.staffName, mData.value.staffTel,
            mData.value.orderMemo, mData.value.sido, mData.value.gungu, mData.value.dong
        ).then((it) async {
          try {
            ReturnMap _response = DioService.dioResponse(it);
            logger.d("editAddr() _response -> ${_response.status} // ${_response
                .resultMap}");
            if (_response.status == "200") {
              if (_response.resultMap?["result"] == true) {
                Util.toast("${Strings.of(context)?.get("order_addr_edit_title")}${Strings.of(context)?.get("reg_success")}");
                Navigator.of(context).pop({'code':200,Const.ADDR_VO: mData.value, "position": position});
              } else {
                openOkBox(context, "${_response.resultMap?["msg"]}",
                    Strings.of(context)?.get("confirm") ?? "Error!!", () {
                      Navigator.of(context).pop(false);
                 });
              }
            }
          }catch(e) {
            print("editAddr() Exeption =>$e");
          }
        }).catchError((Object obj){
          switch (obj.runtimeType) {
            case DioError:
            // Here's the sample to get the failed response error code and message
              final res = (obj as DioError).response;
              print("editAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
              break;
            default:
              print("editAddr() getOrder Default => ");
              break;
          }
        });
      }
  }

  Future<bool> validation() async {
    if(mData.value.addrName?.trim().isEmpty == true || mData.value.addrName?.trim() == null) {
      Util.toast(Strings.of(context)?.get("order_addr_reg_addr_name_hint"));
      return false;
    }
    if(mData.value.addr?.trim().isEmpty == true || mData.value.addr?.trim() == null) {
      Util.toast(Strings.of(context)?.get("order_addr_reg_addr_hint"));
      return false;
    }
    return true;
  }

  Widget bodyWidget() {
    addrNameController.text = mData.value.addrName??"";
    addrDetailController.text = mData.value.addrDetail??"";
    staffNameController.text = mData.value.staffName??"";
    staffTelController.text = mData.value.staffTel??"";
    orderMemoController.text = mData.value.orderMemo??"";


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //주소지명
        Row(
            children :[
              Text(
                Strings.of(context)?.get("order_addr_reg_addr_name")??"",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              Container(
                padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                child: Text(
                  Strings.of(context)?.get("essential")??"",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                ),
              )
            ]
        ),
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            height: CustomStyle.getHeight(45.h),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              controller: addrNameController,
              maxLines: null,
              decoration: addrNameController.text.isNotEmpty
                  ? InputDecoration(
                counterText: '',
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
                    addrNameController.clear();
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
                hintText: Strings.of(context)?.get("order_addr_reg_addr_name_hint")??"Not Found",
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
                mData.value.addrName = value;
              },
            )
        ),
        // 주소
        Container(
          padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
          child: Row(
              children :[
                Text(
                  Strings.of(context)?.get("order_addr_reg_addr")??"",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                  child: Text(
                    Strings.of(context)?.get("essential")??"",
                    style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                  ),
                )
              ]
          )
        ),
        InkWell(
          onTap: () async {
            await goToAddrSearch();
          },
        child: Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
       
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
            decoration: BoxDecoration(
              border: Border.all(color: text_box_color_02,width: 1.w),
              borderRadius: BorderRadius.all(Radius.circular(10.w))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          text: "${mData.value.addr??Strings.of(context)?.get("order_addr_reg_addr_hint")}",
                          style: mData.value.addr == null ? CustomStyle.greyDefFont() : CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        )
                    )
                ),
                Icon(Icons.search, color: styleDefaultGrey,size: 28.h)
              ],
            )
        )),
        //상세주소
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
          child: Text(
            Strings.of(context)?.get("order_addr_reg_addr_detail")??"",
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          )
        ),
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            height: CustomStyle.getHeight(45.h),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              controller: addrDetailController,
              maxLines: null,
              decoration: addrDetailController.text.isNotEmpty
                  ? InputDecoration(
                counterText: '',
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
                    addrDetailController.clear();
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
                hintText: Strings.of(context)?.get("order_addr_reg_addr_detail_hint")??"Not Found",
                hintStyle:CustomStyle.greyDefFont(),
                contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
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
                mData.value.addrDetail = value;
              },
            )
        ),
        // 담당자
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
            child: Text(
              Strings.of(context)?.get("order_addr_reg_staff")??"",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            )
        ),
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            height: CustomStyle.getHeight(45.h),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              controller: staffNameController,
              maxLines: null,
              decoration: staffNameController.text.isNotEmpty
                  ? InputDecoration(
                counterText: '',
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
                    staffNameController.clear();
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
                contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
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
            )
        ),
        //담당자 연락처
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
            child: Text(
              Strings.of(context)?.get("order_addr_reg_tel")??"",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            )
        ),
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            height: CustomStyle.getHeight(45.h),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              controller: staffTelController,
              maxLines: null,
              decoration: staffTelController.text.isNotEmpty
                  ? InputDecoration(
                counterText: '',
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
                mData.value.staffTel = value;
              },
            )
        ),
        //메모
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
            child: Text(
              Strings.of(context)?.get("order_addr_reg_memo")??"",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            )
        ),
        Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
            height: CustomStyle.getHeight(250.h),
            child: TextField(
              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.text,
              controller: orderMemoController,
              maxLines: null,
              decoration: orderMemoController.text.isNotEmpty
                  ? InputDecoration(
                counterText: '',
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
                    orderMemoController.clear();
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
                hintText: Strings.of(context)?.get("order_addr_reg_memo_hint")??"Not Found",
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
            )
        ),
      ],
    );
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
                title: Obx((){
                  return Center(
                    child: Text(
                      mTitle.value,
                      style: CustomStyle.appBarTitleFont(
                          styleFontSize16, styleWhiteCol)
                    )
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
                  icon: Icon(Icons.arrow_back,size: 24.h, color: styleWhiteCol),
                ),
              ),
          body: SafeArea(
              child: Obx((){
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  child: bodyWidget()
                )
              );
              })
          ),
          bottomNavigationBar: Obx((){
              return SizedBox(
                height: CustomStyle.getHeight(60.0.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tvReg.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await regAddr();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, size: 20.h, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("reg_btn")??"Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ])
                            )
                        )
                    ):const SizedBox(),
                    tvEdit.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await editAddr();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit, size: 20.h, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("edit_btn")??"Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ])
                            )
                        )
                    ) : const SizedBox(),
                    tvInput.value ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await inputAddr();
                            },
                            child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: main_color),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check, size: 20.h, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("confirm")??"Not Found",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, styleWhiteCol),
                                      ),
                                    ])
                            )
                        )
                    ) : const SizedBox()
                  ],
                ));
          }),
        )
    );
  }

}