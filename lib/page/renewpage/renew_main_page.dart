import 'dart:convert';
import 'dart:io';

import 'package:fbroadcast/fbroadcast.dart' as fbroad;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_main_widget.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/dept_model.dart';
import 'package:logislink_tms_flutter/common/model/order_link_current_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/template_model.dart';
import 'package:logislink_tms_flutter/common/model/template_stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/model/user_rpa_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/renewpage/create_template_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_appbar_mypage.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_appbar_setting_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_general_regist_order_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_order_detail_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/renew_order_trans_info_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/template_manage_page.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_monitor_page.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_notice_page.dart';
import 'package:logislink_tms_flutter/page/subpage/notification_page.dart';
import 'package:logislink_tms_flutter/page/subpage/point_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/regist_order_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/style_theme.dart';

class RenewMainPage extends StatefulWidget {
  final String? allocId;
  const RenewMainPage({Key? key, this.allocId}) : super(key:key);

  @override
  _RenewMainPageState createState() => _RenewMainPageState();
}

class _RenewMainPageState extends State<RenewMainPage> with CommonMainWidget, WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final isExpanded = [].obs;
  final isSelected = [].obs;
  final controller = Get.find<App>();
  final mUser = UserModel().obs;

  final dateSelectOption = ["-7일","-1일","당일","+1일","+7일","직접설정"];
  final dateSelectValue = 3.obs;
  final daySelectOption = "0".obs;
  final filterOrderOption = ["오더전체","접수","배차","운송사지정","취소"];
  final filterRpaOption = ["화망무관","화망배차전", "배차확정"];

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  final orderList = List.empty(growable: true).obs;
  final custUserList = List.empty(growable: true).obs;
  final deptList = List.empty(growable: true).obs;
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
  CalendarFormat _calendarWeekFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  final categoryOrderCode = "".obs;
  final categoryOrderState = "오더전체".obs;
  final categoryDeptCode = "".obs;
  final categoryDeptState = "부서전체".obs;
  final categoryRpaCode = "".obs;
  final categoryRpaState = "화망무관".obs;
  final categoryStaffModel = CustUserModel(userId: "",userName: "담당자전체").obs;
  List<CodeModel>? dropDownList = List.empty(growable: true);
  final select_value = CodeModel().obs;
  final _isNewVersionCheck = false.obs;

  AutoScrollController  scrollController = AutoScrollController();
  final page = 1.obs;
  final api24Data = <String, dynamic>{}.obs;
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

  /// Function Start

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
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(allocId: widget.allocId)));
      }
      scrollController.addListener(() {
        var nowScroll = scrollController.position.pixels;
        var maxScroll = scrollController.position.maxScrollExtent;
        if(nowScroll >= 300) {
          ivTop.value = true;
        } else {
          ivTop.value = false;
        }
        if(nowScroll < (maxScroll-800)) {
          ivBottom.value = true;
        }else{
          ivBottom.value = false;
        }
        if((maxScroll - nowScroll) <= 50){
          if(page.value < totalPage.value){
            lastPositionItem.value = orderList.value.length;
            page.value++;
          }
        }
      });
      searchOrderController = TextEditingController();
      db = controller.getRepository();
      db.deleteAll();
      await getPointResult();
      await initView();
      await getDeptList();
      dropDownList?.add(CodeModel(code: "carNum",codeName: "차량번호"));
      dropDownList?.add(CodeModel(code: "driverName",codeName: "차주명"));
      dropDownList?.add(CodeModel(code: "sellCustName",codeName: "거래처명"));

    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Util.notificationDialog(context,"기본",webViewKey);
    });

    super.initState();
  }

  Future<void> initView() async {
    await getCustUser();
    mUser.value = await controller.getUserInfo();
    List<OrderModel> list = await db.getOrderList(context);
    if(list.isNotEmpty) {
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
                //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderDetailPage(allocId: allocId)));
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

  Future openCalendarDialog() {
    mCalendarNowDate = DateTime.now();
    DateTime? tempSelectedDay;
    DateTime? tempRangeStart = mCalendarStartDate.value;
    DateTime? tempRangeEnd = mCalendarEndDate.value;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: "날짜 직접설정",
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState)
        {
          return FractionallySizedBox(
              widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
              heightFactor: 0.65,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(
                      horizontal: CustomStyle.getWidth(15)),
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10),
                      left: CustomStyle.getWidth(10),
                      top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                      color: Colors.white
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                            child: SizedBox(
                                width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width,
                                height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.6,
                                child: Column(
                                    children: [
                                      TableCalendar(
                                        rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(45.h),
                                        locale: 'ko_KR',
                                        firstDay: DateTime.utc(2010, 1, 1),
                                        lastDay: DateTime.utc(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day),
                                        daysOfWeekHeight: 32 * MediaQuery.of(context).textScaleFactor,
                                        headerStyle: HeaderStyle(
                                          // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                          formatButtonVisible: false,
                                          // 달력 타이틀을 센터로
                                          titleCentered: true,
                                          // 말 그대로 타이틀 텍스트 스타일링
                                          titleTextStyle:
                                          CustomStyle.CustomFont(
                                              styleFontSize16, Colors.black,
                                              font_weight: FontWeight.w700
                                          ),
                                          rightChevronIcon: Icon(
                                              Icons.chevron_right, size: 26.h),
                                          leftChevronIcon: Icon(
                                              Icons.chevron_left, size: 26.h),
                                        ),
                                        calendarStyle: CalendarStyle(
                                          tablePadding: EdgeInsets.symmetric(
                                              vertical: CustomStyle.getHeight(10.h),
                                              horizontal: CustomStyle.getWidth(5.w)
                                          ),
                                          outsideTextStyle: CustomStyle.CustomFont(styleFontSize12, line),
                                          // 오늘 날짜에 하이라이팅의 유무
                                          isTodayHighlighted: false,
                                          // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                          defaultDecoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          // 캘린더의 주말 배경 스타일링
                                          weekendDecoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          // 선택한 날짜 배경 스타일링
                                          selectedDecoration: BoxDecoration(
                                              color: styleWhiteCol,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: main_color, width: 1.w)
                                          ),
                                          defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                          weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red, font_weight: FontWeight.w600),
                                          selectedTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),
                                          // range 크기 조절
                                          rangeHighlightScale: 1.0,

                                          // range 색상 조정
                                          rangeHighlightColor: const Color(0xFFDFE8F4),

                                          // rangeStartDay 글자 조정
                                          rangeStartTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),

                                          // rangeStartDay 모양 조정
                                          rangeStartDecoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 1.w)
                                          ),

                                          // rangeEndDay 글자 조정
                                          rangeEndTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),

                                          // rangeEndDay 모양 조정
                                          rangeEndDecoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 1.w)
                                          ),

                                          // startDay, endDay 사이의 글자 조정
                                          withinRangeTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black),

                                          // startDay, endDay 사이의 모양 조정
                                          withinRangeDecoration: const BoxDecoration(),
                                        ),
                                        //locale: 'ko_KR',
                                        focusedDay: mCalendarNowDate,
                                        selectedDayPredicate: (day) {
                                          return isSameDay(tempSelectedDay, day);
                                        },
                                        rangeStartDay: tempRangeStart,
                                        rangeEndDay: tempRangeEnd,
                                        calendarFormat: _calendarFormat,
                                        rangeSelectionMode: _rangeSelectionMode,
                                        onDaySelected: (selectedDay, focusedDay) {
                                          if (!isSameDay(tempSelectedDay, selectedDay)) {
                                            setState(() {
                                              tempSelectedDay = selectedDay;
                                              mCalendarNowDate = focusedDay;
                                              _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                            });
                                          }
                                        },
                                        onRangeSelected: (start, end, focusedDay) {
                                          setState(() {
                                            tempSelectedDay = start;
                                            mCalendarNowDate = focusedDay;
                                            tempRangeStart = start;
                                            tempRangeEnd = end;
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
                                      InkWell(
                                          onTap: () async {
                                            int? diffDay = tempRangeEnd?.difference(tempRangeStart!).inDays;
                                            if (tempRangeStart == null || tempRangeEnd == null) {
                                              if (tempRangeStart == null && tempRangeEnd != null) {
                                                tempRangeStart = tempRangeEnd?.add(const Duration(days: -30));
                                              } else
                                              if (tempRangeStart != null && tempRangeEnd == null) {
                                                DateTime? tempDate = tempRangeStart?.add(const Duration(days: 30));
                                                int startDiffDay = tempDate!.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
                                                if (startDiffDay > 0) {
                                                  tempRangeEnd = tempRangeStart;
                                                  tempRangeStart = tempRangeEnd?.add(const Duration(days: -30));
                                                } else {
                                                  tempRangeEnd =
                                                      tempRangeStart?.add(const Duration(days: 30));
                                                }
                                              } else {
                                                return Util.toast(
                                                    "시작 날짜 또는 종료 날짜를 선택해주세요.");
                                              }
                                            } else if (diffDay! > 30) {
                                              return Util.toast(Strings.of(context)?.get("dateOver") ?? "Not Found");
                                            }
                                            mCalendarStartDate.value = tempRangeStart!;
                                            mCalendarEndDate.value = tempRangeEnd!;
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Center(
                                              child: Container(

                                                height: CustomStyle.getHeight(
                                                    50),
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: CustomStyle
                                                        .getHeight(5)),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(50),
                                                    color: renew_main_color2),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  "적용",
                                                  style: CustomStyle.CustomFont(
                                                      styleFontSize18,
                                                      styleWhiteCol),
                                                ),
                                              )
                                          )
                                      )
                                    ]
                                )
                            )
                        )
                      ]
                  )
              )
          );
        });
      },
    );
  }

  String statMsg(String? linkStat, String? jobStat) {
    var msg = "";
    if (jobStat == "W") {
      if (linkStat == "I") {
        msg = "(등록중)";
      } else if (linkStat == "D") {
        msg = "(취소중)";
      } else if (linkStat == "U") {
        msg = "(수정중)";
      } else {
        msg = "";
      }
    } else if (jobStat == "E") {
      if (linkStat == "I") {
        msg = "(등록실패)";
      } else if (linkStat == "D") {
        msg = "(취소실패)";
      } else if (linkStat == "U") {
        msg = "(수정실패)";
      } else {
        msg = "";
      }
    } else if (jobStat == "F") {
      if (linkStat == "D") {
        msg = "(취소완료)";
      } else {
        msg = "";
      }
    } else if (jobStat == "C") {
      if (linkStat == "U") {
        msg = "(수정중)";
      } else {
        msg = "";
      }
    } else if (jobStat == "R") {
      msg = "(화망처리중)";
    } else {
      msg = "";
    }
    return msg;
  }

  Future<void> openStoEDateSheet(BuildContext context,TemplateModel templateItem) {
    mCalendarNowDate = DateTime.now();
    DateTime? tempStartSelectedDay = DateTime.now();
    final seletStartMode = false.obs;
    DateTime? tempEndSelectedDay = DateTime.now();
    final selectEndMode = false.obs;
    final startTimeChk = true.obs;
    final sTime = DateTime.now().obs;
    final endTimeChk = true.obs;
    final eTime = DateTime.now().obs;
    templateItem.sDate = Util.getAllDate(DateTime(tempStartSelectedDay!.year,tempStartSelectedDay!.month,tempStartSelectedDay!.day,!startTimeChk.value ? sTime.value.hour : 0,!startTimeChk.value ? sTime.value.minute : 0 ,0));
    templateItem.eDate = Util.getAllDate(DateTime(tempEndSelectedDay!.year,tempEndSelectedDay!.month,tempEndSelectedDay!.day, !endTimeChk.value ? eTime.value.hour : 23, !endTimeChk.value ? eTime.value.minute : 59, 0));

    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: "상/하차 일시",
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return FractionallySizedBox(
                widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
                heightFactor: 0.70,
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.symmetric(
                        horizontal: CustomStyle.getWidth(15)),
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(10),
                        left: CustomStyle.getWidth(10),
                        top: CustomStyle.getHeight(10)),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.white
                    ),
                    child: Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(
                                        bottom: CustomStyle.getHeight(15)),
                                    child: Text("\"${templateItem.templateTitle}\"\n상/하차 날짜를 선택해주세요.",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize20, Colors.black,
                                            font_weight: FontWeight.w800)
                                    )
                                )
                              ]),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                color: light_gray24,
                                width: 2
                              )
                          )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children : [
                            Container(
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "상차일",
                                    style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w600),
                                  ),
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "시간무관",
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                                      ),
                                      Checkbox(
                                        value: startTimeChk.value,
                                        onChanged: (value) {
                                          setState(() {
                                            startTimeChk.value = value!;
                                          });
                                        },
                                      ),
                                    ]
                                  )
                                ]
                              )
                            ),
                            InkWell(
                              onTap: (){
                                seletStartMode.value = !seletStartMode.value;
                                if(selectEndMode.value) selectEndMode.value = false;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(color: light_gray23,width: 2)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${tempStartSelectedDay == null?"-":"${tempStartSelectedDay?.year}-${tempStartSelectedDay?.month}-${tempStartSelectedDay?.day}"}",
                                        style: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                      ),
                                      Icon(Icons.calendar_today,color: light_gray23,size: 24.r)
                                    ]
                                )
                              )
                            ),

                          ]
                        )
                      ),
                      seletStartMode.value ?
                            Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                              decoration: BoxDecoration(
                                border: Border.all(color: light_gray23,width: 2),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: TableCalendar(
                              rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(45.h),
                              locale: 'ko_KR',
                              firstDay: DateTime.utc(DateTime.now().year - 10, 1, 1),
                              lastDay: DateTime.utc(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day),
                              daysOfWeekHeight: 32 * MediaQuery.of(context).textScaleFactor,
                              headerVisible: false,
                              headerStyle: HeaderStyle(
                                // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                formatButtonVisible: false,
                                // 달력 타이틀을 센터로
                                titleCentered: true,
                                // 말 그대로 타이틀 텍스트 스타일링
                                titleTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                rightChevronIcon: Icon(Icons.chevron_right, size: 26.h),
                                leftChevronIcon: Icon(Icons.chevron_left, size: 26.h),
                              ),
                              calendarStyle: CalendarStyle(
                                tablePadding: EdgeInsets.symmetric( horizontal: CustomStyle.getWidth(5.w)),
                                outsideTextStyle: CustomStyle.CustomFont(styleFontSize12, line),
                                // 오늘 날짜에 하이라이팅의 유무
                                isTodayHighlighted: false,
                                // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                defaultDecoration: const BoxDecoration(color: Colors.white,),
                                // 캘린더의 주말 배경 스타일링
                                weekendDecoration: const BoxDecoration(color: Colors.white,),
                                // 선택한 날짜 배경 스타일링
                                selectedDecoration: BoxDecoration(
                                    color: const Color(0xffFFB4B9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xffFFB4B9), width: 1.w)

                                ),
                                defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red, font_weight: FontWeight.w600),
                                selectedTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                // startDay, endDay 사이의 글자 조정
                                withinRangeTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black),

                                // startDay, endDay 사이의 모양 조정
                                withinRangeDecoration: const BoxDecoration(),
                              ),
                              focusedDay: mCalendarNowDate,
                              selectedDayPredicate: (day) {
                                return isSameDay(tempStartSelectedDay, day);
                              },
                              calendarFormat: _calendarWeekFormat,
                              onDaySelected: (selectedDay, focusedDay) {
                                if (!isSameDay(tempStartSelectedDay, selectedDay)) {
                                  setState(() {
                                    tempStartSelectedDay = selectedDay;
                                    mCalendarNowDate = focusedDay;
                                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                  });
                                }
                              },
                              onFormatChanged: (format) {
                                if (_calendarWeekFormat != format) {
                                  setState(() {
                                    _calendarWeekFormat = format;
                                  });
                                }
                              },
                              onPageChanged: (focusedDay) {
                                mCalendarNowDate = focusedDay;
                              },
                            )
                        ) : const SizedBox(),
                          !startTimeChk.value ?
                          Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: light_gray23, width: 2)
                              ),
                              child: TimePickerSpinner(
                                is24HourMode: true,
                                normalTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                highlightedTextStyle: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
                                time: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0),
                                spacing: 50,
                                itemHeight: 30,
                                isForce2Digits: true,
                                minutesInterval: 30,
                                onTimeChange: (time) {
                                  setState((){
                                    sTime.value = DateTime(sTime.value.year,sTime.value.month,sTime.value.day,time.hour,time.minute,0);
                                  });
                                },
                              )
                          ) : const SizedBox(),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children : [
                                Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "하차일",
                                            style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w600),
                                          ),
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "시간무관",
                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w500),
                                                ),
                                                Checkbox(
                                                  value: endTimeChk.value,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      endTimeChk.value = value!;
                                                    });
                                                  },
                                                ),
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                InkWell(
                                    onTap: (){
                                      selectEndMode.value = !selectEndMode.value;
                                      if(seletStartMode.value) seletStartMode.value = false;
                                    },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(10.w)),
                                        margin: EdgeInsets.only(top: CustomStyle.getHeight(5.h)),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                            border: Border.all(color: light_gray23,width: 2)
                                        ),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${tempEndSelectedDay == null?"-":"${tempEndSelectedDay?.year}-${tempEndSelectedDay?.month}-${tempEndSelectedDay?.day}"}",
                                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                              ),
                                              Icon(Icons.calendar_today,color: light_gray23,size: 24.r)
                                            ]
                                        )
                                    )
                                ),

                              ]
                          ),
                          selectEndMode.value ?
                          Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                              decoration: BoxDecoration(
                                  border: Border.all(color: light_gray23,width: 2),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: TableCalendar(
                                rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(45.h),
                                locale: 'ko_KR',
                                firstDay: DateTime.utc(DateTime.now().year - 10, 1, 1),
                                lastDay: DateTime.utc(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day),
                                daysOfWeekHeight: 32 * MediaQuery.of(context).textScaleFactor,
                                headerVisible: false,
                                headerStyle: HeaderStyle(
                                  // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                  formatButtonVisible: false,
                                  // 달력 타이틀을 센터로
                                  titleCentered: true,
                                  // 말 그대로 타이틀 텍스트 스타일링
                                  titleTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                  rightChevronIcon: Icon(Icons.chevron_right, size: 26.h),
                                  leftChevronIcon: Icon(Icons.chevron_left, size: 26.h),
                                ),
                                calendarStyle: CalendarStyle(
                                  tablePadding: EdgeInsets.symmetric( horizontal: CustomStyle.getWidth(5.w)),
                                  outsideTextStyle: CustomStyle.CustomFont(styleFontSize12, line),
                                  // 오늘 날짜에 하이라이팅의 유무
                                  isTodayHighlighted: false,
                                  // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                  defaultDecoration: const BoxDecoration(color: Colors.white,),
                                  // 캘린더의 주말 배경 스타일링
                                  weekendDecoration: const BoxDecoration(color: Colors.white,),
                                  // 선택한 날짜 배경 스타일링
                                  selectedDecoration: BoxDecoration(
                                      color: const Color(0xFF50C8FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF50C8FF), width: 1.w)

                                  ),
                                  defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                  weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red, font_weight: FontWeight.w600),
                                  selectedTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w700),
                                  // startDay, endDay 사이의 글자 조정
                                  withinRangeTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black),

                                  // startDay, endDay 사이의 모양 조정
                                  withinRangeDecoration: const BoxDecoration(),
                                ),
                                focusedDay: mCalendarNowDate,
                                selectedDayPredicate: (day) {
                                  return isSameDay(tempEndSelectedDay, day);
                                },
                                calendarFormat: _calendarWeekFormat,
                                onDaySelected: (selectedDay, focusedDay) {
                                  if(parseIntDate(Util.getAllDate(tempStartSelectedDay!)) > parseIntDate(Util.getTextDate(selectedDay))) {
                                    Util.toast(Strings.of(context)?.get("order_reg_day_date_fail"));
                                  }else {
                                    if (!isSameDay(tempEndSelectedDay, selectedDay)) {
                                      setState(() {
                                        tempEndSelectedDay = selectedDay;
                                        mCalendarNowDate = focusedDay;
                                        _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                      });
                                    }
                                  }
                                },
                                onFormatChanged: (format) {
                                  if (_calendarWeekFormat != format) {
                                    setState(() {
                                      _calendarWeekFormat = format;
                                    });
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  mCalendarNowDate = focusedDay;
                                },
                              )
                          ) : const SizedBox(),
                          !endTimeChk.value ?
                            Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(3.h)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: light_gray23, width: 2)
                              ),
                              child: TimePickerSpinner(
                                is24HourMode: true,
                                normalTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                highlightedTextStyle: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
                                time: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour+1,0),
                                spacing: 50,
                                itemHeight: 30,
                                isForce2Digits: true,
                                minutesInterval: 30,
                                onTimeChange: (time) {
                                  setState((){
                                    eTime.value = DateTime(eTime.value.year,eTime.value.month,eTime.value.day,time.hour,time.minute,0);
                                  });
                                },
                              )
                            ) : const SizedBox(),


                            InkWell(
                                  onTap: () async {
                                    await getTemplateStopList(templateItem);
                                    DateTime? sDateTime = DateTime(tempStartSelectedDay!.year,tempStartSelectedDay!.month,tempStartSelectedDay!.day,!startTimeChk.value ? sTime.value.hour : 0,!startTimeChk.value ? sTime.value.minute : 0 ,0);
                                    DateTime? eDateTime = DateTime(tempEndSelectedDay!.year,tempEndSelectedDay!.month,tempEndSelectedDay!.day, !endTimeChk.value ? eTime.value.hour : 23, !endTimeChk.value ? eTime.value.minute : 59, 0);
                                    templateItem.sDate = Util.getAllDate(sDateTime);
                                    templateItem.eDate = Util.getAllDate(eDateTime);

                                    Map<String,dynamic> results  = await Navigator.of(context).push(PageAnimationTransition(page: CreateTemplatePage(flag: "D",tModel: templateItem, sTimeFreeYn: startTimeChk.value, eTimeFreeYn: endTimeChk.value), pageAnimationType: LeftToRightTransition()));
                                    Navigator.of(context).pop();
                                    if(results != null && results.containsKey("code")){
                                      if(results["code"] == 200) {
                                        Util.toast("오더가 정상적으로 등록되었습니다.");
                                        await refresh();
                                      }
                                    }

                                  },
                                  child: Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(15)),
                                    width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                    height: CustomStyle.getHeight(50),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "오더 등록",
                                      style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                    ),
                                  )
                              )
                            )
                        ])
                      )
                    )
                )
            );
          });
        });
  }

  Future<void> openRegOrderTemplateSheet(BuildContext context, String title) async {
    final template_list = List.empty(growable: true).obs;
    final selectItem = TemplateModel().obs;
    await getTemplateList(template_list.value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: title,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
            heightFactor: 0.7,
            child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                            child: Text(
                                title,
                                style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                            )
                          )
                        ),
                        Expanded(
                        flex:2,
                          child: InkWell(
                            onTap:() async {
                              await Navigator.of(context).push(PageAnimationTransition(page: TemplateManagePage(), pageAnimationType: LeftToRightTransition()));
                            },
                            child: Container(
                            margin: EdgeInsets.only(right: CustomStyle.getWidth(15)),
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(2),horizontal: CustomStyle.getWidth(15)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: renew_main_color2, width: 1.5)
                            ),
                            child: Text(
                                "관리",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w600),
                              )
                            )
                          )
                        )
                      ]),
                      templateListWidget(template_list,selectItem),
                      InkWell(
                          onTap: () async {
                            if(selectItem.value.templateId.isNull == true || selectItem.value.templateId?.isEmpty == true) {
                                  Util.toast("등록할 탬플릿을 선택해주세요.");
                            }else{
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.of(context).pop();
                                openStoEDateSheet(context,selectItem.value);
                              });
                            }
                          },
                          child: Center(
                              child: Obx(() => Container(
                                width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                height: CustomStyle.getHeight(50),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: selectItem.value.templateId.isNull == true || selectItem.value.templateId?.isEmpty == true ? light_gray24 : renew_main_color2),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "상/하차 날짜 선택",
                                  style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                ),
                              ))
                          )
                      )
                    ]
                )
            )
        );
      },
    );
  }

  Future<void> openCodeBottomSheet(BuildContext context, String title, String codeType, Function(String codeType,{CodeModel codeModel,CustUserModel custUserModel,int value}) callback) async {

    if (codeType == Const.ORDER_STATE_CD) {
      final tempCodemodel = CodeModel(code: categoryOrderCode.value ,codeName:  categoryOrderState.value).obs;
      List<CodeModel>? mCodeList = SP.getCodeList(codeType);
      mCodeList?.insert(0, CodeModel(code: "",codeName:  "오더전체"));

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: title,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return FractionallySizedBox(
              widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
              heightFactor: App().isTablet(context) ? mCodeList!.length > 16 ? 0.70 : mCodeList.length > 12 ? 0.6 : 0.5 :  mCodeList!.length > 16 ? 0.65 : mCodeList.length > 12 ? 0.55 : 0.45,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                            child: Text(
                                title,
                                style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                            )
                        ),
                        Expanded(
                            child: AnimationLimiter(
                                child: GridView.builder(
                                itemCount: mCodeList.length,
                                physics: const ScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                                  childAspectRatio: (1 / .5),
                                  mainAxisSpacing: 10, //수평 Padding
                                  crossAxisSpacing: 10, //수직 Padding
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: const Duration(milliseconds: 400),
                                      columnCount: 4,
                                      child: ScaleAnimation(
                                          child: FadeInAnimation(
                                              child: Obx(() =>  InkWell(
                                      onTap: () {
                                        tempCodemodel.value = CodeModel(code: mCodeList[index].code,codeName: mCodeList[index].codeName);
                                      },
                                      child: Container(
                                          height: CustomStyle.getHeight(70.0),
                                          decoration: BoxDecoration(
                                              color: tempCodemodel.value.code  == mCodeList[index].code ? renew_main_color2 : light_gray24,
                                              borderRadius: BorderRadius.circular(30)
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${mCodeList[index].codeName}",
                                              textAlign: TextAlign.center,
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize12, tempCodemodel.value.code  == mCodeList[index].code ? Colors.white: text_color_01,
                                                  font_weight: tempCodemodel.value.code  == mCodeList[index].code ? FontWeight.w800 : FontWeight.w600),
                                            ),
                                          )
                                      )
                                  )))));
                                }
                            ))
                        ),
                        InkWell(
                            onTap: () async {
                              callback(codeType,codeModel: tempCodemodel.value);
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.of(context).pop();
                              });
                            },
                            child: Center(
                                child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                  height: CustomStyle.getHeight(50),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "적용",
                                    style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                  ),
                                )
                            )
                        )
                      ]
                  )
              )
          );
        },
      );

    } else if (codeType == Const.DEPT) {
      final tempCodemodel = CodeModel(code: categoryDeptCode.value ,codeName:  categoryDeptState.value).obs;
      List<CodeModel>? mCodeList = SP.getCodeList(Const.DEPT);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: title,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return FractionallySizedBox(
              widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
              heightFactor: App().isTablet(context) ? mCodeList!.length > 16 ? 0.70 : mCodeList.length > 12 ? 0.6 : 0.5 :  mCodeList!.length > 16 ? 0.65 : mCodeList.length > 12 ? 0.55 : 0.45,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                            child: Text(
                                title,
                                style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                            )
                        ),
                        Expanded(
                            child: AnimationLimiter(
                                child: GridView.builder(
                                    itemCount: mCodeList.length,
                                    physics: const ScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                      childAspectRatio: (1 / .4),
                                      mainAxisSpacing: 10, //수평 Padding
                                      crossAxisSpacing: 10, //수직 Padding
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      return AnimationConfiguration.staggeredGrid(
                                          position: index,
                                          duration: const Duration(milliseconds: 400),
                                          columnCount: 3,
                                          child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                  child: Obx(() =>  InkWell(
                                                      onTap: () {
                                                        tempCodemodel.value = CodeModel(code: mCodeList[index].code,codeName: mCodeList[index].codeName);
                                                      },
                                                      child: Container(
                                                          height: CustomStyle.getHeight(70.0),
                                                          decoration: BoxDecoration(
                                                              color: tempCodemodel.value.code  == mCodeList[index].code ? renew_main_color2 : light_gray24,
                                                              borderRadius: BorderRadius.circular(30)
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "${mCodeList[index].codeName}",
                                                              textAlign: TextAlign.center,
                                                              style: CustomStyle.CustomFont(
                                                                  styleFontSize12, tempCodemodel.value.code  == mCodeList[index].code ? Colors.white: text_color_01,
                                                                  font_weight: tempCodemodel.value.code  == mCodeList[index].code ? FontWeight.w800 : FontWeight.w600),
                                                            ),
                                                          )
                                                      )
                                                  )))));
                                    }
                                ))
                        ),
                        InkWell(
                            onTap: () async {
                              callback(codeType,codeModel: tempCodemodel.value);
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.of(context).pop();
                              });
                            },
                            child: Center(
                                child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                  height: CustomStyle.getHeight(50),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "적용",
                                    style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                  ),
                                )
                            )
                        )
                      ]
                  )
              )
          );
        },
      );

    } else if(codeType == Const.RPA_STATE_CD) {

      final tempCodemodel = CodeModel(code: categoryRpaCode.value ,codeName: categoryRpaState.value).obs;
      List<CodeModel>? mCodeList = List.empty(growable: true);
      mCodeList?.insert(0, CodeModel(code: "",codeName:  "화망무관"));
      mCodeList?.insert(1, CodeModel(code: "W",codeName:  "화망배차전"));
      mCodeList?.insert(2, CodeModel(code: "F",codeName:  "배차확정"));

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: title,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return FractionallySizedBox(
              widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
              heightFactor: App().isTablet(context) ? mCodeList!.length > 16 ? 0.70 : mCodeList.length > 12 ? 0.6 : 0.5 :  mCodeList!.length > 16 ? 0.65 : mCodeList.length > 12 ? 0.55 : 0.45,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                            child: Text(
                                title,
                                style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                            )
                        ),
                        Expanded(
                            child: AnimationLimiter(
                                child: GridView.builder(
                                    itemCount: mCodeList.length,
                                    physics: const ScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                      childAspectRatio: (1 / .4),
                                      mainAxisSpacing: 10, //수평 Padding
                                      crossAxisSpacing: 10, //수직 Padding
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      return AnimationConfiguration.staggeredGrid(
                                          position: index,
                                          duration: const Duration(milliseconds: 400),
                                          columnCount: 4,
                                          child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                  child: Obx(() =>  InkWell(
                                                      onTap: () {
                                                        tempCodemodel.value = CodeModel(code: mCodeList[index].code,codeName: mCodeList[index].codeName);
                                                      },
                                                      child: Container(
                                                          height: CustomStyle.getHeight(70.0),
                                                          decoration: BoxDecoration(
                                                              color: tempCodemodel.value.code  == mCodeList[index].code ? renew_main_color2 : light_gray24,
                                                              borderRadius: BorderRadius.circular(30)
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "${mCodeList[index].codeName}",
                                                              textAlign: TextAlign.center,
                                                              style: CustomStyle.CustomFont(
                                                                  styleFontSize12, tempCodemodel.value.code  == mCodeList[index].code ? Colors.white: text_color_01,
                                                                  font_weight: tempCodemodel.value.code  == mCodeList[index].code ? FontWeight.w800 : FontWeight.w600),
                                                            ),
                                                          )
                                                      )
                                                  )))));
                                    }
                                ))
                        ),
                        InkWell(
                            onTap: () async {
                              callback(codeType,codeModel: tempCodemodel.value);
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.of(context).pop();
                              });
                            },
                            child: Center(
                                child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                  height: CustomStyle.getHeight(50),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "적용",
                                    style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                  ),
                                )
                            )
                        )
                      ]
                  )
              )
          );
        },
      );
    } else if(codeType == Const.STAFF_STATE_CD) {

      final tempStaffmodel = categoryStaffModel.value.obs;
      final mStaffList = custUserList;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        barrierLabel: title,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
            side: BorderSide(color: Color(0xffEDEEF0), width: 1)
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return FractionallySizedBox(
              widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
              heightFactor: mStaffList.length > 16 ? 0.50 : mStaffList.length > 12 ? 0.4 : 0.3,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                            child: Text(
                                title,
                                style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                            )
                        ),
                        Expanded(
                            child: AnimationLimiter(
                                child: GridView.builder(
                                itemCount: mStaffList.length,
                                physics: const ScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                                  childAspectRatio: (1 / .5),
                                  mainAxisSpacing: 10, //수평 Padding
                                  crossAxisSpacing: 10, //수직 Padding
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: const Duration(milliseconds: 400),
                                      columnCount: 4,
                                      child: ScaleAnimation(
                                          child: FadeInAnimation(
                                              child: Obx(() =>  InkWell(
                                      onTap: () {
                                        tempStaffmodel.value = mStaffList[index];
                                      },
                                      child: Container(
                                          height: CustomStyle.getHeight(70.0),
                                          decoration: BoxDecoration(
                                              color: (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? renew_main_color2 : light_gray24,
                                              borderRadius: BorderRadius.circular(30)
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${mStaffList[index].userName}",
                                              textAlign: TextAlign.center,
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize12, (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? Colors.white: text_color_01,
                                                  font_weight: (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? FontWeight.w800 : FontWeight.w600),
                                            ),
                                          )
                                      )
                                  )))));
                                }
                            ))
                        ),
                        InkWell(
                            onTap: (){
                              callback(codeType,custUserModel: tempStaffmodel.value);
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.of(context).pop();
                              });
                            },
                            child: Center(
                                child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                  height: CustomStyle.getHeight(50),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "적용",
                                    style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                  ),
                                )
                            )
                        )
                      ]
                  )
              )
          );
        },
      );
    }
  }

  Future<void> openRpaModiDialog(BuildContext context, OrderModel item, String? linkType,int itemIndex, {String? flag}) async {

    final SelectNumber = "0".obs;
    if(flag != "D") {
      SelectNumber.value = Const.CALL_24_KEY_NAME == linkType ? item.call24Charge ?? "0" : Const.HWA_MULL_KEY_NAME == linkType ? item.manCharge ?? "0" : item.oneCharge ?? "0";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
            heightFactor: 0.70,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
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
                                "${linkType == "03" ? "24시콜" : linkType == "21" ? "화물맨" : linkType == "18" ? "원콜" : ""}\n금액을 ${flag == "D" ? "등록" : "변경"}해주세요.",
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    if (SelectNumber.value == '0') {
                                      return;
                                    } else {
                                      SelectNumber.value = '${SelectNumber.value}0';
                                    }
                                    return;
                                  case 11:
                                  //remove
                                    if (SelectNumber.value.length == 1) {
                                      SelectNumber.value = '0';
                                    } else {
                                      SelectNumber.value = SelectNumber.value.substring(0, SelectNumber.value.length - 1);
                                    }
                                    return;

                                  default:
                                    if(SelectNumber.value.length >= 8) return;
                                    if (SelectNumber.value == '0') {
                                      SelectNumber.value = '${index + 1}';
                                    } else {
                                      SelectNumber.value = '${SelectNumber.value}${index + 1}';
                                    }
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
                                            style: const TextStyle(
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
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: rpa_btn_regist,
                        ),
                        child: TextButton(
                            onPressed: () async {
                              if(SelectNumber.value.isEmpty == true) SelectNumber.value = "0";
                              var cd = "";
                              if(Const.CALL_24_KEY_NAME == linkType) {
                                cd = "24Cargo";
                              }else if(Const.ONE_CALL_KEY_NAME == linkType) {
                                cd = "oneCargo";
                              }else if(Const.HWA_MULL_KEY_NAME == linkType) {
                                cd = "manCargo";
                              }else{
                                cd = "";
                              }
                              if(int.parse(SelectNumber.value) >= 20000){
                                if(flag == "D") {
                                  await registRpa(item,linkType,SelectNumber.value,itemIndex);
                                }else {
                                  await modLink("N", item, SelectNumber.value, cd, "U",itemIndex);
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

  Future<void> openSelectRegOrderDialog(BuildContext context) async {

    final selectRegOrder = "01".obs;
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: "어떤 방법으로\n오더를 등록하시겠어요?",
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
            heightFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height > 1000 ? 0.9 : 0.7,
            child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                padding: EdgeInsets.only(right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(10)),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                          child: Text(
                              "어떤 방법으로\n오더를 등록하시겠어요?",
                              style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w800)
                          )
                      ),
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                           children: [
                             Obx(() => InkWell(
                               onTap: (){
                                 selectRegOrder.value = "01";
                               },
                               child: Container(
                                  width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.4,
                                  height: CustomStyle.getHeight(180),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: selectRegOrder.value == "01" ? renew_main_color2 : const Color(0xffD9D9D9),width: 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                        child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xffD9D9D9),width: 1),
                                            borderRadius: const BorderRadius.all(Radius.circular(5))
                                        ),
                                        child: Image.asset(
                                          "assets/image/ic_smart_order.png",
                                          width: CustomStyle.getWidth(25.0),
                                          height: CustomStyle.getHeight(25.0),
                                          color: selectRegOrder.value == "01" ? renew_main_color2 : const Color(0xffC8C8C8),
                                        )
                                      )
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                          child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      selectRegOrder.value == "01" ?
                                                      Container(
                                                        margin: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                                                        child: const Icon(
                                                            Icons.check_circle_outline_rounded,
                                                          color: renew_main_color2,
                                                          size: 18,
                                                        )
                                                      ) : const SizedBox(),
                                                      Text(
                                                          "스마트오더",
                                                          style: CustomStyle.CustomFont(styleFontSize18, selectRegOrder.value == "01" ? renew_main_color2 : Colors.black,font_weight: FontWeight.w700)
                                                      ),
                                                    ]
                                                  ),
                                                  Text(
                                                      "등록된 탬플릿으로\n신속한 등록을 해요",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(styleFontSize13,selectRegOrder.value == "01" ? renew_main_color2 :  Colors.black,font_weight: FontWeight.w400)
                                                  ),
                                                ],
                                          )
                                      )
                                    )
                                    ],
                                  )
                                )
                             )) ,
                             Obx(() => InkWell(
                               onTap: (){
                                 selectRegOrder.value = "02";
                               },
                               child: Container(
                                   width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.4,
                                   height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height > 1000 ? CustomStyle.getHeight(250) : CustomStyle.getHeight(180),
                                   padding: const EdgeInsets.all(10),
                                   decoration: BoxDecoration(
                                       border: Border.all(color: selectRegOrder.value == "02" ? renew_main_color2 : const Color(0xffD9D9D9),width: 1),
                                       borderRadius: const BorderRadius.all(Radius.circular(10))
                                   ),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.stretch,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Expanded(
                                           flex: 1,
                                           child: Container(
                                               padding: const EdgeInsets.all(10),
                                               decoration: BoxDecoration(
                                                   border: Border.all(color: const Color(0xffD9D9D9),width: 1),
                                                   borderRadius: const BorderRadius.all(Radius.circular(5))
                                               ),
                                               child: Image.asset(
                                                 "assets/image/ic_hwa.png",
                                                 width: CustomStyle.getWidth(25.0),
                                                 height: CustomStyle.getHeight(25.0),
                                                 color: selectRegOrder.value == "02" ? renew_main_color2 : const Color(0xffC8C8C8),
                                               )
                                           )
                                       ),
                                       Expanded(
                                           flex: 1,
                                           child: Container(
                                               alignment: Alignment.center,
                                               padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                               child: Column(
                                                 children: [
                                                   Row(
                                                       crossAxisAlignment: CrossAxisAlignment.center,
                                                       mainAxisAlignment: MainAxisAlignment.center,
                                                       children: [
                                                         selectRegOrder.value == "02" ?
                                                         Container(
                                                             margin: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                                                             child: const Icon(
                                                               Icons.check_circle_outline_rounded,
                                                               color: renew_main_color2,
                                                               size: 18,
                                                             )
                                                         ) : const SizedBox(),
                                                         Text(
                                                             "일반오더",
                                                             style: CustomStyle.CustomFont(styleFontSize18, selectRegOrder.value == "02" ? renew_main_color2 : Colors.black,font_weight: FontWeight.w700)
                                                         ),
                                                       ]
                                                   ),
                                                   Text(
                                                       "상세한 오더 등록이\n가능해요",
                                                       textAlign: TextAlign.center,
                                                       style: CustomStyle.CustomFont(styleFontSize13, selectRegOrder.value == "02" ? renew_main_color2 : Colors.black,font_weight: FontWeight.w400)
                                                   ),
                                                 ],
                                               )
                                           )
                                       )
                                     ],
                                   )
                                )
                              )),
                            ]
                       ),
                       Container(
                         margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(20)),
                         child: AnimationLimiter(
                             child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start ,
                             mainAxisAlignment: MainAxisAlignment.center,
                              children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 600),
                              childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                              child: widget,
                              ),
                              ),
                           children:[
                             Container(
                               margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
                               child:Text(
                                 "이런 분들께 추천해요",
                                 style:CustomStyle.CustomFont(styleFontSize20, Colors.black,font_weight: FontWeight.w500)
                               )
                             ),
                             Container(
                                 margin: EdgeInsets.only(bottom: CustomStyle.getHeight(6)),
                                 child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.start,
                                children :[
                                  Container(
                                     margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                      child: Image.asset(
                                        "assets/image/ic_info1.png",
                                        width: CustomStyle.getWidth(15.0),
                                        height: CustomStyle.getHeight(15.0),
                                      )
                                  ),
                                  Obx(() =>
                                    Text(
                                        selectRegOrder.value == "01" ? "많은 정보 입력은 귀찮아요" : "디테일한 오더 등록이 필요해요",
                                        style:CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                      )
                                  )
                                  ]
                                )
                             ),
                             Container(
                                 margin: EdgeInsets.only(bottom: CustomStyle.getHeight(6)),
                                 child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     children :[
                                       Container(
                                           margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                           child: Image.asset(
                                             "assets/image/ic_info2.png",
                                             width: CustomStyle.getWidth(15.0),
                                             height: CustomStyle.getHeight(15.0),
                                           )
                                       ),
                                       Obx(() =>
                                         Text(
                                             selectRegOrder.value == "01"? "중요하지 않은 조건은, 알아서 넣어주세요" : "내 손으로 차근차근 정보를 입력할래요",
                                             style:CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                         )
                                       ),
                                     ]
                                 )
                             ),
                             Container(
                                 margin: EdgeInsets.only(bottom: CustomStyle.getHeight(6)),
                                 child: Obx(() => Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     children :[
                                       Container(
                                           margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                           child: Image.asset(
                                             "assets/image/ic_info3.png",
                                             width: CustomStyle.getWidth(15.0),
                                             height: CustomStyle.getHeight(15.0),
                                           )
                                       ),
                                       selectRegOrder.value == "01" ?
                                        Text(
                                          "최소한의 조건",
                                            style:CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w500)
                                        ) : Text(
                                           "신속한 등록",
                                           style:CustomStyle.CustomFont(styleFontSize14, renew_main_color2,font_weight: FontWeight.w500)
                                       ),
                                       selectRegOrder.value == "01" ?
                                       Text(
                                           "으로 빠르게 오더를 등록하고 싶어요",
                                           style:CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                       ) : Text(
                                           "보다는 꼼꼼한 오더 등록을하고 싶어요",
                                           style:CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w400)
                                       )
                                     ]
                                 ))
                             )
                           ]
                         )))
                       ),
                       Obx(() => InkWell(
                          onTap: () async {
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if(selectRegOrder.value == "") {
                                Util.toast("오더 방법을 선택해주세요.");
                              }else{
                                Navigator.of(context).pop();
                                goToRegOrderPage(selectRegOrder.value);
                              }
                            });
                          },
                          child: Center(
                              child: Container(
                                width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                height: CustomStyle.getHeight(50),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: selectRegOrder.value == "" ? const Color(0xffD9D9D9) : renew_main_color2),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "다음",
                                  style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                ),
                              )
                          )
                      ))
                    ]
                )
            )
        );
      },
    );
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

  Future<void> registRpa(OrderModel item, String? linkCd, String? rpaPay,int itemIndex) async {
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
        "금액: $rpaPay원\n$text",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await modLink("N",item, rpaPay, cd,"D",itemIndex);
        }
    );

  }

  Future<void> cancelRpa(String? orderId, OrderLinkCurrentModel data,int itemIndex) async {
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
        text,
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await cancelLink(orderId, allocCharge, cd, true,itemIndex);
        }
    );
  }

  Future<void> cancelLink(String? orderId, String? rpaPay,String? linkCd, bool flag,int itemIndex) async {

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
        ReturnMap response = DioService.dioResponse(it);
        logger.d("cancelLink() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          if (response.resultMap?["result"] == true) {
            if(flag == true) {
              var linkName = '';
              if(linkCd == Const.CALL_24_KEY_NAME) {
                linkName = "24시콜";
              } else if(linkCd == Const.HWA_MULL_KEY_NAME) linkName = "화물맨";
              else if(linkCd == Const.ONE_CALL_KEY_NAME) linkName = "원콜";
              Util.snackbar(context, "$linkName 지불운임이 취소되었습니다.");
              //await refresh();
            }

          } else {
            openOkBox(context, "${response.resultMap?["msg"]}",
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

  Future<void> modLink(String allocChargeYn,OrderModel item,String rpaPay, String linkCd, String flag, int itemIndex) async {
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
        ReturnMap response = DioService.dioResponse(it);
        logger.d("modLink() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          if (response.resultMap?["result"] == true) {
            Navigator.of(context).pop(false);
            var linkName = '';
            if(linkCd == Const.CALL_24_KEY_NAME) {
              linkName = "24시콜";
            } else if(linkCd == Const.HWA_MULL_KEY_NAME) linkName = "화물맨";
            else if(linkCd == Const.ONE_CALL_KEY_NAME) linkName = "원콜";

            Util.snackbar(context, "$linkName 지불운임이 ${flag == "D" ? "등록" : "수정"}되었습니다.");
            if(flag == "D") { // D: 등록일 경우 리스트 최상단 이동
              //await refresh();
            }else{ // U: 수정일 경우 현재 리스트 위치 이동
              setState(() {
                lastPositionItem.value = itemIndex;
              });
            }
          } else {
            openOkBox(context, "${response.resultMap?["msg"]}",
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

  Future<void> openRpaInfoDialog(BuildContext context,OrderModel item,String allocType, String? linkType,int itemIndex,{OrderLinkCurrentModel? link_model})  async {
    // alloc_type: 01 = 배차 확정된 상태, 02 = 배차 미확정 상태

    Map<String,dynamic> currendLink = await currentLink(item.orderId, linkType);

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
                                      item.allocState == "00" ? "${currendLink["currentItem"].carNum}" : "${item.carNum}",
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
                                      "${currendLink["currentItem"].carType}",
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
                                      "${currendLink["currentItem"].carTon}",
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
                                      item.allocState == "00" ? currendLink["currentItem"].driverName??"" : item.driverName??"",
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
                                      item.allocState == "00" ? Util.makePhoneNumber(currendLink["currentItem"].driverTel??"") : Util.makePhoneNumber(item.driverTel??""),
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
                            allocType == "02" ?
                            InkWell(
                              onTap: () async {
                                await carConfirmRpa(currendLink,itemIndex);
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

  Future<Map<String,dynamic>> currentLink(String? orderId, String? linkType) async {
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
        ReturnMap response = DioService.dioResponse(it);
        logger.d("main currentLink() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          if (response.resultMap?["result"] == true) {
            if(response.resultMap?["rpa"] != null) {
              rpa = UserRpaModel(
                  link24Id: response.resultMap?["rpa"]["link24Id"],
                  link24Pass: response.resultMap?["rpa"]["link24Pass"],
                  man24Id: response.resultMap?["rpa"]["man24Id"],
                  man24Pass: response.resultMap?["rpa"]["man24Pass"],
                  one24Id: response.resultMap?["rpa"]["one24Id"],
                  one24Pass: response.resultMap?["rpa"]["one24Pass"]
              );
            }
            userRpaModel.value = rpa;
            if (response.resultMap?["data"] != null) {
              var mList = response.resultMap?["data"] as List;
              if(mList.isNotEmpty) {
                List<OrderLinkCurrentModel> itemsList = mList.map((i) => OrderLinkCurrentModel.fromJSON(i)).toList();
                for (var list in itemsList) {
                  if (list.allocCd?.isNotEmpty == true &&
                      list.allocCd != null && list.linkCd == linkType) {
                    returnModel = list;
                  }
                }
                result = {"currentList": itemsList, "currentItem": returnModel};
              }
            }
          } else {
            openOkBox(context, "${response.resultMap?["msg"]}",
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

  Future<void> carConfirmRpa(Map<String,dynamic> dataMap,int itemIndex) async {
    String textHeader = "${dataMap["currentItem"].carNum}\t\t${dataMap["currentItem"].carType}\t\t${dataMap["currentItem"].carTon}";
    String textSub = "${dataMap["currentItem"].driverName}\t\t${Util.makePhoneNumber(dataMap["currentItem"].driverTel)}";
    String text = "배차 확정 하시겠습니까?";
    String textEtc="(나머지 정보망전송은 취소됩니다)";

    openCommonConfirmBox(
        context,
        "$textHeader\n$textSub\n$text\n$textEtc",
        Strings.of(context)?.get("no") ?? "아니오_",
        Strings.of(context)?.get("yes") ?? "예_",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);

          for(var value in dataMap["currentList"]) {
            if(value.linkCd == Const.CALL_24_KEY_NAME) {
              if(value.linkCd == dataMap["currentItem"].linkCd) {
                await confirmLink(dataMap["currentItem"]);
              }else{
                await cancelLink(dataMap["currentItem"].orderId, value.allocCharge, "24Cargo", false,itemIndex);
              }
            }
            if(value.linkCd == Const.ONE_CALL_KEY_NAME) {
              if(value.linkCd == dataMap["currentItem"].linkCd) {
                await confirmLink(dataMap["currentItem"]);
              }else{
                await cancelLink(dataMap["currentItem"].orderId, value.allocCharge, "oneCargo", false,itemIndex);
              }
            }
            if(value.linkCd == Const.HWA_MULL_KEY_NAME) {
              if(value.linkCd == dataMap["currentItem"].linkCd) {
                await confirmLink(dataMap["currentItem"]);
              }else{
                await cancelLink(dataMap["currentItem"].orderId, value.allocCharge, "manCargo", false,itemIndex);
              }
            }
          }
          setState(() {
            lastPositionItem.value = itemIndex;
          });
        }
    );
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
        ReturnMap response = DioService.dioResponse(it);
        logger.d("confirmLink() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          if (response.resultMap?["result"] == true) {


          } else {
            openOkBox(context, "${response.resultMap?["msg"]}",
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

  void selectItem(String? codeType,{CodeModel? codeModel, CustUserModel? custUserModel,value = 0}) {
      switch(codeType) {
        case 'ORDER_STATE_CD':
          categoryOrderCode.value = codeModel?.code??"";
          categoryOrderState.value = codeModel?.codeName??"-";
          page.value = 1;
          scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
        case 'DEPT' :
            categoryDeptCode.value = codeModel?.code??"";
            categoryDeptState.value = codeModel?.codeName??"-";
            page.value = 1;
            scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
        case 'RPA_STATE_CD':
          categoryRpaCode.value = codeModel?.code??"";
          categoryRpaState.value = codeModel?.codeName??"-";
          page.value = 1;
          scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
        case 'STAFF_STATE_CD':
          categoryStaffModel.value = custUserModel ?? CustUserModel(userId: "",userName: "담당자전체");
          page.value = 1;
          scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);
          break;
      }
  }

  Future<void> openFilterBottomSheet(BuildContext context, String title, Function(String codeType ,{CodeModel? codeModel,CustUserModel custUserModel,int value}) callback) async {
    final tempSearchColumn = select_value.value.code == null || select_value.value.code?.isEmpty == true ? dropDownList![0].obs : select_value.value.obs; // 오더 검색 카테고리
    searchOrderController.text = searchValue.value; // 오더 검색창
    final tempStatecode = CodeModel(code: categoryOrderCode.value ,codeName:  categoryOrderState.value).obs; // 오더 상태
    List<CodeModel>? mOrderList = SP.getCodeList(Const.ORDER_STATE_CD);
    mOrderList?.insert(0, CodeModel(code: "",codeName:  "오더전체"));
    final tempDeptStatecode = CodeModel(code: categoryDeptCode.value ,codeName:  categoryDeptState.value).obs; // 부서 검색
    List<CodeModel>? mDeptList = SP.getCodeList(Const.DEPT);
    final tempRpamodel = CodeModel(code: categoryRpaCode.value ,codeName: categoryRpaState.value).obs;
    List<CodeModel>? mRpaList = List.empty(growable: true);
    mRpaList?.insert(0, CodeModel(code: "",codeName:  "화망무관"));
    mRpaList?.insert(1, CodeModel(code: "W",codeName:  "화망배차전"));
    mRpaList?.insert(2, CodeModel(code: "F",codeName:  "배차확정"));
    final tempStaffmodel = categoryStaffModel.value.obs;
    final mStaffList = custUserList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: title,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
            widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
            heightFactor: 0.9,
            child: SingleChildScrollView(
                child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                      margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children :[
                                  Image.asset(
                                    "assets/image/ic_filter.png",
                                    width: CustomStyle.getWidth(22.0),
                                    height: CustomStyle.getHeight(22.0),
                                    color: Colors.black,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                      child: Text(
                                          title,
                                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black, font_weight: FontWeight.w500)
                                      )
                                  ),
                                ]
                              ),

                              InkWell(
                                  onTap: () async {
                                    var result = await searchValidation();
                                    if(result) {
                                      Future.delayed(
                                          const Duration(milliseconds: 300), () {
                                        // 오더 검색
                                        select_value.value = tempSearchColumn.value; // 오더 검색 카테고리
                                        searchValue.value = searchOrderController.text; // 검색Field

                                        // 부서 검색
                                        categoryDeptCode.value = tempDeptStatecode.value.code??"";
                                        categoryDeptState.value = tempDeptStatecode.value.codeName??"-";

                                        //오더 상태
                                        categoryOrderCode.value = tempStatecode.value.code??""; // 오더 상태 Code
                                        categoryOrderState.value = tempStatecode.value.codeName??"-"; // 오더 상태 Name

                                        // 정보망상태
                                        categoryRpaCode.value = tempRpamodel.value.code??"";
                                        categoryRpaState.value = tempRpamodel.value.codeName??"";

                                        //담당자 선택
                                        categoryStaffModel.value = tempStaffmodel.value;

                                        page.value = 1;
                                        scrollController.animateTo(0, duration: const Duration(milliseconds: 1500), curve: Curves.ease);

                                        Navigator.of(context).pop();
                                      });
                                    }else{
                                      Util.toast("검색어를 2글자 이상 입력해주세요.");
                                    }
                                  },
                                  child: Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: renew_main_color2),
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(15.w)),
                                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          "적용",
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                        ),
                                      )
                                  )
                              )
                            ]
                          )
                      ),
                      CustomStyle.getDivider2(),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children :[
                                Text(
                                  "오더 검색",
                                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                                    child: AnimationLimiter(
                                        child: GridView.builder(
                                        itemCount: dropDownList?.length,
                                        physics: const ScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                                          childAspectRatio: (1 / .4),
                                          mainAxisSpacing: 10, //수평 Padding
                                          crossAxisSpacing: 10, //수직 Padding
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                              position: index,
                                              duration: const Duration(milliseconds: 400),
                                              columnCount: 4,
                                              child: ScaleAnimation(
                                                  child: FadeInAnimation(
                                                      child: Obx(() =>  InkWell(
                                              onTap: () {
                                                tempSearchColumn.value = CodeModel(code: dropDownList?[index].code,codeName: dropDownList?[index].codeName);
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: tempSearchColumn.value.code  == dropDownList?[index].code ? renew_main_color2 : light_gray24,
                                                      borderRadius: BorderRadius.circular(30)
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${dropDownList?[index].codeName}",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(
                                                          styleFontSize12, tempSearchColumn.value.code  == dropDownList?[index].code ? Colors.white: text_color_01,
                                                          font_weight: tempSearchColumn.value.code  == dropDownList?[index].code ? FontWeight.w800 : FontWeight.w600),
                                                    ),
                                                  )
                                              )
                                          )))));
                                        }
                                    ))
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
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
                                CustomStyle.getDivider2()
                              ]
                          )
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children :[
                           Text(
                                "오더 상태",
                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                           ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                              child: AnimationLimiter(
                                  child: GridView.builder(
                                  itemCount: mOrderList?.length,
                                  physics: const ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                                    childAspectRatio: (1 / .4),
                                    mainAxisSpacing: 10, //수평 Padding
                                    crossAxisSpacing: 10, //수직 Padding
                                  ),
                                  itemBuilder: (BuildContext context, int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                        position: index,
                                        duration: const Duration(milliseconds: 400),
                                        columnCount: 4,
                                        child: ScaleAnimation(
                                            child: FadeInAnimation(
                                            child: Obx(() =>  InkWell(
                                        onTap: () {
                                          tempStatecode.value = CodeModel(code: mOrderList?[index].code,codeName: mOrderList?[index].codeName);
                                        },
                                        child: Container(
                                            height: CustomStyle.getHeight(70.0),
                                            decoration: BoxDecoration(
                                                color: tempStatecode.value.code  == mOrderList?[index].code ? renew_main_color2 : light_gray24,
                                                borderRadius: BorderRadius.circular(30)
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${mOrderList?[index].codeName}",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(
                                                    styleFontSize12, tempStatecode.value.code  == mOrderList?[index].code ? Colors.white: text_color_01,
                                                    font_weight: tempStatecode.value.code  == mOrderList?[index].code ? FontWeight.w800 : FontWeight.w600),
                                              ),
                                            )
                                        )
                                    )))));
                                  }
                              ))
                            ),
                            CustomStyle.getDivider2()
                          ]
                        )
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children :[
                                Text(
                                  "부서 검색",
                                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                    child: AnimationLimiter(
                                        child: GridView.builder(
                                            itemCount: mDeptList?.length,
                                            physics: const ScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                              childAspectRatio: (1 / .3),
                                              mainAxisSpacing: 10, //수평 Padding
                                              crossAxisSpacing: 10, //수직 Padding
                                            ),
                                            itemBuilder: (BuildContext context, int index) {
                                              return AnimationConfiguration.staggeredGrid(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 400),
                                                  columnCount: 4,
                                                  child: ScaleAnimation(
                                                      child: FadeInAnimation(
                                                          child: Obx(() =>  InkWell(
                                                              onTap: () {
                                                                tempDeptStatecode.value = CodeModel(code: mDeptList?[index].code,codeName: mDeptList?[index].codeName);
                                                              },
                                                              child: Container(
                                                                  height: CustomStyle.getHeight(70.0),
                                                                  decoration: BoxDecoration(
                                                                      color: tempDeptStatecode.value.code  == mDeptList?[index].code ? renew_main_color2 : light_gray24,
                                                                      borderRadius: BorderRadius.circular(30)
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "${mDeptList?[index].codeName}",
                                                                      textAlign: TextAlign.center,
                                                                      style: CustomStyle.CustomFont(
                                                                          styleFontSize12, tempDeptStatecode.value.code  == mDeptList?[index].code ? Colors.white: text_color_01,
                                                                          font_weight: tempDeptStatecode.value.code  == mDeptList?[index].code ? FontWeight.w800 : FontWeight.w600),
                                                                    ),
                                                                  )
                                                              )
                                                          )))));
                                            }
                                        ))
                                ),
                                CustomStyle.getDivider2()
                              ]
                          )
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children :[
                                Text(
                                  "정보망 상태",
                                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                    child: AnimationLimiter(
                                        child: GridView.builder(
                                        itemCount: mRpaList?.length,
                                        physics: const ScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                                          childAspectRatio: (1 / .3),
                                          mainAxisSpacing: 10, //수평 Padding
                                          crossAxisSpacing: 10, //수직 Padding
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                              position: index,
                                              duration: const Duration(milliseconds: 400),
                                              columnCount: 4,
                                              child: ScaleAnimation(
                                                  child: FadeInAnimation(
                                                  child: Obx(() =>  InkWell(
                                              onTap: () {
                                                tempRpamodel.value = CodeModel(code: mRpaList?[index].code,codeName: mRpaList?[index].codeName);
                                              },
                                              child: Container(
                                                  height: CustomStyle.getHeight(70.0),
                                                  decoration: BoxDecoration(
                                                      color: tempRpamodel.value.code  == mRpaList?[index].code ? renew_main_color2 : light_gray24,
                                                      borderRadius: BorderRadius.circular(30)
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${mRpaList?[index].codeName}",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(
                                                          styleFontSize12, tempRpamodel.value.code  == mRpaList?[index].code ? Colors.white: text_color_01,
                                                          font_weight: tempRpamodel.value.code  == mRpaList?[index].code ? FontWeight.w800 : FontWeight.w600),
                                                    ),
                                                  )
                                              )
                                          )))));
                                        }
                                    ))
                                ),
                                CustomStyle.getDivider2()
                              ]
                          )
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children :[
                                Text(
                                  "담당자 선택",
                                  style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500),
                                ),
                                Container(
                                    height:CustomStyle.getHeight(140),
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                    child: AnimationLimiter(
                                        child: GridView.builder(
                                        itemCount: mStaffList.length,
                                        physics: const ScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                                          childAspectRatio: (1 / .4),
                                          mainAxisSpacing: 10, //수평 Padding
                                          crossAxisSpacing: 10, //수직 Padding
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                              position: index,
                                              duration: const Duration(milliseconds: 400),
                                              columnCount: 4,
                                              child: ScaleAnimation(
                                                  child: FadeInAnimation(
                                                  child: Obx(() =>  InkWell(
                                              onTap: () {
                                                  tempStaffmodel.value = mStaffList[index];
                                              },
                                              child: Container(
                                                  height: CustomStyle.getHeight(70.0),
                                                  decoration: BoxDecoration(
                                                      color: (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? renew_main_color2 : light_gray24,
                                                      borderRadius: BorderRadius.circular(30)
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${mStaffList[index].userName}",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(
                                                          styleFontSize12, (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? Colors.white: text_color_01,
                                                          font_weight: (tempStaffmodel.value.mobile  == mStaffList[index].mobile) && (tempStaffmodel.value.userName  == mStaffList[index].userName) ? FontWeight.w800 : FontWeight.w600),
                                                    ),
                                                  )
                                              )
                                          )))));
                                        }
                                    ))
                                ),
                                CustomStyle.getDivider2()
                              ]
                          )
                      ),
                    ]
                )
              )
            )
        );
      },
    );
  }

  Future<void> refresh() async {
    await getCustUser();
    setState(() {
      page.value = 1;
      lastPositionItem.value = 0;
    });
  }

  Future<void> getCustUser() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCustUser2(
        user.authorization,
        user.custId,
        user.deptId
    ).then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getCustUser() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if(response.resultMap?["result"] == true) {
          if(response.resultMap?["data"] != null) {
            var list = response.resultMap?["data"] as List;
            if(custUserList.isNotEmpty) custUserList.clear();
              List<CustUserModel> itemsList = list.map((i) => CustUserModel.fromJSON(i)).toList();
              custUserList.insert(0, CustUserModel(userId: user.userId,userName:  "내 담당"));
              custUserList.addAll(itemsList);
              custUserList.insert(custUserList.length, CustUserModel(userId: "",userName:  "담당자전체"));
          }else{
            custUserList.value = List.empty(growable: true);
            custUserList.insert(0, CustUserModel(userId: user.userId,userName:  "내 담당"));
            custUserList.insert(1, CustUserModel(userId: "",userName:  "담당자전체"));
          }
        }else{
          openOkBox(context,"${response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
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

  Future<bool> searchValidation() async {
    var mSearchValue = searchOrderController.text.trim();
    if(mSearchValue.length == 1) {
      return false;
    }
    return true;
  }

  Future<void> goToOrderDetail(OrderModel item,int index) async {
    var user = await controller.getUserInfo();
    await FirebaseAnalytics.instance.logEvent(
      name: Platform.isAndroid ? "inquire_order_aos" : "inquire_order_ios",
      parameters: {
        "user_id": user.userId??"",
        "user_custId" : user.custId??"",
        "user_deptId": user.deptId??"",
        "orderId" : item.orderId??"",
      },
    );

    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RenewOrderDetailPage(order_vo: item), pageAnimationType: LeftToRightTransition()));

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results,item_index: index);
      }
    }
    setState(() {
      lastPositionItem.value = index;
    });
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
        "오더가 등록되었습니다.\n바로 이어서 배차를 진행하시겠습니까?",
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
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getOrderDetail() _response -> ${response.status} | ${response.resultMap}");
      if(response.status == "200") {
        if(response.resultMap?["result"] == true) {
          if (response.resultMap?["data"] != null) {
            var list = response.resultMap?["data"] as List;
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
            OrderModel data = itemsList[0];
            await goToTransInfo(data);
          }
        }else{
          openOkBox(context,"${response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
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
    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewOrderTransInfoPage(order_vo: data)));
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  int tempChargeTotal(String? chargeFlag,TemplateModel mData) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(mData.sellCharge ?? "0") +
          int.parse(mData.sellWayPointCharge ?? "0") +
          int.parse(mData.sellStayCharge ?? "0") +
          int.parse(mData.sellHandWorkCharge ?? "0") +
          int.parse(mData.sellRoundCharge ?? "0") +
          int.parse(mData.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(mData.buyCharge ?? "0") +
          int.parse(mData.wayPointCharge ?? "0") +
          int.parse(mData.stayCharge ?? "0") +
          int.parse(mData.handWorkCharge ?? "0") +
          int.parse(mData.roundCharge ?? "0") +
          int.parse(mData.otherAddCharge ?? "0") -
          int.parse(mData.sellFee ?? "0");
    }
    return total;
  }

  int ordChargeTotal(String? chargeFlag,OrderModel mData) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(mData.sellCharge ?? "0") +
          int.parse(mData.sellWayPointCharge ?? "0") +
          int.parse(mData.sellStayCharge ?? "0") +
          int.parse(mData.sellHandWorkCharge ?? "0") +
          int.parse(mData.sellRoundCharge ?? "0") +
          int.parse(mData.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(mData.buyCharge ?? "0") +
          int.parse(mData.wayPointCharge ?? "0") +
          int.parse(mData.stayCharge ?? "0") +
          int.parse(mData.handWorkCharge ?? "0") +
          int.parse(mData.roundCharge ?? "0") +
          int.parse(mData.otherAddCharge ?? "0") -
          int.parse(mData.sellFee ?? "0");
    }
    return total;
  }


  String validation(TemplateModel templateItem){
    var valiType = "";
    if(templateItem.sellCustId?.isEmpty == true || templateItem.sellCustId.isNull) {
      valiType = "거래처명";
    }else if(templateItem.sellDeptId?.isEmpty == true || templateItem.sellDeptId.isNull) {
      valiType = "담당부서";
    }else if(templateItem.sDate?.isEmpty == true || templateItem.sDate.isNull) {
      valiType = "상차일";
    }else if(templateItem.sAddr?.isEmpty == true || templateItem.sAddr.isNull){
      valiType = "상차지 주소";
    }else if(templateItem.eDate?.isEmpty == true || templateItem.eDate.isNull) {
      valiType = "하차일";
    }else if(templateItem.eAddr?.isEmpty == true || templateItem.eAddr.isNull){
      valiType = "하차지 주소";
    }else if(templateItem.carTypeCode?.isEmpty == true || templateItem.carTypeCode.isNull) {
      valiType = "차종";
    }else if(templateItem.carTonCode?.isEmpty == true || templateItem.carTonCode.isNull) {
      valiType = "톤수";
    }else if(templateItem.goodsName?.isEmpty == true || templateItem.goodsName.isNull) {
      valiType = "화물정보";
    }else if(templateItem.buyCharge?.isEmpty == true || templateItem.buyCharge.isNull) {
      valiType = "청구운임";
    }
    return valiType;
  }

  int parseIntDate(String date) {
    return int.parse(Util.mergeDate(date));
  }

  int parseIntDate2(String date) {
    return int.parse(Util.mergeAllDate(date));
  }

  int parseIntTime(String time){
    return int.parse(Util.mergeTime(time));
  }

  Future<void> getPointResult() async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    await DioService.dioClient(header: true).getTmsPointResult(user.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getPointResult() _response -> ${_response.status} // ${_response.resultMap}");
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

  Future<void> getTemplateList(List mList) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTemplateList(
        user.authorization
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getTemplateList() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              if(mList.isNotEmpty) mList.clear();
              if(list.length > 0){
                List<TemplateModel> itemsList = list.map((i) => TemplateModel.fromJSON(i)).toList();
                mList.addAll(itemsList);
              }

            }else{
              mList = List.empty(growable: true);
            }
          } else {
            mList = List.empty(growable: true);
          }
        }
      }catch(e) {
        print("getTemplateList() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTemplateList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getTemplateList() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getTemplateStopList(TemplateModel? tModel) async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTemplateStopList(user.authorization, tModel?.templateId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getTemplateStopList() Regist _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<TemplateStopPointModel> itemsList = list.map((i) => TemplateStopPointModel.fromJSON(i)).toList();
            if (itemsList.length != 0) {
              tModel?.templateStopList?.addAll(itemsList);
            }
          }
        } else {
          openOkBox(context, "${_response.resultMap?["msg"]}",
              Strings.of(context)?.get("confirm") ?? "Error!!", () {
                Navigator.of(context).pop(false);
              });
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTemplateStopList() RegVersion Error => ${res?.statusCode} // ${res
              ?.statusMessage}");
          break;
        default:
          print("getTemplateStopList() RegVersion getOrder Default => ");
          break;
      }
    });
  }

  Future<void> getDeptList() async {
    Logger logger = Logger();
    await pr?.show();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getDeptList(
        mUser.value.authorization,
        user.custId
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getDeptList() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          var list = response.resultMap?["data"] as List;
          List<DeptModel> itemsList = list.map((i) => DeptModel.fromJSON(i)).toList();
          if(deptList.isNotEmpty) deptList.clear();
          deptList.addAll(itemsList);

          List<CodeModel> codeList = List.empty(growable: true);
          codeList.add(CodeModel(code: "",codeName: "부서전체"));
          for(var data in deptList) {
            codeList.add(CodeModel(code: data.deptId, codeName: data.deptName));
          }
          var mapList = ({
            "data": codeList
          });
          var jsonString = jsonEncode(mapList);
          await SP.putCodeList(Const.DEPT, jsonString);

        }
      }
      setState(() {});
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getDeptList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getDeptList() Error Default => ");
          break;
      }
    });
  }

  /**
   * Function End
   */








  /// Widget Start


  @override
  Widget build(BuildContext mContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: light_gray24,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: light_gray24,
        toolbarHeight: 50.h,
        automaticallyImplyLeading: false,
        actions: [
          /*IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.black,
            ),
            onPressed: () async {
              await Navigator.of(context).push(PageAnimationTransition(page: NotificationPage(), pageAnimationType: LeftToRightTransition()));
            },
            tooltip: MaterialLocalizations.of(mContext).openAppDrawerTooltip,
          ),*/
          IconButton(
            icon: Image.asset("assets/image/ic_menu.png",
                width: CustomStyle.getWidth(25.0.w),
                height: CustomStyle.getHeight(25.0.h),
                color: Colors.black
            ),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
            tooltip: MaterialLocalizations.of(mContext).openAppDrawerTooltip,
          )
        ],
        leading: Builder(
          builder: (context) => Image.asset("assets/image/ic_logo.png", color: Colors.black),
        ),
      ),
      endDrawer: getAppBarMenu(),
        body: SafeArea(
            child: Obx((){
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children :[
                    searchDateOrderWidget(),
                    orderItemFuture(),
                  ]
              );
            })
        ),
    );
  }

  Drawer getAppBarMenu() {
    return Drawer(
        backgroundColor: light_gray24,
        width: App().isTablet(context) ? MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7 : MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          )
        ),
        child: Column(
            children :[
            Expanded(
                child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: App().isTablet(context) ? 260.h : 220.h,
                  child: DrawerHeader(
                      decoration: const BoxDecoration(
                        color: renew_main_color2,
                      ),
                      padding: EdgeInsetsDirectional.only(top: CustomStyle.getHeight(0)),
                      child: Row(
                        children: [
                          Expanded(
                              flex:1,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                      children:[
                                        Container(
                                          margin: App().isTablet(context) ?  EdgeInsets.only(right: CustomStyle.getWidth(5.w)) : EdgeInsets.only(right: CustomStyle.getWidth(0.w)),
                                          width: App().isTablet(context) ? CustomStyle.getWidth(10.w) : CustomStyle.getWidth(50),
                                          height: App().isTablet(context) ? CustomStyle.getHeight(25.h) : CustomStyle.getHeight(50),
                                          child: IconButton(
                                              onPressed: (){
                                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ReNewAppBarSettingPage()));
                                              },
                                              icon: Icon(Icons.settings,size: App().isTablet(context) ? 38.h : 28.h ,color: Colors.white)
                                          )
                                        ),
                                        Container(
                                          width: App().isTablet(context) ? CustomStyle.getWidth(10.w) : CustomStyle.getWidth(50),
                                          height: App().isTablet(context) ? CustomStyle.getHeight(25.h) : CustomStyle.getHeight(50),
                                          margin: App().isTablet(context) ?  EdgeInsets.only(right: CustomStyle.getWidth(5.w)) : EdgeInsets.only(right: CustomStyle.getWidth(0.w)),
                                          child: IconButton(
                                              onPressed: (){
                                                _scaffoldKey.currentState!.closeEndDrawer();
                                              },
                                              icon: Icon(Icons.close,size: App().isTablet(context) ? 38.h : 28.h ,color: Colors.white)
                                          )
                                        ),
                                      ]
                                    ),
                                    Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children:[
                                          Container(
                                            margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children:[
                                                Obx(()=>
                                                    Text(
                                                      "${mUser.value.bizName}",
                                                      style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol,font_weight: FontWeight.w700),
                                                    )
                                                ),
                                                CustomStyle.sizedBoxHeight(5.0.h),
                                                Obx(()=>Text(
                                                  "${mUser.value.deptName}",
                                                  style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                                                )
                                                )
                                              ]
                                            )
                                          )
                                        ]
                                      )
                                    )
                                    ),
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      //padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8)),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.white,
                                            width: 1.w
                                          )
                                        )
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:1,
                                              child: InkWell(
                                                onTap: () async {
                                                  await Navigator.of(context).push(PageAnimationTransition(page: NotificationPage(), pageAnimationType: RightToLeftFadedTransition()));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.notifications,
                                                      size: App().isTablet(context) ? 38.h : 28.h,
                                                      color: Colors.white
                                                  ),
                                                  Text(
                                                      "알림",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol,font_weight: FontWeight.w700)
                                                  )
                                                ]
                                              )
                                              )
                                            )
                                          ),
                                          Expanded(
                                              flex:1,
                                              child: InkWell(
                                                onTap: (){
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RenewAppBarMyPage(call24Yn: api24Data.value["apiKey24"] != null && api24Data.value["apiKey24"] != '' ? "Y" : "N")));
                                                },
                                                  child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                    child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children :[
                                                      Icon(Icons.manage_accounts,
                                                          size: App().isTablet(context) ? 38.h : 28.h,
                                                          color: Colors.white
                                                      ),
                                                      Text(
                                                          "마이페이지",
                                                          textAlign: TextAlign.center,
                                                          style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol,font_weight: FontWeight.w700)
                                                        )
                                                      ]
                                                    )
                                                )
                                            )
                                          )
                                        ],
                                      ),
                                    )
                                  ]
                              )
                          ),
                        ],
                      )
                  )),
                  Obx(() =>
                  mPoint.value != 0 ?
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                      title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                        decoration: BoxDecoration(
                          border: Border.all(color: light_gray18,width: 1),
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(30))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/image/ic_point.png",
                                  width: CustomStyle.getWidth(21.0),
                                  height: CustomStyle.getHeight(21.0),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Text(
                                    "포인트",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                                  )
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                              child: Text(
                                "${Util.getInCodeCommaWon(mPoint.value.toString())} P",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                              )
                            ),
                          ],
                        )
                      ),
                      onTap: () async {
                        await goToPoint();
                      },
                    ) : const SizedBox()
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                        decoration: BoxDecoration(
                            border: Border.all(color: light_gray18,width: 1),
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(30))
                        ),
                        child: Row(
                              children: [
                                Image.asset(
                                  "assets/image/ic_report.png",
                                  width: CustomStyle.getWidth(21),
                                  height: CustomStyle.getHeight(21),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                    child: Text(
                                      "실적현황",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                                    )
                                )
                              ],
                        ),
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AppBarMonitorPage()));
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                    title: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                      decoration: BoxDecoration(
                          border: Border.all(color: light_gray18,width: 1),
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(30))
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/image/ic_noti.png",
                            width: CustomStyle.getWidth(21.0),
                            height: CustomStyle.getHeight(21.0),
                          ),
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              child: Text(
                                "공지사항",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                              )
                          )
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AppBarNoticePage()));
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                    title: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                      decoration: BoxDecoration(
                          border: Border.all(color: light_gray18,width: 1),
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(30))
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help,
                            size: 21.h,
                            color: renew_main_color2,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                              child: Text(
                                "도움말",
                                style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                              )
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      var url = Uri.parse(URL_MANUAL);
                      if (await canLaunchUrl(url)) {
                        await Util.setEventLog(URL_MANUAL, "도움말");
                        launchUrl(url);
                      }
                    },
                  ),
                ],
              )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
          child: Align(
              alignment: FractionalOffset.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                    child: Row(
                      children:[
                        Container(
                          margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                          child: Text(
                            "신버전",
                            style:CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w600)
                          )
                        ),
                        Obx(() =>
                            Transform.scale(
                                scale: 0.7,
                                child: CupertinoSwitch(
                                  value:  controller.renew_value.value,
                                  activeColor: renew_main_color2,
                                  onChanged: (bool? value) async {
                                    controller.setRenewValue(value ?? false);
                                  },
                              )
                            )
                        )
                      ]
                    )
                  ),*/
                  Container(),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h),horizontal: CustomStyle.getWidth(5.w)),
                    child: InkWell(
                        onTap: () async {
                          await goToExit();
                        },
                        child: Icon(
                          Icons.exit_to_app,
                          size: App().isTablet(context) ? 21.sp : 28.sp,
                          color: Colors.black,
                        )
                    ),
                  )
                ]
              )
            )
          )
        ])
    );
  }

  Widget searchDateOrderWidget() {
    return Column(
      children: [
        // 날짜 조건 버튼
          Container(
            color: renew_main_color2,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
            child: Row(
              children :[
                InkWell(
                  onTap: (){
                    daySelectOption.value == "0" ? daySelectOption.value = "1" : daySelectOption.value = "0";
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                    decoration: BoxDecoration(
                      color: daySelectOption.value == "0" ? renew_main_color2_sub : rpa_btn_cancle,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      daySelectOption.value == "0" ? "상차일" : "하차일",
                      style: CustomStyle.CustomFont(styleFontSize12,Colors.white,font_weight: FontWeight.w800 ),
                    )
                  )
                ),
              Row(
                children: List.generate(
                    dateSelectOption.length,
                        (index) => InkWell(
                        onTap: (){

                          switch(index) {
                            case 0 :
                              dateSelectValue.value = index;
                              mCalendarStartDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-7);
                              mCalendarEndDate.value = DateTime.now();
                              page.value = 1;
                              lastPositionItem.value = 0;
                              break;
                            case 1 :
                              dateSelectValue.value = index;
                              mCalendarStartDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1);
                              mCalendarEndDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                              page.value = 1;
                              lastPositionItem.value = 0;
                              break;
                            case 2 :
                              dateSelectValue.value = index;
                              mCalendarStartDate.value = DateTime.now();
                              mCalendarEndDate.value = DateTime.now();
                              page.value = 1;
                              lastPositionItem.value = 0;
                              break;
                            case 3 :
                              dateSelectValue.value = index;
                              mCalendarStartDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                              mCalendarEndDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);
                              page.value = 1;
                              lastPositionItem.value = 0;
                              break;
                            case 4 :
                              dateSelectValue.value = index;
                              mCalendarStartDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                              mCalendarEndDate.value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7);
                              page.value = 1;
                              lastPositionItem.value = 0;
                              break;
                            case 5 :
                              dateSelectValue.value = index;
                              openCalendarDialog();
                              break;
                          }

                        },
                        child: Container(
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(7)),
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(7)),
                            decoration: BoxDecoration(
                                color: dateSelectValue.value == index ? main_color: Colors.white,
                                border: dateSelectValue.value == index  ? Border.all(color: Colors.white,width: 1) : Border.all(color: Colors.white,width: 0),
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Text(
                              dateSelectOption[index],
                              style: CustomStyle.CustomFont(styleFontSize12, dateSelectValue.value == index ? Colors.white: Colors.black,font_weight: dateSelectValue.value == index ? FontWeight.w800 : FontWeight.w400),
                            )
                        )
                    )
                ),
              )
            ])
          ),
        Container(height: CustomStyle.getHeight(3),color: Colors.white),
        // 검색 날짜 View
        Container(
          color: renew_main_color2,
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                  child: Text(
                  mCalendarStartDate.value == null?"-":"${mCalendarStartDate.value.year}년 ${mCalendarStartDate.value.month}월 ${mCalendarStartDate.value.day}일",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                )
              ),
             Expanded(
                 flex: 1,
                 child: Text(
                   " ~ ",
                   textAlign: TextAlign.center,
                   style: CustomStyle.CustomFont(styleFontSize22, Colors.white,font_weight: FontWeight.w800),
                 )
             ),
              Expanded(
                flex: 1 ,
                child: Text(
                  mCalendarEndDate.value == null?"-":"${mCalendarEndDate.value.year}년 ${mCalendarEndDate.value.month}월 ${mCalendarEndDate.value.day}일",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                )
              )
            ],
          )
        ),
      ],
    );
  }

  Widget orderItemFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.getOrder(
            context,
            Util.getTextDate(mCalendarStartDate.value),
            Util.getTextDate(mCalendarEndDate.value),
            daySelectOption.value,
            categoryOrderCode.value,
            categoryDeptCode.value,
            categoryRpaCode.value,
            categoryStaffModel.value.userId,
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
          return SizedBox(
              width: CustomStyle.getWidth(30.0),
              height: CustomStyle.getHeight(30.0),
              child: const Center(child: CircularProgressIndicator())
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
                      child: AnimationLimiter(
                        child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          var item = orderList[index];
                          return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: AutoScrollTag (
                                    key: ValueKey(index),
                                    controller: scrollController,
                                    index: index,
                                    child: getListCardView(item,index)
                                )
                              )
                            )
                          );
                        },
                      )
                    )
                  )
              ),
              // 검색 필터 상태 View
              Positioned(
                  child: Container(
                      color:Colors.black.withOpacity(0.4),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: (){
                                  openCodeBottomSheet(context,Strings.of(context)?.get("order_state")??"",Const.ORDER_STATE_CD,selectItem);
                                },
                                child: Obx(() => Text(
                                  categoryOrderState.value,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                )
                              )
                            )
                          ),
                          mUser.value.masterYn == "Y" ?
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                  onTap: (){
                                    openCodeBottomSheet(context,"부서 선택",Const.DEPT,selectItem);
                                  },
                                  child: Obx(() => Text(
                                      categoryDeptState.value,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                  )
                                  )
                              )
                          ) : const SizedBox(),
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  openCodeBottomSheet(context,"정보망 상태",Const.RPA_STATE_CD,selectItem);
                                },
                                  child: Obx(() => Text(
                                  categoryRpaState.value,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                  )
                              )
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: (){
                                openCodeBottomSheet(context,"담당자 선택",Const.STAFF_STATE_CD,selectItem);
                              },
                              child: Obx(() => Text(
                                  categoryStaffModel.value.userName!,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                              )
                              )
                            )
                          ),
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () async {
                                  await openFilterBottomSheet(context,"필터",selectItem);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                      child: Image.asset(
                                        "assets/image/ic_filter.png",
                                        width: CustomStyle.getWidth(15.0),
                                        height: CustomStyle.getHeight(15.0),
                                        color: Colors.white,
                                      )
                                    ),
                                    Text(
                                      "필터",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                        textAlign: TextAlign.center,
                                    )
                                  ],
                                )
                              )
                          )
                        ],
                      )
                  )
              ),
              Obx((){
                return ivTop.value == true ?
                Positioned(
                    right: 15.w,
                    bottom: ivBottom.value == false ? 130.h : 180.h,
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
                  right: 15.w,
                  bottom: ivBottom.value == false ? 80.h : App().isTablet(context) ? 140.h : 130.h,
                  child: InkWell(
                      onTap: () async {
                        Future(() {
                          setState(() {
                            var itemIndex = scrollController.position.pixels / (scrollController.position.maxScrollExtent / orderList.length);
                            lastPositionItem.value = itemIndex.toInt();
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
                    right: 15.w,
                    bottom: 80.h,
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

              Positioned.fill(
                  bottom: 10.h,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                      child: InkWell(
                      onTap: () async {
                        var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                        if(guest) {
                          showGuestDialog();
                            return;
                        }
                        openSelectRegOrderDialog(context);
                      },
                      child: Container(
                          width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                          height: CustomStyle.getHeight(50),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.app_registration_rounded, size: 25.h, color: styleWhiteCol),
                                CustomStyle.sizedBoxWidth(5.0.w),
                                Text(
                                  textAlign: TextAlign.center,
                                  Strings.of(context)?.get("order_reg_title") ?? "Not Found",
                                  style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                ),
                              ]
                          )
                      )
                  )
                )
              )
            ]))
        : Expanded(
          child: Stack(
              children: [
                Positioned(
                  child: Container(
                    alignment: Alignment.center,
                      child: Text(
                        Strings.of(context)?.get("empty_list") ?? "Not Found",
                        style: CustomStyle.baseFont(),
                      )
                  )
                ),
                Positioned(
                    right: 15.w,
                    bottom: 80.h,
                    child: InkWell(
                        onTap: () async {
                          Future(() {
                            setState(() {
                              var itemIndex = scrollController.position.pixels / (scrollController.position.maxScrollExtent / orderList.length);
                              lastPositionItem.value = itemIndex.toInt();
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
                // 검색 필터 상태 View
                Positioned(
                    child: Container(
                        color:Colors.black.withOpacity(0.4),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: (){
                                      openCodeBottomSheet(context,Strings.of(context)?.get("order_state")??"",Const.ORDER_STATE_CD,selectItem);
                                    },
                                    child: Obx(() => Text(
                                        categoryOrderState.value,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                    )
                                    )
                                )
                            ),
                            mUser.value.masterYn == "Y" ?
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: (){
                                      openCodeBottomSheet(context,"부서 선택",Const.DEPT,selectItem);
                                    },
                                    child: Obx(() => Text(
                                        categoryDeptState.value,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                    )
                                    )
                                )
                            ) : const SizedBox(),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: (){
                                      openCodeBottomSheet(context,"정보망 상태",Const.RPA_STATE_CD,selectItem);
                                    },
                                    child: Obx(() => Text(
                                        categoryRpaState.value,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                    )
                                    )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: (){
                                      openCodeBottomSheet(context,"담당자 선택",Const.STAFF_STATE_CD,selectItem);
                                    },
                                    child: Obx(() => Text(
                                        categoryStaffModel.value.userName!,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white,font_weight: FontWeight.w700)
                                    )
                                    )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () async {
                                      await openFilterBottomSheet(context,"필터",selectItem);
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                            child: Image.asset(
                                              "assets/image/ic_filter.png",
                                              width: CustomStyle.getWidth(17.0),
                                              height: CustomStyle.getHeight(17.0),
                                              color: Colors.white,
                                            )
                                        ),
                                        Text(
                                          "필터",
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                        )
                                      ],
                                    )
                                )
                            )
                          ],
                        )
                    )
                ),
                Positioned.fill(
                    bottom: 10,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                            onTap: () async {
                              var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest) {
                                //showGuestDialog();
                                return;
                              }
                              //await goToRegOrder();
                              openSelectRegOrderDialog(context);
                            },
                            child: Container(
                                width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
                                height: CustomStyle.getHeight(50),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.app_registration_rounded, size: 25.h, color: styleWhiteCol),
                                      CustomStyle.sizedBoxWidth(5.0.w),
                                      Text(
                                        textAlign: TextAlign.center,
                                        Strings.of(context)?.get("order_reg_title") ?? "Not Found",
                                        style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                                      ),
                                    ]
                                )
                            )
                        )
                    )
                )
              ]
            )
          );
  }

  Widget HorizontalDashedDivider() {
    final DividerThemeData dividerTheme = DividerTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10)),
      child: Container(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final dashCount = App().isTablet(context) ? (constraints.constrainWidth().toInt() / 15.0).floor() : (constraints.constrainWidth().toInt() / 5.0).floor();
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: CustomStyle.getWidth(3),
                  height:  CustomStyle.getHeight(1),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: light_gray18)
                  )
                );
              }),
            );
          },
        )
      )
    );
  }

  Widget getListCardView(OrderModel item,int itemIndex) {

    return Container(
        padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(5.w),top: CustomStyle.getHeight(10.0.h)),
        child: InkWell(
            onTap: () async {
              await goToOrderDetail(item,itemIndex);
            },
            child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                color: item.orderState == "09" ? const Color(0xffE6A9A9) : styleWhiteCol,
                child: Column(
                    children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                          children: [
                            Container(
                            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                            child: Row(
                              children:[
                                item.orderState != "09" && item.driverState != null ?
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: renew_main_color2
                                    ),
                                    margin: EdgeInsets.only(right: CustomStyle.getWidth(5.w)),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3.0.h),horizontal: CustomStyle.getWidth(15.w)),
                                    child: Text(
                                      "${item.driverStateName}",
                                      style: CustomStyle.CustomFont(styleFontSize11, Colors.white,font_weight: FontWeight.w600),
                                    )
                                ) : const SizedBox(),
                                Util.ynToBoolean(item.payType)?
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: rpa_btn_cancle
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3.0.h),horizontal: CustomStyle.getWidth(10.w)),
                                    child: Text(
                                      "빠른지급",
                                      style: CustomStyle.CustomFont(styleFontSize11, Colors.white, font_weight: FontWeight.w600),
                                    )
                                ):const SizedBox(),
                              ]
                            )
                          ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Row(children: [
                                  item.orderState == "09" ?
                                  Container(
                                      decoration: CustomStyle.baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3), horizontal: CustomStyle.getWidth(7)),
                                      margin: EdgeInsets.only(right: CustomStyle.getWidth(3)),
                                      child: Text(
                                        item.orderStateName??"",
                                        style: CustomStyle.CustomFont(styleFontSize12, Util.getOrderStateColor(item.orderState),font_weight: FontWeight.w800),
                                      )
                                  ) : const SizedBox(),
                                  Container(
                                    margin: EdgeInsets.only(right:CustomStyle.getWidth(3.w)),
                                      child: Text(
                                        item.sellCustName??"",
                                        style: CustomStyle.CustomFont(styleFontSize16, main_color,font_weight: FontWeight.w700),
                                      )
                                  ),
                                  Flexible(
                                      child: RichText(
                                          overflow: TextOverflow.visible,
                                          text: TextSpan(
                                            text: item.sellDeptName??"",
                                            style: CustomStyle.CustomFont(styleFontSize11, main_color,font_weight: FontWeight.w400),
                                          )
                                      )
                                  ),
                                ])),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  alignment:
                                  Alignment.centerRight,
                                  child: Text(
                                    "${Util.getInCodeCommaWon(item.sellCharge.toString())}원",
                                    style: CustomStyle.CustomFont(styleFontSize16, text_color_01, font_weight: FontWeight.w800),
                                  ),
                                ))
                          ],
                        ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        item.orderState != "09" && item.driverState == null ?
                                        Container(
                                            decoration: CustomStyle.baseBoxDecoWhite(),
                                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
                                            child: Text(
                                              "${item.allocStateName} ",
                                              overflow: TextOverflow.ellipsis,
                                              style: CustomStyle.CustomFont(styleFontSize14, order_state_01,font_weight: FontWeight.w700),
                                            )
                                        ) : const SizedBox(),
                                        item.linkName?.isEmpty == false && item.linkName != "" ?
                                        (item.call24Cargo == null || item.call24Cargo?.isEmpty == true)
                                            && (item.manCargo == null || item.manCargo?.isEmpty == true)
                                            && (item.oneCargo == null || item.oneCargo?.isEmpty == true) ?
                                        Container(
                                            padding: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                            child: Text(
                                              "지불운임",
                                              style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
                                            )
                                        ) : Expanded(
                                            flex: 1,
                                            child: Container(
                                            padding: EdgeInsets.only(
                                                right: CustomStyle.getWidth(5.w)),
                                            child: Text(
                                              "${item.linkName??""}",
                                              overflow: TextOverflow.ellipsis,
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            )
                                          )
                                        ) : const SizedBox(),
                                        item.buyCustName?.isEmpty == false && item.buyCustName != "" ?
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "${item.buyCustName??""}",
                                            overflow: TextOverflow.ellipsis,
                                            style: CustomStyle.CustomFont(styleFontSize12, order_state_01,font_weight: FontWeight.w700),
                                          )
                                        ) : const SizedBox(),
                                        item.buyDeptName?.isEmpty == false && item.buyDeptName != "" ?
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            " | ${item.buyDeptName??""}",
                                            overflow: TextOverflow.ellipsis,
                                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black,font_weight: FontWeight.w600),
                                          )
                                        ) : const SizedBox()
                                      ]
                                    )
                                ),
                                Flexible(
                                    flex: 1,
                                    child: (item.call24Cargo != "" && item.call24Cargo != null) ||
                                        (item.manCargo != "" && item.manCargo != null ) ||
                                        (item.oneCargo != "" && item.oneCargo != null)
                                        ? const SizedBox()
                                        : Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${Util.getInCodeCommaWon(ordChargeTotal("T", item).toString())}원",
                                        style: CustomStyle.CustomFont(styleFontSize16, text_color_01, font_weight: FontWeight.w700),
                                      ),
                                    )
                                )
                              ],
                            ),
                        item.orderState != "09" && item.driverState != null? HorizontalDashedDivider() : const SizedBox(),
                        item.orderState != "09" && item.driverState != null?
                        Container(
                            decoration: CustomStyle.baseBoxDecoWhite(),
                            child: Row(
                                children: [
                                  Flexible(
                                      flex: 9,
                                      child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${item.driverName} 차주님",
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w800),
                                            ),
                                            Text(
                                              "${item.carNum}",
                                              style: CustomStyle.CustomFont(styleFontSize12, text_color_01,font_weight: FontWeight.w600),
                                            )
                                          ],
                                        )
                                      ]
                                      )
                                  ),
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
                                                color: renew_main_color2,
                                              ),
                                              child: Icon(Icons.call_rounded,
                                                  size: 24.h,
                                                  color: Colors.white)
                                          )
                                      )
                                  )
                                ])
                        ):const SizedBox(),
                        HorizontalDashedDivider(),
                        item.orderState != "09" && item.driverState != null? CustomStyle.sizedBoxHeight(5.0.h):const SizedBox(),
                        item.call24Cargo == "R" || item.manCargo == "R" || item.oneCargo == "R" ? CustomStyle.getDivider1(): const SizedBox(),
                             Column(
                               children:[
                             Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Expanded(
                                   flex: 4,
                                   child: Container(
                                       child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Row(
                                                 crossAxisAlignment: CrossAxisAlignment.center,
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   Container(
                                                       padding:App().isTablet(context) ? const EdgeInsets.all(10) : const EdgeInsets.all(3),
                                                       margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                                       decoration: const BoxDecoration(
                                                          color: renew_main_color2,
                                                          shape: BoxShape.circle
                                                       ),
                                                       child: Text("상",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                                   ),
                                                   Text(
                                                     Util.splitSDate(item.sDate),
                                                     style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400),
                                                     textAlign: TextAlign.center,
                                                   ),
                                                 ]
                                             ),
                                             Flexible(
                                                 child: RichText(
                                                     overflow: TextOverflow.ellipsis,
                                                     maxLines: 2,
                                                     textAlign:TextAlign.center,
                                                     text: TextSpan(
                                                       text: item.sComName??"",
                                                       style:  CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                                     )
                                                 )
                                             ),
                                             CustomStyle.sizedBoxHeight(5.0.h),
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
                                           ]
                                       )
                                   ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "assets/image/ic_arrow.png",
                                                  width: CustomStyle.getWidth(32.0),
                                                  height: CustomStyle.getHeight(32.0),
                                                  color: const Color(0xffC7CBDE),
                                                ),
                                                Text(
                                                  Util.makeDistance(item.distance),
                                                  style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                                ),
                                                Text(
                                                  Util.makeTime(item.time??0),
                                                  style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                                )
                                              ]
                                          )
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  borderRadius:  BorderRadius.all(Radius.circular(10)),
                                              ),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                              padding:App().isTablet(context) ? const EdgeInsets.all(10) : const EdgeInsets.all(3),
                                                              margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                                              decoration: const BoxDecoration(
                                                                  color: rpa_btn_cancle,
                                                                  shape: BoxShape.circle
                                                              ),
                                                              child: Text("하",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                                          ),
                                                          Text(
                                                            Util.splitSDate(item.eDate),
                                                            style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ]
                                                    ),
                                                    Flexible(
                                                        child: RichText(
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                            textAlign: TextAlign.center,
                                                            text: TextSpan(
                                                              text:
                                                              item.eComName ?? "",
                                                              style: CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                                            )
                                                        )
                                                    ),
                                                    CustomStyle.sizedBoxHeight(5.h),
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
                                  ) ,
                                 Container(
                                     padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w), right: CustomStyle.getWidth(5.w), bottom: CustomStyle.getHeight(5.0.h),top: CustomStyle.getHeight(15.h)),
                                     child: Row(
                                       crossAxisAlignment: CrossAxisAlignment.center,
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Row(
                                          children:[
                                            Container(
                                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                                margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xffC7CBDE),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Text(
                                                  "${item.carTonName}",
                                                  style: CustomStyle.CustomFont(styleFontSize10, text_color_02,font_weight: FontWeight.w600),
                                                )
                                            ),
                                            Container(
                                                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xffC7CBDE),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Text(
                                                  "${item.carTypeName}",
                                                  style: CustomStyle.CustomFont(styleFontSize10, text_color_02,font_weight: FontWeight.w600),
                                                )
                                              ),
                                            ]
                                         ),
                                         Row(
                                           children: [
                                             item.truckTypeName != null || item.truckTypeName?.isNotEmpty == true?
                                             Container(
                                                 padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                                 margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                                 decoration: BoxDecoration(
                                                     color: const Color(0xffC7CBDE),
                                                     borderRadius: BorderRadius.circular(10)
                                                 ),
                                               child: Text(
                                                  "${item.truckTypeName}",
                                                  style: CustomStyle.CustomFont(styleFontSize10, text_color_02,font_weight: FontWeight.w600),
                                                )
                                             ) : const SizedBox(),
                                             Container(
                                                 padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                                 margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                                 decoration: BoxDecoration(
                                                     color: const Color(0xffC7CBDE),
                                                     borderRadius: BorderRadius.circular(10)
                                                 ),
                                                 child: Text(
                                                 item.mixYn == "Y" ? "혼적" : "독차",
                                                 style: CustomStyle.CustomFont(styleFontSize10, text_color_02,font_weight: FontWeight.w600),
                                                 )
                                             ),
                                             Container(
                                                 padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(10)),
                                                 margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                                 decoration: BoxDecoration(
                                                     color: const Color(0xffC7CBDE),
                                                     borderRadius: BorderRadius.circular(10)
                                                 ),
                                                 child: Text(
                                                   item.returnYn == "Y" ? "왕복" : "편도",
                                                   style: CustomStyle.CustomFont(styleFontSize10, text_color_02,font_weight: FontWeight.w600),
                                                )
                                             ),
                                         ])
                                       ],
                                     )
                                 )
                               ]
                             ),
                        HorizontalDashedDivider(),
                        //RPA
                        item.orderState != "09" ? rpaFunctionFuture(item,itemIndex) : const SizedBox(),
                      ])
                  ),
                ]
                )
            )
        )
    );
  }

  Widget rpaFunctionFuture(OrderModel item,int itemIndex) {
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
              return rpaFunctionWidget(item, snapshot,itemIndex);
            } else if (snapshot.hasError) {
              return const SizedBox();
            }
          }
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Widget rpaFunctionWidget(OrderModel item, AsyncSnapshot snapshot,itemIndex) {
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
                          height: App().isTablet(context) ? CustomStyle.getHeight(50.h) : CustomStyle.getHeight(85),
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
                                                      style: statMsg(call24LinkModel.value.linkStat, call24LinkModel.value.jobStat) == "" ?  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800)
                                                          : call24LinkModel.value.linkStat == "D" && call24LinkModel.value.jobStat == "F"
                                                          ?   TextStyle(decoration: TextDecoration.lineThrough, fontSize: styleFontSize13)
                                                          :  CustomStyle.CustomFont(styleFontSize13, text_color_06, font_weight: FontWeight.w800),
                                                    ),
                                                    Text(
                                                      statMsg(call24LinkModel.value.linkStat, call24LinkModel.value.jobStat),
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
                                                height: App().isTablet(context) ? CustomStyle.getHeight(45.h) : CustomStyle.getHeight(65),
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
                                                      statMsg(hwaMullLinkModel.value.linkStat, hwaMullLinkModel.value.jobStat),
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
                                                height: App().isTablet(context) ? CustomStyle.getHeight(45.h) : CustomStyle.getHeight(65),
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
                                                      statMsg(oneCallLinkModel.value.linkStat, oneCallLinkModel.value.jobStat),
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
                    final selected = false.obs;
                    if(call24State.value || manState.value || oneCallState.value) selected.value = true;
                    if(item.orderState == "09") selected.value = false;

                    return AnimatedContainer(
                        width: double.infinity,
                        height: selected.value ? CustomStyle.getHeight(55) : CustomStyle.getHeight(30),
                        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(5)),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.fastOutSlowIn,
                        decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(color: light_gray4, width: 1),
                                bottom: BorderSide(color: light_gray4, width: 1)
                            )
                        ),
                        child: Obx(() =>
                        // 24시콜 OpenInfo
                        call24State.value ?
                          clickRpaInfoWidget(call24LinkModel.value,userRpaData.value, item,Const.CALL_24_KEY_NAME,itemIndex)
                        // 화물맨 OpenInfo
                        : manState.value ?
                          clickRpaInfoWidget(hwaMullLinkModel.value,userRpaData.value,item,Const.HWA_MULL_KEY_NAME,itemIndex)
                        // 원콜 OpenInfo
                        : oneCallState.value ?
                          clickRpaInfoWidget(oneCallLinkModel.value,userRpaData.value,item,Const.ONE_CALL_KEY_NAME,itemIndex)
                        : const SizedBox()
                        )
                    );
                  })
                ]
            )
        ) : const SizedBox()
    );
  }

  Widget clickRpaInfoWidget(OrderLinkCurrentModel mLinkModel,UserRpaModel mUserRpaData, OrderModel orderItem, String linkType,int itemIndex) {

    var linkName = "";

    final linkModel = OrderLinkCurrentModel().obs;
    linkModel.value = mLinkModel;
    final userRpaData = UserRpaModel().obs;
    userRpaData.value = mUserRpaData;
    final item = OrderModel().obs;
    item.value = orderItem;

    switch(linkType) {
      case "03" :
        linkName = "24시콜";
        break;
      case "21" :
        linkName = "화물맨";
        break;
      case "18" :
        linkName = "원콜";
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

                statMsg(linkModel.value.linkStat, linkModel.value.jobStat) == "" ?
                linkModel.value.linkStat == "R" ?
                item.value.orderStateName == "접수" ?
                InkWell(
                    onTap:(){
                      openRpaInfoDialog(context, item.value, "02",linkType,itemIndex,link_model: linkModel.value);
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
                          "$linkName 배차확정",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) :  InkWell(
                    onTap:(){
                      openRpaInfoDialog(context, item.value, "01",linkType,itemIndex);
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
                          "$linkName 배차정보",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                )
                    : const SizedBox()
                    : linkModel.value.linkStat == "D" && linkModel.value.jobStat == "F" ?
                const SizedBox()
                    : const SizedBox(),

                // 전체 조건문 시작
                ((linkModel.value.allocCharge != "" && linkModel.value.allocCharge != null) && (linkModel.value.linkStat != "D" && linkModel.value.jobStat != "F") && (linkModel.value.linkStat != "I" && linkModel.value.jobStat != "E")
                    || (linkModel.value.linkStat == "D" && linkModel.value.jobStat == "E") || (linkModel.value.linkStat == "I" && linkModel.value.jobStat == "W")
                    || (linkModel.value.linkStat == "I" && linkModel.value.jobStat == "F") || (linkModel.value.linkStat == "R" && linkModel.value.jobStat == "W")
                    || (linkModel.value.linkStat == "R" && linkModel.value.jobStat == "F") || linkModel.value.linkStat == "U") ?
                linkType == Const.CALL_24_KEY_NAME ?
                (userRpaData.value.link24Id?.isNotEmpty == true && userRpaData.value.link24Id != "") && (userRpaData.value.link24Pass?.isNotEmpty == true && userRpaData.value.link24Pass != "") ? // link24Id와 link24Pass이 등록되어 있는 상태
                item.value.orderStateName == "접수" ? // 24시콜 OrderStateName = "접수" 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ? // 24시콜 인수증, 선불, 착불 상태
                Row(
                    children: [
                      InkWell(
                          onTap:(){
                            openRpaModiDialog(context, item.value, linkType,itemIndex);
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
                                "$linkName 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, linkModel.value,itemIndex);
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
                                "$linkName 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                )  : const SizedBox()
                    : InkWell(  // 24시콜 OrderStateName = "접수" 아닐때
                    onTap:() async {
                      await cancelRpa(item.value.orderId, linkModel.value,itemIndex);
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
                          "$linkName 취소",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) : const SizedBox()

                    : linkType == Const.ONE_CALL_KEY_NAME ?
                (userRpaData.value.one24Id?.isNotEmpty == true && userRpaData.value.one24Id != "") && (userRpaData.value.one24Pass?.isNotEmpty == true && userRpaData.value.one24Pass != "") ? // one24Id와 one24Pass이 등록되어 있는 상태
                item.value.orderStateName == "접수" && linkModel.value.linkStat != "R" ? // 원콜 OrderStateName = "접수"상태고 linkStat 값이 R(배차 확정)이 아닌 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ? // 원콜 인수증, 선불, 착불 상태
                Row(
                    children: [
                      InkWell(
                          onTap:(){
                            openRpaModiDialog(context, item.value, linkType,itemIndex);
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
                                "$linkName 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, linkModel.value,itemIndex);
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
                                "$linkName 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                ) : const SizedBox()
                    : InkWell( // 원콜 OrderStateName = "접수" 상태가 아니거나 linkStat 값이 R(배차 확정)인 상태
                    onTap:() async {
                      await cancelRpa(item.value.orderId, linkModel.value,itemIndex);
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
                          "$linkName 취소",
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
                            openRpaModiDialog(context, item.value, linkType,itemIndex);
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
                                "$linkName 수정",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                      InkWell(
                          onTap:() async {
                            await cancelRpa(item.value.orderId, linkModel.value,itemIndex);
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
                                "$linkName 취소",
                                style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                              )
                          )
                      ),
                    ]
                )  : const SizedBox()
                    : const SizedBox()
                // 전체 조건문 아닐 경우
                    : item.value.orderStateName == "접수" ?
                linkType == Const.HWA_MULL_KEY_NAME ? // 전체 조건문이 맞지 않을때(화물맨)
                (userRpaData.value.man24Id?.isNotEmpty == true && userRpaData.value.man24Id != "") && (userRpaData.value.man24Pass?.isNotEmpty == true && userRpaData.value.man24Pass != "") ? // man24Id와 man24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" ? // 시작(1)
                InkWell(
                    onTap: () {
                      openRpaModiDialog(context, item.value, linkType,itemIndex,flag: "D");
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
                          "$linkName 등록",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                ) :  const SizedBox() // 끝(1)
                    : const SizedBox()
                    :linkType == Const.CALL_24_KEY_NAME ? // 전체 조건문이 맞지 않을때(24시콜)
                (userRpaData.value.link24Id?.isNotEmpty == true && userRpaData.value.link24Id != "") && (userRpaData.value.link24Pass?.isNotEmpty == true && userRpaData.value.link24Pass != "") ? // link24Id와 link24Pass이 등록되어 있는 상태
                item.value.chargeType == "01" || item.value.chargeType == "04" || item.value.chargeType == "05" ?
                InkWell(
                    onTap: () {
                      openRpaModiDialog(context, item.value, linkType,itemIndex,flag: "D");
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
                          "$linkName 등록",
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
                      openRpaModiDialog(context, item.value, linkType,itemIndex,flag: "D");
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
                          "$linkName 등록",
                          style: CustomStyle.CustomFont(styleFontSize10, Colors.white),
                        )
                    )
                )
                    :  const SizedBox()
                    : const SizedBox()

                    : const SizedBox()
              ]),
          linkModel.value.linkStat != "D" && linkModel.value.jobStat != "F" ?
          linkModel.value.rpaMsg != null && linkModel.value.rpaMsg?.isNotEmpty == true ?
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(top: CustomStyle.getHeight(5)
                  ),
                  child: RichText(
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        text: "${linkModel.value.rpaMsg}",
                        style: CustomStyle.CustomFont(styleFontSize10, Colors.redAccent),
                      )
                  )
              )
          ) : const SizedBox()
              : const SizedBox()
        ])
    );
  }

  Future goToRegOrder() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegistOrderPage(flag: "R")));

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        await setRegResult(results);
      }
    }
  }

  Future goToRegOrderPage(String type) async {
    if(type == "01") {
      openRegOrderTemplateSheet(context, "등록할\n탬플릿을 선택해주세요.");
    }else{
      //Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RegistOrderPage(flag: "R"), pageAnimationType: LeftToRightTransition()));
      Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: RenewGeneralRegistOrderPage(flag: "R"), pageAnimationType: LeftToRightTransition()));

      if(results.containsKey("code")){
        if(results["code"] == 200) {
          await setRegResult(results);
        }
      }
    }
  }

  Widget templateListWidget(List template_list, Rx<TemplateModel> selectItem){

    return Container(
      child: template_list.isNotEmpty
          ? Expanded(
          child: AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: template_list.length,
                itemBuilder: (context, index) {
                  var item = template_list[index];
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                              child: getListItemView(item,selectItem)
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

  Widget getListItemView(TemplateModel item,Rx<TemplateModel> selectItem) {

    return InkWell(
        onTap: (){
          if(selectItem.value.templateId == item.templateId) {
            selectItem.value = TemplateModel();
          }else{
            selectItem.value = item;
          }
        },
        child: Obx(() => Container(
            margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
            decoration: BoxDecoration(
                color: light_gray4,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: selectItem.value.templateId == item.templateId ? renew_main_color2 : Colors.white,width: 2)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(15)),
                            child: Text(
                                "${item.templateTitle}",
                                style:CustomStyle.CustomFont(styleFontSize18, renew_main_color2,font_weight: FontWeight.w600)
                            )
                        )
                      ],
                    ),
                Container(height: 1,color: light_gray23,),
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(5),left: CustomStyle.getWidth(15),right: CustomStyle.getWidth(15)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                "${item.sellCustName}",
                                style:CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500)
                            ),
                            Text(
                                "${item.sellDeptName}",
                                style:CustomStyle.CustomFont(styleFontSize13, Colors.black,font_weight: FontWeight.w300)
                            )
                          ],
                        ),
                        Util.ynToBoolean(item.payType)?
                        Text(
                          "빠른지급",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.red,font_weight: FontWeight.w700),
                        ) : const SizedBox()
                      ],
                    )
                ),
                Column(
                    children:[
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 2,
                                      color: light_gray24
                                  )
                              )
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    padding:const EdgeInsets.all(3),
                                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                                    decoration: const BoxDecoration(
                                                        color: renew_main_color2,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Text("상",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                                ),
                                              ]
                                          ),
                                          Flexible(
                                              child: RichText(
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  textAlign:TextAlign.center,
                                                  text: TextSpan(
                                                    text: item.sComName??"",
                                                    style:  CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                                  )
                                              )
                                          ),
                                          CustomStyle.sizedBoxHeight(5.0.h),
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
                                        ]
                                    )
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/image/ic_arrow.png",
                                          width: CustomStyle.getWidth(32.0),
                                          height: CustomStyle.getHeight(32.0),
                                          color: const Color(0xffC7CBDE),
                                        ),
                                        Text(
                                          Util.makeDistance(item.distance),
                                          style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                        ),
                                        Text(
                                          Util.makeTime(item.time??0),
                                          style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                        )
                                      ]
                                  )
                              ),
                              Expanded(
                                  flex: 4,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      padding:const EdgeInsets.all(3),
                                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                                      decoration: const BoxDecoration(
                                                          color: rpa_btn_cancle,
                                                          shape: BoxShape.circle
                                                      ),
                                                      child: Text("하",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                                  ),
                                                ]
                                            ),
                                            Flexible(
                                                child: RichText(
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(
                                                      text:
                                                      item.eComName ?? "",
                                                      style: CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                                    )
                                                )
                                            ),
                                            CustomStyle.sizedBoxHeight(5.h),
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
                      ) ,
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15), vertical: CustomStyle.getHeight(5)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "청구운임",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                  ),
                                  Text(
                                    "${Util.getInCodeCommaWon(tempChargeTotal("S",item).toString())} 원",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w700),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "지불운임",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                                  ),
                                  Text(
                                    "${Util.getInCodeCommaWon(tempChargeTotal("T",item).toString())} 원",
                                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w700),
                                  )
                                ],
                              )
                            ],
                          )
                      ),
                      Container(
                          padding: EdgeInsets.only(left: CustomStyle.getWidth(5), bottom: CustomStyle.getHeight(10),top: CustomStyle.getHeight(5)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  children:[
                                    Container(
                                        padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                        margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffDBD1FF),
                                            borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: Text(
                                          "${item.carTonName}",
                                          style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff8674C7),font_weight: FontWeight.w600),
                                        )
                                    ),
                                    Container(
                                        padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffDBD1FF),
                                            borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: Text(
                                          "${item.carTypeName}",
                                          style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff8674C7),font_weight: FontWeight.w600),
                                        )
                                    ),
                                  ]
                              ),
                              Row(
                                  children: [
                                    item.truckTypeName != null || item.truckTypeName?.isNotEmpty == true?
                                    Container(
                                        padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                        margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffD2DAF5),
                                            borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: Text(
                                          "${item.truckTypeName}",
                                          style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5C67C1),font_weight: FontWeight.w600),
                                        )
                                    ) : const SizedBox(),
                                    Container(
                                        padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                        margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffADEFD1),
                                            borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: Text(
                                          item.mixYn == "Y" ? "혼적" : "독차",
                                          style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5EAD89),font_weight: FontWeight.w600),
                                        )
                                    ),
                                    Container(
                                        padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                        margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffADEFD1),
                                            borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: Text(
                                          item.returnYn == "Y" ? "왕복" : "편도",
                                          style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5EAD89),font_weight: FontWeight.w600),
                                        )
                                    ),
                                  ])
                            ],
                          )
                      ),
                    ]
                ),
              ],
            )
        ))
    );
  }

  /**
   * Widget End
   */

}