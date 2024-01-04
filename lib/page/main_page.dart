import 'dart:async';
import 'dart:io';
import 'package:fbroadcast/fbroadcast.dart' as fbroad;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_main_widget.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_monitor_page.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_mypage.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_notice_page.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_setting_page.dart';
import 'package:logislink_tms_flutter/page/subpage/notification_page.dart';
import 'package:logislink_tms_flutter/page/subpage/order_detail_page.dart';
import 'package:logislink_tms_flutter/page/subpage/order_trans_info_page.dart';
import 'package:logislink_tms_flutter/page/subpage/point_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/regist_order_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_select_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  final String? allocId;
  const MainPage({Key? key, this.allocId}):super(key:key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with CommonMainWidget,WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final isExpanded = [].obs;
  final isSelected = [].obs;
  final controller = Get.find<App>();
  final mUser = UserModel().obs;

  final GlobalKey webViewKey = GlobalKey();
  final orderList = List.empty(growable: true).obs;
  final myOrder = "N".obs;
  final orderState = "".obs;
  final allocState = "".obs;
  final searchValue = "".obs;
  late String startDate, endDate, nowDate;

  DateTime mCalendarNowDate = DateTime.now();
  final mCalendarStartDate = DateTime.now().add(const Duration(days: -30)).obs;
  final mCalendarEndDate = DateTime.now().obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  final myOrderSelect = false.obs;
  final categoryOrderCode = "".obs;
  final categoryOrderState = "전체".obs;
  final categoryVehicCode = "".obs;
  final categoryVehicState = "전체".obs;
  List<CodeModel>? dropDownList = List.empty(growable: true);
  final select_value = CodeModel().obs;

  var scrollController = ScrollController();
  final page = 1.obs;
  final totalPage = 1.obs;
  final mPoint = 0.obs;
  final ivTop = false.obs;

  late TextEditingController searchOrderController;

  late AppDataBase db;

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    fbroad.FBroadcast.instance().register(Const.INTENT_ORDER_REFRESH, (value, callback) async {
      UserModel? user = await controller.getUserInfo();
      mUser.value = user;
      await getOrder();
    },context: this);
    handleDeepLink();
    Future.delayed(Duration.zero, () async {
      pr = Util.networkProgress(context);
      if(widget.allocId != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(allocId: widget.allocId)));
      }
      scrollController.addListener(() async {
        var now_scroll = scrollController.position.pixels;
        var max_scroll = scrollController.position.maxScrollExtent;
        if(now_scroll >= 300) {
          ivTop.value = true;
        } else {
          ivTop.value = false;
        }
        if((max_scroll - now_scroll) <= 300){
          if(page.value < totalPage.value){
            page.value++;
          }
        }
      });
      searchOrderController = TextEditingController();
      db = controller.getRepository();
      db.deleteAll();
      await initView();
      await getPointResult();
      dropDownList?.add(CodeModel(code: "carNum",codeName: "차량번호"));
      dropDownList?.add(CodeModel(code: "driverName",codeName: "차주명"));
      dropDownList?.add(CodeModel(code: "sellCustName",codeName: "거래처명"));
    });
  }

  void selectItem(CodeModel? codeModel,{codeType = "",value = 0}) {
    if(codeType != ""){
      switch(codeType) {
        case 'ORDER_STATE_CD':
          categoryOrderCode.value = codeModel?.code??"";
          categoryOrderState.value = codeModel?.codeName??"-";
          page.value = 1;
          scrollController.jumpTo(0);
          break;
        case 'ALLOC_STATE_CD':
         categoryVehicCode.value = codeModel?.code??"";
         categoryVehicState.value = codeModel?.codeName??"-";
         page.value = 1;
         scrollController.jumpTo(0);
          break;
      }
    }
  }

  Future<void> initView() async {
    UserModel? user = await controller.getUserInfo();
    mUser.value = user;
    List<OrderModel> list = await db.getOrderList(context);
    if(list != null && list.length != 0) {
      if(orderList.isNotEmpty) orderList.clear();
      orderList.addAll(list);
    }
  }

  Future<void> getOrder() async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getOrder(
        user.authorization,
        Util.getTextDate(mCalendarStartDate.value),
        Util.getTextDate(mCalendarEndDate.value),
        categoryOrderCode.value,
        categoryVehicCode.value,
        myOrderSelect.value == true? "Y":"N",
        page.value,
        select_value.value.code??"",
        searchValue.value
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrder() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            try {
              var list = _response.resultMap?["data"] as List;
              List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
              var db = App().getRepository();
              if(itemsList.length != 0){
                await db.insertAll(context,itemsList);

                List<OrderModel> list = await db.getOrderList(context);
                  if(list != null && list.length != 0) {
                    if(orderList.isNotEmpty) orderList.clear();
                    orderList.addAll(list);
                  }
              }
              int total = 0;
              if(_response.resultMap?["total"].runtimeType.toString() == "String") {
                total = int.parse(_response.resultMap?["total"]);
              }else{
                total = _response.resultMap?["total"];
              }
              totalPage.value = Util.getTotalPage(total);
            } catch (e) {
              print(e);
            }
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrder() getOrder Default => ");
          break;
      }
    });
  }

  void handleDeepLink() async {
    
    FirebaseDynamicLinks.instance.getInitialLink().then(
          (PendingDynamicLinkData? dynamicLinkData) {
        // Set up the `onLink` event listener next as it may be received here
        if (dynamicLinkData != null) {
          final Uri deepLink = dynamicLinkData.link;
          String? code = deepLink.pathSegments.last;
          String? allocId = deepLink.queryParameters["allocId"];
          if(allocId == null) return;
          switch(code) {
            case "tmsOrder":
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderDetailPage(allocId: allocId)));
              break;
          }
        }else{
          return;
        }
      });

  }

  @override
  void dispose() {
    super.dispose();
    searchOrderController.dispose();
  }

  void exited(){
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
      //SystemNavigator.pop();
    });
  }

  Future<void> goToExit() async {
    openCommonConfirmBox(
        context,
        "로그아웃 하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await SP.clear();
          await logout();
        }
    );
  }

  Future<void> logout() async {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
      //SystemNavigator.pop();
    });
  }

  Future<void> goToPoint() async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PointPage()));
  }

  Drawer getAppBarMenu() {
    return Drawer(
        backgroundColor: styleWhiteCol,
        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: const BoxDecoration(
                  color: main_color,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex:1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(()=>
                                Text(
                                  "${mUser.value.bizName}",
                                  style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                )),
                            CustomStyle.sizedBoxHeight(10.0.h),
                            Obx(()=>Text(
                              "${mUser.value.deptName}",
                              style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                            )
                            )
                          ]
                      )
                    ),
                    Expanded(
                        flex:1,
                        child: mPoint.value != 0 && mPoint.value != null ?
                            Obx(()=>
                              InkWell(
                                onTap: () async {
                                  await goToPoint();
                                },
                                child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      Positioned(
                                          child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/image/pointBox.png')
                                          )
                                        ),
                                      )
                                      ),
                                      Positioned(
                                        right: 15.w,
                                        child: Text(
                                          Util.getInCodeCommaWon(mPoint.value.toString()),
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                                        ),
                                      )
                                    ],
                                  )
                            )
                        ) : const SizedBox(),
                    )
                  ],
                )
            ),

            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "내정보",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarMyPage()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "실적현황",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AppBarMonitorPage()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "공지사항",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AppBarNoticePage()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "설정",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AppBarSettingPage()));
              },
            ),ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "도움말",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: () async {
                var url = Uri.parse(URL_MANUAL);
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                }
              },
            ),ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
              title: Text(
                "로그아웃",
                style: CustomStyle.CustomFont(styleFontSize14, order_state_09),
              ),
              onTap: () async {
                await goToExit();
              },
            )
          ],
        )
    );
  }

  Future<void> goToOrderDetail(OrderModel item) async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderDetailPage(order_vo: item)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results);
      }
    }
  }

  Widget getListCardView(OrderModel item) {
    return Container(
        padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w),top: CustomStyle.getHeight(10.0.h)),
        child: InkWell(
            onTap: () async {
              await goToOrderDetail(item);
            },
            child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                color: styleWhiteCol,
                child: Column(children: [
                  Container(
                      padding: EdgeInsets.all(10.0.h),
                      color: Colors.white,
                      child: Column(children: [
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 3,
                                child: Row(children: [
                                  item.orderState == "09" ? Container(
                                      decoration: CustomStyle.baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(
                                          vertical: CustomStyle.getHeight(5.0.h),
                                          horizontal: CustomStyle.getWidth(10.0.w)),
                                      child: Text(
                                        "${item.orderStateName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            Util.getOrderStateColor(
                                                item.orderStateName)),
                                      )) : const SizedBox(),
                                  Container(
                                      /*padding: EdgeInsets.only(
                                          left: CustomStyle.getWidth(
                                              5.0.w),
                                          right: CustomStyle.getWidth(
                                              5.0.w)),*/
                                      child: Text(
                                        "${item.sellCustName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            main_color),
                                      )),
                                  Text(
                                    "${item.sellDeptName}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, main_color),
                                  )
                                ])),
                            Flexible(
                                flex: 1,
                                child: Container(
                                  alignment:
                                  Alignment.centerRight,
                                  child: Text(
                                    "${Util.getInCodeCommaWon(item.sellCharge.toString())}원",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize14,
                                        text_color_01,
                                    font_weight: FontWeight.w700),
                                  ),
                                ))
                          ],
                        ),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 3,
                                child: Row(children: [
                                  item.orderState != "09" && item.driverState == null ? Container(
                                      decoration: CustomStyle
                                          .baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                          CustomStyle.getHeight(
                                              5.0.h),
                                          /*horizontal:
                                          CustomStyle.getWidth(
                                            10.0.w)*/),
                                      child: Text(
                                        "${item.allocStateName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize14,
                                            order_state_01),
                                      )) : const SizedBox(),
                                      item.linkName?.isEmpty == false && item.linkName != "" ?
                                  Container(
                                      padding: EdgeInsets.only(
                                          right: CustomStyle.getWidth(
                                              5.0.w)),
                                      child: Text(
                                        item.linkName??"",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            text_color_01),
                                      )): const SizedBox(),
                                  item.buyCustName?.isEmpty == false && item.buyCustName != "" ?
                                    Text(
                                      item.buyCustName??"",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_01),
                                    ) : const SizedBox(),
                                  item.buyDeptName?.isEmpty == false && item.buyDeptName != "" ?
                                    Text(
                                      item.buyDeptName??"",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize10, text_color_01),
                                    ) : const SizedBox()
                                ])),
                            Flexible(
                                flex: 1,
                                child: Container(
                                  alignment:
                                  Alignment.centerRight,
                                  child: Text(
                                    "${Util.getInCodeCommaWon(item.buyCharge.toString())}원",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize14,
                                        text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                ))
                          ],
                        ),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(3.0.h):const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.getDivider1():const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(3.0.h):const SizedBox(),
                        item.orderState != "09" && item.driverState != null? Container(
                            decoration: CustomStyle
                                .baseBoxDecoWhite(),
                          
                          child: Row(children: [
                                  Flexible(
                                      flex: 9,
                                      child: Row(children: [
                                        Container(
                                            padding: EdgeInsets.only(
                                                right: CustomStyle.getWidth(
                                                    10.0.w)),
                                            child: Text(
                                                item.driverStateName ?? "",
                                                style: CustomStyle.CustomFont(
                                                    styleFontSize14,
                                                    order_state_01,
                                                    font_weight:
                                                        FontWeight.w700))),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${item.driverName} 차주님",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize14,
                                                  text_color_01),
                                            ),
                                            Text(
                                              "${item.carNum}",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize12,
                                                  text_color_01),
                                            )
                                          ],
                                        )
                                      ])),
                            Flexible(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: (){
                                          Util.call(item.driverTel);
                                        },
                                          child: Container(
                                              padding: EdgeInsets.all(4.0.h),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xff3535b2),
                                              ),
                                              child: Icon(Icons.call_rounded,
                                                  size: 24.h,
                                                  color: Colors.white)
                                          )
                                      )
                                  )
                                ])
                        ):const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(5.0.h):const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.getDivider1(): const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(5.0.h): const SizedBox(),
                        Container(
                            padding: EdgeInsets.symmetric(vertical:CustomStyle.getWidth(8.w),horizontal: CustomStyle.getHeight(8.h)),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0),topRight: Radius.circular(5.0)),
                              color: sub_color
                            ),
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Util.ynToBoolean(item.payType)?
                          Container(
                              child: Text(
                                "빠른지급",
                                style: CustomStyle.CustomFont(styleFontSize12, order_state_09,font_weight: FontWeight.w700),
                              )):const SizedBox(),
                          Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 150.h,
                                 margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: light_gray1
                                  ),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Text(
                                  "${Util.splitSDate(item.sDate)} 상차",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, text_box_color_01,
                                      font_weight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                                    Flexible(
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign:TextAlign.center,
                                            text: TextSpan(
                                              text: item.sComName??"",
                                              style:  CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w600),
                                            )
                                        )
                                    ),
                                CustomStyle.sizedBoxHeight(15.0.h),
                                    Flexible(
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign:TextAlign.center,
                                            text: TextSpan(
                                              text: item.sAddr??"",
                                              style: CustomStyle.CustomFont(styleFontSize12, main_color),
                                            )
                                        )
                                    ),
                              ])),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(Icons.arrow_right_alt,size: 21.h,color: const Color(0xff6d7780)),
                            ),
                            Expanded(
                                flex: 4,
                                child: Container(
                                    height: 150.h,
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                    decoration: const BoxDecoration(
                                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                                        color: light_gray1
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                  Text(
                                    "${Util.splitSDate(item.eDate)} 하차",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize14, text_box_color_01,
                                        font_weight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                  Flexible(
                                     child: RichText(
                                         overflow: TextOverflow.ellipsis,
                                         maxLines: 2,
                                         textAlign: TextAlign.center,
                                         text: TextSpan(
                                           text:
                                           item.eComName ?? "",
                                           style: CustomStyle.CustomFont(
                                               styleFontSize16,
                                               main_color,
                                               font_weight: FontWeight.w600),
                                         )
                                     )
                                  ),
                                  CustomStyle.sizedBoxHeight(15.0.h),
                                  Flexible(
                                     child: RichText(
                                         overflow: TextOverflow.ellipsis,
                                         maxLines: 2,
                                         textAlign: TextAlign.center,
                                         text: TextSpan(
                                           text: item.eAddr??"",
                                           style:CustomStyle.CustomFont(styleFontSize12, main_color)
                                         )
                                     )
                                  ),
                                ])))
                          ],
                        )
                        ])),
                        Container(
                          color: sub_color,
                        padding: EdgeInsets.only(left:CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w),bottom: CustomStyle.getHeight(5.h)),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                          decoration: const BoxDecoration(
                            color: light_gray1,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5.0.w)),
                                  child: Icon(Icons.social_distance,size: 24.h,color: text_color_01)
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: CustomStyle.getWidth(5.0.w)),
                                  child: Text(
                                    "${Util.makeDistance(item.distance)} ${Util.makeTime(item.time??0)}",
                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                  )
                              )
                            ]),
                            item.stopCount!=0? Container(
                                padding: EdgeInsets.only(right: CustomStyle.getWidth(5.0.w)),
                                child: Text(
                                  "경유지 ${item.stopCount}곳",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                )
                            ):const SizedBox()
                          ],
                        )
                        )
                      ),
                        Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w), right: CustomStyle.getWidth(5.w), bottom: CustomStyle.getHeight(10.0.h)),
                            decoration: const BoxDecoration(
                              color: sub_color,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5.0),bottomRight:  Radius.circular(5.0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item.carTonName}  ${item.carTypeName} ",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                                ),
                                Row(children: [
                                  Text(
                                    item.truckTypeName == null?"":"${item.truckTypeName}  |  ",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_02),
                                  ),
                                  Text(
                                    "${item.mixYn == "Y" ? "혼적" : "독차"}  |  ",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_02),
                                  ),
                                  Text(
                                    item.returnYn == "Y" ? "왕복" : "편도",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_02),
                                  ),
                                ])
                              ],
                            ))
                      ])),
                ]
                )
            )
        )
    );
  }

  Future openCalendarDialog() {
    mCalendarNowDate = DateTime.now();
    DateTime? _tempSelectedDay = null;
    DateTime? _tempRangeStart = mCalendarStartDate.value;
    DateTime? _tempRangeEnd = mCalendarEndDate.value;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))
                    ),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(15.0)),
                        color: main_color,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "시작 날짜 : ${_tempRangeStart == null?"-":"${_tempRangeStart?.year}년 ${_tempRangeStart?.month}월 ${_tempRangeStart?.day}일"}",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, styleWhiteCol),
                              ),
                              CustomStyle.sizedBoxHeight(5.0),
                              Text(
                                "종료 날짜 : ${_tempRangeEnd == null?"-":"${_tempRangeEnd?.year}년 ${_tempRangeEnd?.month}월 ${_tempRangeEnd?.day}일"}",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, styleWhiteCol),
                              ),
                            ]
                        )
                    ),
                    content: SingleChildScrollView(
                        child: SizedBox(
                            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                            height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.6,
                            child: Column(
                                children: [
                                  TableCalendar(
                                    rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) :CustomStyle.getHeight(45.h) ,
                                    locale: 'ko_KR',
                                    firstDay: DateTime.utc(2010, 1, 1),
                                    lastDay: DateTime.utc(DateTime.now().year+10, DateTime.now().month, DateTime.now().day),
                                    headerStyle: HeaderStyle(
                                      // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                      formatButtonVisible: false,
                                      // 달력 타이틀을 센터로
                                      titleCentered: true,
                                      // 말 그대로 타이틀 텍스트 스타일링
                                      titleTextStyle: 
                                      CustomStyle.CustomFont(
                                          styleFontSize16, Colors.black,font_weight: FontWeight.w700
                                          ),
                                          rightChevronIcon: Icon(Icons.chevron_right,size: 26.h),
                                          leftChevronIcon: Icon(Icons.chevron_left, size: 26.h),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      tablePadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                                      outsideTextStyle: CustomStyle.CustomFont(styleFontSize12, line),
                                      // 오늘 날짜에 하이라이팅의 유무
                                      isTodayHighlighted: false,
                                      // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                      defaultDecoration: const BoxDecoration(
                                        color: order_item_background,
                                        shape: BoxShape.rectangle,
                                      ),
                                      // 캘린더의 주말 배경 스타일링
                                      weekendDecoration:  const BoxDecoration(
                                        color: order_item_background,
                                        shape: BoxShape.rectangle,
                                      ),
                                      // 선택한 날짜 배경 스타일링
                                      selectedDecoration: BoxDecoration(
                                          color: styleWhiteCol,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(color: main_color,width: 1.w)
                                    
                                      ),
                                      defaultTextStyle: CustomStyle.CustomFont(
                                          styleFontSize14, Colors.black),
                                      weekendTextStyle:
                                      CustomStyle.CustomFont(styleFontSize14, Colors.red),
                                      selectedTextStyle: CustomStyle.CustomFont(
                                          styleFontSize14, Colors.black),
                                      // range 크기 조절
                                      rangeHighlightScale: 1.0,

                                      // range 색상 조정
                                      rangeHighlightColor: const Color(0xFFBBDDFF),

                                      // rangeStartDay 글자 조정
                                      rangeStartTextStyle: CustomStyle.CustomFont(
                                          styleFontSize14, Colors.black),

                                      // rangeStartDay 모양 조정
                                      rangeStartDecoration: BoxDecoration(
                                          color: styleWhiteCol,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(color: main_color,width: 1.w)
                                      ),

                                      // rangeEndDay 글자 조정
                                      rangeEndTextStyle: CustomStyle.CustomFont(
                                          styleFontSize14, Colors.black),

                                      // rangeEndDay 모양 조정
                                      rangeEndDecoration: BoxDecoration(
                                          color: styleWhiteCol,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(color: main_color,width: 1.w)
                                      ),

                                      // startDay, endDay 사이의 글자 조정
                                      withinRangeTextStyle: CustomStyle.CustomFont(
                                          styleFontSize14, Colors.black),

                                      // startDay, endDay 사이의 모양 조정
                                      withinRangeDecoration:
                                      const BoxDecoration(),
                                    ),
                                    //locale: 'ko_KR',
                                    focusedDay: mCalendarNowDate,
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_tempSelectedDay, day);
                                    },
                                    rangeStartDay: _tempRangeStart,
                                    rangeEndDay: _tempRangeEnd,
                                    calendarFormat: _calendarFormat,
                                    rangeSelectionMode: _rangeSelectionMode,
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (!isSameDay(_tempSelectedDay, selectedDay)) {
                                        setState(() {
                                          _tempSelectedDay = selectedDay;
                                          mCalendarNowDate = focusedDay;
                                          _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                        });
                                      }
                                    },
                                    onRangeSelected: (start, end, focusedDay) {
                                      //print("onRangeSelected => ${start} // $end // ${focusedDay}");
                                      setState(() {
                                        _tempSelectedDay = start;
                                        mCalendarNowDate = focusedDay;
                                        _tempRangeStart = start;
                                        _tempRangeEnd = end;
                                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                                      });
                                    },

                                    onFormatChanged: (format) {
                                      if (_calendarFormat != format) {
                                        setState(() {
                                          _calendarFormat = format;
                                        });
                                      }
                                    },
                                    onPageChanged: (focusedDay) {
                                      mCalendarNowDate = focusedDay;
                                    },
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              Strings.of(context)?.get("cancel")??"Not Found",
                                              style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
                                            )
                                        ),
                                        CustomStyle.sizedBoxWidth(CustomStyle.getWidth(15.0)),
                                        TextButton(
                                            onPressed: () async {
                                              int? diff_day = _tempRangeEnd?.difference(_tempRangeStart!).inDays;
                                              if(_tempRangeStart == null || _tempRangeEnd == null){
                                                if(_tempRangeStart == null && _tempRangeEnd != null) {
                                                  _tempRangeStart = _tempRangeEnd?.add(const Duration(days: -30));
                                                }else if(_tempRangeStart != null &&_tempRangeEnd == null) {
                                                  DateTime? _tempDate = _tempRangeStart?.add(const Duration(days: 30));
                                                  int start_diff_day = _tempDate!.difference(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)).inDays;
                                                  if(start_diff_day > 0) {
                                                    _tempRangeEnd = _tempRangeStart;
                                                    _tempRangeStart = _tempRangeEnd?.add(const Duration(days: -30));
                                                  }else{
                                                    _tempRangeEnd = _tempRangeStart?.add(const Duration(days: 30));
                                                  }
                                                }else{
                                                  return Util.toast("시작 날짜 또는 종료 날짜를 선택해주세요.");
                                                }
                                              }
                                              mCalendarStartDate.value = _tempRangeStart!;
                                              mCalendarEndDate.value = _tempRangeEnd!;
                                              page.value = 1;
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(
                                              Strings.of(context)?.get("confirm")??"Not Found",
                                              style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
                                            )
                                        )
                                      ],
                                    ),
                                  )
                                ]
                            )
                        )
                    )
                );
              });
        });
  }

  Widget calendarPanelWidget() {
    isExpanded.value = List.filled(1, true);
    return SingleChildScrollView(
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ExpansionPanelList.radio(
              animationDuration: const Duration(milliseconds: 500),
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 0,
              initialOpenPanelValue: 0,
              children: [
                ExpansionPanelRadio(
                  value: index,
                  backgroundColor: text_color_03,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                        //margin: EdgeInsets.only(left: CustomStyle.getWidth(40.h)),
                        height: CustomStyle.getHeight(25.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded,size: 20.h,color: styleWhiteCol,),
                            CustomStyle.sizedBoxWidth(5.0),
                            Text("날짜 설정",style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol))
                          ],
                        ));
                  },
                  body: Obx((){
                    return InkWell(
                        onTap: () {
                          openCalendarDialog();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: line,
                                        width: CustomStyle.getWidth(1.0)
                                    )
                                ),
                                color: const Color(0xfffafafa)
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(15.0)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      mCalendarStartDate.value == null?"-":"${mCalendarStartDate.value?.year}년 ${mCalendarStartDate.value?.month}월 ${mCalendarStartDate.value?.day}일",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize10, text_color_01)
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "~",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize10, text_color_01)
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      mCalendarEndDate.value == null?"-":"${mCalendarEndDate.value?.year}년 ${mCalendarEndDate.value?.month}월 ${mCalendarEndDate.value?.day}일",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize10, text_color_01)
                                    )
                                )
                              ],
                            )
                        )
                    );
                  }),
                  canTapOnHeader: true,
                )
              ],
              expansionCallback: (int _index, bool status) {
                isExpanded[index] = !isExpanded[index];
                //for (int i = 0; i < isExpanded.length; i++)
                //  if (i != index) isExpanded[i] = false;
              },
            );
          }),
        )
    );
  }

  Widget orderCategoryWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w), vertical: CustomStyle.getHeight(5.h)),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            InkWell(
              onTap: () {
                ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("order_state")??"", codeType: Const.ORDER_STATE_CD, value: 0, callback: selectItem).showDialog();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: CustomStyle.getHeight(5.h),
                      horizontal: CustomStyle.getWidth(10.w)),
                  decoration: CustomStyle.customBoxDeco(sub_color,
                      radius: 5.w, border_color: Colors.white),
                  child: Text(
                    categoryOrderState.value,
                    style:
                        CustomStyle.CustomFont(styleFontSize12, text_color_01),
                  )),
            ),
            CustomStyle.sizedBoxWidth(5.0),
            InkWell(
              onTap: () {
                ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("alloc_state")??"", codeType: Const.ALLOC_STATE_CD, value: 0, callback: selectItem).showDialog();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: CustomStyle.getHeight(5.h),
                      horizontal: CustomStyle.getWidth(10.w)),
                  decoration: CustomStyle.customBoxDeco(sub_color,
                      radius: 5.0, border_color: Colors.white),
                  child: Text(
                    categoryVehicState.value,
                    style:
                        CustomStyle.CustomFont(styleFontSize12, text_color_01),
                  )),
            )
          ]),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){
                  page.value = 1;
                  myOrderSelect.value = !myOrderSelect.value;
                  scrollController.jumpTo(0);
                },
              child: Container(
                decoration: CustomStyle.customBoxDeco(Colors.white,radius: 5.0, border_color: myOrderSelect.value?text_box_color_01:text_box_color_02),
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                child: Text(
                  "내오더",
                  style: CustomStyle.CustomFont(styleFontSize12, myOrderSelect.value?text_box_color_01:text_box_color_02),
                ),
              )
              ),
              IconButton(
                  onPressed: () async {
                    await showSearchDialog();
                  },
                  icon: Icon(Icons.search,size: 28.h,color: text_box_color_02)
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> search(CodeModel search_value) async {
    var mSearchValue = searchOrderController.text.trim();
    if(mSearchValue.length != 1) {
        select_value.value = search_value;
        searchValue.value = mSearchValue;
        await refresh();
    }else{
      Util.toast("검색어를 2글자 이상 입력해주세요.");
    }
  }

  Future<void> refresh() async {
    await db.deleteAll();
    page.value = 1;
    await getOrder();
  }

  Future<void> showSearchDialog() async {
    var temp_search_column = dropDownList![0];
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                insetPadding: EdgeInsets.all(CustomStyle.getHeight(10.0)),
                contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                content: SingleChildScrollView(
                  child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                    Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                    color: main_color,
                    child: Stack(
                    alignment: Alignment.center,
                    children: [
                    Container(
                    alignment: Alignment.center,
                    child: Text(
                    "오더 검색",
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                                textAlign: TextAlign.center,
                              )),
                              Positioned(
                                right: 5.w,
                                child: IconButton(
                                    onPressed: (){
                                      Navigator.of(context).pop(false);
                                    },
                                    icon: Icon(Icons.close,size: 24.h,color: Colors.white)
                                ),
                              )
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(30.h),horizontal: CustomStyle.getWidth(15.w)),
                        child: Row(
                           children: [
                             Expanded(
                               flex: 2,
                             child: DropdownButton(
                                 value: temp_search_column,
                                 items: dropDownList?.map((value) {
                                   return DropdownMenuItem(
                                     value: value,
                                     child: Text(
                                      "${value.codeName}",
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01)
                                      ),
                                   );
                                 }).toList(),
                                 onChanged: (value) {
                                   setState(() {
                                     temp_search_column = value!;
                                   });
                                 }
                             )),
                             Expanded(
                               flex: 5,
                             child: Container(
                               padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
                                 //height: CustomStyle.getHeight(40.h),
                                 child: TextField(
                                   style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                   textAlign: TextAlign.start,
                                   keyboardType: TextInputType.text,
                                   controller: searchOrderController,
                                   maxLines: null,
                                   decoration: searchOrderController.text.isNotEmpty
                                       ? InputDecoration(
                                     counterText: '',
                                     contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                                     enabledBorder: OutlineInputBorder(
                                         borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                         borderRadius: BorderRadius.circular(5.h)
                                     ),
                                     disabledBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                     ),
                                     focusedBorder: OutlineInputBorder(
                                         borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                         borderRadius: BorderRadius.circular(5.h)
                                     ),
                                     suffixIcon: IconButton(
                                       onPressed: () {
                                         searchOrderController.clear();
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
                                     contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                                     enabledBorder: OutlineInputBorder(
                                         borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                         borderRadius: BorderRadius.circular(5.h)
                                     ),
                                     disabledBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                                     ),
                                     focusedBorder: OutlineInputBorder(
                                         borderSide: BorderSide(color: text_box_color_02, width: CustomStyle.getWidth(1.0.w)),
                                         borderRadius: BorderRadius.circular(5.h)
                                     ),
                                   ),
                                   onChanged: (value){

                                   },
                                   maxLength: 50,
                                 )
                             ))
                           ],
                        )
                      ),
                      InkWell(
                        onTap: () async {
                          await search(temp_search_column);
                          Navigator.of(context).pop(false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
                          decoration: BoxDecoration(
                            color: sub_btn,
                            border: CustomStyle.borderAllBase(),
                          ),
                          child: Text(
                            Strings.of(context)?.get("confirm") ?? "Not Found",
                            style: CustomStyle.whiteFont15B(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                )),
          );
        });
  }

  Widget orderItemFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.getOrder(
            context,
            Util.getTextDate(mCalendarStartDate.value),
            Util.getTextDate(mCalendarEndDate.value),
            categoryOrderCode.value,
            categoryVehicCode.value,
            myOrderSelect.value == true? "Y":"N",
            page.value,
            select_value.value.code??"",
            searchValue.value
        ),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Expanded(
                child: Container(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator())
            ));
          }else {
            if (snapshot.hasData) {
              if (orderList.isNotEmpty) orderList.clear();
              orderList.addAll(snapshot.data["list"]);
              totalPage.value = snapshot.data?["total"];
              return Obx(()=> orderListWidget());
            } else if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
                alignment: Alignment.center,
                child: Text(
                    "${Strings.of(context)?.get("empty_list")}",
                    style: CustomStyle.baseFont()),
              );
            }
          }
          return Container(
              width: CustomStyle.getWidth(30.0),
              height: CustomStyle.getHeight(30.0),
              child: Center(child: CircularProgressIndicator())
          );
        }
    );
  }

  Widget orderListWidget() {
    return orderList.isNotEmpty
        ? Expanded(
      child: Stack(
        children: [
          Positioned(
        child: RefreshIndicator(
      onRefresh: () async {
        await refresh();
      },
      child: ListView.builder(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      shrinkWrap: true,
      itemCount: orderList.length,
      itemBuilder: (context, index) {
        var item = orderList[index];
        return getListCardView(item);
      },
    ))),
          Obx((){
          return ivTop.value == true ?
          Positioned(
              right: 10.w,
              bottom: 10.h,
              child: InkWell(
                  onTap: () async {
                    scrollController.jumpTo(0);
                  },
                  child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                        color: Color(0x9965656D),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        size: 21.h,
                        color: Colors.white,
                      )
                  )
              )
          ) : const SizedBox();
          })
    ]))
        : Expanded(
        child: Container(
            alignment: Alignment.center,
            child: Text(
              Strings.of(context)?.get("empty_list") ?? "Not Found",
              style: CustomStyle.baseFont(),
            )));
  }

  Future goToRegOrder() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegistOrderPage()));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results);
      }
    }
  }

  Future<void> setRegResult(Map<String,dynamic> results) async {
    await refresh();
    Util.toast("${Strings.of(context)?.get("order_reg_title")}${Strings.of(context)?.get("reg_success")}");
    if(results["allocId"] != null){
      String allocId = results["allocId"].toString();
      await showOrderTrans(allocId);
    }
  }

  Future<void> showOrderTrans(String allocId) async {
    openCommonConfirmBox(
        context,
        "오더가 등록되었습니다.\n바로 이어서 배차를 진행하시겠습니까??",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await getOrderDetail(allocId);
        }
    );
  }

  Future<void> getOrderDetail(String allocId) async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getOrderDetail(
        user.authorization,allocId
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderDetail() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
              OrderModel data = itemsList[0];
              await goToTransInfo(data);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderDetail() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderDetail() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> goToTransInfo(OrderModel data) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderTransInfoPage(order_vo: data)));
  }

  Future<void> getPointResult() async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await DioService.dioClient(header: true).getTmsPointResult(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getPointResult() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["point"] != null) {
            mPoint.value = _response.resultMap?["point"];
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getPointResult() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getPointResult() getOrder Default => ");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: order_item_background,
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        backgroundColor: main_color,
        title: Text(
            "로지스링크 주선사/운송사용",
            style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
        ),
        toolbarHeight: 50.h,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationPage()));
              },
              icon: Icon(
                Icons.notifications,
                size: 24.h,
                color: Colors.white,
              )),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset("assets/image/menu.png",
                width: CustomStyle.getWidth(20.0.w),
                height: CustomStyle.getHeight(20.0.h)),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ),
      drawer: getAppBarMenu(),
      body: SafeArea(
          child: Obx(() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children :[
              calendarPanelWidget(),
              orderCategoryWidget(),
              orderItemFuture()
        ]);
      })),
      bottomNavigationBar: SizedBox(
          height: CustomStyle.getHeight(60.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () async {
                        await goToRegOrder();
                      },
                      child: Container(
                          height: CustomStyle.getHeight(60),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: main_color),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.app_registration_rounded,
                                    size: 21.h, color: styleWhiteCol),
                                CustomStyle.sizedBoxWidth(5.0.w),
                                Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_reg_title") ??
                                      "Not Found",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, styleWhiteCol),
                                ),
                              ])))),
            ],
          )),
    );
  }
}