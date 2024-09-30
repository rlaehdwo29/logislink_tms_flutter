import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/notification_model.dart';
import 'package:logislink_tms_flutter/common/model/point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/order_detail_page.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/notification_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class PointPage extends StatefulWidget {

  PointPage({Key? key}):super(key: key);

  _PointPageState createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {

  final controller = Get.find<App>();
  final mList = List.empty(growable: true).obs;

  ProgressDialog? pr;

  var scrollController = ScrollController();
  final page = 1.obs;
  final totalPage = 1.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getPoint();

      scrollController.addListener(() async {
        var now_scroll = scrollController.position.pixels;
        var max_scroll = scrollController.position.maxScrollExtent;
        if((max_scroll - now_scroll) <= 300){
          if(page.value < totalPage.value){
            page.value++;
          }
        }
      });
    });
  }

  Future<void> getPoint() async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    mList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getTmsUserPointList(app.authorization,page.value).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("point_page.dart getUserPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<PointModel> itemsList = list.map((i) => PointModel.fromJSON(i)).toList();
            mList?.addAll(itemsList);
            int total = 0;
            if(_response.resultMap?["total"].runtimeType.toString() == "String") {
              total = int.parse(_response.resultMap?["total"]);
            }else{
              total = _response.resultMap?["total"];
            }
            totalPage.value = Util.getTotalPage(total);
          }catch(e) {
            print("point_page.dart getUserPoint() Error => $e");
          }
        }
      }else{
        mList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("point_page.dart getUserPoint() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("point_page.dart getUserPoint() Error Default => ");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(    // <-  WillPopScope로 감싼다.
        onWillPop: () async {

          return Future((){
            FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
            return true;
          });
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                  centerTitle: true,
                  title: Text("포인트 조회",
                      style: CustomStyle.appBarTitleFont(
                          styleFontSize18, Colors.black)
                  ),
                  toolbarHeight: 50.h,
                  leading: IconButton(
                    onPressed: () {
                      FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                      Navigator.of(context).pop();
                    },
                    color: styleWhiteCol,
                    icon: Icon(Icons.arrow_back,size: 24.h, color: Colors.black),
                  ),
                ),
            body: SafeArea(
                child: Container(
                    //width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                    //height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                    child: itemListFuture()
                )
            ))
    );
  }

  Widget getPointListWidget() {
    return mList.isNotEmpty ?
    Expanded(
      child: ListView.builder(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      shrinkWrap: true,
      itemCount: mList.length,
      itemBuilder: (context, index) {
        var item = mList[index];
        return Container(
          height: CustomStyle.getHeight(75.h),
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(17.w),vertical: CustomStyle.getWidth(7.w)),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1.h,
                      color: line
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Container(
                        padding:const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: item.ptypeCD == "SAVE" ? point_blue : item.ptypeCD == "MOVE" ? rpa_btn_modify : item.ptypeCD == "USE" ? point_red : text_color_01,
                            shape: BoxShape.circle,
                        ),
                      ),
                      Center(
                        child: Text(
                          item.ptypeCD == "SAVE" ? "적립" : item.ptypeCD == "MOVE" ? "이관" : item.ptypeCD == "USE" ? "사용" : "Error",
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                        ),
                      )
                    ],
                  )
              ),
              Expanded(
                  flex: 10,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      child: RichText(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          text: TextSpan(
                            text: "${item.pointType}",
                            style: CustomStyle.CustomFont(styleFontSize13, item.ptypeCD == "SAVE" ? Colors.black : item.ptypeCD == "MOVE" ? rpa_btn_modify : item.ptypeCD == "USE" ? point_red : text_color_01),
                          )
                      )
                  )
              ),
              Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: light_gray1,
                                  border: Border.all(color: light_gray22,width: 1.w),
                                  borderRadius: BorderRadius.all(Radius.circular(100.w))
                              ),
                              child: Text(
                                "${item.ptypeCD == "SAVE" ? "+" : "-"} ${Util.getInCodeCommaWon(item.point.toString())} P",
                                style: CustomStyle.CustomFont(styleFontSize12, item.ptypeCD == "SAVE" ? point_blue : item.ptypeCD == "MOVE" ? rpa_btn_modify : item.ptypeCD == "USE" ? point_red : text_color_01,font_weight: FontWeight.w700),
                              )
                          )
                      ),
                      Expanded(
                          flex: 4,
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                              alignment: Alignment.center,
                              child: Text(
                                "${Util.pointDate(item.pointDate)}",
                                style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                              )
                          )
                      ),
                    ],
                  )
              ),
            ],
          ),
        );
      })
    ) : SizedBox(
      child: Center(
          child: Text(
            Strings.of(context)?.get("empty_list") ?? "Not Found",
            style:
            CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
          )),
    );
  }

  Widget itemListFuture() {
    final appBarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
      future: appBarService.getUserPoint(context,page.value),
      builder: (context, snapshot) {
        if(snapshot.connectionState != ConnectionState.done) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h)),
              alignment: Alignment.center,
              child: const Center(child: CircularProgressIndicator())
          );
        }else {
          if (snapshot.hasData) {
            if (mList.isNotEmpty) mList.clear();
            mList.value.addAll(snapshot.data['list']);
            return getPointListWidget();
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
      },
    );
  }
}