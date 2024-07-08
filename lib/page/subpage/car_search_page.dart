import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/car_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class CarSearchPage extends StatefulWidget {
  
  _CarSearchPageState createState() => _CarSearchPageState();
}

class _CarSearchPageState extends State<CarSearchPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final search_text = "".obs;
  final mList = List.empty(growable: true).obs;
  final mData = CarModel().obs;

  final size = 0.obs;

  late TextEditingController etCarNumController;
  late TextEditingController etDriverNameController;
  late TextEditingController etTelController;
  late TextEditingController etCarTypeController;
  late TextEditingController etCarTonController;

  @override
  void initState() {
    super.initState();
    etCarNumController = TextEditingController();
    etDriverNameController = TextEditingController();
    etTelController = TextEditingController();
    etCarTypeController = TextEditingController();
    etCarTonController = TextEditingController();
    Future.delayed(Duration.zero, () async {
      await initView();
    });
  }

  Future<void> initView() async {
    await getCar();
  }

  @override
  void dispose() {
    super.dispose();
    etCarNumController.dispose();
    etDriverNameController.dispose();
    etTelController.dispose();
    etCarTypeController.dispose();
    etCarTonController.dispose();
  }

  Widget searchBoxWidget() {
    return Row(
        children :[
          Expanded(
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.number,
                onChanged: (value) async {
                  search_text.value = value;
                  await searchCar();
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: Strings.of(context)?.get("car_search_hint")??"Not Found",
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
                  ),
                  suffixIcon: GestureDetector(
                    child: Icon(
                      Icons.search, size: 24.h, color: Colors.black,
                    ),
                    onTap: (){

                    },
                  ),
                ),
              )
          ),
        ]
    );
  }

  Widget selfInputWidget() {
    return InkWell(
        onTap: () async {
          await showCarAdd();
        },
        child: Container(
            padding: EdgeInsets.symmetric(
                vertical: CustomStyle.getHeight(5.h),
                horizontal: CustomStyle.getWidth(15.w)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: line, width: CustomStyle.getWidth(0.5)))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "직접입력",
                    style:
                    CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                  Icon(Icons.keyboard_arrow_right,
                      size: 24.h, color: text_color_03)
                ])));
  }

  Widget searchListWidget() {
    return Container(
      child: mList.isNotEmpty
          ? Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: mList.length,
            itemBuilder: (context, index) {
              var item = mList[index];
              return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: getListItemView(item)
                  )
                )
              );
            },
          )
        )
      ):Expanded(
          child: Container(
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style: CustomStyle.baseFont(),
              )
          )
      ),
    );
  }

  Widget getListItemView(CarModel item) {
    return InkWell(
        onTap: (){
          Navigator.of(context).pop({'code':200,'car':item});
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: line,
                  width: 1.w
                )
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.carNum??"",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
                    child: Row(
                      children: [
                        Text(
                          item.driverName??"",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                          child: Text(
                            Util.makePhoneNumber(item.mobile),
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                          ),
                        )
                      ],
                    )
                )
              ],
            )
        )
    );
  }

  Future<void> getCar() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCar(
        user.authorization,
        search_text.value
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mList.length > 0) mList.clear();
            if(list.length > 0) {
              List<CarModel> itemsList = list.map((i) => CarModel.fromJSON(i)).toList();
              size.value = itemsList.length;
              mList.addAll(itemsList);
            }
          }else{
            mList.value = List.empty(growable: true);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getCustUser() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCustUser() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> searchCar() async {
    if(search_text.value.length == 1) {
      Util.toast("검색어를 2글자 이상 입력해 주세요.");
    }else{
      search_text.value = search_text.value.trim();
      await getCar();
    }
  }

  Future<void> showCarAdd() async {
    etCarNumController.text = "";
    etDriverNameController.text = "";
    etTelController.text = "";
    etCarTypeController.text = "";
    etCarTonController.text = "";

    if(mData.value == null) {
      mData.value = CarModel();
    }else{
      mData.value.carTonCode = "";
      mData.value.carTonName = "";
      mData.value.carTypeCode = "";
      mData.value.carTypeName = "";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context ){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))
                    ),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                        decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                        child: Text(
                          '${Strings.of(context)?.get("order_detail_vehicle_dispatch")}',
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                        )
                    ),
                    content: Obx((){
                      return SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 차량번호(필수)
                                Container(
                                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),top: CustomStyle.getHeight(10.h),left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                                            child: Text(
                                              Strings.of(context)?.get("order_detail_car_num")??"차랑번호_",
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            )
                                        ),
                                        Text(
                                          Strings.of(context)?.get("essential")??"(필수_)",
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                        )
                                      ],
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                    height: CustomStyle.getHeight(35.h),
                                    child: TextField(
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      controller: etCarNumController,
                                      maxLines: 1,
                                      decoration: etCarNumController.text.isNotEmpty
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
                                            etCarNumController.clear();
                                            mData.value.carNum = "";
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
                                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
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
                                        mData.value.carNum = value.trim();
                                      },
                                      maxLength: 50,
                                    )
                                ),
                                // 성명/연락처
                                Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_driver_name")??"성명_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                                  height: CustomStyle.getHeight(35.h),
                                                  child: TextField(
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                    textAlign: TextAlign.start,
                                                    keyboardType: TextInputType.text,
                                                    controller: etDriverNameController,
                                                    maxLines: 1,
                                                    decoration: etDriverNameController.text.isNotEmpty
                                                        ? InputDecoration(
                                                      counterText: '',
                                                      
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
                                                          etDriverNameController.clear();
                                                          mData.value.driverName = "";
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
                                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
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
                                                      mData.value.driverName = value.trim();
                                                    },
                                                    maxLength: 50,
                                                  )
                                              ),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_driver_tel")??"연락처_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),right: CustomStyle.getWidth(3.w)),
                                                  height: CustomStyle.getHeight(35.h),
                                                  child: TextField(
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                    textAlign: TextAlign.start,
                                                    keyboardType: TextInputType.phone,
                                                    controller: etTelController,
                                                    maxLines: 1,
                                                    decoration: etTelController.text.isNotEmpty
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
                                                          etTelController.clear();
                                                          mData.value.mobile = "";
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
                                                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
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
                                                      mData.value.mobile = value.trim();
                                                    },
                                                    maxLength: 50,
                                                  )
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                // 차종 / 톤급
                                Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_type_code")??"차종_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_car_type")??"", codeType: Const.CAR_TYPE_CD, mFilter: "", callback: selectCarTypeName).showDialog();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(3.w)),
                                                  height: CustomStyle.getHeight(30.h),
                                                  alignment: Alignment.centerLeft,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: text_color_01,width: 0.5.w),
                                                    borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                  ),
                                                  child: Text(
                                                    mData.value.carTypeName??"",
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  ),
                                                )
                                              ),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Strings.of(context)?.get("order_detail_car_ton_code")??"톤급_",
                                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                                                          child: Text(
                                                            Strings.of(context)?.get("essential")??"(필수_)",
                                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  ShowCodeDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_cargo_info_car_ton")??"", codeType: Const.CAR_TON_CD, mFilter: "", callback: selectCarTon).showDialog();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h),left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w)),
                                                  height: CustomStyle.getHeight(30.h),
                                                  alignment: Alignment.centerLeft,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: text_color_01,width: 0.5.w),
                                                    borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                                  ),
                                                  child: Text(
                                                    mData.value.carTonCode??"",
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  ),
                                                )
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: CustomStyle.getHeight(40.h),
                                  margin: EdgeInsets.only(top: CustomStyle.getHeight(20.h)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop(false);
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                  color: sub_btn,
                                                  child: Text(
                                                    Strings.of(context)?.get("cancel") ?? "취소_",
                                                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                                                  )
                                              )
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: InkWell(
                                              onTap: () async {
                                                var result = await dialogConfirm();
                                                if(result) Navigator.of(context).pop({'code': 200,'car':mData.value});
                                              },
                                              child: Container(
                                                  color: main_btn,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    Strings.of(context)?.get("confirm") ?? "확인_",
                                                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                                                  )
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                )

                              ]
                          )
                      );
                  })
                );
              }
          );
        }
    );
  }

  void selectCarTypeName(CodeModel? codeModel,String? codeType) {
      if(codeType != ""){
        switch(codeType) {
          case 'CAR_TYPE_CD':
            setState(() {
              mData.value.carTypeCode = codeModel?.code;
              mData.value.carTypeName = codeModel?.codeName;
            });
            break;
        }
      }
  }

  void selectCarTon(CodeModel? codeModel,String? codeType) {
    if(codeType != ""){
      switch(codeType) {
        case 'CAR_TON_CD':
          setState(() {
            mData.value.carTonCode = codeModel?.code;
            mData.value.carTonName = codeModel?.codeName;
          });
          break;
      }
    }
  }

  Future<bool> dialogConfirm() async {
    var result = await allocRegValid();
    if(result) {
      if(Util.regexCarNumber(etCarNumController.text.trim())){
        Util.toast("차량번호를 확인해 주세요.");
      }else{
        mData.value.carNum = etCarNumController.text.trim();
        mData.value.driverName = etDriverNameController.text.trim();
        mData.value.mobile = etTelController.text.trim();
        mData.value.talkYn = "N";
        Navigator.of(context).pop({'code':200});
        return true;
      }
    }
    return false;
  }

  Future<bool> allocRegValid() async {
      if(etCarNumController.text.trim().isEmpty == true || etCarNumController.text.trim() == null) {
        Util.toast("차량번호를 입력해 주세요.");
        return false;
      }
      if(mData.value.driverName?.trim().isEmpty == true || mData.value.driverName?.trim() == null) {
        Util.toast("차주성명을 입력해 주세요.");
        return false;
      }
      if(mData.value.mobile?.trim().isEmpty == true || mData.value.mobile?.trim() == null) {
        Util.toast("연락처를 입력해 주세요.");
        return false;
      }
      if(mData.value.carTonCode?.trim().isEmpty == true || mData.value.carTonCode?.trim() == null) {
        Util.toast("톤급을 설정해 주세요.");
        return false;
      }
      if(mData.value.carTypeName?.trim().isEmpty == true || mData.value.carTypeName?.trim() == null) {
        Util.toast("차종을 설정해 주세요.");
        return false;
      }
      return true;
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
                  title: Text(
                      Strings.of(context)?.get("car_search_title")??"Not Found",
                      style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
                  ),
                  toolbarHeight: 50.h,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop({'code':100});
                    },
                    color: styleWhiteCol,
                    icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.white),
                  ),
                ),
            body: SafeArea(
                child: Obx((){
                  return SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          searchBoxWidget(),
                          selfInputWidget(),
                          searchListWidget()
                        ],
                      )
                  );
                })
            )
        )
    );
  }

}