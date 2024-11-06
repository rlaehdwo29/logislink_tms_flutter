import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/dept_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderCustomerDeptPage extends StatefulWidget {

  String? sellBuySctn;
  String? sellCustId;
  String? code;

  OrderCustomerDeptPage({Key? key, this.sellBuySctn, this.sellCustId, this.code}):super(key:key);

  _OrderCustomerDeptPageState createState() => _OrderCustomerDeptPageState();
}

class _OrderCustomerDeptPageState extends State<OrderCustomerDeptPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final search_text = "".obs;
  final mList = List.empty(growable: true).obs;
  final arrayList = List.empty(growable: true).obs;
  final size = 0.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await initView();
    });
  }

  Future<void> initView() async {
    await getCustomerDept();
  }

  Future<void> getCustomerDept() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getDeptList(
        user.authorization,
        widget.sellCustId
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustomerDept() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mList.length > 0) mList.clear();
            if(list.length > 0) {
              List<DeptModel> itemsList = list.map((i) => DeptModel.fromJSON(i)).toList();
              mList.addAll(itemsList);
              arrayList.addAll(mList);
            } else {
              arrayList.clear();
            }
            size.value = mList.length;
          }else{
            mList.value = List.empty(growable: true);
            arrayList.clear();
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
          print("getCustomerDept() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCustomerDept() getOrder Default => ");
          break;
      }
    });
  }

  Widget searchListWidget(){
    return Container(
      child: mList.isNotEmpty
          ? Expanded(
          child: AnimationLimiter(
              child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: mList.length,
              itemBuilder: (context, index) {
                var item = mList[index];
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: getListItemView(item)
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

  Widget getListItemView(DeptModel item) {
    return InkWell(
        onTap: (){
          Navigator.of(context).pop({'code':200, "custDept":item});
        },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.h), horizontal: CustomStyle.getWidth(20.w)),
            child: Row(
              children: [
                Text(
                  item.deptName??"",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                CustomStyle.getDivider1()
              ],
            )
        )
    );
  }

  Future<void> onNoneCustomerDept() async {
    DeptModel value = DeptModel();
    String result = search_text.value.trim();

    if(result != "" && result != null) {
      value.deptName = result;

      Navigator.of(context).pop({'code':200,'cust':value, "nonCustDept":true});
    }else{
      Util.toast("부서명을 작성해주세요.");
    }
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
                  if(size.value != 0) {
                    await getFilter(search_text.value);
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
                    child: Icon(
                      Icons.search, size: 20.h, color: Colors.black,
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

  Future<void> getFilter(String str) async {
    String search = str;
    search = search.toLowerCase();
    mList.clear();
    if(search.length == 0) {
      mList.addAll(arrayList);
    }else{
      for(var data in arrayList) {
        String name = data.custName;
        if(name.toLowerCase().contains(search)) {
          mList.add(data);
        }
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
              title:  Text(
                  Strings.of(context)?.get("order_customer_dept_title")??"Not Found",
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