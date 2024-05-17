import 'dart:async';
import 'dart:io';
import 'package:fbroadcast/fbroadcast.dart' as fbroad;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_main_widget.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/model/user_rpa_model.dart';
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
import 'package:logislink_tms_flutter/page/subpage/reg_order/regist_smart_order_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_select_dialog_widget.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/model/order_link_current_model.dart';

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
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  final orderList = List.empty(growable: true).obs;
  final userRpaModel = UserRpaModel().obs;
  final myOrder = "N".obs;
  final orderState = "".obs;
  final allocState = "".obs;
  final searchValue = "".obs;
  late String startDate, endDate, nowDate;

  DateTime mCalendarNowDate = DateTime.now();
  final mCalendarStartDate = DateTime.now().obs;
  final mCalendarEndDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1).obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  final myOrderSelect = false.obs;
  final categoryOrderCode = "".obs;
  final categoryOrderState = "전체".obs;
  final categoryVehicCode = "".obs;
  final categoryVehicState = "전체".obs;
  List<CodeModel>? dropDownList = List.empty(growable: true);
  final select_value = CodeModel().obs;

  AutoScrollController  scrollController = AutoScrollController();
  final page = 1.obs;
  final api24Data = Map<String, dynamic>().obs;
  final prev_page = 1.obs;
  final totalPage = 1.obs;
  final mPoint = 0.obs;
  final ivTop = false.obs;
  final ivBottom = true.obs;
  final maxScroller = 0.obs;
  final lastPositionItem = 0.obs;

  late TextEditingController searchOrderController;

  late AppDataBase db;

  ProgressDialog? pr;

  //Sample
  final smartOrderCode = "".obs;

  @override
  void initState() {
    fbroad.FBroadcast.instance().register(Const.INTENT_ORDER_REFRESH, (value, callback) async {
      UserModel? user = await controller.getUserInfo();
      mUser.value = user;
    },context: this);
    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;
    handleDeepLink();
    Future.delayed(Duration.zero, () async {
      pr = Util.networkProgress(context);
      if(widget.allocId != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(allocId: widget.allocId)));
      }
      scrollController.addListener(() {
        var now_scroll = scrollController.position.pixels;
        var max_scroll = scrollController.position.maxScrollExtent;
        if(now_scroll >= 300) {
          ivTop.value = true;
        } else {
          ivTop.value = false;
        }
        if(now_scroll < (max_scroll-800)) {
          ivBottom.value = true;
        }else{
          ivBottom.value = false;
        }
        if((max_scroll - now_scroll) <= 50){
          if(page.value < totalPage.value){
            lastPositionItem.value = orderList.value.length;
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Util.notificationDialog(context,"기본",webViewKey);
    });

    super.initState();
  }

  void selectItem(CodeModel? codeModel,{codeType = "",value = 0}) {
    if(codeType != ""){
      switch(codeType) {
        case 'ORDER_STATE_CD':
          categoryOrderCode.value = codeModel?.code??"";
          categoryOrderState.value = codeModel?.codeName??"-";
          page.value = 1;
          scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
        case 'ALLOC_STATE_CD':
          categoryVehicCode.value = codeModel?.code??"";
          categoryVehicState.value = codeModel?.codeName??"-";
          page.value = 1;
          scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
      }
      refresh();
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

  Future<void> goToOrderDetail(OrderModel item,int index) async {
    var user = await controller.getUserInfo();
    await FirebaseAnalytics.instance.logEvent(
      name: Platform.isAndroid ? "inquire_order_aos" : "inquire_order_ios",
      parameters: {
        "user_id": user.userId,
        "user_custId" : user.custId,
        "user_deptId": user.deptId,
        "orderId" : item.orderId,
      },
    );

    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderDetailPage(order_vo: item)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results,item_index: index);
      }
    }
    setState(() {
      lastPositionItem.value = index;
    });
  }

  Widget getListCardView(OrderModel item,int item_index) {

    return Container(
        padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w),top: CustomStyle.getHeight(10.0.h)),
        child: InkWell(
            onTap: () async {
              await goToOrderDetail(item,item_index);
            },
            child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
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
                                  item.orderState == "09" ?
                                  Container(
                                      decoration: CustomStyle.baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(
                                          vertical: CustomStyle.getHeight(5.0.h),
                                          horizontal: CustomStyle.getWidth(10.0.w)),
                                      child: Text(
                                        item.orderStateName??"",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            Util.getOrderStateColor(item.orderStateName)),
                                      )) : const SizedBox(),
                                  Container(
                                      child: Text(
                                        item.sellCustName??"",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            main_color),
                                      )),
                                  Text(
                                    item.sellDeptName??"",
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
                                  item.orderState != "09" && item.driverState == null ?
                                  Container(
                                      decoration: CustomStyle.baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                        CustomStyle.getHeight(5.0.h),),
                                      child: Text(
                                        "${item.allocStateName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize14,
                                            order_state_01),
                                      )) : const SizedBox(),
                                  item.linkName?.isEmpty == false && item.linkName != "" ?
                                  (item.call24Cargo == null || item.call24Cargo?.isEmpty == true)
                                      && (item.manCargo == null || item.manCargo?.isEmpty == true)
                                      && (item.oneCargo == null || item.oneCargo?.isEmpty == true) ?
                                  Container(
                                      padding: EdgeInsets.only(
                                          right: CustomStyle.getWidth(5.0.w)),
                                      child: Text(
                                        "지불운임",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            text_color_01),
                                      )) :
                                  Container(
                                      padding: EdgeInsets.only(
                                          right: CustomStyle.getWidth(5.0.w)),
                                      child: Text(
                                        item.linkName??"",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            text_color_01),
                                      ))
                                      : const SizedBox(),
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
                                child: (item.call24Cargo != "" && item.call24Cargo != null) ||
                                    (item.manCargo != "" && item.manCargo != null ) ||
                                    (item.oneCargo != "" && item.oneCargo != null)
                                    ? const SizedBox()
                                    : Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${Util.getInCodeCommaWon(item.buyCharge.toString())}원",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize14,
                                        text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                )
                            )
                          ],
                        ),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(3.0.h):const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.getDivider1():const SizedBox(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(3.0.h):const SizedBox(),
                        item.orderState != "09" && item.driverState != null?
                        Container(
                            decoration: CustomStyle.baseBoxDecoWhite(),
                            child: Row(
                                children: [
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
                        //RPA
                        item.orderState != "09" ? rpaFunctionFuture(item,item_index) : const SizedBox(),
                        item.call24Cargo == "R" || item.manCargo == "R" || item.oneCargo == "R" ? CustomStyle.getDivider1(): const SizedBox(),
                        Container(
                            padding: EdgeInsets.symmetric(vertical:CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(8.w)),
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
                                            height: 130.h,
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
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_box_color_01,
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
                                                            style:  CustomStyle.CustomFont(styleFontSize14, main_color, font_weight: FontWeight.w600),
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
                                                            style: CustomStyle.CustomFont(styleFontSize11, main_color),
                                                          )
                                                      )
                                                  ),
                                                ])),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    child: Text(
                                                      "${Util.makeDistance(item.distance)}",
                                                      style: CustomStyle.CustomFont(styleFontSize11, text_color_01),
                                                    )
                                                ),
                                                Icon(Icons.arrow_right_alt,size: 21.h,color: const Color(0xff6d7780)),
                                                Container(

                                                    child: Text(
                                                      "${Util.makeTime(item.time??0)}",
                                                      style: CustomStyle.CustomFont(styleFontSize11, text_color_01),
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                              height: 130.h,
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
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_box_color_01, font_weight: FontWeight.w400),
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
                                                              style: CustomStyle.CustomFont(styleFontSize14, main_color, font_weight: FontWeight.w600),
                                                            )
                                                        )
                                                    ),
                                                    CustomStyle.sizedBoxHeight(15.h),
                                                    Flexible(
                                                        child: RichText(
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                            textAlign: TextAlign.center,
                                                            text: TextSpan(
                                                                text: item.eAddr??"",
                                                                style:CustomStyle.CustomFont(styleFontSize11, main_color)
                                                            )
                                                        )
                                                    ),
                                                  ]
                                              )
                                          )
                                      )
                                    ],
                                  )
                                ]
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
                                  style: CustomStyle.CustomFont(styleFontSize10, text_color_02),
                                ),
                                Row(children: [
                                  Text(
                                    item.truckTypeName == null?"":"${item.truckTypeName}  |  ",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, text_color_02),
                                  ),
                                  Text(
                                    "${item.mixYn == "Y" ? "혼적" : "독차"}  |  ",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, text_color_02),
                                  ),
                                  Text(
                                    item.returnYn == "Y" ? "왕복" : "편도",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, text_color_02),
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
                                              Navigator.of(context).pop(false);
                                              await refresh();
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
                  onTap: () async {
                    myOrderSelect.value = !myOrderSelect.value;
                    await refresh();
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
    Navigator.of(context).pop();
    if(mSearchValue.length != 1) {
      select_value.value = search_value;
      searchValue.value = mSearchValue;
      setState(() async {
        await refresh();
      });
    }else{
      searchOrderController.text = "";
      Util.toast("검색어를 2글자 이상 입력해주세요.");
    }
  }

  Future<void> refresh() async {
    setState(() {
      page.value = 1;
      lastPositionItem.value = 0;
    });
  }

  Future<void> showSearchDialog() async {
    final temp_search_column = select_value.value.code == null || select_value.value.code?.isEmpty == true ? dropDownList![0].obs : select_value.value.obs;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
           child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15),vertical:  CustomStyle.getWidth(10)),
              padding: EdgeInsets.only(left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              "assets/image/ic_order_search.png",
                              width: CustomStyle.getWidth(25),
                              height: CustomStyle.getHeight(25)
                          ),
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              child: Text(
                                "오더를 검색해 주세요.",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, Colors.black,
                                    font_weight: FontWeight.w600),
                              )
                          )
                        ]
                    ),
                    Row(
                      children: dropDownList!.map((value) {
                        return InkWell(
                          onTap: (){
                            temp_search_column.value = value;
                          },
                          child: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(8), vertical: CustomStyle.getHeight(5)),
                          margin: EdgeInsets.only(top: CustomStyle.getHeight(15),left: CustomStyle.getWidth(5), right: CustomStyle.getWidth(5)),
                          decoration: BoxDecoration(
                            color: temp_search_column.value.code == value.code ? rpa_btn_regist : sub_color,
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),
                            child: Text(
                            "${value.codeName}",
                            style: CustomStyle.CustomFont(styleFontSize14, temp_search_column.value.code == value.code ? Colors.white : text_color_01,font_weight: FontWeight.w500)
                          )
                        )
                        );
                      }).toList()
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
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
                            hintText: "검색어를 입력해주세요.",
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
                    ),

                    Container(
                        width: double.infinity,
                        height: CustomStyle.getHeight(45),
                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: rpa_btn_regist,
                        ),
                        child: TextButton(
                            onPressed: () async {
                              await search(temp_search_column.value);
                            },
                            child: Text(
                              "검색",
                              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                            )
                        )
                    )
                  ]
              )),
            ));
      },
    );

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
                child: Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Colors.white,
                      size: 45,
                    ),
                )
            );
          }else {
            if (snapshot.hasData) {
              if (orderList.isNotEmpty) orderList.clear();
              orderList.addAll(snapshot.data["list"]);
              api24Data.value = snapshot.data?["api24Data"];
              totalPage.value = snapshot.data?["total"];

              if(lastPositionItem.value > 0) {
                scrollController.scrollToIndex(
                  lastPositionItem.value,
                  duration: const Duration(milliseconds: 1000),
                  preferPosition: AutoScrollPosition.begin,
                );
              }

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
                        return Future(() {
                          refresh();
                        });
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          var item = orderList[index];
                          return AutoScrollTag (
                              key: ValueKey(index),
                              controller: scrollController,
                              index: index,
                              child: getListCardView(item,index)
                          );
                        },
                      )
                  )
              ),
              Obx((){
                return ivTop.value == true ?
                Positioned(
                    right: 10.w,
                    bottom: ivBottom.value == false ? 60.h : 110.h,
                    child: InkWell(
                        onTap: () async {
                          scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
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
              }),

              Positioned(
                  right: 10.w,
                  bottom: ivBottom.value == false ? 10.h : 60.h,
                  child: InkWell(
                      onTap: () async {
                        Future(() {
                          setState(() {
                            var item_index = scrollController.position.pixels / (scrollController.position.maxScrollExtent / orderList.length);
                            lastPositionItem.value = item_index.toInt();
                          });
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: const BoxDecoration(
                            color: Color(0x9965656D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.refresh,
                            size: 21.h,
                            color: Colors.white,
                          )
                      )
                  )
              ),

              Obx((){
                return ivBottom.value == true ?
                Positioned(
                    right: 10.w,
                    bottom: 10.h,
                    child: InkWell(
                        onTap: () async {
                          scrollController.scrollToIndex(
                            orderList.value.length-2,
                            duration: const Duration(milliseconds: 1000),
                            preferPosition: AutoScrollPosition.begin,
                          );
                        },
                        child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: const BoxDecoration(
                              color: Color(0x9965656D),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_downward,
                              size: 21.h,
                              color: Colors.white,
                            )
                        )
                    )
                ) : const SizedBox();
              }),
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
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegistOrderPage(flag: "R")));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results);
      }
    }
  }

  Future goToSmartRegOrder() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegistSmartOrderPage()));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results);
      }
    }
  }

  Future goToRegOrderSample() async {
    smartOrderCode.value = "";
    Dialogs.materialDialog(
      context: context,
      color: Colors.white,
      customView: RegOrderCustomView(),
      customViewPosition: CustomViewPosition.BEFORE_ACTION,
      actions: [
        Obx((){
          return IconsButton(
            onPressed: () async {
              if(smartOrderCode.value == "") {
                return Util.toast("등록할 오더 방법을 선택해주세요.");
              }
              if(smartOrderCode.value == "01") {
                Navigator.of(context).pop();
                await goToSmartRegOrder();
              }else if(smartOrderCode.value == "02") {
                Navigator.of(context).pop();
                await goToRegOrder();
              }
            },
            text: '다음',
            color: smartOrderCode.value != "" ? renew_main_color : const Color(0xffA5A5A5),
            textStyle: CustomStyle.CustomFont(styleFontSize16, Colors.white),
            iconColor: Colors.white,
          );
        }),
      ],
    );
  }

  Widget RegOrderCustomView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: CustomStyle.getHeight(5.h)),
          child: Text(
            "어떤 방법으로\n오더를 등록하시겠어요?",
            style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w600),
          ),
        ),
        Obx((){
          return Container(
              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(3.h)),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: (){
                            smartOrderCode.value = "01";
                          },
                          child: Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              color: smartOrderCode.value == "01" ? renew_main_color : Colors.white,
                              margin: const EdgeInsets.only(bottom: 20,top: 20,left: 10,right: 10),
                              surfaceTintColor: text_box_color_02,
                              child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(50)),
                                          color: smartOrderCode.value == "01" ? Colors.white : renew_main_color,
                                        ),
                                        child: Image.asset(
                                          "assets/image/ic_smart_order_on.png",
                                          width: 10.w,
                                          height: 10.h,
                                          color: smartOrderCode.value == "01" ? renew_main_color : Colors.white,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.only(top: 15),
                                          child: Text(
                                            "신속한 오더 등록이\n가능해요",
                                            style: CustomStyle.CustomFont(styleFontSize12, smartOrderCode.value == "01" ? Colors.white : const Color(0xffA5A5A5)),
                                            textAlign: TextAlign.center,
                                          )
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "스마트오더",
                                          style: CustomStyle.CustomFont(styleFontSize16, smartOrderCode.value == "01" ? Colors.white : Colors.black ,font_weight: FontWeight.w800),
                                        ),
                                      )
                                    ],
                                  )
                              )
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: (){
                            smartOrderCode.value = "02";
                          },
                          child: Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              color: smartOrderCode.value == "02" ? renew_main_color : Colors.white,
                              margin: const EdgeInsets.only(bottom: 20,top: 20,left: 10,right: 10),
                              surfaceTintColor: text_box_color_02,
                              child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                                            color: smartOrderCode.value == "02" ? Colors.white : renew_main_color
                                        ),
                                        child: Image.asset(
                                          "assets/image/ic_nomal_order_off.png",
                                          width: 10.w,
                                          height: 10.h,
                                          color: smartOrderCode.value == "02" ? renew_main_color : Colors.white,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.only(top: 15),
                                          child: Text(
                                            "정확한 오더 등록이\n가능해요",
                                            style: CustomStyle.CustomFont(styleFontSize12,  smartOrderCode.value == "02" ? Colors.white : const Color(0xffA5A5A5)),
                                            textAlign: TextAlign.center,
                                          )
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "일반오더",
                                          style: CustomStyle.CustomFont(styleFontSize16, smartOrderCode.value == "02" ? Colors.white : Colors.black ,font_weight: FontWeight.w800),
                                        ),
                                      )
                                    ],
                                  )
                              )
                          )
                      )
                  )
                ],
              )
          );
        })
      ],
    );
  }

  Future<void> setRegResult(Map<String,dynamic> results, {int? item_index}) async {
    if(mounted) {
        Util.toast("오더 등록이 완료되었습니다.");
        if (results["allocId"] != null) {
          String allocId = results["allocId"].toString();
          showOrderTrans(allocId);
        }
        await refresh();
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
      logger.d("getOrderDetail() _response -> ${_response.status} | ${_response.resultMap}");
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

  Widget rpaFunctionFuture(OrderModel item,int item_index) {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.currentLink(
            context,
            item.orderId
        ),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return const SizedBox();
          }else {
            if (snapshot.hasData) {
              return rpaFunctionWidget(item, snapshot,item_index);
            } else if (snapshot.hasError) {
              return const SizedBox();
            }
          }
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Widget rpaFunctionWidget(OrderModel item, AsyncSnapshot snapshot,item_index) {
    final call24State = false.obs;
    final manState = false.obs;
    final oneCallState = false.obs;

    final call24LinkModel = OrderLinkCurrentModel().obs;
    final hwaMullLinkModel = OrderLinkCurrentModel().obs;
    final oneCallLinkModel = OrderLinkCurrentModel().obs;

    for(var linkData in snapshot.data["list"]) {
      if(linkData.linkCd  == Const.CALL_24_KEY_NAME){
        call24LinkModel.value = linkData;
      }else if(linkData.linkCd == Const.HWA_MULL_KEY_NAME) {
        hwaMullLinkModel.value = linkData;
      }else if(linkData.linkCd == Const.ONE_CALL_KEY_NAME) {
        oneCallLinkModel.value = linkData;
      }
    }

    final userRpaData = UserRpaModel().obs;
    userRpaData.value = snapshot.data["rpa"];

    return InkWell(
        onTap: () {

        },
        child: (item.call24Cargo != "" && item.call24Cargo != null) ||
            (item.manCargo != "" && item.manCargo != null ) ||
            (item.oneCargo != "" && item.oneCargo != null) ?
        SizedBox(
            child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 24시콜
                      api24Data.value["apiKey24"] != null && api24Data.value["apiKey24"] != '' ?
                      SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(85),
                              child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          manState.value = false;
                                          oneCallState.value = false;
                                          call24State.value = !call24State.value;
                                        },
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Obx(() =>
                                                  Container(
                                                    width: CustomStyle.getWidth(80),
                                                    height: CustomStyle.getHeight(65),
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: CustomStyle.getHeight(3.h)),
                                                    decoration: BoxDecoration(
                                                        color: statMsg(call24LinkModel.value.linkStat, call24LinkModel.value.jobStat) == ""
                                                            ? card_background
                                                            : call24LinkModel.value.linkStat == "D" && call24LinkModel.value.jobStat == "F"
                                                            ? styleGreyCol1
                                                            : card_background,
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "24시콜",
                                                          style: CustomStyle.CustomFont(styleFontSize13, main_color, font_weight: FontWeight.w500),
                                                        ),
                                                        Text(
                                                          "${Util.getInCodeCommaWon(item.call24Charge)}원",
                                                          style: statMsg(call24LinkModel.value.linkStat, call24LinkModel.value.jobStat) == ""
                                                              ?  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                              : call24LinkModel.value.linkStat == "D" && call24LinkModel.value.jobStat == "F"
                                                              ?   TextStyle(decoration: TextDecoration.lineThrough, fontSize: styleFontSize13)
                                                              :  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800),
                                                        ),
                                                        Text(
                                                          "${statMsg(call24LinkModel.value.linkStat, call24LinkModel.value.jobStat)}",
                                                          style: CustomStyle.CustomFont(styleFontSize10, Colors.redAccent,font_weight: FontWeight.w800),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              )
                                            ])
                                    ),
                                    Obx(() =>
                                    call24State.value ? Positioned(
                                        bottom: 0,
                                        child: Image.asset(
                                          "assets/image/down-arrow.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: styleBaseCol1,
                                        )
                                    ) : const SizedBox()
                                    ),
                                    item.call24Cargo == "R" && item.driverState == "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(6),
                                                vertical: CustomStyle.getHeight(6)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차\n확정",
                                              style: CustomStyle.CustomFont(styleFontSize8, Colors.white, font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : item.call24Cargo == "R" && item.driverState != "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(8),
                                                vertical: CustomStyle.getHeight(8)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize9, Colors.white,
                                                  font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : const SizedBox()
                                  ])
                          ) : const SizedBox(),
                      //화물맨
                      SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(85),
                              child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          oneCallState.value = false;
                                          call24State.value = false;
                                          manState.value = !manState.value;
                                        },
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Obx(() =>
                                                  Container(
                                                    width: CustomStyle.getWidth(80),
                                                    height: CustomStyle.getHeight(65),
                                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3.h)),
                                                    decoration: BoxDecoration(
                                                        color: statMsg(hwaMullLinkModel.value.linkStat, hwaMullLinkModel.value.jobStat) == ""
                                                            ? card_background
                                                            : hwaMullLinkModel.value.linkStat == "D" && hwaMullLinkModel.value.jobStat == "F"
                                                            ? styleGreyCol1 : card_background,
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "화물맨",
                                                          style: CustomStyle.CustomFont(styleFontSize13, main_color, font_weight: FontWeight.w500),
                                                        ),
                                                        Text(
                                                            "${Util.getInCodeCommaWon(item.manCharge)}원",
                                                            style: statMsg(hwaMullLinkModel.value.linkStat, hwaMullLinkModel.value.jobStat) == ""
                                                                ?  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                                : hwaMullLinkModel.value.linkStat == "D" && hwaMullLinkModel.value.jobStat == "F"
                                                                ?   TextStyle(decoration: TextDecoration.lineThrough, fontSize: styleFontSize13)
                                                                :  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                        ),
                                                        Text(
                                                          "${statMsg(hwaMullLinkModel.value.linkStat, hwaMullLinkModel.value.jobStat)}",
                                                          style: CustomStyle.CustomFont(styleFontSize10, Colors.redAccent,font_weight: FontWeight.w800),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              )
                                            ])
                                    ),
                                    Obx(() =>
                                    manState.value ? Positioned(
                                        bottom: 0,
                                        child: Image.asset(
                                          "assets/image/down-arrow.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: styleBaseCol1,
                                        )
                                    ) : const SizedBox()
                                    ),
                                    item.manCargo == "R" && item.driverState == "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(6),
                                                vertical: CustomStyle.getHeight(6)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차\n확정",
                                              style: CustomStyle.CustomFont(styleFontSize8, Colors.white, font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : item.manCargo == "R" && item.driverState != "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(8),
                                                vertical: CustomStyle.getHeight(8)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize9, Colors.white,
                                                  font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : const SizedBox()
                                  ])
                          ),
                      //원콜
                      SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(85),
                              child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          manState.value = false;
                                          call24State.value = false;
                                          oneCallState.value = !oneCallState.value;
                                        },
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Obx(() =>
                                                  Container(
                                                    width: CustomStyle.getWidth(80),
                                                    height: CustomStyle.getHeight(65),
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: CustomStyle.getHeight(3.h)),
                                                    decoration: BoxDecoration(
                                                        color: statMsg(oneCallLinkModel.value.linkStat, oneCallLinkModel.value.jobStat) == ""
                                                            ? card_background
                                                            : oneCallLinkModel.value.linkStat == "D" && oneCallLinkModel.value.jobStat == "F"
                                                            ? styleGreyCol1 : card_background,
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "원콜",
                                                          style: CustomStyle.CustomFont(styleFontSize13, main_color, font_weight: FontWeight.w500),
                                                        ),
                                                        Text(
                                                            "${Util.getInCodeCommaWon(item.oneCharge)}원",
                                                            style: statMsg(oneCallLinkModel.value.linkStat, oneCallLinkModel.value.jobStat) == ""
                                                                ?  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                                : oneCallLinkModel.value.linkStat == "D" && oneCallLinkModel.value.jobStat == "F"
                                                                ?   TextStyle(decoration: TextDecoration.lineThrough, fontSize: styleFontSize13)
                                                                :  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                        ),
                                                        Text(
                                                          "${statMsg(oneCallLinkModel.value.linkStat, oneCallLinkModel.value.jobStat)}",
                                                          style: CustomStyle.CustomFont(styleFontSize10, Colors.redAccent,font_weight: FontWeight.w800),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              )
                                            ])
                                    ),
                                    Obx(() =>
                                    oneCallState.value ? Positioned(
                                        bottom: 0,
                                        child: Image.asset(
                                          "assets/image/down-arrow.png",
                                          width: CustomStyle.getWidth(10.0),
                                          height: CustomStyle.getHeight(10.0),
                                          color: styleBaseCol1,
                                        )
                                    ) : const SizedBox()
                                    ),
                                    item.oneCargo == "R" && item.driverState == "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(6),
                                                vertical: CustomStyle.getHeight(6)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차\n확정",
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize8, Colors.white,
                                                  font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : item.oneCargo == "R" && item.driverState != "01" ?
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: CustomStyle.getWidth(8),
                                                vertical: CustomStyle.getHeight(8)),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle
                                            ),
                                            child: Text(
                                              "배차",
                                              style: CustomStyle.CustomFont(styleFontSize9, Colors.white, font_weight: FontWeight.w500),
                                            )
                                        )
                                    ) : const SizedBox()
                                  ])
                          ),
                    ],
                  ),

                  Obx((){
                    final _selected = false.obs;
                    if(call24State.value || manState.value || oneCallState.value) _selected.value = true;
                    if(item.orderState == "09") _selected.value = false;

                    return AnimatedContainer(
                        width: double.infinity,
                        height: _selected.value ? CustomStyle.getHeight(55) : CustomStyle.getHeight(30),
                        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5)),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.fastOutSlowIn,
                        decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(color: light_gray4, width: 1),
                                bottom: BorderSide(color: light_gray4, width: 1)
                            )
                        ),
                        child:
                        Obx(() =>
                          // 24시콜 OpenInfo
                          call24State.value ?
                            clickRpaInfoWidget(call24LinkModel.value,userRpaData.value, item,Const.CALL_24_KEY_NAME,item_index)
                          // 화물맨 OpenInfo
                          : manState.value ?
                            clickRpaInfoWidget(hwaMullLinkModel.value,userRpaData.value,item,Const.HWA_MULL_KEY_NAME,item_index)
                          // 원콜 OpenInfo
                          : oneCallState.value ?
                            clickRpaInfoWidget(oneCallLinkModel.value,userRpaData.value,item,Const.ONE_CALL_KEY_NAME,item_index)
                          : const SizedBox()
                        )
                    );
                  })
                ]
            )
        ) : const SizedBox()
    );

  }

  Widget clickRpaInfoWidget(OrderLinkCurrentModel linkModel,UserRpaModel user_Rpa_Data, OrderModel orderItem, String link_type,int item_index) {

    var link_name = "";

    final link_model = OrderLinkCurrentModel().obs;
    link_model.value = linkModel;
    final userRpaData = UserRpaModel().obs;
    userRpaData.value = user_Rpa_Data;
    final item = OrderModel().obs;
    item.value = orderItem;

    switch(link_type) {
      case "03" :
        link_name = "24시콜";
        break;
      case "21" :
        link_name = "화물맨";
        break;
      case "18" :
        link_name = "원콜";
        break;
    }


    return Obx(() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                statMsg(link_model.value.linkStat, link_model.value.jobStat) == "" ?
                link_model.value.linkStat == "R" ?
                item.value.orderStateName == "접수" ?
                InkWell(
                    onTap:(){
                      openRpaInfoDialog(context, item.value, "02",link_type,item_index,link_model: link_model.value);
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                            color: main_color,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 배차확정",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) :  InkWell(
                    onTap:(){
                      openRpaInfoDialog(context, item.value, "01",link_type,item_index);
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                            color: main_color,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 배차정보",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                )
                    : const SizedBox()
                    : link_model.value.linkStat == "D" && link_model.value.jobStat == "F" ?
                const SizedBox()
                    : const SizedBox(),

                // 전체 조건문 시작
                ((link_model.value.allocCharge != "" && link_model.value.allocCharge != null) && (link_model.value.linkStat != "D" && link_model.value.jobStat != "F") && (link_model.value.linkStat != "I" && link_model.value.jobStat != "E")
                    || (link_model.value.linkStat == "D" && link_model.value.jobStat == "E") || (link_model.value.linkStat == "I" && link_model.value.jobStat == "W")
                    || (link_model.value.linkStat == "I" && link_model.value.jobStat == "F") || (link_model.value.linkStat == "R" && link_model.value.jobStat == "W")
                    || (link_model.value.linkStat == "R" && link_model.value.jobStat == "F") || link_model.value.linkStat == "U") ?
                link_type == Const.CALL_24_KEY_NAME ?
                (userRpaData.value.link24Id?.isNotEmpty == true && userRpaData.value.link24Id != "") && (userRpaData.value.link24Pass?.isNotEmpty == true && userRpaData.value.link24Pass != "") ? // link24Id와 link24Pass이 등록되어 있는 상태
                item.value.orderStateName == "접수" ? // 24시콜 OrderStateName = "접수" 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ? // 24시콜 인수증, 선불, 착불 상태
                Row(
                    children: [
                      InkWell(
                          onTap:(){
                            openRpaModiDialog(context, item.value, link_type,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_modify,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, link_model.value,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_cancle,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                )  : const SizedBox()
                    : InkWell(  // 24시콜 OrderStateName = "접수" 아닐때
                    onTap:() async {
                      await cancelRpa(item.value.orderId, link_model.value,item_index);
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                            color: rpa_btn_cancle,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 취소",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) : const SizedBox()

                    : link_type == Const.ONE_CALL_KEY_NAME ?
                (userRpaData.value.one24Id?.isNotEmpty == true && userRpaData.value.one24Id != "") && (userRpaData.value.one24Pass?.isNotEmpty == true && userRpaData.value.one24Pass != "") ? // one24Id와 one24Pass이 등록되어 있는 상태
                item.value.orderStateName == "접수" && link_model.value.linkStat != "R" ? // 원콜 OrderStateName = "접수"상태고 linkStat 값이 R(배차 확정)이 아닌 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ? // 원콜 인수증, 선불, 착불 상태
                Row(
                    children: [
                      InkWell(
                          onTap:(){
                            openRpaModiDialog(context, item.value, link_type,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_modify,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, link_model.value,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_cancle,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                ) : const SizedBox()
                    : InkWell( // 원콜 OrderStateName = "접수" 상태가 아니거나 linkStat 값이 R(배차 확정)인 상태
                    onTap:() async {
                      await cancelRpa(item.value.orderId, link_model.value,item_index);
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                        decoration: const BoxDecoration(
                            color: rpa_btn_cancle,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 취소",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                )
                    : const SizedBox()

                    : (userRpaData.value.man24Id?.isNotEmpty == true && userRpaData.value.man24Id != "") && (userRpaData.value.man24Pass?.isNotEmpty == true && userRpaData.value.man24Pass != "") ? // man24Id와 man24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" ? // 화물맨
                Row(
                    children: [
                      InkWell(
                          onTap:(){
                            openRpaModiDialog(context, item.value, link_type,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_modify,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, link_model.value,item_index);
                          },
                          child: Container(
                              width: CustomStyle.getWidth(80),
                              height: CustomStyle.getHeight(25),
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              decoration: const BoxDecoration(
                                  color: rpa_btn_cancle,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${link_name} 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                )  : const SizedBox()
                    : const SizedBox()
                // 전체 조건문 아닐 경우
                    : item.value.orderStateName == "접수" ?
                link_type == Const.HWA_MULL_KEY_NAME ? // 전체 조건문이 맞지 않을때(화물맨)
                (userRpaData.value.man24Id?.isNotEmpty == true && userRpaData.value.man24Id != "") && (userRpaData.value.man24Pass?.isNotEmpty == true && userRpaData.value.man24Pass != "") ? // man24Id와 man24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" ? // 시작(1)
                InkWell(
                    onTap: () {
                      openRpaModiDialog(context, item.value, link_type,item_index,flag: "D");
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        decoration: const BoxDecoration(
                            color: rpa_btn_regist,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 등록",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) :  const SizedBox() // 끝(1)
                    : const SizedBox()
                    :link_type == Const.CALL_24_KEY_NAME ? // 전체 조건문이 맞지 않을때(24시콜)
                (userRpaData.value.link24Id?.isNotEmpty == true && userRpaData.value.link24Id != "") && (userRpaData.value.link24Pass?.isNotEmpty == true && userRpaData.value.link24Pass != "") ? // link24Id와 link24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ?
                InkWell(
                    onTap: () {
                      openRpaModiDialog(context, item.value, link_type,item_index,flag: "D");
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        decoration: const BoxDecoration(
                            color: rpa_btn_regist,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 등록",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) :  const SizedBox()
                    : const SizedBox()

                // 전체 조건문이 맞지 않을때(원콜)
                    : (userRpaData.value.one24Id?.isNotEmpty == true && userRpaData.value.one24Id != "") && (userRpaData.value.one24Pass?.isNotEmpty == true && userRpaData.value.one24Pass != "") ? // one24Id와 one24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ?
                InkWell(
                    onTap: () {
                      openRpaModiDialog(context, item.value, link_type,item_index,flag: "D");
                    },
                    child: Container(
                        width: CustomStyle.getWidth(80),
                        height: CustomStyle.getHeight(25),
                        decoration: const BoxDecoration(
                            color: rpa_btn_regist,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${link_name} 등록",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                )
                    :  const SizedBox()
                    : const SizedBox()

                    : const SizedBox()
              ]),
          link_model.value.linkStat != "D" && link_model.value.jobStat != "F" ?
          link_model.value.rpaMsg != null && link_model.value.rpaMsg?.isNotEmpty == true ?
            Flexible(
                child: Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5)
                    ),
                    child: RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          text: "${link_model.value.rpaMsg}",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.redAccent),
                        )
                    )
                )
            ) : const SizedBox()
          : const SizedBox()
        ])
    );
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  Future<Map<String,dynamic>> currentLink(String? orderId, String? link_type) async {
    // link_type = 03: 24시콜, 18: 원콜, 21: 화물맨
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    Map<String,dynamic> result = {};
    UserRpaModel rpa = UserRpaModel();
    OrderLinkCurrentModel returnModel = OrderLinkCurrentModel();

    await DioService.dioClient(header: true).currentNewLink(
      user.authorization,
      orderId,
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("main currentLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(_response.resultMap?["rpa"] != null) {
              rpa = UserRpaModel(
                  link24Id: _response.resultMap?["rpa"]["link24Id"],
                  link24Pass: _response.resultMap?["rpa"]["link24Pass"],
                  man24Id: _response.resultMap?["rpa"]["man24Id"],
                  man24Pass: _response.resultMap?["rpa"]["man24Pass"],
                  one24Id: _response.resultMap?["rpa"]["one24Id"],
                  one24Pass: _response.resultMap?["rpa"]["one24Pass"]
              );
            }
            userRpaModel.value = rpa;
            if (_response.resultMap?["data"] != null) {
              var mList = _response.resultMap?["data"] as List;
              if(mList.length > 0) {
                List<OrderLinkCurrentModel> itemsList = mList.map((i) => OrderLinkCurrentModel.fromJSON(i)).toList();
                  for (var list in itemsList) {
                    if (list.allocCd?.isNotEmpty == true &&
                        list.allocCd != null && list.linkCd == link_type) {
                      returnModel = list;
                    }
                  }
                  result = {"currentList": itemsList, "currentItem": returnModel};
              }
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("main currentLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("main currentLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("main currentLink() getOrder Default => ");
          break;
      }
    });
    return result;
  }

  Future<void> carConfirmRpa(Map<String,dynamic> data_map,int item_index) async {
    String textHeader = "${data_map["currentItem"].carNum}\t\t${data_map["currentItem"].carType}\t\t${data_map["currentItem"].carTon}";
    String textSub = "${data_map["currentItem"].driverName}\t\t${Util.makePhoneNumber(data_map["currentItem"].driverTel)}";
    String text = "배차 확정 하시겠습니까?";
    String textEtc="(나머지 정보망전송은 취소됩니다)";

    openCommonConfirmBox(
        context,
        "${textHeader}\n${textSub}\n${text}\n${textEtc}",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);

          for(var value in data_map["currentList"]) {
            if(value.linkCd == Const.CALL_24_KEY_NAME) {
              if(value.linkCd == data_map["currentItem"].linkCd) {
                await confirmLink(data_map["currentItem"]);
              }else{
                await cancelLink(data_map["currentItem"].orderId, value.allocCharge, "24Cargo", false,item_index);
              }
            }
            if(value.linkCd == Const.ONE_CALL_KEY_NAME) {
              if(value.linkCd == data_map["currentItem"].linkCd) {
                await confirmLink(data_map["currentItem"]);
              }else{
                await cancelLink(data_map["currentItem"].orderId, value.allocCharge, "oneCargo", false,item_index);
              }
            }
            if(value.linkCd == Const.HWA_MULL_KEY_NAME) {
              if(value.linkCd == data_map["currentItem"].linkCd) {
                await confirmLink(data_map["currentItem"]);
              }else{
                await cancelLink(data_map["currentItem"].orderId, value.allocCharge, "manCargo", false,item_index);
              }
            }
          }
          setState(() {
            lastPositionItem.value = item_index;
          });
        }
    );
  }

  Future<void> openRpaInfoDialog(BuildContext context,OrderModel item,String alloc_type, String? link_type,int item_index,{OrderLinkCurrentModel? link_model})  async {
    // alloc_type: 01 = 배차 확정된 상태, 02 = 배차 미확정 상태

    Map<String,dynamic> currend_link = await currentLink(item.orderId, link_type);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                insetPadding: EdgeInsets.all(CustomStyle.getHeight(10.0)),
                contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getWidth(10.0)),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "차주님 정보",
                            style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                          ),
                        ),
                      ),

                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_carplate.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "차량번호",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      item.allocState == "00" ? "${currend_link["currentItem"].carNum}" : "${item.carNum}",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ),

                      item.allocState == "00" ?
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_truck.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "요청차종",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.carTypeName}",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ) : const SizedBox(),

                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_truck.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "차종",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${currend_link["currentItem"].carType}",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ),

                      item.allocState == "00" ?
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_scales.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "요청톤수",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.carTonName}",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ) : const SizedBox(),

                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_scales.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "톤수",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${currend_link["currentItem"].carTon}",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ),

                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_name.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "차주명",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      item.allocState == "00" ? currend_link["currentItem"].driverName??"" : item.driverName??"",
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ),

                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal:CustomStyle.getWidth(10)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal:CustomStyle.getWidth(5)),
                          decoration: const BoxDecoration(
                              color: Color(0xffEDEEF0),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                              child: Image.asset(
                                                "assets/image/icon_phone.png",
                                                width: CustomStyle.getWidth(20.0),
                                                height: CustomStyle.getHeight(20.0),
                                              )
                                          ),
                                          Text(
                                            "차주핸드폰번호",
                                            textAlign: TextAlign.start,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                          )
                                        ])
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      item.allocState == "00" ? Util.makePhoneNumber(currend_link["currentItem"].driverTel??"") : Util.makePhoneNumber(item.driverTel??""),
                                      textAlign: TextAlign.end,
                                      style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w400),
                                    )
                                )
                              ]
                          )
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.of(context).pop(false);
                              },
                              child: Container(
                                width: CustomStyle.getWidth(100),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(14.0), bottom: CustomStyle.getHeight(14.0), right: CustomStyle.getWidth(10.0)),
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                decoration: const BoxDecoration(
                                    color: copy_btn,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Text(
                                  "닫기",
                                  style: CustomStyle.CustomFont(styleFontSize11, Colors.white,font_weight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // 배차확정 버튼
                            alloc_type == "02" ?
                            InkWell(
                              onTap: () async {
                                await carConfirmRpa(currend_link,item_index);
                              },
                              child: Container(
                                width: CustomStyle.getWidth(100),
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                decoration: const BoxDecoration(
                                    color: rpa_btn_regist,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Text(
                                  "배차 확정",
                                  style: CustomStyle.CustomFont(styleFontSize11, Colors.white,font_weight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ) : const SizedBox()
                          ]
                      )
                    ],
                  ),
                )
            ),
          );
        });
  }

  String getPadvalue(index) {
    if (index < 9) {
      return (index + 1).toString();
    } else if (index == 9) {
      return '초기화';
    } else if (index == 10) {
      return '0';
    } else {
      return '<';
    }
  }

  Future<void> registRpa(OrderModel item, String? linkCd, String? rpaPay,int item_index) async {
    if(rpaPay == "0" || rpaPay == "" || rpaPay == null) {
      Util.toast("지불운임을 입력해 주세요.");
      return;
    }

    String cd;
    String text = "";

    if(Const.CALL_24_KEY_NAME == linkCd) {
      cd = "24Cargo";
      text = "24시콜 정보망에 등록하시겠습니까?";
    }else if(Const.ONE_CALL_KEY_NAME == linkCd) {
      cd = "oneCargo";
      text = "원콜 정보망에 등록하시겠습니까?";
    }else if(Const.HWA_MULL_KEY_NAME == linkCd) {
      cd = "manCargo";
      text = "화물맨 정보망에 등록하시겠습니까?";
    }else{
      cd = "";
    }

    await openCommonConfirmBox(
        context,
        "금액: ${rpaPay}원\n$text",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await modLink("N",item, rpaPay, cd,"D",item_index);
        }
    );

  }

  Future<void> cancelRpa(String? orderId, OrderLinkCurrentModel data,int item_index) async {
    String? allocCharge = data.allocCharge;
    String? cd;
    String? text;

    if(Const.CALL_24_KEY_NAME == data.linkCd) {
      cd = "24Cargo";
      text = "24시콜 정보망 전송 \n\n취소하시겠습니까?";
    }else if(Const.ONE_CALL_KEY_NAME == data.linkCd) {
      cd = "oneCargo";
      text = "원콜 정보망 전송\n\n취소하시겠습니까?";
    }else if(Const.HWA_MULL_KEY_NAME == data.linkCd) {
      cd = "manCargo";
      text = "화물맨 정보망 전송\n\n취소하시겠습니까?";
    }else{
      cd = "";
      text ="";
    }

    openCommonConfirmBox(
        context,
        "${text}",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await cancelLink(orderId, allocCharge, cd, true,item_index);
        }
    );

  }

  Future<void> cancelLink(String? orderId, String? rpaPay,String? linkCd, bool flag,int item_index) async {

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).cancelNewLink(
        user.authorization,
        orderId,
        rpaPay,
        "09",
        linkCd
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if(flag == true) {
              var link_name = '';
              if(linkCd == Const.CALL_24_KEY_NAME) link_name = "24시콜";
              else if(linkCd == Const.HWA_MULL_KEY_NAME) link_name = "화물맨";
              else if(linkCd == Const.ONE_CALL_KEY_NAME) link_name = "원콜";
              Util.snackbar(context, "${link_name} 지불운임이 취소되었습니다.");
              await refresh();
            }

          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("cancelLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("cancelLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("cancelLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> modLink(String allocChargeYn,OrderModel item,String rpaPay, String linkCd, String flag, int item_index) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).modNewLink(
        user.authorization,
        item.orderId,
        rpaPay,
        item.orderState,
        linkCd,
        allocChargeYn
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("modLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
              Navigator.of(context).pop(false);
              var link_name = '';
              if(linkCd == Const.CALL_24_KEY_NAME) link_name = "24시콜";
              else if(linkCd == Const.HWA_MULL_KEY_NAME) link_name = "화물맨";
              else if(linkCd == Const.ONE_CALL_KEY_NAME) link_name = "원콜";

              Util.snackbar(context, "${link_name} 지불운임이 ${flag == "D" ? "등록" : "수정"}되었습니다.");
              if(flag == "D") { // D: 등록일 경우 리스트 최상단 이동
                await refresh();
              }else{ // U: 수정일 경우 현재 리스트 위치 이동
                setState(() {
                  lastPositionItem.value = item_index;
                });
              }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("modLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("modLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("modLink() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> confirmLink(OrderLinkCurrentModel? data) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).confirmNewLink(
        user.authorization,
        data?.orderId,
        data?.allocCharge,
        data?.linkCd,
        data?.carNum,
        data?.carType,
        data?.carTon,
        data?.driverName,
        data?.driverTel
    ).then((it) async {
      try {
        Navigator.of(context).pop(false);
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("confirmLink() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {


          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("confirmLink() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("confirmLink() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("confirmLink() getOrder Default => ");
          break;
      }
    });
  }

  String statMsg(String? link_stat, String? job_stat){

    var msg = "";
    if(job_stat=="W"){
      if(link_stat=="I"){
        msg ="(등록중)";
      }else if(link_stat=="D"){
        msg ="(취소중)";
      }else if(link_stat=="U"){
        msg ="(수정중)";
      }else{
        msg ="";
      }
    }else if(job_stat=="E"){
      if(link_stat=="I"){
        msg ="(등록실패)";
      }else if(link_stat=="D"){
        msg ="(취소실패)";
      }else if(link_stat=="U"){
        msg ="(수정실패)";
      }else{
        msg ="";
      }
    }else if(job_stat=="F"){
      if(link_stat=="D"){
        msg ="(취소완료)";
      }else{
        msg ="";
      }
    }else if(job_stat=="C"){
      if(link_stat=="U"){
        msg ="(수정중)";
      }else{
        msg ="";
      }
    }else if(job_stat=="R"){
      msg ="(화망처리중)";
    }else{
      msg ="";
    }
    return msg;
  }

  Future<void> openRpaModiDialog(BuildContext context, OrderModel item, String? link_type,int item_index, {String? flag}) async {

    final SelectNumber = "0".obs;
    if(flag != "D") {
      SelectNumber.value =
      Const.CALL_24_KEY_NAME == link_type ? item.call24Charge ?? "0" : Const
          .HWA_MULL_KEY_NAME == link_type ? item.manCharge ?? "0" : item
          .oneCharge ?? "0";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.70,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              child: Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              "assets/image/icon_won.png",
                              width: CustomStyle.getWidth(25),
                              height: CustomStyle.getHeight(25)
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: CustomStyle.getWidth(10)),
                              child: Text(
                                "${link_type == "03" ? "24시콜" : link_type == "21" ? "화물맨" : link_type == "18" ? "원콜" : ""}\n금액을 ${flag == "D" ? "등록" : "변경"}해주세요.",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, Colors.black,
                                    font_weight: FontWeight.w600),
                              )
                          )
                        ]
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                            vertical: CustomStyle.getHeight(15)),
                        child: Obx(() =>
                            Text(
                              "${Util.getInCodeCommaWon(SelectNumber.value)} 원",
                              style: CustomStyle.CustomFont(
                                  styleFontSize28, Colors.black,
                                  font_weight: FontWeight.w600),
                            ))
                    ),
                    // 숫자 키패드
                    GridView.builder(
                        shrinkWrap: true,
                        itemCount: 12,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                          childAspectRatio: 1.5 / 1, //item 의 가로 1, 세로 1 의 비율
                          mainAxisSpacing: 5, //수평 Padding
                          crossAxisSpacing: 5, //수직 Padding
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          // return Text(index.toString());
                          return InkWell(
                              onTap: () {
                                switch (index) {
                                  case 9:
                                  //reset
                                    SelectNumber.value = '0';
                                    return;
                                  case 10:
                                    if(SelectNumber.value.length >= 8) return;
                                    if (SelectNumber.value == '0') return;
                                    else SelectNumber.value = '${SelectNumber.value}0';
                                    return;
                                  case 11:
                                  //remove
                                    if (SelectNumber.value.length == 1) SelectNumber.value = '0';
                                    else
                                      SelectNumber.value = SelectNumber.value.substring(0, SelectNumber.value.length - 1);
                                    return;

                                  default:
                                    if(SelectNumber.value.length >= 8) return;
                                    if (SelectNumber.value == '0') SelectNumber.value = '${index + 1}';
                                    else SelectNumber.value = '${SelectNumber.value}${index + 1}';
                                    return;
                                }
                              },
                              child: Ink(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Center(
                                        child: Text(getPadvalue(index),
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)
                                        )
                                    ),
                                  )
                              )
                          );
                        }
                    ),

                    Container(
                        width: double.infinity,
                        height: CustomStyle.getHeight(45),
                        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: rpa_btn_regist,
                        ),
                        child: TextButton(
                            onPressed: () async {
                              if(SelectNumber.value == null || SelectNumber.value.isEmpty == true) SelectNumber.value = "0";
                              var cd = "";
                              if(Const.CALL_24_KEY_NAME == link_type) {
                                cd = "24Cargo";
                              }else if(Const.ONE_CALL_KEY_NAME == link_type) {
                                cd = "oneCargo";
                              }else if(Const.HWA_MULL_KEY_NAME == link_type) {
                                cd = "manCargo";
                              }else{
                                cd = "";
                              }
                              if(int.parse(SelectNumber.value) > 20000){
                                if(flag == "D") {
                                  await registRpa(item,link_type,SelectNumber.value,item_index);
                                }else {
                                  await modLink("N", item, SelectNumber.value, cd, "U",item_index);
                                }
                              }else{
                                Util.toast("지불운임은 20,000원이상입니다.");
                              }
                            },
                            child: Text(
                              flag == "D" ? "등록" : "수정",
                              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                            )
                        )
                    )
                  ]
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: order_item_background,
      resizeToAvoidBottomInset:true,
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

                        var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                        if(guest) {
                          showGuestDialog();
                          return;
                        }
                        await goToRegOrder();
                      },
                      child: Container(
                          height: CustomStyle.getHeight(80),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: main_color),
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
                              ]
                          )
                      )
                  )
              ),
            ],
          )),
    );
  }
}