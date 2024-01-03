import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/addr_model.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class AddrSearchPage extends StatefulWidget {

  final void Function(KakaoModel kakao) callback;

  AddrSearchPage({Key? key,required this.callback}):super(key: key);

  _AddrSearchPageState createState() => _AddrSearchPageState();
}

class _AddrSearchPageState extends State<AddrSearchPage> {

  TextEditingController searchController = TextEditingController();

  final mList = List.empty(growable: true).obs;
  final isExpanded = [].obs;

  final mSido = "".obs;
  final mSidoArea = "".obs;
  final mAddr = "".obs;

  final controller = Get.find<App>();

  Future<void> getJuso() async {
    if(searchController.text.isEmpty) {
      Util.toast("검색할 주소를 입력해 주세요.");
      return;
    }
    Logger logger = Logger();
    mList.value = List.empty(growable: true);
    await DioService.jusoDioClient(header: false).getJuso(Const.JUSU_KEY,"1","20",searchController.text,"json").then((it) {
      if (mList.isNotEmpty == true) mList.value = List.empty(growable: true);
      mList.value.addAll(DioService.jusoDioResponse(it));
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getJuso() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getJuso() Error Default => ");
          break;
      }
    });
  }

  Future<void> onSelectItem(String? addr) async {
    Logger logger = Logger();
    await DioService.kakaoClient(header: true).getGeoAddress(
        "KakaoAK ${Strings.of(context)?.get("kakao_rest_app_key")}",
        addr
    ).then((it) async {
      try {
        KakaoModel kakao = DioService.kakaoDioResponse(it);
        widget.callback(kakao);
        Navigator.of(context).pop();
      }catch(e) {
        print("onSelectItem() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("onSelectItem() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("onSelectItem() getOrder Default => ");
          break;
      }
    });
  }

  Widget getAddrListWidget() {
    return Expanded(
        child: mList.isNotEmpty ?
        SingleChildScrollView(
            child:Flex(
                direction: Axis.vertical,
                children: List.generate(
                    mList.length,
                        (index) {
                      var item = mList[index];
                      return InkWell(
                        onTap: (){},
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: line, width: CustomStyle.getWidth(0.5)
                                  )
                              )
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${item.zipNo}",
                                style: CustomStyle.CustomFont(styleFontSize14, addr_zip_no),
                              ),
                              InkWell(
                                  onTap: (){
                                    //selectRoad(item.roadAddr);
                                    onSelectItem(item.roadAddr);
                                  },
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children :[
                                        Container(
                                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                            child: Text(
                                              "도로명",
                                              style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                                            )
                                        ),
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                                child: Text(
                                                  "${item.roadAddr}",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                )
                                            )
                                        )
                                      ])
                              ),
                              InkWell(
                                  onTap: (){
                                    //selectJibun(item.jibunAddr);
                                    onSelectItem(item.jibunAddr);
                                  },
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children :[
                                        Container(
                                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                            child: Text(
                                              "지번",
                                              style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                                            )
                                        ),
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                                child: Text(
                                                  "${item.jibunAddr}",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                )
                                            )
                                        )
                                      ])
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                )
            )
        ): SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style:
                CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
        )
    );

  }

  void selectSido(CodeModel? codeModel,String? codeType) {
    if(codeType != "") {
      switch (codeType) {
        case 'SIDO' :
          mSido.value = codeModel?.codeName??"";
          mSidoArea.value = "";
          break;
      }
    }
    setState(() {});
  }

  void selectSidoArea(CodeModel? codeModel,String? codeType) {
    if(codeType != "") {
      switch (codeType) {
        case 'SIDO_AREA' :
          mSidoArea.value = codeModel?.codeName??"";
          mAddr.value = "${mSido.value} ${mSidoArea.value}";
          break;
      }
    }
    setState(() {});
  }

  Future<void> confirm() async {
    if(mSido.value.isEmpty == true || mSido.value == "") {
      Util.toast("시/도를 선택해 주세요.");
      return;
    }
    if(mSidoArea.value.isEmpty == true || mSidoArea.value == "") {
      Util.toast("시/군/구를 선택해 주세요.");
      return;
    }
    await onSelectItem(mAddr.value);
  }

  Widget filterWidget() {
    isExpanded.value = List.filled(1, false);
    return Flex(
      direction: Axis.vertical,
      children: List.generate(1, (index) {
        return ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          initialOpenPanelValue: 0,
          children: [
            ExpansionPanelRadio(
              value: index,
              backgroundColor: text_color_03,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                     padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(5.h)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.house,size: 20.h,color: styleWhiteCol,),
                        CustomStyle.sizedBoxWidth(5.0),
                        Text("주소지 불분명 시",style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol))
                      ],
                    ));
              },
              body: Obx((){
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children : [
                        Row(
                          children: [
                          InkWell(
                          onTap: (){
                            ShowCodeDialogWidget(context:context, mTitle: "시/도", codeType: Const.SIDO, mFilter: "", callback: selectSido).showDialog();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(15.w)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                color: Colors.white,
                              border: Border.all(color: styleDefaultGrey,width: 1.w)
                            ),
                            child: Text(
                              mSido.value.isEmpty == true ? "시/도" : mSido.value,
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            ),
                          )
                        ),
                        InkWell(
                          onTap: (){
                            if(mSido.value == "") {
                              Util.toast("시/도를 선택해 주세요.");
                              return;
                            }
                            ShowCodeDialogWidget(context:context, mTitle: "시/군/구", codeType: Const.SIDO_AREA, mFilter: mSido.value, callback: selectSidoArea).showDialog();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(15.w)),
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5.w)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                color: Colors.white,
                                border: Border.all(color: styleDefaultGrey,width: 1.w)
                            ),
                            child: Text(
                              mSidoArea.value.isEmpty == true ? "시/군/구" : mSidoArea.value,
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            ),
                          )
                        ),
                          ]
                        ),
                        InkWell(
                          onTap: () async {
                            await confirm();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.h),horizontal: CustomStyle.getWidth(10.w)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                color: main_color,
                                border: Border.all(color: main_color,width: 1.w)
                            ),
                            child: Text(
                              "선택",
                              style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                            ),
                          )
                        )
                      ]
                    )
              );
              }),
              canTapOnHeader: true,
            )
          ],
          expansionCallback: (int _index, bool status) {
            isExpanded[index] = !isExpanded[index];
            //for (int i = 0; i < isExpanded.length; i++)
            //  if (i != index) isExpanded[i] = false;
          },
        );
      }),
    );
  }

  Widget searchWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
        child: Row(children: [
          Expanded(
              flex: 8,
              child: TextField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                style:
                CustomStyle.CustomFont(styleFontSize14, Colors.black),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textAlignVertical: TextAlignVertical.center,
                controller: searchController,
                decoration: searchController.text.isNotEmpty ? InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                    },
                    icon: Icon(Icons.clear, size: 18.h,color: Colors.black,),
                  ),
                ) : InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                ),
                onChanged: (bizKindText) {
                  if (bizKindText.isNotEmpty) {
                    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
                  } else {

                  }
                  setState(() {});
                },
              )),
          Expanded(
              flex: 1,
              child: IconButton(
                onPressed: (){
                  getJuso();
                },
                icon: Icon(Icons.search, size: 28.h,color: Colors.black),
              )
          )
        ]));
  }

  Widget itemListFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getAddr(context, searchController.text),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Expanded(child: Container(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator())
            ));
          }else {
            if (snapshot.hasData) {
              if (mList.isNotEmpty) mList.clear();
              mList.value.addAll(snapshot.data);
              return getAddrListWidget();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
              centerTitle: true,
              title: Center(
                child: Text(
                  Strings.of(context)?.get("addr_search_title") ?? "Not Found",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize18, styleWhiteCol)
                )
              ),
              toolbarHeight: 50.h,
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(
                    Icons.keyboard_arrow_left, size: 24.h, color: styleWhiteCol),
              ),
            ),
        body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                filterWidget(),
                searchWidget(),
                CustomStyle.getDivider1(),
                itemListFuture()
              ],
            )
        ));
  }

}