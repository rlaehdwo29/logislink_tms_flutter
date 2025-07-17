import 'package:avatar_glow/avatar_glow.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/kakao_model.dart';
import 'package:logislink_tms_flutter/common/model/sido_area_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/speech_controller.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:logislink_tms_flutter/widget/show_code_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class RenewNomalAddrPage extends StatefulWidget {

  final String type;
  final void Function(String type, KakaoModel kakao,{String? jibun}) callback;

  RenewNomalAddrPage({Key? key,required this.type, required this.callback}):super(key: key);

  _RenewNomalAddrPageState createState() => _RenewNomalAddrPageState();
}

class _RenewNomalAddrPageState extends State<RenewNomalAddrPage> {

  TextEditingController searchController = TextEditingController();
  TextEditingController inputJibunController = TextEditingController();
  final SpeechController speechController = Get.put(SpeechController());

  final mList = List.empty(growable: true).obs;
  final jibunStep = 0.obs;
  final jibunCode1 = CodeModel().obs;
  final jibunCode2 = CodeModel().obs;
  final jibunCode3 = CodeModel().obs;
  final jibunCode4 = "".obs;
  List<CodeModel>? nJibunList1 = List.empty(growable: true);
  List<CodeModel>? nJibunList2 = List.empty(growable: true);
  final nJibunList3 = List.empty(growable: true).obs;
  final mJibunList = List.empty(growable: true).obs;
  final isExpanded = [].obs;

  final mSido = "".obs;
  final mSidoArea = "".obs;
  final mAddr = "".obs;

  final controller = Get.find<App>();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {

    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

  }

  /**
   * Start Function
   */

  void _loadData() async {
    nJibunList1 = SP.getCodeList(Const.SIDO);
    nJibunList2 = SP.getCodeList(Const.SIDO_AREA);
    setState(() {});
  }

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

  Future<List<CodeModel>> getSidoArea(String? mFilter) async {
    List<CodeModel> mList = List.empty(growable: true);
    Logger logger = Logger();
    await DioService.dioClient(header: true).getSidoArea(mFilter).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getSidoArea() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<SidoAreaModel> itemsList = list.map((i) => SidoAreaModel.fromJSON(i)).toList();
            nJibunList2?.clear();
            for(var item in itemsList) {
              nJibunList2?.add(CodeModel(code: item.areaCd,codeName: item.sigun));
            }
          }
        } else {
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getSidoArea() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getSidoArea() getOrder Default => ");
          break;
      }
    });
    return mList;
  }

  Future<void> onSelectItem(String? addr) async {
    Logger logger = Logger();
    await DioService.kakaoClient(header: true).getGeoAddress(
        "KakaoAK ${Strings.of(context)?.get("kakao_rest_app_key")}",
        addr
    ).then((it) async {
      try {
        KakaoModel kakao = DioService.kakaoDioResponse(it);
        widget.callback(widget.type, kakao,jibun: inputJibunController.text);
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

  Future<void> onSelectItem2(String? addr) async {
    Logger logger = Logger();
    await DioService.kakaoClient(header: true).getGeoAddress(
        "KakaoAK ${Strings.of(context)?.get("kakao_rest_app_key")}",
        addr
    ).then((it) async {
      try {
        KakaoModel kakao = DioService.kakaoDioResponse2(it);
        widget.callback(widget.type,kakao);
        Navigator.of(context).pop();
      }catch(e) {
        print("onSelectItem() Exeption =>$e");
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("onSelectItem2() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("onSelectItem2() getOrder Default => ");
          break;
      }
    });
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
    await onSelectItem("${mSido.value} ${mSidoArea.value}");
  }

  /**
   * End Function
   */


  /**
   * Start Widget
   */
  Widget getJibunListWidget() {
    return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(10)),
              decoration: BoxDecoration(
                color: light_gray1,
                border: Border(
                  bottom: BorderSide(
                    color: light_gray12,
                    width: 5.w
                  )
                )
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                      child: Text(
                          "시/도",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                      ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "구/군",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      "동",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                    ),
                  ),
                  Expanded(flex: 3,
                    child: Text(
                      "리",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w600),
                    ),
                  )
                ],
              )
            ),
            
            mJibunList.isNotEmpty ?
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: mJibunList.length,
                  itemBuilder: (context, index) {
                          var item = mJibunList[index];
                          return InkWell(
                            onTap: (){
                              onSelectItem(item.fullAddr);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: line, width: CustomStyle.getWidth(0.5)
                                        )
                                    )
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "${item.sido}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                      )
                                    ),
                                    Expanded(
                                      flex: 3,
                                        child: Text(
                                          "${item.gugun}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    ),
                                    Expanded(
                                      flex: 5,
                                        child: Text(
                                          "${item.dong}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    ),
                                    Expanded(
                                      flex: 3,
                                        child: Text(
                                          "${item.ri}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    )
                                  ],
                                )
                            ),
                          );
                  }
              )
            ):  Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
              alignment: Alignment.center,
              child: Text(
                  "${Strings.of(context)?.get("empty_list")}",
                  style: CustomStyle.baseFont()),
              )
          ],
        );

  }

  Widget getAddrListWidget() {
    return mList.isNotEmpty ?
        SingleChildScrollView(
            child: Flex(
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
              style:CustomStyle.baseFont()
            ),
          )
      );
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
        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20)),
        child: Row(children: [
          Expanded(
              flex: 8,
              child: TextField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textAlignVertical: TextAlignVertical.center,
                controller: searchController,
                decoration: searchController.text.isNotEmpty ? InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize16, text_color_02,font_weight: FontWeight.w800),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(Icons.clear, size: 18.h,color: Colors.black,),
                  ),
                ) : InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize16, text_color_02, font_weight: FontWeight.w800),
                ),
                onChanged: (bizKindText) {
                  if (bizKindText.isNotEmpty) {
                    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
                  } else {

                  }
                  setState(() {});
                },
              )),
          searchController.text.length > 1 ?
          Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () async {
                  await getJuso();
                },
                icon: Icon(Icons.search, size: 28.h,color: Colors.black),
              )
          ) : IconButton(
            onPressed: (){
              speechDialog();
            },
            icon: const Icon(Icons.mic),
          ),
        ]));
  }

  Widget jibunWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
                "${mSido.value} ${mSidoArea.value}",
              style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
            )
          ),
          Expanded(
            flex: 5,
            child: jibunCode2.value.code != null ?
            SizedBox(
              height: CustomStyle.getHeight(35),
              child: TextField(
                style: CustomStyle.CustomFont(styleFontSize16, light_gray17, font_weight: FontWeight.w800),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                controller: inputJibunController,
                maxLines: null,
                decoration: inputJibunController.text.isNotEmpty
                    ? InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  disabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      inputJibunController.text = "";
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18.h,
                      color: Colors.black,
                    ),
                  ),
                )
                    : InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0),vertical: CustomStyle.getHeight(5.0)),
                  hintText: "직접입력(선택)",
                  hintStyle: CustomStyle.CustomFont(styleFontSize16, light_gray23,font_weight: FontWeight.w800),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  disabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                ),
                onChanged: (value){

                },
                maxLength: 100,
              )
            ) : const SizedBox()
          )
        ],
      )
    );
  }

  Widget addrItemListFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getAddr(context, searchController.text),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Container(
                alignment: Alignment.center,
                child: const Center(child: CircularProgressIndicator())
            );
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
            child: const CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Widget jibunItemListFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getJibunAddr(context, searchController.text),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return Container(
                alignment: Alignment.center,
                child: const Center(child: CircularProgressIndicator())
            );
          }else {
            if (snapshot.hasData) {
              if (mJibunList.isNotEmpty) mJibunList.clear();
              mJibunList.addAll(snapshot.data);
              return getJibunListWidget();
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
            child: const CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Future<void> speechDialog() async {
    speechController.initSpeech();
    await Navigator.of(context).push(
        DialogRoute(
            context: context,
            builder: (_context) =>
                AlertDialog(
                  backgroundColor: Colors.black,
                  contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)
                  ),
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  content: Container(
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.4,
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                      alignment: Alignment.center,
                      color: Colors.black,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "음성 검색",
                            style: CustomStyle.CustomFont(styleFontSize20, Colors.white, font_weight: FontWeight.w800),
                          ),
                          Obx(() =>
                              AvatarGlow(
                                  endRadius: 75.0,
                                  animate: speechController.isListening.value,
                                  duration: const Duration(milliseconds: 2000),
                                  glowColor: const Color(0xff00A67E),
                                  repeat: true,
                                  repeatPauseDuration: const Duration(milliseconds: 100),
                                  showTwoGlows: true,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await speechController.startListening();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: const Color(0xff00A67E),
                                      radius: 30,
                                      child: Icon(
                                        speechController.isListening.value ? Icons.mic : Icons.mic_off,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              )
                          ),
                          Obx(() =>
                              Text(
                                speechController.speechText.value == "0200" ? "듣고있어요.."
                                    : speechController.speechText.value == "0300" ? "다시 말씀해주세요.."
                                    : speechController.speechText.value,
                                style: CustomStyle.CustomFont(styleFontSize16, styleGreyCol1),
                              )
                          ),
                          Obx(() =>
                              InkWell(
                                onTap: (){
                                  if(speechController.speechText.value == "0200") {
                                    searchController.text = "";
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  }else if(speechController.speechText.value == "0300"){
                                    speechController.startListening();
                                  }else{
                                    searchController.text = speechController.speechText.value;
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10),vertical: CustomStyle.getHeight(5)),
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: styleGreyCol1,width: 1)
                                  ),
                                  child: Text(
                                    speechController.speechText.value == "0200" ? "확인"
                                        : speechController.speechText.value == "0300" ? "다시 시도"
                                        : "로 검색",
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.blueAccent),
                                  ),
                                ),
                              )
                          )
                        ],
                      )
                  ),
                )
        )
    );

  }

  /**
   * End Widget
   */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
              centerTitle: true,
              title: Text(
                  Strings.of(context)?.get("addr_search_title") ?? "Not Found",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize18, Colors.black)
              ),
              toolbarHeight: 50.h,
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(
                    Icons.keyboard_arrow_left, size: 24.h, color: Colors.black),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                        await confirm();
                    },
                    child: Text(
                      "저장",
                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w800),
                    )
                )
              ],
            ),
        body:Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //filterWidget(),
                jibunStep.value == 0 ? searchWidget() : jibunWidget(),
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: CustomStyle.getWidth(15)),
                    child: CustomStyle.getDivider1()
                ),
                Expanded(
                  child: searchController.text.length > 1 ?
                  Expanded(
                      child: ContainedTabBarView(
                        tabs: [
                          Text(
                              "시/군/동",
                              style: CustomStyle.CustomFont(styleFontSize15, Colors.black)
                          ),
                          Text(
                              "도로명+지번",
                              style: CustomStyle.CustomFont(styleFontSize15, Colors.black)
                          )
                        ],
                        views: [
                          jibunItemListFuture(),
                          addrItemListFuture()
                        ],
                      )
                  )
                      : jibunStep.value == 0 ?
                  Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: nJibunList1?.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .6),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 2, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () async {
                                  Future.delayed(const Duration(milliseconds: 100), () async {
                                    jibunCode1.value = CodeModel(code: nJibunList1?[index].code, codeName: nJibunList1?[index].codeName);
                                    mSido.value = jibunCode1.value.codeName??"-";
                                    await getSidoArea(jibunCode1.value.codeName);
                                    jibunStep.value = 1;
                                  });
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: renew_main_color2,
                                            width: CustomStyle.getWidth(1.0)
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${nJibunList1?[index].codeName}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            styleFontSize14, text_color_01,
                                            font_weight: FontWeight.w800),
                                      ),
                                    )
                                )
                            );
                          }
                      )
                  ) : jibunStep.value == 1 ?
                  Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: nJibunList2?.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .6),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 2, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () async {
                                  Future.delayed(const Duration(milliseconds: 100), () async {
                                    jibunCode2.value = CodeModel(code: nJibunList2?[index].code, codeName: nJibunList2?[index].codeName);
                                    mSidoArea.value = jibunCode2.value.codeName??"-";
                                  });
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: renew_main_color2,
                                            width: CustomStyle.getWidth(1.0)
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${nJibunList2?[index].codeName}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            styleFontSize14, text_color_01,
                                            font_weight: FontWeight.w800),
                                      ),
                                    )
                                )
                            );
                          }
                      )
                  ) : Container(
                      margin: EdgeInsets.only(top: CustomStyle.getHeight(10)),
                      child: GridView.builder(
                          itemCount: nJibunList3?.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: (1 / .6),
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 2, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    jibunCode3.value = CodeModel(code: nJibunList3?[index].code, codeName: nJibunList3?[index].codeName);
                                  });
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: renew_main_color2,
                                            width: CustomStyle.getWidth(1.0)
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${nJibunList3?[index].codeName}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            styleFontSize14, text_color_01,
                                            font_weight: FontWeight.w800),
                                      ),
                                    )
                                )
                            );
                          }
                      )
                  ),
                )
              ],
            );
          })
    ));
  }

}