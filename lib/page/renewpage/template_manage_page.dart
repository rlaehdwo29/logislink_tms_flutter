import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/template_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/page/renewpage/create_template_page.dart';
import 'package:logislink_tms_flutter/page/renewpage/template_manage_detail_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:dio/dio.dart';

class TemplateManagePage extends StatefulWidget {

  TemplateManagePage({Key? key}):super(key:key);

  _TemplateManagePageState createState() => _TemplateManagePageState();
}

class _TemplateManagePageState extends State<TemplateManagePage> {

  final controller = Get.find<App>();

  final template_list = List.empty(growable: true).obs;
  final selectMode = false.obs;
  final select_template_list = <TemplateModel>[].obs;
  

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await getTemplateList();
    });

  }


  /**
   * Function Start
   */
  int chargeTotal(String? chargeFlag,TemplateModel mData) {
    int total = 0;
    if(chargeFlag == "S") {
      total = int.parse(mData.sellCharge ?? "0") +
          int.parse(mData.sellWayPointCharge ?? "0") +
          int.parse(mData.sellStayCharge ?? "0") +
          int.parse(mData.sellHandWorkCharge ?? "0") +
          int.parse(mData.sellRoundCharge ?? "0") +
          int.parse(mData.sellOtherAddCharge ?? "0");
    }else {
      total = int.parse(mData.buyCharge ?? "0") +
          int.parse(mData.wayPointCharge ?? "0") +
          int.parse(mData.stayCharge ?? "0") +
          int.parse(mData.handWorkCharge ?? "0") +
          int.parse(mData.roundCharge ?? "0") +
          int.parse(mData.otherAddCharge ?? "0") -
          int.parse(mData.sellFee ?? "0");
    }
    return total;
  }

  Future<void> getTemplateList() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).getTemplateList(
      user.authorization
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("getTemplateList() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            if (_response.resultMap?["data"] != null) {
                var list = _response.resultMap?["data"] as List;
                if(template_list.isNotEmpty) template_list.clear();
                if(list.length > 0){
                  List<TemplateModel> itemsList = list.map((i) => TemplateModel.fromJSON(i)).toList();
                  template_list.addAll(itemsList);
                }

            }else{
              template_list.value = List.empty(growable: true);
            }
          } else {
            template_list.value = List.empty(growable: true);
          }
        }
      }catch(e) {
        print("getTemplateList() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTemplateList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getTemplateList() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> delTemplateList() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    await DioService.dioClient(header: true).templateDel(
        user.authorization,
        jsonEncode(select_template_list.value.map((e) => e.toJson()).toList())
    ).then((it) async {
      try {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("delTemplateList() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          if (_response.resultMap?["result"] == true) {
            Util.snackbar(context, "${select_template_list.length}건의 ${_response.resultMap?["msg"]}");
            select_template_list.value = List.empty(growable: true);
          } else {
            Util.toast("${_response.resultMap?["msg"]}");
          }
          await getTemplateList();
        }
      }catch(e) {
        print("delTemplateList() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("delTemplateList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("delTemplateList() getOrder Default => ");
          break;
      }
    });
  }

  /**
   * Function End
   */




  /**
  * Widget Start
  **/

  Widget getListItemView(TemplateModel item) {

    return InkWell(
      onTap: () async {
        if(selectMode.value) {
          if(select_template_list.length > 0){
            select_template_list.forEach((element) { 
              if (element.templateId == item.templateId) {
                select_template_list.remove(item);
              } else {
                select_template_list.add(item);
              }
            });
          }else{
            select_template_list.add(item);
          }
        }else{
          Map<String, dynamic> results = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => TemplateManageDetailPage(item: item)));

          if (results != null && results.containsKey("code")) {
            if (results["code"] == 300) {
                await getTemplateList();
              }
            }
        }
      },
        child: Obx(() => Container(
        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20),vertical: CustomStyle.getHeight(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: select_template_list.contains(item) ? renew_main_color2 : Colors.white,width: 2)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() =>                                                     
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(15)),
                    child:Text(
                        "${item.templateTitle}",
                        style:CustomStyle.CustomFont(styleFontSize18, renew_main_color2,font_weight: FontWeight.w600)
                    )
                ),
                selectMode.value ?
                IconButton(
                  onPressed: (){
                    if(select_template_list.length > 0) {
                      for (var listItem in select_template_list) {
                        if (listItem.templateId == item.templateId) {
                          select_template_list.remove(item);
                        } else {
                          select_template_list.add(item);
                        }
                      }
                    } else {
                      select_template_list.add(item);
                    }
                  },
                  icon: Icon(
                      Icons.check_circle_outline_outlined,
                    size: 28,
                    color: select_template_list.contains(item) ? renew_main_color2 : light_gray23,
                  ),
                ) : const SizedBox()
              ],
            )),
            CustomStyle.getDivider1(),
            Container(
                margin: EdgeInsets.only(top: CustomStyle.getHeight(5),left: CustomStyle.getWidth(15),right: CustomStyle.getWidth(15)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          "${item.sellCustName}",
                          style:CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500)
                      ),
                      Text(
                          "${item.sellDeptName}",
                          style:CustomStyle.CustomFont(styleFontSize13, Colors.black,font_weight: FontWeight.w300)
                      )
                    ],
                  ),
                  Util.ynToBoolean(item.payType)?
                  Text(
                    "빠른지급",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, Colors.red,font_weight: FontWeight.w700),
                  ) : const SizedBox()
                ],
              )
            ),
            Column(
                children:[
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15)),
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: light_gray24
                        )
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding:const EdgeInsets.all(3),
                                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                              decoration: const BoxDecoration(
                                                  color: renew_main_color2,
                                                  shape: BoxShape.circle
                                              ),
                                              child: Text("상",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                          ),
                                        ]
                                    ),
                                    Flexible(
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign:TextAlign.center,
                                            text: TextSpan(
                                              text: item.sComName??"",
                                              style:  CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                            )
                                        )
                                    ),
                                    CustomStyle.sizedBoxHeight(5.0.h),
                                    Flexible(
                                        child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign:TextAlign.center,
                                            text: TextSpan(
                                              text: item.sAddr??"",
                                              style: CustomStyle.CustomFont(styleFontSize11, main_color),
                                            )
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/image/ic_arrow.png",
                                    width: CustomStyle.getWidth(32.0),
                                    height: CustomStyle.getHeight(32.0),
                                    color: const Color(0xffC7CBDE),
                                  ),
                                  Text(
                                    "${Util.makeDistance(item.distance)}",
                                    style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                  ),
                                  Text(
                                    "${Util.makeTime(item.time??0)}",
                                    style: CustomStyle.CustomFont(styleFontSize11, const Color(0xffC7CBDE),font_weight: FontWeight.w700),
                                  )
                                ]
                            )
                        ),
                        Expanded(
                            flex: 4,
                            child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius:  BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding:const EdgeInsets.all(3),
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(10),right: CustomStyle.getWidth(5)),
                                                decoration: const BoxDecoration(
                                                    color: rpa_btn_cancle,
                                                    shape: BoxShape.circle
                                                ),
                                                child: Text("하",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                            ),
                                          ]
                                      ),
                                      Flexible(
                                          child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                text:
                                                item.eComName ?? "",
                                                style: CustomStyle.CustomFont(styleFontSize16, main_color, font_weight: FontWeight.w800),
                                              )
                                          )
                                      ),
                                      CustomStyle.sizedBoxHeight(5.h),
                                      Flexible(
                                          child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                  text: item.eAddr??"",
                                                  style:CustomStyle.CustomFont(styleFontSize11, main_color)
                                              )
                                          )
                                      ),
                                    ]
                                )
                            )
                        )
                      ],
                    )
                  ) ,
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15), vertical: CustomStyle.getHeight(5)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "청구운임",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                            ),
                            Text(
                              "${Util.getInCodeCommaWon(chargeTotal("S",item).toString())} 원",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w700),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "지불운임",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                            ),
                            Text(
                              "${Util.getInCodeCommaWon(chargeTotal("T",item).toString())} 원",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black,font_weight: FontWeight.w700),
                            )
                          ],
                        )
                      ],
                    )
                  ),
                  Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(15), right: CustomStyle.getWidth(15), bottom: CustomStyle.getHeight(10),top: CustomStyle.getHeight(5)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              children:[
                                Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                    margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffDBD1FF),
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Text(
                                      "${item.carTonName}",
                                      style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff8674C7),font_weight: FontWeight.w600),
                                    )
                                ),
                                Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffDBD1FF),
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Text(
                                      "${item.carTypeName}",
                                      style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff8674C7),font_weight: FontWeight.w600),
                                    )
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                item.truckTypeName != null || item.truckTypeName?.isNotEmpty == true?
                                Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                    margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffD2DAF5),
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Text(
                                      "${item.truckTypeName}",
                                      style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5C67C1),font_weight: FontWeight.w600),
                                    )
                                ) : const SizedBox(),
                                Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                    margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffADEFD1),
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Text(
                                      "${item.mixYn == "Y" ? "혼적" : "독차"}",
                                      style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5EAD89),font_weight: FontWeight.w600),
                                    )
                                ),
                                Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(3),horizontal: CustomStyle.getWidth(15)),
                                    margin: EdgeInsets.only(right:CustomStyle.getWidth(5)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffADEFD1),
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Text(
                                      item.returnYn == "Y" ? "왕복" : "편도",
                                      style: CustomStyle.CustomFont(styleFontSize10, const Color(0xff5EAD89),font_weight: FontWeight.w600),
                                    )
                                ),
                              ])
                        ],
                      )
                  ),
                ]
            ),
          ],
        )
      ))
    );
  }

  Widget templateListWidget(){
    return Container(
      child: template_list.isNotEmpty
          ? Expanded(
          child: AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: template_list.length,
                itemBuilder: (context, index) {
                  var item = template_list[index];
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


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code': 100});
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xffECECEC),
          appBar: AppBar(
            title: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    "탬플릿 관리",
                    textAlign: TextAlign.center,
                    style: CustomStyle.appBarTitleFont(styleFontSize16, Colors.black)
                ),
                selectMode.value ?
                Text(
                    "(${select_template_list.length}/${template_list.length})",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w500)
                ) : const SizedBox(),
              ],
            )),
            toolbarHeight: 50.h,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                  onPressed: (){
                    selectMode.value = !selectMode.value;
                    if(selectMode.value == false) select_template_list.value = List.empty(growable: true);
                  },
                  child: Obx(() => Text(
                      selectMode.value ? "선택해제" : "선택",
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                    )
                  )
              ),
            ],
            leading: IconButton(
              onPressed: () async {
                Navigator.of(context).pop({'code': 100});
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
            ),
          ),

          body: SafeArea(
            child: Obx((){
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children :[
                    templateListWidget()
                  ]
              );
            })
          ),
          bottomNavigationBar: Obx(() =>
                selectMode.value ?
               InkWell(
                   onTap: () async {
                     if(select_template_list.length > 0) {
                       openCommonConfirmBox(
                           context,
                           "${select_template_list.length}건의 탬플릿을 삭제하시겠습니까?",
                           Strings.of(context)?.get("cancel") ?? "Not Found",
                           Strings.of(context)?.get("confirm") ?? "Not Found",
                               () {
                             Navigator.of(context).pop(false);
                           },
                               () async {
                             Navigator.of(context).pop(false);
                             await delTemplateList();
                             selectMode.value = false;
                           });
                        }else{
                          Util.toast("삭제할 탬플릿을 선택해주세요.");
                        }
                     },
                   child: Container(
                       width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.5,
                       height: CustomStyle.getHeight(50),
                       alignment: Alignment.center,
                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                       margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                       child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.delete, size: 25.h, color: styleWhiteCol),
                             CustomStyle.sizedBoxWidth(5.0.w),
                             Text(
                               textAlign: TextAlign.center,
                               "${select_template_list.length}건 삭제",
                               style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                             ),
                           ]
                       )
                   )
               ) : InkWell(
                    onTap: () async {
                      Map<String, dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: CreateTemplatePage(), pageAnimationType: LeftToRightTransition()));

                      if (results != null && results.containsKey("code")) {
                        if (results["code"] == 200) {
                          Util.toast("탬플릿이 등록되었습니다.");
                          await getTemplateList();
                        }
                      }
                    },
                    child: Container(
                        width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.5,
                        height: CustomStyle.getHeight(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: renew_main_color2),
                        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(20)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 25.h, color: styleWhiteCol),
                              CustomStyle.sizedBoxWidth(5.0.w),
                              Text(
                                textAlign: TextAlign.center,
                                "탬플릿 생성",
                                style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                              ),
                            ]
                        )
                    )
                )
          ),
        )
    );
  }


  /**
   * Widget End
   **/

}