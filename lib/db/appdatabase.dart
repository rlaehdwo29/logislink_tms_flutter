import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//Table
const String orderTable = "order_table";
// Column
const String orderId = "orderId";                //오더 ID
const String reqCustId = "reqCustId";            //화주 거래처 ID
const String reqCustName = "reqCustName";            //화주 거래처명
const String reqDeptId = "reqDeptId";            //화주 부서 ID
const String reqDeptName = "reqDeptName";            //화주 부서명
const String reqStaff = "reqStaff";            //화주 담당자
const String reqTel = "reqTel";                //화주 연락처
const String reqAddr = "reqAddr";                //화주 주소
const String reqAddrDetail = "reqAddrDetail";        //화주 상세주소
const String custId = "custId";                //화주 지정 운송,주선사 ID
const String custName = "custName";
const String deptId = "deptId";                //화주 지정 운송,주선사 부서 Id
const String deptName = "deptName";
const String inOutSctn = "inOutSctn";            //수출입구분(내수, 수출입)
const String inOutSctnName = "inOutSctnName";
const String truckTypeCode = "truckTypeCode";        //운송유형
const String truckTypeName = "truckTypeName";
const String sComName = "sComName";            //상차지명
const String sSido = "sSido";                //상차지시도
const String sGungu = "sGungu";                //상차지군구
const String sDong = "sDong";                //상차지동
const String sAddr = "sAddr";                //상차지주소
const String sAddrDetail = "sAddrDetail";            //상차지상세주소
const String sDate = "sDate";                //상차일 (YYYY-MM-DD HH:mm:ss)
const String sStaff = "sStaff";                //상차지담당자
const String sTel = "sTel";                //상차지 연락처
const String sMemo = "sMemo";                //상차지메모
const String eComName = "eComName";            //하차지명
const String eSido = "eSido";                //하차지시도
const String eGungu = "eGungu";                //하차지군구
const String eDong = "eDong";                //하차지 동
const String eAddr = "eAddr";                //하차지 주소
const String eAddrDetail = "eAddrDetail";            //하차지 상세주소
const String eDate = "eDate";                //하차일 (YYYY-MM-DD HH:mm:ss)
const String eStaff = "eStaff";                //하차지 담당자
const String eTel = "eTel";                //하차지 연락처
const String eMemo = "eMemo";                //하차지 메모
const String sLat = "sLat";
const String sLon = "sLon";
const String eLat = "eLat";
const String eLon = "eLon";
const String goodsName = "goodsName";            //화물정보
const String goodsWeight = "goodsWeight";            //화물중량
const String weightUnitCode = "weightUnitCode";        //중량단위코드
const String weightUnitName = "weightUnitName";        //중량단위이름
const String goodsQty = "goodsQty";            //화물수량
const String qtyUnitCode = "qtyUnitCode";            //수량단위코드
const String qtyUnitName = "qtyUnitName";            //수량단위이름
const String sWayCode = "sWayCode";            //상차방법
const String sWayName = "sWayName";            //상차방법
const String eWayCode = "eWayCode";            //하차방법
const String eWayName = "eWayName";            //하차방법
const String mixYn = "mixYn";                //혼적여부
const String mixSize = "mixSize";                //혼적크기
const String returnYn = "returnYn";            //왕복여부
const String carTonCode = "carTonCode";
const String carTonName = "carTonName";
const String carTypeCode = "carTypeCode";
const String carTypeName = "carTypeName";
const String chargeType = "chargeType";            //운임구분코드(인수증.선착불)
const String chargeTypeName = "chargeTypeName";
const String distance = "distance";
const String time = "time";
const String reqMemo = "reqMemo";                //화주 요청사항 (주선사/운송사 확인)
const String driverMemo = "driverMemo";            //차주 확인사항
const String itemCode = "itemCode";            //운송품목코드
const String itemName = "itemName";            //운송품목코드
const String orderState = "orderState";
const String orderStateName = "orderStateName";
const String regid = "regid";                   //등록 id
const String regdate = "regdate";                 //오더 등록일
const String stopCount = "stopCount";                  //경유지

/* 매출 정보  */
const String sellAllocId = "sellAllocId";             //매출 배차 ID
const String sellCustId = "sellCustId";              //매출 거래처 ID
const String sellDeptId = "sellDeptId";              //매출 부서 ID
const String sellStaff = "sellStaff";               //매출거래처 담당자
const String sellStaffName = "sellStaffName";           //매출거래처 담당자
const String sellStaffTel = "sellStaffTel";            //매출거래처 담당자 연락처
const String sellCustName = "sellCustName";
const String sellDeptName = "sellDeptName";
const String sellCharge = "sellCharge";              //매출운송비
const String sellFee = "sellFee";                 //매출수수료
const String sellWeight = "sellWeight";              //매출중량
const String sellWayPointMemo = "sellWayPointMemo";        //경유비 메모
const String sellWayPointCharge = "sellWayPointCharge";      //경유비 금액
const String sellStayMemo = "sellStayMemo";            //대기료 메모
const String sellStayCharge = "sellStayCharge";          //대기료 금액
const String sellHandWorkMemo = "sellHandWorkMemo";        //수작업비 메모
const String sellHandWorkCharge = "sellHandWorkCharge";      //수작업비 금액
const String sellRoundMemo = "sellRoundMemo";           //회차료 메모
const String sellRoundCharge = "sellRoundCharge";         //회차료 금액
const String sellOtherAddMemo = "sellOtherAddMemo";        //기타추가비 메모
const String sellOtherAddCharge = "sellOtherAddCharge";      //기타추가비 금액
const String custPayType = "custPayType";             //거래처 빠른지급여부

/* 매입 정보 */
const String allocId = "allocId";                //매입 배차 ID
const String allocState = "allocState";            //배차상태
const String allocStateName = "allocStateName";
const String buyCustId = "buyCustId";            //매입 거래처 ID (물량 받는곳)
const String buyDeptId = "buyDeptId";            //매입 부서 ID
const String buyCustName = "buyCustName";
const String buyDeptName = "buyDeptName";
const String buyStaff = "buyStaff";            //매입거래처담당자 ID
const String buyStaffName = "buyStaffName";            //매입거래처담당자 이름
const String buyStaffTel = "buyStaffTel";            //매입거래처 연락처
const String buyCharge = "buyCharge";                //매입운송비
const String buyFee = "buyFee";                    //매입수수료
const String allocDate = "allocDate";            //배차일 (매입 정보 지정일)

/* 배차 차주 정보*/
const String driverState = "driverState";            //차주 배차 상태
const String vehicId = "vehicId";                //차량 id
const String driverId = "driverId";            //차주 id
const String carNum = "carNum";                //차량번호
const String driverName = "driverName";            //차주명
const String driverTel = "driverTel";        //차주연락처
const String driverStateName = "driverStateName";
const String carMngName = "carMngName"; //차량관리(정상,블랙리스트)
const String carMngMemo = "carMngMemo"; //차량관리메모

const String receiptYn = "receiptYn";            //인수증접수여부
const String receiptPath = "receiptPath";            //인수증 경로
const String receiptDate = "receiptDate";            //인수증접수일

const String charge = "charge";              // 구간별계약단가

const String startDate = "startDate";           // 출발일
const String finishDate = "finishDate";          // 도착일
const String enterDate = "enterDate";           // 입차일

const String payDate = "payDate";             // 결제일

const String linkCode = "linkCode";            // 정보망코드
const String linkCodeName = "linkCodeName";        // 정보망코드이름

const String linkType = "linkType";            // 정보망코드
const String buyLinkYn = "buyLinkYn";           //정보망 배차 여부
const String linkName = "linkName";            //배차된 정보망 이름

const String wayPointMemo = "wayPointMemo";      //경유비 메모
const String wayPointCharge = "wayPointCharge";   //경유비 금액
const String stayMemo = "stayMemo";         //대기료 메모
const String stayCharge = "stayCharge";      //대기료 금액
const String handWorkMemo = "handWorkMemo";      //수작업비 메모
const String handWorkCharge = "handWorkCharge";   //수작업비 금액
const String roundMemo = "roundMemo";      //회차료 메모
const String roundCharge = "roundCharge";      //회차료 금액
const String otherAddMemo = "otherAddMemo";      //기타추가비 메모
const String otherAddCharge = "otherAddCharge";   //기타추가비 금액

const String unitPrice = "unitPrice";
const String unitPriceType = "unitPriceType";
const String unitPriceTypeName = "unitPriceTypeName";

const String custMngName = "custMngName";
const String custMngMemo = "custMngMemo";

const String payType = "payType";
const String reqPayYN = "reqPayYN";
const String reqPayDate = "reqPayDate";
const String talkYn = "talkYn";
const String orderStopList = "orderStopList"; // 경유지 목록
const String reqStaffName = "reqStaffName";

const String call24Cargo = "call24Cargo";
const String manCargo = "manCargo";
const String oneCargo = "oneCargo";
const String call24Charge = "call24Charge";
const String manCharge = "manCharge";
const String oneCharge = "oneCharge";

class AppDataBase {

  static Database? _orderDb;

  Future<Database?> get orderDb async {
    _orderDb = await initOrderDB();
    return _orderDb;
  }

  Future initOrderDB() async {
    String path = join(await getDatabasesPath(), 'logislink_db.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS $orderTable($orderId text primary key,$reqCustId text,$reqCustName text, $reqDeptId text,$reqDeptName text,$reqStaff text,$reqTel text,$reqAddr text,$reqAddrDetail text,$custId text,$custName text,$deptId text,$deptName text,$inOutSctn text,$inOutSctnName text,$truckTypeCode text,$truckTypeName text,$sComName text,$sSido text,$sGungu text,$sDong text,$sAddr text,$sAddrDetail text,$sDate text,$sStaff text,$sTel text,$sMemo text,$eComName text,$eSido text,$eGungu text,$eDong text,$eAddr text,$eAddrDetail text,$eDate text,$eStaff text,$eTel text,$eMemo text,$sLat text NOT NULL,$sLon text NOT NULL,$eLat text NOT NULL,$eLon text NOT NULL,$goodsName text,$goodsWeight text,$weightUnitCode text,$weightUnitName text,$goodsQty text,$qtyUnitCode text,$qtyUnitName text,$sWayCode text,$sWayName text,$eWayCode text,$eWayName text,$mixYn text,$mixSize text,$returnYn text,$carTonCode text,$carTonName text,$carTypeCode text,$carTypeName text,$chargeType text,$chargeTypeName text,$distance text NOT NULL,$time integer NOT NULL,$reqMemo text,$driverMemo text,$itemCode text,$itemName text,$orderState text,$orderStateName text,$regid text,$regdate text,$stopCount integer,$sellAllocId text,$sellCustId text,$sellDeptId text,$sellStaff text,$sellStaffName text,$sellStaffTel text,$sellCustName text,$sellDeptName text,$sellCharge text,$sellFee text,$sellWeight text,$sellWayPointMemo text,$sellWayPointCharge text,$sellStayMemo text,$sellStayCharge text,$sellHandWorkMemo text,$sellHandWorkCharge text,$sellRoundMemo text,$sellRoundCharge text,$sellOtherAddMemo text,$sellOtherAddCharge text,$custPayType text,$allocId text,$allocState text,$allocStateName text,$buyCustId text,$buyDeptId text,$buyCustName text,$buyDeptName text,$buyStaff text,$buyStaffName text,$buyStaffTel text,$buyCharge text,$buyFee text,$allocDate text,$driverState text,$vehicId text,$driverId text,$carNum text,$driverName text,$driverTel text,$driverStateName text,$carMngName text,$carMngMemo text,$receiptYn text,$receiptPath text,$receiptDate text,$charge text,$startDate text,$finishDate text,$enterDate text,$payDate text,$linkCode text,$linkCodeName text,$linkType text,$buyLinkYn text,$linkName text,$wayPointMemo text,$wayPointCharge text,$stayMemo text,$stayCharge text,$handWorkMemo text,$handWorkCharge text,$roundMemo text,$roundCharge text,$otherAddMemo text,$otherAddCharge text,$unitPrice text,$unitPriceType text,$unitPriceTypeName text,$custMngName text,$custMngMemo text,$payType text,$reqPayYN text,$reqPayDate text,$talkYn text,$orderStopList text,$reqStaffName text,$call24Cargo text,$manCargo text,$oneCargo text, $call24Charge text, $manCharge text, $oneCharge text)");
        }
    );
  }

  Future updateOrder(OrderModel order) async {
    final db = await orderDb;
    try {
      final List<Map<String, Object?>>? maps = await db?.query(
          '$orderTable', where: "$orderId = ?", whereArgs: [order.orderId]);
      if (maps == null || maps.length <= 0) {
        var result = await db?.insert(orderTable, order.toMap());
      } else {
        await db?.update('$orderTable', <String, dynamic>{
          "$orderId": "${order.orderId}",
          "$reqCustId": "${order.reqCustId}",
          "$reqCustName": "${order.reqCustName}",
          "$reqDeptId": "${order.reqDeptId}",
          "$reqDeptName": "${order.reqDeptName}",
          "$reqStaff": "${order.reqStaff}",
          "$reqTel": "${order.reqTel}",
          "$reqAddr": "${order.reqAddr}",
          "$reqAddrDetail": "${order.reqAddrDetail}",
          "$custId": "${order.custId}",
          "$custName": "${order.custName}",
          "$deptId": "${order.deptId}",
          "$deptName": "${order.deptName}",
          "$inOutSctn": "${order.inOutSctn}",
          "$inOutSctnName": "${order.inOutSctnName}",
          "$truckTypeCode": "${order.truckTypeCode}",
          "$truckTypeName": "${order.truckTypeName}",
          "$sComName": "${order.sComName}",
          "$sSido": "${order.sSido}",
          "$sGungu": "${order.sGungu}",
          "$sDong": "${order.sDong}",
          "$sAddr": "${order.sAddr}",
          "$sAddrDetail": "${order.sAddrDetail}",
          "$sDate": "${order.sDate}",
          "$sStaff": "${order.sStaff}",
          "$sTel": "${order.sTel}",
          "$sMemo": "${order.sMemo}",
          "$eComName": "${order.eComName}",
          "$eSido": "${order.eSido}",
          "$eGungu": "${order.eGungu}",
          "$eDong": "${order.eDong}",
          "$eAddr": "${order.eAddr}",
          "$eAddrDetail": "${order.eAddrDetail}",
          "$eDate": "${order.eDate}",
          "$eStaff": "${order.eStaff}",
          "$eTel": "${order.eTel}",
          "$eMemo": "${order.eMemo}",
          "$sLat": "${order.sLat}",
          "$sLon": "${order.sLon}",
          "$eLat": "${order.eLat}",
          "$eLon": "${order.eLon}",
          "$goodsName": "${order.goodsName}",
          "$goodsWeight": "${order.goodsWeight}",
          "$weightUnitCode": "${order.weightUnitCode}",
          "$weightUnitName": "${order.weightUnitName}",
          "$goodsQty": "${order.goodsQty}",
          "$qtyUnitCode": "${order.qtyUnitCode}",
          "$qtyUnitName": "${order.qtyUnitName}",
          "$sWayCode": "${order.sWayCode}",
          "$sWayName": "${order.sWayName}",
          "$eWayCode": "${order.eWayCode}",
          "$eWayName": "${order.eWayName}",
          "$mixYn": "${order.mixYn}",
          "$mixSize": "${order.mixSize}",
          "$returnYn": "${order.returnYn}",
          "$carTonCode": "${order.carTonCode}",
          "$carTonName": "${order.carTonName}",
          "$carTypeCode": "${order.carTypeCode}",
          "$carTypeName": "${order.carTypeName}",
          "$chargeType": "${order.chargeType}",
          "$chargeTypeName": "${order.chargeTypeName}",
          "$distance": "${order.distance}",
          "$time": "${order.time}",
          "$reqMemo": "${order.reqMemo}",
          "$driverMemo": "${order.driverMemo}",
          "$itemCode": "${order.itemCode}",
          "$itemName": "${order.itemName}",
          "$orderState": "${order.orderState}",
          "$orderStateName": "${order.orderStateName}",
          "$regid": "${order.regid}",
          "$regdate": "${order.regdate}",
          "$stopCount": "${order.stopCount}",
          "$sellAllocId": "${order.sellAllocId}",
          "$sellCustId": "${order.sellCustId}",
          "$sellDeptId": "${order.sellDeptId}",
          "$sellStaff": "${order.sellStaff}",
          "$sellStaffName": "${order.sellStaffName}",
          "$sellStaffTel": "${order.sellStaffTel}",
          "$sellCustName": "${order.sellCustName}",
          "$sellDeptName": "${order.sellDeptName}",
          "$sellCharge": "${order.sellCharge}",
          "$sellFee": "${order.sellFee}",
          "$sellWeight": "${order.sellWeight}",
          "$sellWayPointMemo": "${order.sellWayPointMemo}",
          "$sellWayPointCharge": "${order.sellWayPointCharge}",
          "$sellStayMemo": "${order.sellStayMemo}",
          "$sellStayCharge": "${order.sellStayCharge}",
          "$sellHandWorkMemo": "${order.sellHandWorkMemo}",
          "$sellHandWorkCharge": "${order.sellHandWorkCharge}",
          "$sellRoundMemo": "${order.sellRoundMemo}",
          "$sellRoundCharge": "${order.sellRoundCharge}",
          "$sellOtherAddMemo": "${order.sellOtherAddMemo}",
          "$sellOtherAddCharge": "${order.sellOtherAddCharge}",
          "$custPayType": "${order.custPayType}",
          "$allocId": "${order.allocId}",
          "$allocState": "${order.allocState}",
          "$allocStateName": "${order.allocStateName}",
          "$buyCustId": "${order.buyCustId}",
          "$buyDeptId": "${order.buyDeptId}",
          "$buyCustName": "${order.buyCustName}",
          "$buyDeptName": "${order.buyDeptName}",
          "$buyStaff": "${order.buyStaff}",
          "$buyStaffName": "${order.buyStaffName}",
          "$buyStaffTel": "${order.buyStaffTel}",
          "$buyCharge": "${order.buyCharge}",
          "$buyFee": "${order.buyFee}",
          "$allocDate": "${order.allocDate}",
          "$driverState": "${order.driverState}",
          "$vehicId": "${order.vehicId}",
          "$driverId": "${order.driverId}",
          "$carNum": "${order.carNum}",
          "$driverName": "${order.driverName}",
          "$driverTel": "${order.driverTel}",
          "$driverStateName": "${order.driverStateName}",
          "$carMngName": "${order.carMngName}",
          "$carMngMemo": "${order.carMngMemo}",
          "$receiptYn": "${order.receiptYn}",
          "$receiptPath": "${order.receiptPath}",
          "$receiptDate": "${order.receiptDate}",
          "$charge": "${order.charge}",
          "$startDate": "${order.startDate}",
          "$finishDate": "${order.finishDate}",
          "$enterDate": "${order.enterDate}",
          "$payDate": "${order.payDate}",
          "$linkCode": "${order.linkCode}",
          "$linkCodeName": "${order.linkCodeName}",
          "$linkType": "${order.linkType}",
          "$buyLinkYn": "${order.buyLinkYn}",
          "$linkName": "${order.linkName}",
          "$wayPointMemo": "${order.wayPointMemo}",
          "$wayPointCharge": "${order.wayPointCharge}",
          "$stayMemo": "${order.stayMemo}",
          "$stayCharge": "${order.stayCharge}",
          "$handWorkMemo": "${order.handWorkMemo}",
          "$handWorkCharge": "${order.handWorkCharge}",
          "$roundMemo": "${order.roundMemo}",
          "$roundCharge": "${order.roundCharge}",
          "$otherAddMemo": "${order.otherAddMemo}",
          "$otherAddCharge": "${order.otherAddCharge}",
          "$unitPrice": "${order.unitPrice}",
          "$unitPriceType": "${order.unitPriceType}",
          "$unitPriceTypeName": "${order.unitPriceTypeName}",
          "$custMngName": "${order.custMngName}",
          "$custMngMemo": "${order.custMngMemo}",
          "$payType": "${order.payType}",
          "$reqPayYN": "${order.reqPayYN}",
          "$reqPayDate": "${order.reqPayDate}",
          "$talkYn": "${order.talkYn}",
          "$orderStopList": "${order.orderStopList}",
          "$reqStaffName":"${order.reqStaffName}",
          "$call24Cargo": "${order.call24Cargo}",
          "$manCargo": "${order.manCargo}",
          "$oneCargo": "${order.oneCargo}",
          "$call24Charge": "${order.call24Charge}",
          "$manCharge": "${order.manCharge}",
          "$oneCharge": "${order.oneCharge}"
        }, where: "$orderId = ?", whereArgs: [order.orderId]);
      }
    }catch(e){
      print("setOrder() Exception => $e");
    }
  }

  Future delete(OrderModel order) async {
    final db = await orderDb;
    await db?.delete('$orderTable',where: "$orderId =?",whereArgs: [order.orderId]);
  }

  Future<void> deleteAll() async {
    var search_table = await orderDb;
    if(search_table != null ){
        final db = await orderDb;
        await db?.rawDelete("DELETE FROM $orderTable");
        //await db?.execute("CREATE TABLE IF NOT EXISTS $orderTable($orderId text primary key,$reqCustId text,$reqCustName text, $reqDeptId text,$reqDeptName text,$reqStaff text,$reqTel text,$reqAddr text,$reqAddrDetail text,$custId text,$custName text,$deptId text,$deptName text,$inOutSctn text,$inOutSctnName text,$truckTypeCode text,$truckTypeName text,$sComName text,$sSido text,$sGungu text,$sDong text,$sAddr text,$sAddrDetail text,$sDate text,$sStaff text,$sTel text,$sMemo text,$eComName text,$eSido text,$eGungu text,$eDong text,$eAddr text,$eAddrDetail text,$eDate text,$eStaff text,$eTel text,$eMemo text,$sLat text NOT NULL,$sLon text NOT NULL,$eLat text NOT NULL,$eLon text NOT NULL,$goodsName text,$goodsWeight text,$weightUnitCode text,$weightUnitName text,$goodsQty text,$qtyUnitCode text,$qtyUnitName text,$sWayCode text,$sWayName text,$eWayCode text,$eWayName text,$mixYn text,$mixSize text,$returnYn text,$carTonCode text,$carTonName text,$carTypeCode text,$carTypeName text,$chargeType text,$chargeTypeName text,$distance text NOT NULL,$time integer NOT NULL,$reqMemo text,$driverMemo text,$itemCode text,$itemName text,$orderState text,$orderStateName text,$regid text,$regdate text,$stopCount integer,$sellAllocId text,$sellCustId text,$sellDeptId text,$sellStaff text,$sellStaffName text,$sellStaffTel text,$sellCustName text,$sellDeptName text,$sellCharge text,$sellFee text,$sellWeight text,$sellWayPointMemo text,$sellWayPointCharge text,$sellStayMemo text,$sellStayCharge text,$sellHandWorkMemo text,$sellHandWorkCharge text,$sellRoundMemo text,$sellRoundCharge text,$sellOtherAddMemo text,$sellOtherAddCharge text,$custPayType text,$allocId text,$allocState text,$allocStateName text,$buyCustId text,$buyDeptId text,$buyCustName text,$buyDeptName text,$buyStaff text,$buyStaffName text,$buyStaffTel text,$buyCharge text,$buyFee text,$allocDate text,$driverState text,$vehicId text,$driverId text,$carNum text,$driverName text,$driverTel text,$driverStateName text,$carMngName text,$carMngMemo text,$receiptYn text,$receiptPath text,$receiptDate text,$charge text,$startDate text,$finishDate text,$enterDate text,$payDate text,$linkCode text,$linkCodeName text,$linkType text,$buyLinkYn text,$linkName text,$wayPointMemo text,$wayPointCharge text,$stayMemo text,$stayCharge text,$handWorkMemo text,$handWorkCharge text,$roundMemo text,$roundCharge text,$otherAddMemo text,$otherAddCharge text,$unitPrice text,$unitPriceType text,$unitPriceTypeName text,$custMngName text,$custMngMemo text,$payType text,$reqPayYN text,$reqPayDate text,$talkYn text,$orderStopList text,$reqStaffName text,$call24Cargo text,$manCargo text,$oneCargo text, $call24Charge text, $manCharge text, $oneCharge text)");
      }
  }

  Future<void> insertAll(BuildContext context, List<OrderModel> orders)async {
    final db = await orderDb;
    try{
      for(var item in orders) {
        final List<Map<String, Object?>>? maps = await db?.query(
            '$orderTable', where: "$orderId = ?", whereArgs: [item.orderId]);
        if (maps == null || maps.length <= 0) {
          await db?.insert(orderTable, item.toMap());
        } else {
          await db?.update('$orderTable', <String, dynamic>{
            "$orderId": "${item.orderId}",
            "$reqCustId": "${item.reqCustId}",
            "$reqCustName": "${item.reqCustName}",
            "$reqDeptId": "${item.reqDeptId}",
            "$reqDeptName": "${item.reqDeptName}",
            "$reqStaff": "${item.reqStaff}",
            "$reqTel": "${item.reqTel}",
            "$reqAddr": "${item.reqAddr}",
            "$reqAddrDetail": "${item.reqAddrDetail}",
            "$custId": "${item.custId}",
            "$custName": "${item.custName}",
            "$deptId": "${item.deptId}",
            "$deptName": "${item.deptName}",
            "$inOutSctn": "${item.inOutSctn}",
            "$inOutSctnName": "${item.inOutSctnName}",
            "$truckTypeCode": "${item.truckTypeCode}",
            "$truckTypeName": "${item.truckTypeName}",
            "$sComName": "${item.sComName}",
            "$sSido": "${item.sSido}",
            "$sGungu": "${item.sGungu}",
            "$sDong": "${item.sDong}",
            "$sAddr": "${item.sAddr}",
            "$sAddrDetail": "${item.sAddrDetail}",
            "$sDate": "${item.sDate}",
            "$sStaff": "${item.sStaff}",
            "$sTel": "${item.sTel}",
            "$sMemo": "${item.sMemo}",
            "$eComName": "${item.eComName}",
            "$eSido": "${item.eSido}",
            "$eGungu": "${item.eGungu}",
            "$eDong": "${item.eDong}",
            "$eAddr": "${item.eAddr}",
            "$eAddrDetail": "${item.eAddrDetail}",
            "$eDate": "${item.eDate}",
            "$eStaff": "${item.eStaff}",
            "$eTel": "${item.eTel}",
            "$eMemo": "${item.eMemo}",
            "$sLat": "${item.sLat}",
            "$sLon": "${item.sLon}",
            "$eLat": "${item.eLat}",
            "$eLon": "${item.eLon}",
            "$goodsName": "${item.goodsName}",
            "$goodsWeight": "${item.goodsWeight}",
            "$weightUnitCode": "${item.weightUnitCode}",
            "$weightUnitName": "${item.weightUnitName}",
            "$goodsQty": "${item.goodsQty}",
            "$qtyUnitCode": "${item.qtyUnitCode}",
            "$qtyUnitName": "${item.qtyUnitName}",
            "$sWayCode": "${item.sWayCode}",
            "$sWayName": "${item.sWayName}",
            "$eWayCode": "${item.eWayCode}",
            "$eWayName": "${item.eWayName}",
            "$mixYn": "${item.mixYn}",
            "$mixSize": "${item.mixSize}",
            "$returnYn": "${item.returnYn}",
            "$carTonCode": "${item.carTonCode}",
            "$carTonName": "${item.carTonName}",
            "$carTypeCode": "${item.carTypeCode}",
            "$carTypeName": "${item.carTypeName}",
            "$chargeType": "${item.chargeType}",
            "$chargeTypeName": "${item.chargeTypeName}",
            "$distance": "${item.distance}",
            "$time": "${item.time}",
            "$reqMemo": "${item.reqMemo}",
            "$driverMemo": "${item.driverMemo}",
            "$itemCode": "${item.itemCode}",
            "$itemName": "${item.itemName}",
            "$orderState": "${item.orderState}",
            "$orderStateName": "${item.orderStateName}",
            "$regid": "${item.regid}",
            "$regdate": "${item.regdate}",
            "$stopCount": "${item.stopCount}",
            "$sellAllocId": "${item.sellAllocId}",
            "$sellCustId": "${item.sellCustId}",
            "$sellDeptId": "${item.sellDeptId}",
            "$sellStaff": "${item.sellStaff}",
            "$sellStaffName": "${item.sellStaffName}",
            "$sellStaffTel": "${item.sellStaffTel}",
            "$sellCustName": "${item.sellCustName}",
            "$sellDeptName": "${item.sellDeptName}",
            "$sellCharge": "${item.sellCharge}",
            "$sellFee": "${item.sellFee}",
            "$sellWeight": "${item.sellWeight}",
            "$sellWayPointMemo": "${item.sellWayPointMemo}",
            "$sellWayPointCharge": "${item.sellWayPointCharge}",
            "$sellStayMemo": "${item.sellStayMemo}",
            "$sellStayCharge": "${item.sellStayCharge}",
            "$sellHandWorkMemo": "${item.sellHandWorkMemo}",
            "$sellHandWorkCharge": "${item.sellHandWorkCharge}",
            "$sellRoundMemo": "${item.sellRoundMemo}",
            "$sellRoundCharge": "${item.sellRoundCharge}",
            "$sellOtherAddMemo": "${item.sellOtherAddMemo}",
            "$sellOtherAddCharge": "${item.sellOtherAddCharge}",
            "$custPayType": "${item.custPayType}",
            "$allocId": "${item.allocId}",
            "$allocState": "${item.allocState}",
            "$allocStateName": "${item.allocStateName}",
            "$buyCustId": "${item.buyCustId}",
            "$buyDeptId": "${item.buyDeptId}",
            "$buyCustName": "${item.buyCustName}",
            "$buyDeptName": "${item.buyDeptName}",
            "$buyStaff": "${item.buyStaff}",
            "$buyStaffName": "${item.buyStaffName}",
            "$buyStaffTel": "${item.buyStaffTel}",
            "$buyCharge": "${item.buyCharge}",
            "$buyFee": "${item.buyFee}",
            "$allocDate": "${item.allocDate}",
            "$driverState": "${item.driverState}",
            "$vehicId": "${item.vehicId}",
            "$driverId": "${item.driverId}",
            "$carNum": "${item.carNum}",
            "$driverName": "${item.driverName}",
            "$driverTel": "${item.driverTel}",
            "$driverStateName": "${item.driverStateName}",
            "$carMngName": "${item.carMngName}",
            "$carMngMemo": "${item.carMngMemo}",
            "$receiptYn": "${item.receiptYn}",
            "$receiptPath": "${item.receiptPath}",
            "$receiptDate": "${item.receiptDate}",
            "$charge": "${item.charge}",
            "$startDate": "${item.startDate}",
            "$finishDate": "${item.finishDate}",
            "$enterDate": "${item.enterDate}",
            "$payDate": "${item.payDate}",
            "$linkCode": "${item.linkCode}",
            "$linkCodeName": "${item.linkCodeName}",
            "$linkType": "${item.linkType}",
            "$buyLinkYn": "${item.buyLinkYn}",
            "$linkName": "${item.linkName}",
            "$wayPointMemo": "${item.wayPointMemo}",
            "$wayPointCharge": "${item.wayPointCharge}",
            "$stayMemo": "${item.stayMemo}",
            "$stayCharge": "${item.stayCharge}",
            "$handWorkMemo": "${item.handWorkMemo}",
            "$handWorkCharge": "${item.handWorkCharge}",
            "$roundMemo": "${item.roundMemo}",
            "$roundCharge": "${item.roundCharge}",
            "$otherAddMemo": "${item.otherAddMemo}",
            "$otherAddCharge": "${item.otherAddCharge}",
            "$unitPrice": "${item.unitPrice}",
            "$unitPriceType": "${item.unitPriceType}",
            "$unitPriceTypeName": "${item.unitPriceTypeName}",
            "$custMngName": "${item.custMngName}",
            "$custMngMemo": "${item.custMngMemo}",
            "$payType": "${item.payType}",
            "$reqPayYN": "${item.reqPayYN}",
            "$reqPayDate": "${item.reqPayDate}",
            "$talkYn": "${item.talkYn}",
            "$orderStopList": "${item.orderStopList.toString()}",
            "$reqStaffName":"${item.reqStaffName}",
            "$call24Cargo": "${item.call24Cargo}",
            "$manCargo": "${item.manCargo}",
            "$oneCargo": "${item.oneCargo}",
            "$call24Charge": "${item.call24Charge}",
            "$manCharge": "${item.manCharge}",
            "$oneCharge": "${item.oneCharge}"
          }, where: "$orderId = ?", whereArgs: [item.orderId]);
        }
      }
    }catch(e){
      print("insertAll() Exepction => $e ");
      openOkBox(context,"insertAll() Exepction => $e ",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    }
  }

  Future<List<OrderModel>> getOrderList(BuildContext context) async {
    final db = await orderDb;
    List<OrderModel> orderList = List.empty(growable: true);
    try {
      List<Map<String, Object?>>? result = await db?.rawQuery(
          "SELECT * FROM $orderTable");
      print("하아아앙=>$result // ${result?.length}");
      if (result != null && result.length > 0) {
        List<OrderModel> itemsList = result.map((i) => OrderModel.fromJSON(i)).toList();
        orderList.addAll(itemsList);
      }
    }catch(e) {
      print("getOrderList() Exepction => $e ");
      openOkBox(context,"getOrderList() Exepction => $e ",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    }
    return orderList;
  }

}