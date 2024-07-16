import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/template_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/utils/util.dart';

class TemplateManagePage extends StatefulWidget {

  TemplateManagePage({Key? key}):super(key:key);

  _TemplateManagePageState createState() => _TemplateManagePageState();
}

class _TemplateManagePageState extends State<TemplateManagePage> {

  final template_list = List.empty(growable: true).obs;
  final selectMode = false.obs;
  final select_template_list = List.empty(growable: true).obs;
  

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      template_list.add(
          TemplateModel(
              templateTitle: "템플릿 테스트",
              templateId: "TP20240711095643",
              reqCustId: "temp_test1",
              reqCustName: "테스트 화주",
              reqDeptId: "dept_test",
              reqDeptName: "배차팀",
              reqStaff: "김담당",
              reqTel: "010-1111-5222",
              reqAddr: "경기도 고양시 일산대로",
              reqAddrDetail: "화정트릴파크움 102동 1102호",
              custId: "C2024070900000",
              custName: "테스트 주선사",
              deptId: "tms_test",
              deptName: "관리자",
              inOutSctn: "01",
              inOutSctnName: "내수",
              truckTypeCode: "TR",
              truckTypeName: "트럭",
              sComName: "테스트 상차지",
              sSido: "경기도 고양시",
              sGungu: "일산서구",
              sDong: "풍산동",
              sAddr: "가내로 184-2길",
              sAddrDetail: "월드센트럴리움아이파크 101동 101호",
              sStaff: "곰담당",
              sTel: "010-9999-8888",
              sMemo: "상차지 테스트 메모",
              eComName: "하차지 테스트",
              eSido: "부산광역시",
              eGungu: "중구",
              eDong: "광산동",
              eAddr: "하천읍17-7길",
              eAddrDetail: "해운드릴터파크 202동 202호",
              eStaff: "쿠담당",
              eTel: "010-9999-7777",
              eMemo: "하차지 테스트 메모",
              sLat: 39.99152432,
              sLon: 72.79536515,
              eLat: 42.24884351,
              eLon: 135.5132484,
              goodsName: "화물정보 테스트",
              goodsWeight: "5톤",
              weightUnitCode: "TON",
              weightUnitName: "톤",
              goodsQty: "11",
              qtyUnitCode: "R/L",
              qtyUnitName: "qtyUnitName",
              sWayCode: "수",
              sWayName: "수작업",
              eWayCode: "지",
              eWayName: "지금",
              mixYn: "N",
              mixSize: "",
              returnYn: "N",
              carTonCode: "5",
              carTonName: "5톤",
              carTypeCode: "06",
              carTypeName: "몰루",
              chargeType: "01",
              chargeTypeName: "인수증",
              distance: 17.12,
              time: 27,
              reqMemo: "요청사항 뭔데?",
              driverMemo: "차주 요청 사항 뭔데?",
              itemCode: "27",
              itemName: "응애",
              stopCount: 0,

              sellCharge: "65000",
              sellFee: "6500",
              sellWeight: "1",
              sellWayPointMemo: "매출경유비 메모",
              sellWayPointCharge: "10000",
              sellStayMemo: "매출 대기료 메모",
              sellStayCharge: "10100",
              sellHandWorkMemo: "매출 수작업비 메모",
              sellHandWorkCharge: "10200",
              sellRoundMemo: "매출 회차료 메모",
              sellRoundCharge: "10300",
              sellOtherAddMemo: "매출 기타추가비 메모",
              sellOtherAddCharge: "10400",
              custPayType: "Y",

              buyCharge: "75000",
              buyFee: "7500",

              linkCode: "F",
              linkCodeName: "접수",
              linkType: "03",
              wayPointMemo: "ㅇㅇㅇ",
              wayPointCharge: "11",
              stayMemo: "ㄴㄴㄴㄴ",
              stayCharge: "22",
              handWorkMemo: "ㄷㄷㄷㄷ",
              handWorkCharge: "33",
              roundMemo: "ㄹㄹㄹㄹ",
              roundCharge: "44",
              otherAddMemo: "ㅁㅁㅁㅁ",
              otherAddCharge: "55",
              unitPrice: "",
              unitPriceType: "01",
              unitPriceTypeName: "대당단가",
              custMngName: "정상",
              custMngMemo: "정상입니다.",
              payType: "N",
              reqPayYN: "N",
              reqPayDate: "",
              talkYn: "Y",
              orderStopList: List.empty(growable: true),
              reqStaffName: "요담당",
              call24Cargo: "D",
              manCargo: "D",
              oneCargo: "R",
              call24Charge: "20000",
              manCharge: "15000",
              oneCharge: "16000"
          )
      );

      template_list.add(
          TemplateModel(
              templateTitle: "템플릿 테스트222",
              templateId: "TP20240710022141",
              reqCustId: "temp_test1",
              reqCustName: "테스트 화주",
              reqDeptId: "dept_test",
              reqDeptName: "배차팀",
              reqStaff: "김담당",
              reqTel: "010-1111-5222",
              reqAddr: "경기도 고양시 일산대로",
              reqAddrDetail: "화정트릴파크움 102동 1102호",
              custId: "C2024070900000",
              custName: "테스트 주선사",
              deptId: "tms_test",
              deptName: "관리자",
              inOutSctn: "01",
              inOutSctnName: "내수",
              truckTypeCode: "TR",
              truckTypeName: "트럭",
              sComName: "테스트 상차지",
              sSido: "경기도 고양시",
              sGungu: "일산서구",
              sDong: "풍산동",
              sAddr: "가내로 184-2길",
              sAddrDetail: "월드센트럴리움아이파크 101동 101호",
              sStaff: "곰담당",
              sTel: "010-9999-8888",
              sMemo: "상차지 테스트 메모",
              eComName: "하차지 테스트",
              eSido: "부산광역시",
              eGungu: "중구",
              eDong: "광산동",
              eAddr: "하천읍17-7길",
              eAddrDetail: "해운드릴터파크 202동 202호",
              eStaff: "쿠담당",
              eTel: "010-9999-7777",
              eMemo: "하차지 테스트 메모",
              sLat: 39.99152432,
              sLon: 72.79536515,
              eLat: 42.24884351,
              eLon: 135.5132484,
              goodsName: "화물정보 테스트",
              goodsWeight: "5톤",
              weightUnitCode: "TON",
              weightUnitName: "톤",
              goodsQty: "11",
              qtyUnitCode: "R/L",
              qtyUnitName: "qtyUnitName",
              sWayCode: "수",
              sWayName: "수작업",
              eWayCode: "지",
              eWayName: "지금",
              mixYn: "N",
              mixSize: "",
              returnYn: "N",
              carTonCode: "5",
              carTonName: "5톤",
              carTypeCode: "06",
              carTypeName: "몰루",
              chargeType: "01",
              chargeTypeName: "인수증",
              distance: 17.12,
              time: 27,
              reqMemo: "요청사항 뭔데?",
              driverMemo: "차주 요청 사항 뭔데?",
              itemCode: "27",
              itemName: "응애",
              stopCount: 0,

              sellCharge: "65000",
              sellFee: "6500",
              sellWeight: "1",
              sellWayPointMemo: "매출경유비 메모",
              sellWayPointCharge: "10000",
              sellStayMemo: "매출 대기료 메모",
              sellStayCharge: "10100",
              sellHandWorkMemo: "매출 수작업비 메모",
              sellHandWorkCharge: "10200",
              sellRoundMemo: "매출 회차료 메모",
              sellRoundCharge: "10300",
              sellOtherAddMemo: "매출 기타추가비 메모",
              sellOtherAddCharge: "10400",
              custPayType: "Y",

              buyCharge: "75000",
              buyFee: "7500",

              linkCode: "F",
              linkCodeName: "접수",
              linkType: "03",
              wayPointMemo: "ㅇㅇㅇ",
              wayPointCharge: "11",
              stayMemo: "ㄴㄴㄴㄴ",
              stayCharge: "22",
              handWorkMemo: "ㄷㄷㄷㄷ",
              handWorkCharge: "33",
              roundMemo: "ㄹㄹㄹㄹ",
              roundCharge: "44",
              otherAddMemo: "ㅁㅁㅁㅁ",
              otherAddCharge: "55",
              unitPrice: "",
              unitPriceType: "01",
              unitPriceTypeName: "대당단가",
              custMngName: "정상",
              custMngMemo: "정상입니다.",
              payType: "N",
              reqPayYN: "N",
              reqPayDate: "",
              talkYn: "Y",
              orderStopList: List.empty(growable: true),
              reqStaffName: "요담당",
              call24Cargo: "D",
              manCargo: "D",
              oneCargo: "R",
              call24Charge: "20000",
              manCharge: "15000",
              oneCharge: "16000"
          )
      );

      template_list.add(
          TemplateModel(
              templateTitle: "템플릿 테스트333",
              templateId: "TP20240713032153",
              reqCustId: "temp_test1",
              reqCustName: "테스트 화주",
              reqDeptId: "dept_test",
              reqDeptName: "배차팀",
              reqStaff: "김담당",
              reqTel: "010-1111-5222",
              reqAddr: "경기도 고양시 일산대로",
              reqAddrDetail: "화정트릴파크움 102동 1102호",
              custId: "C2024070900000",
              custName: "테스트 주선사",
              deptId: "tms_test",
              deptName: "관리자",
              inOutSctn: "01",
              inOutSctnName: "내수",
              truckTypeCode: "TR",
              truckTypeName: "트럭",
              sComName: "테스트 상차지",
              sSido: "경기도 고양시",
              sGungu: "일산서구",
              sDong: "풍산동",
              sAddr: "가내로 184-2길",
              sAddrDetail: "월드센트럴리움아이파크 101동 101호",
              sStaff: "곰담당",
              sTel: "010-9999-8888",
              sMemo: "상차지 테스트 메모",
              eComName: "하차지 테스트",
              eSido: "부산광역시",
              eGungu: "중구",
              eDong: "광산동",
              eAddr: "하천읍17-7길",
              eAddrDetail: "해운드릴터파크 202동 202호",
              eStaff: "쿠담당",
              eTel: "010-9999-7777",
              eMemo: "하차지 테스트 메모",
              sLat: 39.99152432,
              sLon: 72.79536515,
              eLat: 42.24884351,
              eLon: 135.5132484,
              goodsName: "화물정보 테스트",
              goodsWeight: "5톤",
              weightUnitCode: "TON",
              weightUnitName: "톤",
              goodsQty: "11",
              qtyUnitCode: "R/L",
              qtyUnitName: "qtyUnitName",
              sWayCode: "수",
              sWayName: "수작업",
              eWayCode: "지",
              eWayName: "지금",
              mixYn: "N",
              mixSize: "",
              returnYn: "N",
              carTonCode: "5",
              carTonName: "5톤",
              carTypeCode: "06",
              carTypeName: "몰루",
              chargeType: "01",
              chargeTypeName: "인수증",
              distance: 17.12,
              time: 27,
              reqMemo: "요청사항 뭔데?",
              driverMemo: "차주 요청 사항 뭔데?",
              itemCode: "27",
              itemName: "응애",
              stopCount: 0,

              sellCharge: "65000",
              sellFee: "6500",
              sellWeight: "1",
              sellWayPointMemo: "매출경유비 메모",
              sellWayPointCharge: "10000",
              sellStayMemo: "매출 대기료 메모",
              sellStayCharge: "10100",
              sellHandWorkMemo: "매출 수작업비 메모",
              sellHandWorkCharge: "10200",
              sellRoundMemo: "매출 회차료 메모",
              sellRoundCharge: "10300",
              sellOtherAddMemo: "매출 기타추가비 메모",
              sellOtherAddCharge: "10400",
              custPayType: "Y",

              buyCharge: "75000",
              buyFee: "7500",

              linkCode: "F",
              linkCodeName: "접수",
              linkType: "03",
              wayPointMemo: "ㅇㅇㅇ",
              wayPointCharge: "11",
              stayMemo: "ㄴㄴㄴㄴ",
              stayCharge: "22",
              handWorkMemo: "ㄷㄷㄷㄷ",
              handWorkCharge: "33",
              roundMemo: "ㄹㄹㄹㄹ",
              roundCharge: "44",
              otherAddMemo: "ㅁㅁㅁㅁ",
              otherAddCharge: "55",
              unitPrice: "",
              unitPriceType: "01",
              unitPriceTypeName: "대당단가",
              custMngName: "정상",
              custMngMemo: "정상입니다.",
              payType: "N",
              reqPayYN: "N",
              reqPayDate: "",
              talkYn: "Y",
              orderStopList: List.empty(growable: true),
              reqStaffName: "요담당",
              call24Cargo: "D",
              manCargo: "D",
              oneCargo: "R",
              call24Charge: "20000",
              manCharge: "15000",
              oneCharge: "16000"
          )
      );

      template_list.add(
          TemplateModel(
              templateTitle: "템플릿 테스트444",
              templateId: "TP202407141201772",
              reqCustId: "temp_test1",
              reqCustName: "테스트 화주",
              reqDeptId: "dept_test",
              reqDeptName: "배차팀",
              reqStaff: "김담당",
              reqTel: "010-1111-5222",
              reqAddr: "경기도 고양시 일산대로",
              reqAddrDetail: "화정트릴파크움 102동 1102호",
              custId: "C2024070900000",
              custName: "테스트 주선사",
              deptId: "tms_test",
              deptName: "관리자",
              inOutSctn: "01",
              inOutSctnName: "내수",
              truckTypeCode: "TR",
              truckTypeName: "트럭",
              sComName: "테스트 상차지",
              sSido: "경기도 고양시",
              sGungu: "일산서구",
              sDong: "풍산동",
              sAddr: "가내로 184-2길",
              sAddrDetail: "월드센트럴리움아이파크 101동 101호",
              sStaff: "곰담당",
              sTel: "010-9999-8888",
              sMemo: "상차지 테스트 메모",
              eComName: "하차지 테스트",
              eSido: "부산광역시",
              eGungu: "중구",
              eDong: "광산동",
              eAddr: "하천읍17-7길",
              eAddrDetail: "해운드릴터파크 202동 202호",
              eStaff: "쿠담당",
              eTel: "010-9999-7777",
              eMemo: "하차지 테스트 메모",
              sLat: 39.99152432,
              sLon: 72.79536515,
              eLat: 42.24884351,
              eLon: 135.5132484,
              goodsName: "화물정보 테스트",
              goodsWeight: "5톤",
              weightUnitCode: "TON",
              weightUnitName: "톤",
              goodsQty: "11",
              qtyUnitCode: "R/L",
              qtyUnitName: "qtyUnitName",
              sWayCode: "수",
              sWayName: "수작업",
              eWayCode: "지",
              eWayName: "지금",
              mixYn: "N",
              mixSize: "",
              returnYn: "N",
              carTonCode: "5",
              carTonName: "5톤",
              carTypeCode: "06",
              carTypeName: "몰루",
              chargeType: "01",
              chargeTypeName: "인수증",
              distance: 17.12,
              time: 27,
              reqMemo: "요청사항 뭔데?",
              driverMemo: "차주 요청 사항 뭔데?",
              itemCode: "27",
              itemName: "응애",
              stopCount: 0,

              sellCharge: "65000",
              sellFee: "6500",
              sellWeight: "1",
              sellWayPointMemo: "매출경유비 메모",
              sellWayPointCharge: "10000",
              sellStayMemo: "매출 대기료 메모",
              sellStayCharge: "10100",
              sellHandWorkMemo: "매출 수작업비 메모",
              sellHandWorkCharge: "10200",
              sellRoundMemo: "매출 회차료 메모",
              sellRoundCharge: "10300",
              sellOtherAddMemo: "매출 기타추가비 메모",
              sellOtherAddCharge: "10400",
              custPayType: "Y",

              buyCharge: "75000",
              buyFee: "7500",

              linkCode: "F",
              linkCodeName: "접수",
              linkType: "03",
              wayPointMemo: "ㅇㅇㅇ",
              wayPointCharge: "11",
              stayMemo: "ㄴㄴㄴㄴ",
              stayCharge: "22",
              handWorkMemo: "ㄷㄷㄷㄷ",
              handWorkCharge: "33",
              roundMemo: "ㄹㄹㄹㄹ",
              roundCharge: "44",
              otherAddMemo: "ㅁㅁㅁㅁ",
              otherAddCharge: "55",
              unitPrice: "",
              unitPriceType: "01",
              unitPriceTypeName: "대당단가",
              custMngName: "정상",
              custMngMemo: "정상입니다.",
              payType: "N",
              reqPayYN: "N",
              reqPayDate: "",
              talkYn: "Y",
              orderStopList: List.empty(growable: true),
              reqStaffName: "요담당",
              call24Cargo: "D",
              manCargo: "D",
              oneCargo: "R",
              call24Charge: "20000",
              manCharge: "15000",
              oneCharge: "16000"
          )
      );
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


  /**
   * Function End
   */




  /**
  * Widget Start
  **/

  Widget getListItemView(TemplateModel item) {

    return InkWell(
      onTap: (){
        if(selectMode.value) {
          print("몇개여몇개여 => ${select_template_list.length}");
          if(select_template_list.length > 0){
            for (var listItem in select_template_list) {
              if (listItem.templateId == item.templateId) {
                select_template_list.remove(item);
              } else {
                select_template_list.add(item);
              }
            }
          }else{
            select_template_list.add(item);
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
                          "${item.custName}",
                          style:CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w500)
                      ),
                      Text(
                          "${item.deptId}",
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              padding:const EdgeInsets.all(3),
                                              margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                              decoration: const BoxDecoration(
                                                  color: renew_main_color2,
                                                  shape: BoxShape.circle
                                              ),
                                              child: Text("상",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                          ),
                                          Text(
                                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                                            style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400),
                                            textAlign: TextAlign.center,
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                padding:const EdgeInsets.all(3),
                                                margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                                decoration: const BoxDecoration(
                                                    color: rpa_btn_cancle,
                                                    shape: BoxShape.circle
                                                ),
                                                child: Text("하",style: CustomStyle.CustomFont(styleFontSize12, Colors.white,font_weight: FontWeight.w600),)
                                            ),
                                            Text(
                                              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                                              style: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w400),
                                              textAlign: TextAlign.center,
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
              Obx(() =>
              selectMode.value ?
              TextButton(
                  onPressed: (){
                    openCommonConfirmBox(
                        context,
                        "${select_template_list.length}건의 탬플릿을 삭제하시겠습니까?",
                        Strings.of(context)?.get("cancel")??"Not Found",
                        Strings.of(context)?.get("confirm")??"Not Found",
                            () {Navigator.of(context).pop(false);},
                            () async {
                          Navigator.of(context).pop(false);
                          int delCnt = 0;
                          for(var selectItem in select_template_list) {
                            template_list.remove(selectItem);
                            delCnt++;
                          }
                          Util.snackbar(context, "$delCnt건의 탬플릿이 삭제되었습니다.");
                          selectMode.value = false;
                        }
                    );
                  },
                  child: Text(
                    "삭제",
                    style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                  )
              ) : const SizedBox()
              ),
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
        )
    );
  }


  /**
   * Widget End
   **/

}