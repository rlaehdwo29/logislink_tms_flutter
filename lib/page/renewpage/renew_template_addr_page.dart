
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_confirm_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/order_addr_reg_page.dart';
import 'package:logislink_tms_flutter/page/subpage/reg_order/stop_point_confirm_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class RenewTemplateAddrPage extends StatefulWidget {

  String? code;

  RenewTemplateAddrPage({Key? key, this.code}):super(key:key);

  _RenewTemplateAddrPageState createState() => _RenewTemplateAddrPageState();
}


class _RenewTemplateAddrPageState extends State<RenewTemplateAddrPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mData = OrderModel().obs;
  final mList = List.empty(growable: true).obs;

  final mTitle = "".obs;
  final llBottom = false.obs;
  final search_text = "".obs;
  final size = 1.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
        mTitle.value = "경유지 선택";
        await initView();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initView() async {

  }

  Future<void> getAddr() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getAddr(user.authorization, search_text.value).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getAddr() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
              var list = _response.resultMap?["data"] as List;
              if (mList.length > 0) mList.clear();
              if (list.length > 0) {
                List<AddrModel> itemsList = list.map((i) => AddrModel.fromJSON(i)).toList();
                mList.addAll(itemsList);
              }
              size.value = mList.length;
            } else {
              mList.value = List.empty(growable: true);
            }
          } else {
            openOkBox(context, "${_response.resultMap?["msg"]}",
                Strings.of(context)?.get("confirm") ?? "Error!!", () {
                  Navigator.of(context).pop(false);
                });
          }
        }
      }catch(e) {
        print("getAddr() Exception =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getAddr() getOrder Default => ");
          break;
      }
    });
  }

  Widget searchBoxWidget() {
    return Row(
        children :[
          Expanded(
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                onChanged: (value) async {
                  search_text.value = value;
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: Strings.of(context)?.get("search_info")??"Not Found",
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
        await goToAddrInput();
      },
        child: Container(
            padding: EdgeInsets.symmetric(
                vertical: CustomStyle.getHeight(5.h),
                horizontal: CustomStyle.getWidth(5.w)),
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

  Widget addrItemFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.getAddr(
           context,
           search_text.value
        ),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Expanded(
                child: Container(
                alignment: Alignment.center,
                child: const Center(child: CircularProgressIndicator())
            ));
          }else {
            if (snapshot.hasData) {
              if (mList.isNotEmpty) mList.clear();
              mList.addAll(snapshot.data);
              return searchListWidget();
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
              return getListItemView(item,index);
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

  Future<void> confirmStopPoint(AddrModel addr) async {
      StopPointModel data = StopPointModel();
      data.eComName = addr.addrName;
      data.eAddr = addr.addr;
      data.eAddrDetail = addr.addrDetail;
      data.eStaff = addr.staffName;
      data.eTel = addr.staffTel;
      data.eLat = double.parse(addr.lat??"0");
      data.eLon = double.parse(addr.lon??"0");

      Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => StopPointConfirmPage(result_work_stopPoint:data,code:"confirm")));

      if(results != null && results.containsKey("code")){
        if(results["code"] == 200) {
          print("confirmStopPoint() -> ${results[Const.RESULT_WORK_STOP_POINT]}");
          if(results[Const.RESULT_WORK_STOP_POINT] != null) {
            List<StopPointModel>? dataList = mData.value.orderStopList??List.empty(growable: true);
            if(dataList?.length == 0) {
              dataList = List.empty(growable: true);
            }
            StopPointModel data = results[Const.RESULT_WORK_STOP_POINT];
            dataList?.add(data);
            mData.value.orderStopList = dataList;
            Navigator.of(context).pop({'code':200,Const.RESULT_WORK:Const.RESULT_WORK_STOP_POINT, Const.ORDER_VO: mData.value});
          }
        }
      }

  }

  Future<void> goToAddrInput() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrRegPage(code:"input")));
    if(results != null && results.containsKey("code")) {
      if (results["code"] == 200) {
        if(results[Const.ADDR_VO] != null) {
          AddrModel addr = results[Const.ADDR_VO];
          if (Const.RESULT_WORK_STOP_POINT == widget.code) {
            await confirmStopPoint(addr);
          }else{
            await confirmAddr(addr);
          }
        }
      }
    }
  }

  Future<void> confirmAddr(AddrModel addr) async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrConfirmPage(addr_vo:addr)));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        if(widget.code == Const.RESULT_SETTING_SADDR) {
          if(results[Const.ADDR_VO] != null) {
            AddrModel addr = results[Const.ADDR_VO];
            mData.value.sComName = addr.addrName;
            mData.value.sSido = addr.sido;
            mData.value.sGungu = addr.gungu;
            mData.value.sDong = addr.dong;
            mData.value.sAddr = addr.addr;
            mData.value.sAddrDetail = addr.addrDetail;
            mData.value.sStaff = addr.staffName;
            mData.value.sTel = addr.staffTel;
            mData.value.sMemo = addr.orderMemo;
            mData.value.sLat = double.parse(addr.lat??"0.0");
            mData.value.sLon = double.parse(addr.lon??"0.0");
          }
        }else{
          var work_state = "";
          if(results[Const.ADDR_VO] != null) {
            AddrModel addr = results[Const.ADDR_VO];
            if(widget.code == Const.RESULT_WORK_SADDR) {
              mData.value.sComName = addr.addrName;
              mData.value.sSido = addr.sido;
              mData.value.sGungu = addr.gungu;
              mData.value.sDong = addr.dong;
              mData.value.sAddr = addr.addr;
              mData.value.sAddrDetail = addr.addrDetail;
              mData.value.sStaff = addr.staffName;
              mData.value.sTel = addr.staffTel;
              mData.value.sMemo = addr.orderMemo;
              mData.value.sLat = double.parse(addr.lat??"0.0");
              mData.value.sLon = double.parse(addr.lon??"0.0");
              work_state = Const.RESULT_WORK_SADDR;
            }else if(widget.code == Const.RESULT_WORK_EADDR){
              mData.value.eComName = addr.addrName;
              mData.value.eSido = addr.sido;
              mData.value.eGungu = addr.gungu;
              mData.value.eDong = addr.dong;
              mData.value.eAddr = addr.addr;
              mData.value.eAddrDetail = addr.addrDetail;
              mData.value.eStaff = addr.staffName;
              mData.value.eTel = addr.staffTel;
              mData.value.eMemo = addr.orderMemo;
              mData.value.eLat = double.parse(addr.lat??"0.0");
              mData.value.eLon = double.parse(addr.lon??"0.0");
              work_state = Const.RESULT_WORK_EADDR;
            }else{
                List<StopPointModel>? dataList = mData.value.orderStopList;
                if(dataList == null) {
                  dataList = List.empty(growable: true);
                }
                StopPointModel data = results[Const.RESULT_WORK_STOP_POINT];
                dataList.add(data);
                mData.value.orderStopList = dataList;
                work_state = Const.RESULT_WORK_STOP_POINT;
            }
            Navigator.of(context).pop({'code':200,Const.RESULT_WORK:work_state, Const.ORDER_VO:mData.value});
          }

        }
      }
    }
  }

  void onEditAddr(AddrModel addr,int position) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderAddrRegPage(addr_vo: addr,position: position)));
  }

  void dialogAddrDel(AddrModel item, int position) {
    openCommonConfirmBox(
        context,
        "주소지를 삭제하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          //carDel(item);
        });
  }

  Widget getListItemView(AddrModel item,int position) {
    return InkWell(
        onTap: () async {
          if (Const.RESULT_WORK_STOP_POINT == widget.code) {
            await confirmStopPoint(item);
          } else {
            await confirmAddr(item);
          }
        },
        child: Slidable(
            key: const ValueKey(0),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: (BuildContext context) => onEditAddr(item,position),
                  backgroundColor: main_color,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: '수정하기',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) => dialogAddrDel(item,position),
                  backgroundColor: cancel_btn,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: '삭제하기',
                ),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: CustomStyle.getHeight(5.h),
                          horizontal: CustomStyle.getWidth(10.w)),
                      height: 60.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: item.addrName ?? "",
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, text_color_01),
                            ),
                          )),
                          Flexible(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: CustomStyle.getHeight(5.h)),
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      text: item.addr ?? "",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_03),
                                    ),
                                  )))
                        ],
                      )),
                  CustomStyle.getDivider1()
                ])));
  }

  Future<void> goToAddrReg() async {
    Map<String,dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OrderAddrRegPage()));

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToAddrReg() -> ${results[Const.RESULT_WORK]}");
        setState(() {});
      }
    }
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
                title: Obx(() {
                  return Text(
                      mTitle.value,
                      style: CustomStyle.appBarTitleFont(
                          styleFontSize16, Colors.black)
                  );
                }),
                toolbarHeight: 50.h,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back,size: 24.h, color: Colors.black),
                ),
              ),
          body: SafeArea(
              child: Obx((){
                 return SizedBox(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            searchBoxWidget(),
                            selfInputWidget(),
                            addrItemFuture()
                          ],
                        ),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: InkWell(
                                onTap: () async {
                                  await goToAddrReg();
                                },
                                child: Icon(
                                  Icons.add_circle,
                                  color: main_btn,
                                  size: 52.h,
                                )
                            )
                        )
                      ],
                    )
                );
              })
          ),
        )
    );
  }

}
