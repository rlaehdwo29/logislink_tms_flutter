import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderCustUserPage extends StatefulWidget {

  MODE? mode;
  String? custId;
  String? deptId;

  OrderCustUserPage({Key? key, this.mode, this.custId, this.deptId}):super(key:key);

  _OrderCustUserPageState createState() => _OrderCustUserPageState();
}

class _OrderCustUserPageState extends State<OrderCustUserPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final search_text = "".obs;
  final mList = List.empty(growable: true).obs;

  Widget searchBoxWidget() {
    return Row(
        children :[
          Expanded(
            child: TextField(
            style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            onChanged: (value){
              search_text.value = value;
              if(widget.mode == MODE.KEEPER) {
                getCustKeeper();
              }else{
                getCustUser();
              }
            },
            decoration: InputDecoration(
              counterText: '',
              hintText: Strings.of(context)?.get("search_info")??"Not Found",
              hintStyle:CustomStyle.greyDefFont(),
              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical:CustomStyle.getHeight(15.0) ),
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
                child: const Icon(
                  Icons.search, size: 24, color: Colors.black,
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

  Widget searchListWidget() {
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

  Widget getListItemView(CustUserModel item) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pop({'code':200,'custUser':item});
      },
        child: Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
        child: Column(
          children: [
            Text(
              item.userName??"",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            ),
            Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
              child: Text(
                Util.makePhoneNumber(item.mobile),
                style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
              )
            ),
            CustomStyle.getDivider1()
          ],
        )
      )
    );
  }

  Future<void> getCustUser() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCustUser(
        user.authorization,
        widget.custId,
        widget.deptId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mList.length > 0) mList.clear();
            if(list.length > 0) {
              List<CustUserModel> itemsList = list.map((i) => CustUserModel.fromJSON(i)).toList();
              mList.value.addAll(itemsList);
            }
          }else{
            mList.value = List.empty(growable: true);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
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

  Future<void> getCustKeeper() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCustUser2(
        user.authorization,
        widget.custId,
        widget.deptId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustKeeper() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mList.length > 0) mList.clear();
            if(list.length > 0) {
              List<CustUserModel> itemsList = list.map((i) => CustUserModel.fromJSON(i)).toList();
              mList.value.addAll(itemsList);
            }
          }else{
            mList.value = List.empty(growable: true);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getCustKeeper() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCustKeeper() getOrder Default => ");
          break;
      }
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
          resizeToAvoidBottomInset: false,
          backgroundColor: sub_color,
          appBar:PreferredSize(
              preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
              child: AppBar(
                title: Text(
                    Strings.of(context)?.get("order_cust_user_title")??"Not Found",
                    style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop({'code':100});
                  },
                  color: styleWhiteCol,
                  icon: const Icon(Icons.arrow_back),
                ),
              )
          ),
          body: SafeArea(
              child: Obx((){
                return SizedBox(
                  child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          searchBoxWidget(),
                          searchListWidget()
                        ],
                      )
              );
            })
          )
        )
    );
  }

}