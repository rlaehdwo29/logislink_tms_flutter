import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/dept_model.dart';
import 'package:logislink_tms_flutter/common/model/monitor_order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class AppBarMonitorPage extends StatefulWidget {
  AppBarMonitorPage({Key? key}):super(key: key);

  _AppBarMonitorPageState createState() => _AppBarMonitorPageState();
}

class _AppBarMonitorPageState extends State<AppBarMonitorPage> with TickerProviderStateMixin {
  final controller = Get.find<App>();

  final mCarBookList = List.empty(growable: true).obs;
  final mCarList = List.empty(growable: true).obs;
  final focusDate = DateTime.now().obs;
  final startDate = DateTime(DateTime.now().year,DateTime.now().month,1).obs;
  final endDate = DateTime(DateTime.now().year,DateTime.now().month+1,0).obs;
  final mTabCode = "01".obs;
  late TabController _tabController;

  ProgressDialog? pr;

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  final mUser = UserModel().obs;
  final mMonitor = MonitorOrderModel().obs;
  final mDeptList = List.empty(growable: true).obs;
  final mUserList = List.empty(growable: true).obs;

  final mDeptId = "전체".obs;
  final mDeptUserId = "전체".obs;
  final tvDept = "전체".obs;
  final tvDeptUser = "전체".obs;

@override
void initState() {
  super.initState();

  startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
  endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  _tabController = TabController(
      length: 3,
      vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
      initialIndex: 0
  );
  _tabController.addListener(_handleTabSelection);

  Future.delayed(Duration.zero, () async {
    await initView();
  });

  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    await getTabApi(mTabCode.value);
  });

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

}

Future<void> initView() async {
  mUser.value = await controller.getUserInfo();
  mDeptId.value = mUser.value.deptId??"전체";
  tvDept.value = mUser.value.deptName??"";
  await getMonitorDeptList();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
}

Future<void> onCallback(bool? reload,String? code) async {
  if(reload == true){
    if(code?.isNotEmpty == true) {
      await getTabApi(code);
    }else{
      await getTabApi(mTabCode.value);
    }
  }
}

Future<void> backMonth(String? code) async {
  focusDate.value = DateTime(focusDate.value.year,focusDate.value.month-1);
  startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
  endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  await getMonitorOrder();
  //await getTabApi(code);
}

Future<void> nextMonth(String? code) async {
  focusDate.value = DateTime(focusDate.value.year,focusDate.value.month+1);
  startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
  endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  await getMonitorOrder();
  //await getTabApi(code);
}

Future<void> _handleTabSelection() async {
  if (_tabController.indexIsChanging) {
    // 탭이 변경되는 중에만 호출됩니다.
    // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
    int selectedTabIndex = _tabController.index;
    switch(selectedTabIndex) {
      case 0 :
        mTabCode.value = "01";
        break;
      case 1 :
        mTabCode.value = "02";
        break;
      case 2 :
        mTabCode.value = "03";
        break;
      case 3 :
        mTabCode.value = "04";
        break;
    }
    await getTabApi(mTabCode.value);
  }
}

void goToCarList() {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => CarListPage(onCallback)));
}

void goToCarReg() {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(null,onCallback)));
}

void goToCarEdit() {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(mCar.value,onCallback)));
}


void goToCarBookReg() {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(mTabCode.value,null,onCallback)));
}

Widget calendarWidget(String? code) {
  var mCal = Util.getDateCalToStr(focusDate.value, "yyyy-MM-dd");
  return Container(
    color: styleWhiteCol,
    width: MediaQuery.of(context).size.width,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: (){backMonth(code);},
                icon: Icon(Icons.keyboard_arrow_left_outlined,size: 32.w,color: text_color_01)
            )
        ),
        Expanded(
            flex: 1,
            child: Text(
                "${mCal.split("-")[0]}년 ${mCal.split("-")[1]}월",
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black)
            )
        ),
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: (){nextMonth(code);},
                icon: Icon(Icons.keyboard_arrow_right_outlined,size: 32.w,color: text_color_01)
            )
        )
      ],
    ),
  );
}

Widget getTabFuture() {
  return tabBarViewWidget();
  /*final appbarService = Provider.of<AppbarService>(context);
  return FutureBuilder(
      future: appbarService.getTabList(
          mCar.value.carSeq,
          Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
          Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
          mTabCode.value
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          mCarBookList.value = snapshot.data;
          return tabBarViewWidget();
        }else if(snapshot.hasError) {
          return  Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
            alignment: Alignment.center,
            child: Text(
                "${Strings.of(context)?.get("empty_list")}",
                style: CustomStyle.baseFont()),
          );
        }
        return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            backgroundColor: styleGreyCol1,
          ),
        );
      }
  );*/
}

Future<void> getTabApi(String? tabValue) async {
  /*
  Logger logger = Logger();
  await pr?.show();
  await DioService.dioClient(header: true).getCarBook(
      app.value.authorization,
      mCar.value.carSeq,
      Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
      Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
      tabValue
  ).then((it) async {
    await pr?.hide();
    ReturnMap response = DioService.dioResponse(it);
    logger.d("getTabApi() _response -> ${response.status} // ${response.resultMap}");
    if(response.status == "200") {
      if (response.resultMap?["data"] != null) {
        var list = response.resultMap?["data"] as List;
        List<CarBookModel> itemsList = list.map((i) => CarBookModel.fromJSON(i)).toList();
        if(mCarBookList.isNotEmpty) mCarBookList.clear();
        mCarBookList.value?.addAll(itemsList);
      }else{
        mCarBookList.value = List.empty(growable: true);
      }
    }
    setState(() {});
  }).catchError((Object obj) async {
    await pr?.hide();
    switch (obj.runtimeType) {
      case DioError:
      // Here's the sample to get the failed response error code and message
        final res = (obj as DioError).response;
        print("getTabApi() Error => ${res?.statusCode} // ${res?.statusMessage}");
        break;
      default:
        print("getTabApi() Error Default => ");
        break;
    }
  });*/
}

Widget tabBarValueWidget(String? tabValue) {
  Widget _widget = orderFragment(tabValue);
  switch(tabValue) {
    case "01" :
      _widget = orderFragment(tabValue);
      break;
    case "02" :
      _widget = deptProfitFragment(tabValue);
      break;
    case "03" :
      _widget = custProfitFragment(tabValue);
      break;
  }
  return _widget;
}

  Future<void> selectDept(CodeModel? codeModel,String? codeType) async {
    print("ㅇㅇㅇㅇㅇ=>${codeModel?.code} // ${codeModel?.codeName} // ${codeType}");
    if(codeType != "") {
      switch (codeType) {
        case 'DEPT' :
          mDeptId.value = codeModel?.code??"";
          mDeptUserId.value = "";

          tvDept.value = codeModel?.codeName??"";
          tvDeptUser.value = "전체";

          if(mTabCode.value == "01") {
            await getMonitorOrder();
          } else if(mTabCode.value == "02") {
            await getMonitorDeptProfit();
          }else if(mTabCode.value == "03") {

          }
          break;
      }
    }
    setState(() {});
  }

  Future<void> selectDeptUserId(CodeModel? codeModel,String? codeType) async {

    if(codeType != "") {
      switch (codeType) {
        case 'DEPT_USER' :
          mDeptUserId.value = codeModel?.code??"";
          tvDeptUser.value = codeModel?.codeName??"";

          await getMonitorOrder();
          break;
      }
    }
    setState(() {});
  }

  Future<void> getMonitorDeptList() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getDeptList(mUser.value.authorization).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getMonitorDeptList() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          var list = response.resultMap?["data"] as List;
          List<DeptModel> itemsList = list.map((i) => DeptModel.fromJSON(i)).toList();
          if(mDeptList.isNotEmpty) mDeptList.clear();
          mDeptList.addAll(itemsList);

          List<CodeModel> codeList = List.empty(growable: true);
          if(Util.ynToBoolean(mUser.value.masterYn)) {
            codeList.add(CodeModel(code: "",codeName: "전체"));
          }
          for(var data in mDeptList) {
            codeList.add(CodeModel(code: data.deptId, codeName: data.deptName));
          }
          var mapList = ({
            "data": codeList
          });
          var jsonString = jsonEncode(mapList);
          await SP.putCodeList(Const.DEPT, jsonString);

          await getMonitorOrder();
        }else{
          mDeptList.value = List.empty(growable: true);
        }
      }
      setState(() {});
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getMonitorDeptList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getMonitorDeptList() Error Default => ");
          break;
      }
    });
  }

  Future<void> getMonitorOrder() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getMonitorOrder(
        mUser.value.authorization,
        Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
        Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
        mDeptId.value,
        mDeptUserId.value
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getMonitorOrder() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
            var list = response.resultMap?["data"] as List;
            if (list != null && list.length > 0) {
              MonitorOrderModel? monitorOrder = MonitorOrderModel.fromJSON(
                  list[0]);
              mMonitor.value = monitorOrder;
            }
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getMonitorOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getMonitorOrder() Error Default => ");
          break;
      }
    });
  }

  Future<void> getMonitorDeptProfit() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getMonitorDeptProfit(
        mUser.value.authorization,
        Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
        Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
        mDeptId.value
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getMonitorDeptProfit() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          var list = response.resultMap?["data"] as List;
          List<UserModel> itemsList = list.map((i) => UserModel.fromJSON(i)).toList();
          if(mUserList.isNotEmpty) mUserList.clear();
          mUserList?.addAll(itemsList);

          List<DeptModel> deptList = List.empty(growable: true);
          if(!(mDeptId.value == "")) {
            for(var data in mDeptList) {
              if(data.deptId == mDeptId) {
                deptList.add(data);
              }
            }
          }else{
            deptList.addAll(mDeptList.value);
          }
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getMonitorDeptProfit() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getMonitorDeptProfit() Error Default => ");
          break;
      }
    });
  }

  Widget deptSelectWidget() {
  return Container(
    padding: EdgeInsets.all(5.w),
    child: Row(
      children: [
        InkWell(
          onTap: (){
            ShowCodeDialogWidget(context:context, mTitle: "담당부서", codeType: Const.DEPT, mFilter: "", callback: selectDept).showDialog();
          },
          child: Container(
              decoration: BoxDecoration(
                  color: sub_color,
                  borderRadius: BorderRadius.circular(3.w)
              ),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7.h),horizontal: CustomStyle.getWidth(30.w)),
              child: Text(
                tvDept.value,
                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
              )
          ),
        ),
      ],
    ),
  );
  }

  Widget orderStateWidget() {
  return Column(
    children: [
      // 구분 / 오더 현황
      Container(
        padding: EdgeInsets.all(10.w),
        color: main_color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                Strings.of(context)?.get("monitor_order_value_01")??"구분_",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Strings.of(context)?.get("monitor_order_item_order")??"오뎌헌황_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                ),
                Text(
                  Strings.of(context)?.get("monitor_order_item_order_unit")??"(건, %)_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                ),
              ],
              )
            )
          ],
        ),
      ),
      //전체 오더
      Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: line,
              width: 0.5.w
            )
          )
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                Strings.of(context)?.get("monitor_order_item_order_value_01")??"전체오더_",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  Util.getInCodeCommaWon((mMonitor.value.allocCnt??0).toString()),
                  textAlign: TextAlign.right,
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                )
            ),
          ],
        ),
      ),
      // 사전오더
      Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h),horizontal: CustomStyle.getWidth(10.w)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: line,
                    width: 0.5.w
                )
            )
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  Strings.of(context)?.get("monitor_order_item_order_value_02")??"사전오더_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  Strings.of(context)?.get("sub_total")??"소계_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                )
            ),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Util.getInCodeCommaWon((mMonitor.value.preOrder??0).toString()),
                    textAlign: TextAlign.right,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                    child: Text(
                      Util.getPercent(mMonitor.value.preOrder??0, mMonitor.value.allocCnt??0),
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    )
                  )
                ],
                )
            ),
          ],
        ),
      ),
      // 당일오더
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: line,
                    width: 0.5.w
                )
            )
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left:CustomStyle.getWidth(10.w),top: CustomStyle.getHeight(15.h),bottom: CustomStyle.getHeight(15.h)),
                    child: Text(
                    Strings.of(context)?.get("monitor_order_item_order_value_03")??"당일오더_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
                )
            ),
            Expanded(
              flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: line,
                        width: 0.5.w
                      )
                    )
                  ),
                    child:Column(
                  children: [
                    //당일오더 -> 소계
                    Container(
                      padding: EdgeInsets.only(right:CustomStyle.getWidth(10.w),bottom: CustomStyle.getHeight(5.h),top: CustomStyle.getHeight(5.h)),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: line,
                            width: 0.5.w
                          )
                        )
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                Strings.of(context)?.get("sub_total")??"소계_",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                              )
                          ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Util.getInCodeCommaWon((mMonitor.value.todayOrder??0).toString()),
                                    textAlign: TextAlign.right,
                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                      child: Text(
                                        Util.getPercent(mMonitor.value.todayOrder??0, mMonitor.value.allocCnt??0),
                                        textAlign: TextAlign.right,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      )
                                  )
                                ],
                              )
                          ),
                        ],
                      )
                    ),
                    // 당일오더 -> 당착
                    Container(
                        padding: EdgeInsets.only(right:CustomStyle.getWidth(10.w),bottom: CustomStyle.getHeight(5.h),top: CustomStyle.getHeight(5.h)),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: line,
                                    width: 0.5.w
                                )
                            )
                        ),
                        child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              Strings.of(context)?.get("monitor_order_item_order_value_03_01")??"당착_",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        ),
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Util.getInCodeCommaWon((mMonitor.value.todayFinish??0).toString()),
                                  textAlign: TextAlign.right,
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                    child: Text(
                                      Util.getPercent(mMonitor.value.todayFinish??0, mMonitor.value.todayOrder??0),
                                      textAlign: TextAlign.right,
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    )
                                )
                              ],
                            )
                        ),
                      ],
                    )
                  ),
                    // 당일오더 -> 익착
                    Container(
                        padding: EdgeInsets.only(right:CustomStyle.getWidth(10.w),bottom: CustomStyle.getHeight(5.h),top: CustomStyle.getHeight(5.h)),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                  Strings.of(context)?.get("monitor_order_item_order_value_03_02")??"익착_",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                )
                            ),
                            Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Util.getInCodeCommaWon((mMonitor.value.tomorrowFinish??0).toString()),
                                      textAlign: TextAlign.right,
                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                                        child: Text(
                                          Util.getPercent(mMonitor.value.tomorrowFinish??0, mMonitor.value.todayOrder??0),
                                          textAlign: TextAlign.right,
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        )
                                    )
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                  ],
                )
            )
            )
          ],
        ),
      ),
    ],
  );
  }

  Widget kpiWidget() {
    return Column(
      children: [
        // 구분 / 배차 KPI
        Container(
          padding: EdgeInsets.all(10.w),
          color: main_color,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  Strings.of(context)?.get("monitor_order_value_01")??"구분_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Strings.of(context)?.get("monitor_order_item_kpi")??"배차KPI_",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                      ),
                      Text(
                        Strings.of(context)?.get("monitor_order_item_kpi_unit")??"(건, %)_",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                      ),
                    ],
                  )
              )
            ],
          ),
        ),
        // 책임배차
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h),horizontal: CustomStyle.getWidth(10.w)),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: line,
                      width: 0.5.w
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_01")??"책임배차_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_01_01")??"미준수_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Util.getInCodeCommaWon((mMonitor.value.allocDelay??0).toString()),
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                          child: Text(
                            Util.getPercent(mMonitor.value.allocDelay??0, mMonitor.value.allocCnt??0),
                            textAlign: TextAlign.right,
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
        // 입차준수
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h),horizontal: CustomStyle.getWidth(10.w)),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: line,
                      width: 0.5.w
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_02")??"입차준수_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_02_01")??"미준수_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Util.getInCodeCommaWon((mMonitor.value.enterDelay??0).toString()),
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                          child: Text(
                            Util.getPercent(mMonitor.value.enterDelay??0, mMonitor.value.allocCnt??0),
                            textAlign: TextAlign.right,
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
        // 도착준수
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.h),horizontal: CustomStyle.getWidth(10.w)),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: line,
                      width: 0.5.w
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_03")??"도착준수_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_order_item_kpi_value_03_01")??"미준수_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Util.getInCodeCommaWon((mMonitor.value.finishDelay??0).toString()),
                        textAlign: TextAlign.right,
                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: CustomStyle.getHeight(10.h)),
                          child: Text(
                            Util.getPercent(mMonitor.value.finishDelay??0, mMonitor.value.allocCnt??0),
                            textAlign: TextAlign.right,
                            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        )
      ],
    );
  }

Widget orderFragment(String? code) {
  return SingleChildScrollView(
      child: Column(
    children: [
      calendarWidget(code),
      CustomStyle.getDivider2(),
      deptSelectWidget(),
      orderStateWidget(),
      kpiWidget()
    ],
  )
  );
}

Widget deptProfitFragment(String? code) {
  return SingleChildScrollView(
    child: Column(
      children: [
        calendarWidget(code),
        CustomStyle.getDivider2(),
        deptSelectWidget(),
      ],
    ),
  );
}

Widget custProfitFragment(String? code) {
  return Column(
    children: [
      calendarWidget(code),
      Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
          width: MediaQuery.of(context).size.width,
          color: main_color,
          child: Row(
              children : [
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_insurance_value_03")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_insurance_value_02")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_insurance_value_01")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                )
              ]
          )
      ),
      Expanded(
          child: mCarBookList.isNotEmpty
              ? SingleChildScrollView(
              child: Flex(
                  direction: Axis.vertical,
                  children: List.generate(
                    mCarBookList.length,
                        (index) {
                      var item = mCarBookList[index];
                      return InkWell(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: line,
                                          width: CustomStyle.getWidth(1.0)
                                      )
                                  )
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "${item.bookDate}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                  Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.memo}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    ),
                                  ),
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "${Util.getInCodeCommaWon(item.price.toString())}${Strings.of(context)?.get("won")??"Not found"}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                ],
                              )
                          )
                      );
                    },
                  )))
              : SizedBox(
            child: Center(
                child: Text(
                  Strings.of(context)?.get("empty_list") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize20, styleBlackCol1),
                )),
          ))
    ],
  );
}

Widget etcWidget(String? code) {
  return Column(
    children: [
      calendarWidget(code),
      Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
          width: MediaQuery.of(context).size.width,
          color: main_color,
          child: Row(
              children : [
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_etc_value_03")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_etc_value_02")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_etc_value_01")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                )
              ]
          )
      ),
      Expanded(
          child: mCarBookList.isNotEmpty
              ? SingleChildScrollView(
              child: Flex(
                  direction: Axis.vertical,
                  children: List.generate(
                    mCarBookList.length,
                        (index) {
                      var item = mCarBookList[index];
                      return InkWell(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: line,
                                          width: CustomStyle.getWidth(1.0)
                                      )
                                  )
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "${item.bookDate}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                  Expanded(
                                      flex:1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${item.memo}",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                          ),
                                          Text(
                                            "${Util.getInCodeCommaWon(item.price.toString())}원",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                          )
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "${Util.getInCodeCommaWon(item.mileage.toString())}${Strings.of(context)?.get("km")??"Not found"}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                ],
                              )
                          )
                      );
                    },
                  )))
              : SizedBox(
            child: Center(
                child: Text(
                  Strings.of(context)?.get("empty_list") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize20, styleBlackCol1),
                )),
          ))
    ],
  );
}

Widget tabBarViewWidget() {
  return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          tabBarValueWidget("01"),
          tabBarValueWidget("02"),
          tabBarValueWidget("03"),
        ],
      )
  );
}

Widget customTabBarWidget() {
  return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xff31363A),
      child: TabBar(
        tabs: [
          Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                      Strings.of(context)?.get("monitor_value_01")??"Not Found",
                    ),
          ),
          Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("monitor_value_02")??"Not Found",
              ),
          ),
          Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("monitor_value_03")??"Not Found",
              ),
          ),
        ],
        indicator: const BoxDecoration(
            color: Color(0xff31363A)
        ),
        labelColor: Colors.white,
        unselectedLabelColor: text_color_03,
        controller: _tabController,
      ));
}


@override
Widget build(BuildContext context) {
  pr = Util.networkProgress(context);
  return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
              centerTitle: true,
              title: Text(
                  Strings.of(context)?.get("monitor_title")??"Not Found",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.close,size: 28,color: styleWhiteCol),
              )
          )
      ),
      body: SafeArea(
          child: Obx(() {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customTabBarWidget(),
                    getTabFuture()
                  ]
          );
        }
        )
      )
  );
}
  
}