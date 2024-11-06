import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/customer_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class OrderCustomerPage extends StatefulWidget {

  String? sellBuySctn;
  String? code;

  OrderCustomerPage({Key? key, this.sellBuySctn,this.code}):super(key:key);

  _OrderCustomerPageState createState() => _OrderCustomerPageState();
}

class _OrderCustomerPageState extends State<OrderCustomerPage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final search_text = "".obs;
  final mList = List.empty(growable: true).obs;
  final arrayList = List.empty(growable: true).obs;
  final bottom_btn = "신규 거래처로 등록".obs;
  final btn_visable = false.obs;
  final mFlag = false.obs;
  final size = 0.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await initView();
    });
  }

  Future<void> initView() async {
    await getCustomer();
  }

  Future<void> getCustomer() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getCustomer(
        user.authorization,
        widget.sellBuySctn,"",""
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCustUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            if(mList.length > 0) mList.clear();
            if(list.length > 0) {
              List<CustomerModel> itemsList = list.map((i) => CustomerModel.fromJSON(i)).toList();
              mList.addAll(itemsList);
              arrayList.addAll(mList);
            }else{
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
          print("getCustUser() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCustUser() getOrder Default => ");
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

  Widget getListItemView(CustomerModel item) {
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

  Future<void> onNoneCustomer() async {
    CustomerModel value = CustomerModel();
    String result = search_text.value.trim();

    if(result != "" && result != null) {
      value.bizName = result;
      value.custName = result;
      value.custMngName = "정상";
      value.sellBuySctn = "01";

      Navigator.of(context).pop({'code':200,'cust':value, "nonCust":true});
    }else{
      Util.toast("거래처 이름을 작성해주세요.");
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
                    bottom_btn.value = "\"${search_text.value}\" 를 신규 거래처로 등록";
                  }
                  mFlag.value = false;
                  String mResult = search_text.value.trim();
                  for(int i = 0; i < mList.length; i++) {
                    if((mResult == mList[i].custName && "물류팀(임시)" == mList[i].deptName)) {
                      mFlag.value = true;
                    }
                  }
                  if(mFlag.value){
                    btn_visable.value = false;
                  }else{
                    if(Const.RESULT_SETTING_REQUEST == widget.code) {
                      btn_visable.value = false;
                    }else{
                      btn_visable.value = true;
                    }
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
                  Strings.of(context)?.get("order_customer_title")??"Not Found",
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
            ),
            bottomNavigationBar: Obx(() {
              return btn_visable.value
                  ? SizedBox(
                  height: CustomStyle.getHeight(60.0.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: InkWell(
                              onTap: () async {
                                await onNoneCustomer();
                              },
                              child: Container(
                                height: CustomStyle.getHeight(60.0.h),
                                alignment: Alignment.center,
                                decoration:
                                const BoxDecoration(color: main_color),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  bottom_btn.value,
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, styleWhiteCol),
                                ),
                              )
                          )
                      ),
                    ],
                  )
              ) : const SizedBox();
            }))
    );
  }

}