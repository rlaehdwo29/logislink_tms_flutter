import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class RenewSelectCargoinfo extends StatefulWidget {

  CodeModel? carTypeModel;
  CodeModel? carTonModel;

  RenewSelectCargoinfo({Key? key, this.carTypeModel, this.carTonModel}):super(key:key);

  _RenewSelectCargoinfoState createState() => _RenewSelectCargoinfoState();
}

class _RenewSelectCargoinfoState extends State<RenewSelectCargoinfo> {
  late ScrollController _scrollControllerCargo;
  late ScrollController _scrollControllerCarTon;

  final cargoList = List.empty(growable: true).obs;
  final selectCargo = CodeModel().obs;
  final carTonList = List.empty(growable: true).obs;
  final selectCarTon = CodeModel().obs;

  @override
  void initState() {
    super.initState();
    _scrollControllerCargo = ScrollController();
    _scrollControllerCarTon = ScrollController();

    Future.delayed(Duration.zero, () async {
      List<CodeModel>? tempCargoList = await SP.getCodeList(Const.CAR_TYPE_CD);
      List<CodeModel>? tempCarTonList = await SP.getCodeList(Const.CAR_TON_CD);
      cargoList.addAll(tempCargoList??List.empty(growable: true));
      carTonList.addAll(tempCarTonList??List.empty(growable: true));
      if(widget.carTypeModel?.code != null) selectCargo.value = widget.carTypeModel!;
      if(widget.carTonModel?.code != null) selectCarTon.value = widget.carTonModel!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * Start Widget
   */

  Widget selectItem(CodeModel item,String code) {
    return InkWell(
      onTap: (){
        if(code == "01") {
          selectCargo.value = item;
        }else{
          selectCarTon.value = item;
        }
      },
        child: Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: styleGreyCol1,
              width: 1
            )
          )
        ),
        child: Text(
            "${item?.codeName}",
            style: CustomStyle.CustomFont(styleFontSize20, Colors.black, font_weight: FontWeight.w600),
        ),
      )
    );
  }
  /**
   * End Widget
   */

  /**
   * Start Function
   */

  /**
   * End Function
   */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: sub_color,
      appBar: AppBar(
        title: Text(
            "차종/톤 선택",
            style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
        ),
        backgroundColor: renew_main_color2,
        toolbarHeight: 50.h,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop({'code':100});
          },
          color: styleWhiteCol,
          icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: (){
              if(selectCargo.value.code == null || selectCargo.value.code?.isEmpty == true) {
                Util.toast("차종을 선택해주세요.");
              }else if(selectCarTon.value.code == null || selectCarTon.value.code?.isEmpty == true){
                Util.toast("톤수를 선택해주세요.");
              }else{
                Navigator.of(context).pop({'code':200, 'cargo':selectCargo.value, 'carTon': selectCarTon.value});
              }
            },
            child: Container(
                margin: EdgeInsets.only(right: CustomStyle.getWidth(20)),
                child: InkWell(
                  child: Text(
                      "저장",
                      style: CustomStyle.appBarTitleFont(styleFontSize16,Colors.white)
                  ),
                )
            )
          )
        ],
      ),
      body: Obx(() {
            return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                      decoration: const BoxDecoration(
                        border: Border(
                            top:BorderSide(
                              color: rpa_btn_cancle,
                              width: 2
                            ),
                            bottom: BorderSide(
                                color: rpa_btn_cancle,
                                width: 2
                            )
                        )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectCargo.value.code == null || selectCargo.value.code?.isEmpty == true ? "차종" : selectCargo.value.codeName??"",
                            style: CustomStyle.CustomFont(styleFontSize22, Colors.black, font_weight: FontWeight.w800),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                            child: Text(
                              "/",
                              style: CustomStyle.CustomFont(styleFontSize28, rpa_btn_modify, font_weight: FontWeight.w800),
                            ),
                          ),
                          Text(
                              selectCarTon.value.code == null || selectCarTon.value.code?.isEmpty == true ? "톤수" : selectCarTon.value.codeName??"",
                            style: CustomStyle.CustomFont(styleFontSize22, Colors.black, font_weight: FontWeight.w800),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                          child: Scrollbar(
                            controller: _scrollControllerCargo,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                controller: _scrollControllerCargo,
                                shrinkWrap: true,
                                itemCount: cargoList.length,
                                itemBuilder: (context, index) {
                                  var item = cargoList[index];
                                  return selectItem(item,"01");
                                },
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Scrollbar(
                            controller: _scrollControllerCarTon,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                controller: _scrollControllerCarTon,
                                shrinkWrap: true,
                                itemCount: carTonList.length,
                                itemBuilder: (context, index) {
                                  var item = carTonList[index];
                                  return selectItem(item,"02");
                              },
                            )
                          )
                      ),
                    ],
                  )
                )
             ]),
          );
        }),
    ));
  }

}