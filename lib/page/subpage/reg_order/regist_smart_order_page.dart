import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';

class RegistSmartOrderPage extends StatefulWidget {

  OrderModel? order_vo;

  RegistSmartOrderPage({Key? key, this.order_vo}):super(key:key);

  _RegistSmartOrderPageState createState() => _RegistSmartOrderPageState();
}

class _RegistSmartOrderPageState extends State<RegistSmartOrderPage> {

  final mData = OrderModel().obs;
  late TextEditingController transInfoEtcController;
  late ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();

  @override
  void initState() {
    super.initState();

    transInfoEtcController = TextEditingController();

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <= scrollController.position.minScrollExtent && !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {
      }
    });

    Future.delayed(Duration.zero, () async {

      if(widget.order_vo != null) {
        mData.value = widget.order_vo!;
      }else{
        mData.value = OrderModel();
      }
      panelController.hide();
    });
  }

  @override
  void dispose() {
    super.dispose();
    transInfoEtcController.dispose();
  }

  bool transInfoValidation() {
    if(mData.value.sellDeptName == "" || mData.value.sellDeptName == null) {
      return false;
    }
    return true;
  }

  Widget transInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "화주정보",
          style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w700),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            border: Border.all(color: transInfoValidation() ? renew_main_color : const Color(0xffE8E8E8),width: 1.0)
          ),
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  if(SlidingUpPanelStatus.anchored==panelController.status){
                    panelController.hide();
                  }else{
                    panelController.anchor();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  color: transInfoValidation() ? renew_main_color : const Color(0xffEDEDED),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mData.value.sellCustName == "" || mData.value.sellCustName == null ? "화주를 선택해주세요." : mData.value.sellCustName??"",
                        style: CustomStyle.CustomFont(styleFontSize16, mData.value.sellCustName == "" || mData.value.sellCustName == null ? Colors.black : Colors.white, font_weight: FontWeight.w500),
                      ),
                      Container(
                        width: CustomStyle.getWidth(25.0),
                        height: CustomStyle.getHeight(25.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white
                        ),
                        child: Image.asset(
                          "assets/image/ic_check_on.png",
                          width: CustomStyle.getWidth(10.0),
                          height: CustomStyle.getHeight(10.0),
                          color: transInfoValidation() ? renew_main_color : const Color(0xffEDEDED),
                        ),
                      )
                    ],
                  ),
                )
              ),
              CustomStyle.getDivider1(),
              // 담당부서(필수)
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                                  child: Text(
                                    "담당부서",
                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                                  )
                                ),
                                Positioned(
                                  top: 2,
                                  right: 0,
                                  child: Image.asset(
                                    "assets/image/ic_star.png",
                                    width: CustomStyle.getWidth(15.0),
                                    height: CustomStyle.getHeight(15.0),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              mData.value.sellDeptName??"",
                              style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              // 담당자
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "담당자",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Row(
                            children: [
                              Text(
                                "김테스트",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: 21,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 연락처
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "연락처",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Text(
                            "010-0000-1111",
                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 거래처등급
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "거래처등급",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Text(
                            "정상",
                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 거래처등급사유
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "거래처등급사유",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Text(
                            "",
                            style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 차종
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(5),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "차종",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Row(
                            children: [
                              Text(
                                "냉장탑",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: 21,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 톤급
              Container(
                color: const Color(0xffEDEDED),
                padding: EdgeInsets.only(top: CustomStyle.getHeight(5),bottom: CustomStyle.getHeight(10),right: CustomStyle.getWidth(10),left: CustomStyle.getWidth(10)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10),bottom: CustomStyle.getHeight(10), right: CustomStyle.getWidth(15)),
                              child: Text(
                                "톤급",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              )
                          ),
                          Row(
                            children: [
                              Text(
                                "11톤",
                                style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: 21,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              CustomStyle.getDivider1(),
              // 기타 요청사항 입력
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                color: const Color(0xffEDEDED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                    padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
                      child: Text(
                        "기타",
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w600),
                      )
                    ),
                    SizedBox(
                        height: CustomStyle.getHeight(50.0),
                        child: TextField(
                          style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          onChanged: (value){

                          },
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: "요청사항을 입력해주세요.",
                              hintStyle: CustomStyle.CustomFont(styleFontSize14, const Color(0xffB7B7B7)),
                              contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(0.5))
                              ),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(0.5))
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(0.5))
                              )
                          ),
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget cargoInfoWidget() {
    return Container(

    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        } ,
        child: Stack(
            children : [
              Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop({'code': 100});
                    },
                    color: Colors.white,
                    icon: Icon(Icons.arrow_back, size: 24.h, color: Colors.black),
                  ),
                ),
            body: SafeArea(
                child: Obx(() {
                  return Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          transInfoWidget(),
                          transInfoValidation() == true ? cargoInfoWidget() : const SizedBox()
                        ],
                      )
                    )
                  );
              })
            ),
          ),
              SlidingUpPanelWidget(
                controlHeight: CustomStyle.getHeight(35),
                anchor: 0.4,
                panelController: panelController,
                onTap: (){
                  ///Customize the processing logic
                  if(SlidingUpPanelStatus.anchored == panelController.status){
                    panelController.hide();
                  }else{
                    panelController.anchor();
                  }
                },  //Pass a onTap callback to customize the processing logic when user click control bar.
                enableOnTap: true,//Enable the onTap callback for control bar.
                dragDown: (details){
                  print('dragDown -> $details');
                  if(SlidingUpPanelStatus.expanded == panelController.status){
                    panelController.anchor();
                  }else if(SlidingUpPanelStatus.anchored == panelController.status){
                    panelController.hide();
                  }else{
                    panelController.anchor();
                  }
                },
                dragStart: (details){
                  print('dragStart');
                },
                dragCancel: (){
                  print('dragCancel');
                },
                dragUpdate: (details){
                  print('dragUpdate,${panelController.status==SlidingUpPanelStatus.dragging?'dragging':''}');
                },
                dragEnd: (details){
                  print('dragEnd -> $details');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                  decoration: const ShapeDecoration(
                    color: Color(0xffEAEBED),
                    shadows: [BoxShadow(blurRadius: 5.0,spreadRadius: 2.0,color: Color(0x11000000))],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: CustomStyle.getHeight(35),
                        child:  Container(
                          width: CustomStyle.getWidth(50.w),
                          height: CustomStyle.getHeight(3.h),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Color(0xffD6D6D6)
                          ),
                        )
                      ),
                      Divider(
                        height: 0.5,
                        color: Colors.grey[300],
                      ),
                      Flexible(
                        child: ListView.builder(
                            itemCount: 20,
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Container(
                                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                                    alignment: Alignment.centerLeft,
                                    height: 50.h,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white
                                    ),
                                    child: Text('list item $index')
                                ),
                              );
                            },
                            shrinkWrap: true,
                          ),
                      ),
                    ],
                  ),
                ),
              ),
        ])
    );
  }

}