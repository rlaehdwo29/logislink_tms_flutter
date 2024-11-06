import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/model/notice_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/appbar_notice_detail_page.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/util.dart';

class AppBarNoticePage extends StatefulWidget {
  _AppBarNoticePageState createState() => _AppBarNoticePageState();
}

class _AppBarNoticePageState extends State<AppBarNoticePage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mList = List.empty(growable: true).obs;

  Widget getListView(NoticeModel item) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AppBarNoticeDetailPage(item)));
      },
        child: Container(
      padding: EdgeInsets.fromLTRB(CustomStyle.getWidth(20.0), CustomStyle.getHeight(10.0), CustomStyle.getWidth(20.0), CustomStyle.getWidth(10.0)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: line
          )
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "${Util.splitDate(item.regdate??"00000000")}",
            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
          ),
          Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
            child: Text(
              "${item.title}",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            ),
          ),
        ],
      ),
        )
    );
  }

  Widget getNoticeListWidget() {
    return mList.isNotEmpty
            ? SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  mList.length,
                      (index) {
                    var item = mList[index];
                    return getListView(item);
                  },
                )))
            : SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style: CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
        );
  }

  Widget getNoticeFuture() {
    final appBarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
      future: appBarService.getNotice(
        context
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(mList.isNotEmpty) mList.clear();
          mList.value.addAll(snapshot.data);
          return getNoticeListWidget();
        }else if(snapshot.hasError){
          return Container(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return  WillPopScope(
        onWillPop: () async {
          return Future((){
            FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
            return true;
          });
    } ,
      child: Scaffold(
        backgroundColor: styleWhiteCol,
        appBar: AppBar(
              centerTitle: true,
              toolbarHeight: 50.h,
              title: Text(
                  "공지사항",
                  style: CustomStyle.appBarTitleFont(styleFontSize16, Colors.black)
              ),
              leading: IconButton(
                onPressed: () {
                  FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.black),
              ),
          ),
        body: SafeArea(
            child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: getNoticeFuture(),
                  )
              )
        ),
      )
    );


  }
  
}