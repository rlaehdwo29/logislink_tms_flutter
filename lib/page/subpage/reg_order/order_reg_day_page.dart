import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';

class OrderRegDayPage extends StatefulWidget {

  OrderModel order_vo;
  DateTime sCal;
  DateTime eCal;

  OrderRegDayPage({Key? key, required this.order_vo,required this.sCal, required this.eCal}):super(key:key);

  _OrderRegDayPageState createState() => _OrderRegDayPageState();
}

class _OrderRegDayPageState extends State<OrderRegDayPage> with TickerProviderStateMixin {
  final controller = Get.find<App>();
  ProgressDialog? pr;
  late TabController _startTabController;
  late TabController _endTabController;

  final _startTabState = "01".obs;
  final _endTabState = "01".obs;

  final _startFocusedDay = DateTime.now().obs;
  final _endFocusedDay = DateTime.now().obs;
  DateTime _sDatefocusedDay = DateTime.now();
  DateTime _eDatefocusedDay = DateTime.now();
  final mSDate = "".obs;
  final mEDate = "".obs;
  final sCal = DateTime.now().obs;
  final eCal = DateTime.now().obs;
  final mSTime = "".obs;
  final mETime = "".obs;

  late final _defaultDateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    0,
    0,
    0,
  );

  @override
  void initState() {
    super.initState();
    _startTabController = TabController(
        length: 2,
        vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
        initialIndex: 0
    );
    _startTabController.addListener(_startHandleTabSelection);

    _endTabController = TabController(
        length: 2,
        vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
        initialIndex: 0
    );
    _endTabController.addListener(_endHandleTabSelection);

    Future.delayed(Duration.zero, () async {
      sCal.value = widget.sCal;
      eCal.value = widget.eCal;
      await initView();
    });

  }

  Future<void> initView() async {
    await setSDate();
    mSTime.value = Util.splitTime(widget.order_vo.sDate??"");
    await setEDate();
    mETime.value = Util.splitTime(widget.order_vo.eDate??"");

  }

  int parseIntDate(String date) {
    return int.parse(Util.mergeDate(date));
  }

  int parseIntTime(String time){
    return int.parse(Util.mergeTime(time));
  }

  
  Future<void> _startHandleTabSelection() async {

    if (_startTabController.indexIsChanging) {
      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _startTabController.index;
      switch(selectedTabIndex) {
        case 0 :
          _startTabState.value = "01";
          final result =  await TimePicker.show(
              context: context,
              sheet: TimePickerSheet(
                sheetTitle: "상차 예약",
                minuteTitle: "분",
                hourTitle: "시간",
                saveButtonText: "저장",
              )
          );
          mSTime.value = Util.getYoDate2(result);
          if(parseIntDate(mSDate.value) == parseIntDate(mEDate.value)) {
            if(_startTabController.index == 0 && _endTabController.index == 0) {
              mETime.value = Util.getYoDate2(result);
            }
          }
          break;
        case 1 :
          _startTabState.value = "02";
          mSTime.value = "00:00";
          break;
      }
    }
  }

  Future<void> _endHandleTabSelection() async {
    if (_endTabController.indexIsChanging) {

      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _endTabController.index;
      switch(selectedTabIndex) {
        case 0 :
          _endTabState.value = "01";
          final result =  await TimePicker.show(
              context: context,
              sheet: TimePickerSheet(
                  sheetTitle: "하차 예약",
                  minuteTitle: "분",
                  hourTitle: "시간",
                  saveButtonText: "저장",
              )
          );
          mETime.value = Util.getYoDate2(result);
          break;
        case 1 :
          _endTabState.value = "02";
          mETime.value = "00:00";
          break;
      }
    }
  }

  Widget startCustomTabBarWidget() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
        color: sub_color,
        child: TabBar(
          tabs: [
            Container(
                height: 40.h,
                alignment: Alignment.center,
                child: Text(
                _startTabState.value == "01"? mSTime.value : Strings.of(context)?.get("order_reg_day_s_time")??"Not Found",
                ),
            ),
            Container(
                height: 40.h,
                alignment: Alignment.center,
                child: Text(
                  Strings.of(context)?.get("order_reg_day_s_day")??"Not Found",
                ),
            ),
          ],
          indicator: BoxDecoration(
              color: main_color,
          ),
          labelColor: sub_color,
          unselectedLabelColor: Colors.black,
          controller: _startTabController,
          labelPadding: const EdgeInsets.all(0.0),
        ));
  }

  Widget endCustomTabBarWidget() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
        color: sub_color,
        child: TabBar(
          tabs: [
            Container(
              height: 40.h,
              alignment: Alignment.center,
              child: Text(
                _endTabState.value == "01"? mETime.value : Strings.of(context)?.get("order_reg_day_e_time")??"Not Found",
              ),
            ),
            Container(
              height: 40.h,
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("order_reg_day_e_day")??"Not Found",
              ),
            ),
          ],
          indicator: BoxDecoration(
            color: main_color,
          ),
          labelColor: sub_color,
          unselectedLabelColor: Colors.black,
          controller: _endTabController,
          labelPadding: const EdgeInsets.all(0.0),
        ));
  }

  Widget startDateCalendar() {
    return Column(
      children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("order_reg_day_on")??"Not Found",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              Text(
                Util.getYoDate(sCal.value),
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              Icon(Icons.calendar_today,size: 24.h,color: const Color(0xffE4E4EB))
            ],
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(12.h)),
          child: CustomStyle.getDivider1()
        ),
        startCustomTabBarWidget(),
        startCalendarWidget(),
      ],
    );
  }

  Widget endDateCalendar() {
    return Container(
      margin: EdgeInsets.only(top:CustomStyle.getHeight(30.h)),
        child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.of(context)?.get("order_reg_day_off")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            ),
            Text(
              Util.getYoDate(eCal.value),
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            ),
            Icon(Icons.calendar_today,size: 24.h,color: const Color(0xffE4E4EB))
          ],
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(12.h)),
            child: CustomStyle.getDivider1()
        ),
        endCustomTabBarWidget(),
        endCalendarWidget(),
      ],
    )
    );
  }

  Widget tabBarValueWidget(String? tabValue) {
    Widget _widget = startCalendarWidget();
    return _widget;
  }

  Widget startCalendarWidget() {
    _startFocusedDay.value = DateTime.now();
    return Container(
      child: TableCalendar(
        focusedDay: _startFocusedDay.value,
        firstDay:  DateTime.utc(2010, 1, 1),
        locale: 'ko-KR',
        lastDay: DateTime.utc(DateTime.now().year+10, DateTime.now().month, DateTime.now().day),
        headerStyle: const HeaderStyle(
          // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
          formatButtonVisible: false,
          // 달력 타이틀을 센터로
          titleCentered: true,
          // 말 그대로 타이틀 텍스트 스타일링
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
        calendarStyle: CalendarStyle(
          // 오늘 날짜에 하이라이팅의 유무
          isTodayHighlighted: true,
          // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
          defaultDecoration: const BoxDecoration(),
          // 캘린더의 주말 배경 스타일링
          weekendDecoration:  const BoxDecoration(),
          // 선택한 날짜 배경 스타일링
          selectedDecoration: BoxDecoration(
              color: main_color,
              shape: BoxShape.circle,
              border: Border.all(color: main_color),
          ),
          defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black),
          weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red),
          selectedTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.white),
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
              border: Border.all(color: sub_color)
          ),
          // rangeEndDay 글자 조정
          rangeEndTextStyle: CustomStyle.CustomFont(
              styleFontSize14, Colors.black),
          // rangeEndDay 모양 조정
          rangeEndDecoration: BoxDecoration(
              color: styleWhiteCol,
              shape: BoxShape.rectangle,
              border: Border.all(color: sub_color)
          ),

          // startDay, endDay 사이의 글자 조정
          withinRangeTextStyle: const TextStyle(),
          // startDay, endDay 사이의 모양 조정
          withinRangeDecoration: const BoxDecoration(),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(sCal.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(sCal.value, selectedDay)) {
            setState(() {
              sCal.value = selectedDay;
              _startFocusedDay.value = focusedDay;
              eCal.value = selectedDay;
              _endFocusedDay.value = focusedDay;
              setSDate();
              setEDate();
              mETime.value = mSTime.value;
            });
          }
        },
        calendarFormat: CalendarFormat.month,
        onPageChanged: (focusedDay) {
          print("onPageChanged => ${focusedDay}");
          _startFocusedDay.value = focusedDay;
        },
      ),
    );
  }

  Widget endCalendarWidget() {
    _endFocusedDay.value = DateTime.now();
    return Container(
      child: TableCalendar(
        focusedDay: _endFocusedDay.value,
        firstDay:  DateTime.utc(2010, 1, 1),
        locale: 'ko-KR',
        lastDay: DateTime.utc(DateTime.now().year+10, DateTime.now().month, DateTime.now().day),
        headerStyle: const HeaderStyle(
          // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
          formatButtonVisible: false,
          // 달력 타이틀을 센터로
          titleCentered: true,
          // 말 그대로 타이틀 텍스트 스타일링
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
        calendarStyle: CalendarStyle(
          // 오늘 날짜에 하이라이팅의 유무
          isTodayHighlighted: true,
          // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
          defaultDecoration: const BoxDecoration(),
          // 캘린더의 주말 배경 스타일링
          weekendDecoration:  const BoxDecoration(),
          // 선택한 날짜 배경 스타일링
          selectedDecoration: BoxDecoration(
            color: main_color,
            shape: BoxShape.circle,
            border: Border.all(color: main_color),
          ),
          defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black),
          weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red),
          selectedTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.white),
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
              border: Border.all(color: sub_color)
          ),
          // rangeEndDay 글자 조정
          rangeEndTextStyle: CustomStyle.CustomFont(
              styleFontSize14, Colors.black),
          // rangeEndDay 모양 조정
          rangeEndDecoration: BoxDecoration(
              color: styleWhiteCol,
              shape: BoxShape.rectangle,
              border: Border.all(color: sub_color)
          ),

          // startDay, endDay 사이의 글자 조정
          withinRangeTextStyle: const TextStyle(),
          // startDay, endDay 사이의 모양 조정
          withinRangeDecoration: const BoxDecoration(),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(eCal.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          if(parseIntDate(Util.getAllDate(sCal.value)) > parseIntDate(Util.getTextDate(selectedDay))) {
            await setEDate();
            Util.toast(Strings.of(context)?.get("order_reg_day_date_fail"));
          }else{
            if (!isSameDay(eCal.value, selectedDay)) {
              //setState(() async {
                eCal.value = selectedDay;
                _endFocusedDay.value = focusedDay;
                await setEDate();
                if(parseIntDate(Util.getAllDate(sCal.value)) == parseIntDate(Util.getAllDate(eCal.value))){
                  mETime.value = mSTime.value;
                }else{
                  mETime.value = "08:00";
                }
              //});
            }
          }
        },
        calendarFormat: CalendarFormat.month,
        onPageChanged: (focusedDay) {
          print("onPageChanged => ${focusedDay}");
          _endFocusedDay.value = focusedDay;
        },
      ),
    );
  }

  Future<void> setEDate() async {
    mEDate.value = Util.getTextDate(eCal.value);
  }

  Future<void> setSDate() async {
    mSDate.value = Util.getTextDate(sCal.value);
  }

  Future<void> confirm() async {
    Navigator.of(context).pop({
      'code':200,
      Const.RESULT_WORK:Const.RESULT_WORK_DAY,
      "sCal":sCal.value,
      "eCal":eCal.value,
      "sDate": "$mSDate $mSTime:00",
      "eDate": "$mEDate $mETime:00"
    });
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
          backgroundColor: sub_color,
          resizeToAvoidBottomInset:false,
          appBar: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_reg_day_title")??"Not Found",
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
                  icon: Icon(Icons.arrow_back,size: 24.h, color: styleWhiteCol),
                ),
              ),
          body: SafeArea(
              child: Obx((){
                return SizedBox(
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                  child: SingleChildScrollView(
                      child: Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                          color: styleWhiteCol,
                          margin: EdgeInsets.all(20.h),
                          surfaceTintColor: text_box_color_02,
                          child: Container(
                            padding: EdgeInsets.all(20.0.h),
                              child: Column(
                          children: [
                            startDateCalendar(),
                            endDateCalendar()
                          ],
                        )
                      )
                    )
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
                              decoration: BoxDecoration(color: main_color),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check,
                                        size: 20.h, color: styleWhiteCol),
                                    CustomStyle.sizedBoxWidth(5.0.w),
                                    Text(
                                      textAlign: TextAlign.center,
                                      Strings.of(context)?.get("confirm") ??
                                          "Not Found",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize16, styleWhiteCol),
                                    ),
                                  ])))),
                ],
              )),
        )
    );
  }
}