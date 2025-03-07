import 'dart:convert';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/dept_model.dart';
import 'package:logislink_tms_flutter/common/model/monitor_order_model.dart';
import 'package:logislink_tms_flutter/common/model/monitor_profit_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

import '../../common/config_url.dart';

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
  final mList = List.empty(growable: true).obs;

  final mDeptId = "".obs;
  final mDeptUserId = "".obs;
  final tvDept = "전체".obs;
  final tvDeptUser = "전체".obs;

  //부서별 손익 Fragment
  final tvSellTotal = "".obs;
  final tvBuyTotal = "".obs;
  final tvProfitTotal = "".obs;
  final tvProfitPercentTotal = "".obs;

  final adapter01 = {}.obs;
  final adapter02 = {}.obs;
  final adapter03 = {}.obs;
  final adapter04 = {}.obs;


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
  });

  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    await initView();
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
  if(mTabCode.value == "01") {
    await getMonitorDeptList();
  }else if(mTabCode.value == "02"){
    await getMonitorDeptProfit();
  }else if(mTabCode.value == "03"){
    await getMonitorCustProfit();
  }
}

Future<void> backMonth(String? code) async {
  focusDate.value = DateTime(focusDate.value.year,focusDate.value.month-1);
  startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
  endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  if(mTabCode.value == "01") {
    await getMonitorOrder();
  }else if(mTabCode.value == "02"){
    await getMonitorDeptProfit();
  }else if(mTabCode.value == "03"){
    await getMonitorCustProfit();
  }else if(mTabCode.value== "04"){

  }
}

Future<void> nextMonth(String? code) async {
  focusDate.value = DateTime(focusDate.value.year,focusDate.value.month+1);
  startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
  endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  if(mTabCode.value == "01") {
    await getMonitorOrder();
  }else if(mTabCode.value == "02"){
    await getMonitorDeptProfit();
  }else if(mTabCode.value == "03"){
    await getMonitorCustProfit();
  }else if(mTabCode.value== "04"){

  }
}

Future<void> _handleTabSelection() async {
  if (_tabController.indexIsChanging) {
    // 탭이 변경되는 중에만 호출됩니다.
    // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
    int selectedTabIndex = _tabController.index;
    switch(selectedTabIndex) {
      case 0 :
        mTabCode.value = "01";
        await initView();
        break;
      case 1 :
        mTabCode.value = "02";
        await initView();
        break;
      case 2 :
        mTabCode.value = "03";
        await initView();
        break;
    }
  }
}

Widget calendarWidget(String? code) {
  var mCal = Util.getDateCalToStr(focusDate.value, "yyyy-MM-dd");
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
    color: styleWhiteCol,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: (){backMonth(code);},
                alignment: Alignment.center,
                icon: Icon(Icons.keyboard_arrow_left_outlined,size: 26.h,color: text_color_01)
            )
        ),
        Expanded(
            flex: 1,
            child: Text(
                "${mCal.split("-")[0]}년 ${mCal.split("-")[1]}월",
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.center,
            )
        ),
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: (){nextMonth(code);},
                alignment: Alignment.center,
                icon: Icon(Icons.keyboard_arrow_right_outlined,size: 26.h,color: text_color_01)
            )
        )
      ],
    ),
  );
}

Widget getTabFuture() {
  return tabBarViewWidget();
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
            await getMonitorCustProfit();
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
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getDeptList(
        mUser.value.authorization,
        user.custId
    ).then((it) async {
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
          await Util.setEventLog(URL_MONITOR_ORDER, "포인트조회 - 오더&배차");
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
              MonitorOrderModel? monitorOrder = MonitorOrderModel.fromJSON(list[0]);
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
            List<MonitorProfitModel> itemsList = list.map((i) => MonitorProfitModel.fromJSON(i)).toList();
            mUserList.value = itemsList;

            var deptList = List.empty(growable: true);
            if (!(mDeptId.value == "" || mDeptId.value == null)) {
              for (var data in mDeptList) {
                if (data.deptId == mDeptId.value) {
                  deptList.add(data);
                }
              }
            } else {
              deptList.addAll(mDeptList);
            }
            int sellTotal = mUserList.fold(0,(value, element) => value + element.sellCharge as int);
            tvSellTotal.value = sellTotal.toString();
            adapter01.value = {'deptList': deptList, 'userList': mUserList.value, 'code': "01"};

            int buyTotal = mUserList.fold(0, (value, element) => value + element.buyCharge as int);
            tvBuyTotal.value = buyTotal.toString();
            adapter02.value = {"deptList": deptList, "userList": mUserList.value, "code": "02"};

            int profitTotal = mUserList.fold(0, (value, element) => value + element.profitCharge as int);
            tvProfitTotal.value = profitTotal.toString();
            adapter03.value = {"deptList": deptList, "userList": mUserList.value, "code": "03"};

            double profitPercentTotal = Util.getInCodePercent(int.parse(tvProfitTotal.value), int.parse(tvSellTotal.value));
            tvProfitPercentTotal.value = profitPercentTotal.toString();
            adapter04.value = {"deptList": deptList, "userList": mUserList.value, "code": "04"};
            await Util.setEventLog(URL_MONITOR_DEPT_PROFIT, "포인트조회 - 부서별손익");
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
    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(5.w)),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: line, width: 1.w
        )
      )
    ),
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
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7.h),horizontal: CustomStyle.getWidth(15.w)),
              child: Text(
                tvDept.value,
                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
              )
          ),
        ),
        mTabCode.value == "01" ?
        InkWell(
          onTap: (){
            if(mDeptId.value.isEmpty) {
              Util.toast("담당부서를 지정해 주세요.");
              return;
            }
            ShowCodeDialogWidget(context:context, mTitle: "배차담당자", codeType: Const.DEPT_USER, mFilter: mDeptId.value, callback: selectDeptUserId).showDialog();
          },
          child: Container(
              margin: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
              decoration: BoxDecoration(
                  color: sub_color,
                  borderRadius: BorderRadius.circular(3.w)
              ),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(7.h),horizontal: CustomStyle.getWidth(15.w)),
              child: Text(
                tvDeptUser.value,
                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
              )
          ),
        ) : const SizedBox()
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
        color: renew_main_color2,
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
          color: renew_main_color2,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
    children: [
      calendarWidget(code),
      deptSelectWidget(),
      orderStateWidget(),
      kpiWidget()
    ],
  )
  );
}

  Widget deptProfitFragment(String? code) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: Column(
          children: [
            calendarWidget(code),
            CustomStyle.getDivider2(),
            deptSelectWidget(),
            deptProfitWidget()
          ],
        ))
      ],
    );
  }

  Widget deptProfitWidget() {
  return Column(
      children: [
        // 1번째 Area
        deptListWidget("01"),
        // 2번째 Area
        deptListWidget("02"),
        // 3번째 Area
        deptListWidget("03"),
        // 4번째 Area
        deptListWidget("04")
      ],
  );
}

  Widget deptListWidget(String? code) {
    var adapter = code == "01"
        ? adapter01.value
        : code == "02"
            ? adapter02.value
            : code == "03"
                ? adapter03.value
                : adapter04;
    return Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            color: renew_main_color2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_dept_value_01")??"부서_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    Strings.of(context)?.get("monitor_dept_value_02")??"담당자_",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          code == "01" ? Strings.of(context)?.get("monitor_dept_item_value_01")??"매출액_" :
                          code == "02" ? Strings.of(context)?.get("monitor_dept_item_value_02")??"매입액_" :
                          code == "03" ? Strings.of(context)?.get("monitor_dept_item_value_03")??"한계이익_" :
                          Strings.of(context)?.get("monitor_dept_item_value_04")??"한계이익율_",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                        ),
                        Text(
                          code == "04" ? Strings.of(context)?.get("monitor_dept_item_value_unit_02")??"(%)_" : Strings.of(context)?.get("monitor_dept_item_value_unit_01")??"(원)_",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, Colors.white),
                        ),
                      ],
                    )
                )
              ],
            ),
          ),
      Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h)),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("total") ?? "합계_",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                )),
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomStyle.getWidth(20.w)),
                    child: Text(
                      "${Util.getInCodeCommaWon(code == "01" ? tvSellTotal.value : code == "02" ? tvBuyTotal.value : code == "03" ? tvProfitTotal.value : tvProfitPercentTotal.value )} ${code == "04" ? "%" : ""}",
                      textAlign: TextAlign.right,
                      style: CustomStyle.CustomFont(
                          styleFontSize14, text_color_01),
                    ))),
          ],
        ),
      ),
      CustomStyle.getDivider1(),
      Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20.w)),
          child: adapter["deptList"] != null
              ? Column(
                  children: List.generate(adapter["deptList"].length, (index) {
                    var item = adapter["deptList"][index];
                    return deptItemView(item, code);
                  }),
                )
              : const SizedBox())
    ]);
  }

  Widget deptItemView(DeptModel item,String? code) {
    var adapter = code == "01" ? adapter01.value : code == "02" ? adapter02.value : code == "03" ? adapter03.value : adapter04.value;
    List<MonitorProfitModel> _userList = List.empty(growable: true);
    for(MonitorProfitModel user in mUserList.value) {
      if(item.deptName == user.deptName) {
        _userList.add(user);
      }
    }
    int sum = 0;
    String subTotal = "0";
    switch(code) {
      case "01" :
        sum = _userList.fold(sum, (value, element) => value + (element.sellCharge??0));
        subTotal = Util.getInCodeCommaWon(sum.toString());
        break;
      case "02" :
        sum = _userList.fold(sum, (value, element) => value + (element.buyCharge??0));
        subTotal = Util.getInCodeCommaWon(sum.toString());
        break;
      case "03" :
        sum = _userList.fold(sum, (value, element) => value + (element.profitCharge??0));
        subTotal = Util.getInCodeCommaWon(sum.toString());
        break;
      case "04" :
        sum = _userList.fold(sum, (value, element) => value + (element.sellCharge??0));
        int sum2 = _userList.fold(0, (value, element) => value + (element.profitCharge??0));
        subTotal = "${Util.getInCodePercent(sum2, sum)}%";
        break;
    }
    _userList.add(MonitorProfitModel(userName: Strings.of(context)?.get("sub_total")??"소계_",subTotal: subTotal));
    adapter["userList"] = _userList;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.deptName??"",
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          ),
        ),
        Expanded(
          flex: 5,
          child: adapter["userList"] != null ? Column(
              children: List.generate(adapter["userList"].length, (index) {
                      var item = adapter["userList"][index];
                      return userItemView(item,code);
                    })
          ) : const SizedBox()
        )
      ],
    );
  }

  Widget userItemView(MonitorProfitModel item,String? code) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
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
            item.userName??"",
            textAlign: TextAlign.center,
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          )
          ),
          Expanded(
              flex: 5,
              child: Text(
                code == "01" ?
                    item.userName == Strings.of(context)?.get("sub_total") ? item.subTotal??"0" : Util.getInCodeCommaWon((item.sellCharge??0).toString()) :
                code == "02" ?
                  item.userName == Strings.of(context)?.get("sub_total") ? item.subTotal??"0" : Util.getInCodeCommaWon((item.buyCharge??0).toString()) :
                code == "03" ?
                  item.userName == Strings.of(context)?.get("sub_total") ? item.subTotal??"0" : Util.getInCodeCommaWon((item.profitCharge??0).toString()) :
                  item.userName == Strings.of(context)?.get("sub_total") ? item.subTotal??"0" : "${item.profitPercent??0} %",
                textAlign: TextAlign.right,
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              )
          ),
        ],
      )
    );
  }

Widget custProfitFragment(String? code) {
  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
          child: Column(
            children: [
              calendarWidget(code),
              CustomStyle.getDivider2(),
              deptSelectWidget(),
              custProfitWidget()
            ],
          ))
    ],
  );
}

Widget custProfitWidget() {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(10.w),
        color: renew_main_color2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                Strings.of(context)?.get("monitor_dept_value_01")??"부서_",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                Strings.of(context)?.get("monitor_dept_value_02")??"담당자_",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
              ),
            ),
            Expanded(
                flex: 1,
                child: Text(
                      Strings.of(context)?.get("sub_total")??"소계_",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                    ),
            )
          ],
        ),
      ),
      Column(
        children: List.generate(mList.length, (index) {
          var item = mList[index];
          return custItemView(item);
        }),
      )
    ],
  );
}

Future<void> getMonitorCustProfit() async {
  Logger logger = Logger();
  await pr?.show();
  await DioService.dioClient(header: true).getMonitorCustProfit(
      mUser.value.authorization,
      Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
      Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
      mDeptId.value
  ).then((it) async {
    await pr?.hide();
    ReturnMap response = DioService.dioResponse(it);
    logger.d("getMonitorCustProfit() _response -> ${response.status} // ${response.resultMap}");
    if(response.status == "200") {
      if (response.resultMap?["data"] != null) {
        var list = response.resultMap?["data"] as List;
        List<MonitorProfitModel> itemsList = list.map((i) => MonitorProfitModel.fromJSON(i)).toList();
        if(mList.isNotEmpty) mList.clear();
        mList.addAll(itemsList);

        MonitorProfitModel data = MonitorProfitModel();
        if(mList.length == 0) {
          data = MonitorProfitModel(custName: Strings.of(context)?.get("total") , profitPercent: 0.0, buyAmt: 0, sellAmt: 0, profitAmt: 0 );
        }else{
          int sellAmt = mList.fold(0,(value, element) => value + element.sellAmt as int);
          int buyAmt = mList.fold(0, (value, element) => value + element.buyAmt as int);
          int profitAmt = mList.fold(0, (value, element) => value + element.profitAmt as int);
          double profitPercent = Util.getInCodePercent(profitAmt, sellAmt);

          data = MonitorProfitModel(custName: Strings.of(context)?.get("total"),profitPercent: profitPercent, buyAmt: buyAmt, sellAmt: sellAmt, profitAmt: profitAmt);
        }
        mList.value.insert(0, data);
        await Util.setEventLog(URL_MONITOR_CUST_PROFIT, "포인트조회 - 거래처별손익");
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
        print("getMonitorCustProfit() Error => ${res?.statusCode} // ${res?.statusMessage}");
        break;
      default:
        print("getMonitorCustProfit() Error Default => ");
        break;
    }
  });
}

Widget custItemView(MonitorProfitModel data) {
  return Container(
    padding: EdgeInsets.all(5.w),
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
          flex: 1,
          child: Text(
            data.custName??"",
            textAlign: TextAlign.center,
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          ),
        ),
       Expanded(
         flex: 1,
           child: Column(
         children: [
           Container(
             padding: EdgeInsets.all(5.w),
             alignment: Alignment.center,
             child: Text(
               Strings.of(context)?.get("monitor_cust_item_value_01")??"매출_",
               style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
             ),
           ),
           Container(
             padding: EdgeInsets.all(5.w),
             alignment: Alignment.center,
             child: Text(
               Strings.of(context)?.get("monitor_cust_item_value_02")??"매입_",
               style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
             ),
           ),
           Container(
             padding: EdgeInsets.all(5.w),
             alignment: Alignment.center,
             child: Text(
               Strings.of(context)?.get("monitor_cust_item_value_03")??"이익_",
               style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
             ),
           ),
           Container(
             padding: EdgeInsets.all(5.w),
             alignment: Alignment.center,
             child: Text(
               Strings.of(context)?.get("monitor_cust_item_value_04")??"%_",
               style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
             ),
           )
         ],
       )
      ),
      Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                alignment: Alignment.centerRight,
                child: Text(
                  Util.getInCodeCommaWon(data.sellAmt.toString()),
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                alignment: Alignment.centerRight,
                child: Text(
                  Util.getInCodeCommaWon(data.buyAmt.toString()),
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                alignment: Alignment.centerRight,
                child: Text(
                  Util.getInCodeCommaWon(data.profitAmt.toString()),
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                alignment: Alignment.centerRight,
                child: Text(
                  "${data.profitPercent}%",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
              )
            ],
          )
      ),
    ],
  )
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
                      style: TextStyle(
                  fontSize: styleFontSize14,
                )
                    ),
          ),
          Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("monitor_value_02")??"Not Found",
                style: TextStyle(
                  fontSize: styleFontSize14,
                )
              ),
          ),
          Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                Strings.of(context)?.get("monitor_value_03")??"Not Found",
                style: TextStyle(
                  fontSize: styleFontSize14,
                )
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
  return WillPopScope(
      onWillPop: () async {
        return Future((){
          FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
          return true;
        });
      } ,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
              centerTitle: true,
              toolbarHeight: 50.h,
              title: Text(
                  Strings.of(context)?.get("monitor_title")??"Not Found",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,Colors.black)
              ),
              leading: IconButton(
                onPressed: () async {
                  FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.close,size: 24.h,color: Colors.black),
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
  ));
}
  
}