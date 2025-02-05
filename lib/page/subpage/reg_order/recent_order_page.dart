import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class RecentOrderPage extends StatefulWidget {

  String? custId;
  String? deptId;

  RecentOrderPage({Key? key, this.custId,this.deptId}):super(key:key);

  _RecentOrderPageState createState() => _RecentOrderPageState();
}

class _RecentOrderPageState extends State<RecentOrderPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mList = List.empty(growable: true).obs;

  var scrollController = ScrollController();

  DateTime _focusedDay = DateTime.now();
  final _rangeStart = DateTime.now().add(const Duration(days: -30)).obs;
  final _rangeEnd = DateTime.now().obs;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  final page = 1.obs;
  final totalPage = 1.obs;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initView() async {
  }

  Widget orderItemFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.getRecentOrder(
            context,
            Util.getTextDate(_rangeStart.value),
            Util.getTextDate(_rangeEnd.value),
            widget.custId,
            widget.deptId,
            page.value
        ),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Expanded(child: Container(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator())
            ));
          }else {
            if (snapshot.hasData) {
              if (mList.isNotEmpty) mList.clear();
              mList.addAll(snapshot.data["list"]);
              totalPage.value = snapshot.data?["total"];
              return orderListWidget();
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
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Widget orderListWidget() {
    return mList.isNotEmpty
        ? Expanded(child: ListView.builder(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      shrinkWrap: true,
      itemCount: mList.length,
      itemBuilder: (context, index) {
        var item = mList[index];
        return getListCardView(item);
      },
    ))
        : Expanded(
        child: Container(
            alignment: Alignment.center,
            child: Text(
              Strings.of(context)?.get("empty_list") ?? "Not Found",
              style: CustomStyle.baseFont(),
            )));
  }

  Widget getListCardView(OrderModel? item) {
      return Container(
          padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0.w),right: CustomStyle.getWidth(10.0.w),top: CustomStyle.getHeight(10.0.h)),
          child: InkWell(
              onTap: () {
                Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_WORK_RECENT_ORDER, Const.ORDER_VO:item});
              },
              child: Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  color: styleWhiteCol,
                  child: Container( 
                    padding: EdgeInsets.all(10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.h)),
                            child: Text(
                                Util.getAllDate2(item?.regdate),
                              style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
                            )
                        ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(10.w)),
                          child: Text(
                            "■",
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                        ),
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.visible,
                            text:TextSpan(
                              text: item?.sComName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                          )
                        )
                      ],
                      ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(10.w)),
                            child: Text(
                              "■",
                              style: CustomStyle.CustomFont(styleFontSize14, light_gray1),
                            )
                        ),
                        Flexible(
                        child: RichText(
                          overflow: TextOverflow.visible,
                            text:TextSpan(
                            text: item?.sAddr??"",
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                            )
                          )
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h)),
                      child: Row(
                        children: [
                          Icon(Icons.more_vert,size: 24.h,color: light_gray2),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                            child: Text(
                              Util.makeDistance(item?.distance),
                              style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                            ),
                          ),
                          Text(
                            Util.makeTime(item?.time??0),
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                          )
                        ],
                      )
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(10.w)),
                            child: Text(
                              "■",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        ),
                        Flexible(
                          child: RichText(
                          overflow: TextOverflow.visible,
                            text:TextSpan(
                              text: item?.eComName??"",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                          )
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: CustomStyle.getWidth(5.w),right: CustomStyle.getWidth(10.w)),
                            child: Text(
                              "■",
                              style: CustomStyle.CustomFont(styleFontSize14, light_gray1),
                            )
                        ),
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.visible,
                            text:TextSpan(
                              text:
                              "${item?.eAddr}",
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                            )
                          )
                        )
                      ],
                    ),
                    ]
                  )
                )
              )
          )
      );
  }

  Future openCalendarDialog() {
    _focusedDay = DateTime.now();
    DateTime? _tempSelectedDay = null;
    DateTime? _tempRangeStart = _rangeStart.value;
    DateTime? _tempRangeEnd = _rangeEnd.value;
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
                        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
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
                            child: Column(
                                children: [
                                  TableCalendar(
                                    locale: 'ko_KR',
                                    rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) :CustomStyle.getHeight(45.h) ,
                                    firstDay: DateTime.utc(2010, 1, 1),
                                    lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                    daysOfWeekHeight: 32 * MediaQuery.of(context).textScaleFactor,
                                    headerStyle: HeaderStyle(
                                      // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                      formatButtonVisible: false,
                                      // 달력 타이틀을 센터로
                                      titleCentered: true,
                                      // 말 그대로 타이틀 텍스트 스타일링
                                      titleTextStyle:   CustomStyle.CustomFont(
                                          styleFontSize16, Colors.black,font_weight: FontWeight.w700
                                          ),
                                          rightChevronIcon: Icon(Icons.chevron_right,size: 26.h),
                                          leftChevronIcon: Icon(Icons.chevron_left, size: 26.h),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      // 오늘 날짜에 하이라이팅의 유무
                                      isTodayHighlighted: false,
                                      // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                      defaultDecoration: BoxDecoration(
                                        color: order_item_background,
                                        shape: BoxShape.rectangle,
                                      ),
                                      // 캘린더의 주말 배경 스타일링
                                      weekendDecoration:  BoxDecoration(
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
                                      withinRangeTextStyle: const TextStyle(),

                                      // startDay, endDay 사이의 모양 조정
                                      withinRangeDecoration:
                                      const BoxDecoration(),
                                    ),
                                    //locale: 'ko_KR',
                                    focusedDay: _focusedDay,
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
                                          _focusedDay = focusedDay;
                                          _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                        });
                                      }
                                    },
                                    onRangeSelected: (start, end, focusedDay) {
                                      setState(() {
                                        _tempSelectedDay = start;
                                        _focusedDay = focusedDay;
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
                                      _focusedDay = focusedDay;
                                    },
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
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
                                              }else if(diff_day! > 30){
                                                return Util.toast(Strings.of(context)?.get("dateOver")??"Not Found");
                                              }
                                              _rangeStart.value = _tempRangeStart!;
                                              _rangeEnd.value = _tempRangeEnd!;
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

  Widget calendar_st_en_widget() {
    return InkWell(
        onTap: () async {
          await openCalendarDialog();
        },
        child: Container(
            padding: EdgeInsets.symmetric(
                vertical: CustomStyle.getHeight(20.h),
                horizontal: CustomStyle.getWidth(10.w)),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.w)),
                    child: Text(
                      _rangeStart.value == null
                          ? "-"
                          : "${_rangeStart.value?.year}년 ${_rangeStart.value?.month}월 ${_rangeStart.value?.day}일",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_02),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: CustomStyle.getWidth(5.w)),
                  child: Text(
                    " ~ ",
                    style:
                        CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(right: CustomStyle.getWidth(10.w)),
                    child: Text(
                      _rangeEnd.value == null
                          ? "-"
                          : "${_rangeEnd.value?.year}년 ${_rangeEnd.value?.month}월 ${_rangeEnd.value?.day}일",
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_02),
                    ))
              ],
            )));
  }

  Widget getListItemView(OrderModel item) {
    return InkWell(
        onTap: (){
          Navigator.of(context).pop({'code':200,'cust':item, "nonCust":false});
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
            child: Row(
              children: [
                Text(
                  item.custName??"",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getHeight(5.0.w)),
                    child: Text(
                      item.deptName??"",
                      style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
                    )
                ),
                CustomStyle.getDivider1()
              ],
            )
        )
    );
  }

  Widget searchListWidget(){
    return Container(
      child: mList.isNotEmpty
          ? Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: mList.length,
            itemBuilder: (context, index) {
              var item = mList[index];
              return getListItemView(item);
            },
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
                    Strings.of(context)?.get("order_recent_order_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.black)
                ),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
                ),
              ),
          body: SafeArea(
              child: Obx((){
                 return SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        calendar_st_en_widget(),
                        orderItemFuture()
                      ],
                    )
                );
              })
          ),
        )
    );
  }

}