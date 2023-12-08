import 'dart:core';

import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_tms_flutter/common/model/result_model.dart';
import 'package:logislink_tms_flutter/common/model/stop_point_model.dart';

class OrderModel extends ResultModel {
  String? orderId;                //오더 ID
  String? reqCustId;            //화주 거래처 ID
  String? reqCustName;            //화주 거래처명
  String? reqDeptId;            //화주 부서 ID
  String? reqDeptName;            //화주 부서명
  String? reqStaff;            //화주 담당자
  String? reqTel;                //화주 연락처
  String? reqAddr;                //화주 주소
  String? reqAddrDetail;        //화주 상세주소
  String? custId;                //화주 지정 운송,주선사 ID
  String? custName;
  String? deptId;                //화주 지정 운송,주선사 부서 Id
  String? deptName;
  String? inOutSctn;            //수출입구분(내수, 수출입)
  String? inOutSctnName;
  String? truckTypeCode;        //운송유형
  String? truckTypeName;
  String? sComName;            //상차지명
  String? sSido;                //상차지시도
  String? sGungu;                //상차지군구
  String? sDong;                //상차지동
  String? sAddr;                //상차지주소
  String? sAddrDetail;            //상차지상세주소
  String? sDate;                //상차일 (YYYY-MM-DD HH:mm:ss)
  String? sStaff;                //상차지담당자
  String? sTel;                //상차지 연락처
  String? sMemo;                //상차지메모
  String? eComName;            //하차지명
  String? eSido;                //하차지시도
  String? eGungu;                //하차지군구
  String? eDong;                //하차지 동
  String? eAddr;                //하차지 주소
  String? eAddrDetail;            //하차지 상세주소
  String? eDate;                //하차일 (YYYY-MM-DD HH:mm:ss)
  String? eStaff;                //하차지 담당자
  String? eTel;                //하차지 연락처
  String? eMemo;                //하차지 메모
  double? sLat;
  double? sLon;
  double? eLat;
  double? eLon;
  String? goodsName;            //화물정보
  String? goodsWeight;            //화물중량
  String? weightUnitCode;        //중량단위코드
  String? weightUnitName;        //중량단위이름
  String? goodsQty;            //화물수량
  String? qtyUnitCode;            //수량단위코드
  String? qtyUnitName;            //수량단위이름
  String? sWayCode;            //상차방법
  String? sWayName;            //상차방법
  String? eWayCode;            //하차방법
  String? eWayName;            //하차방법
  String? mixYn;                //혼적여부
  String? mixSize;                //혼적크기
  String? returnYn;            //왕복여부
  String? carTonCode;
  String? carTonName;
  String? carTypeCode;
  String? carTypeName;
  String? chargeType;            //운임구분코드(인수증.선착불)
  String? chargeTypeName;
  double? distance;
  int? time;
  String? reqMemo;                //화주 요청사항 (주선사/운송사 확인)
  String? driverMemo;            //차주 확인사항
  String? itemCode;            //운송품목코드
  String? itemName;            //운송품목코드
  String? orderState;
  String? orderStateName;
  String? regid;                   //등록 id
  String? regdate;                 //오더 등록일
  int? stopCount;                  //경유지

  /* 매출 정보  */
  String? sellAllocId;             //매출 배차 ID
  String? sellCustId;              //매출 거래처 ID
  String? sellDeptId;              //매출 부서 ID
  String? sellStaff;               //매출거래처 담당자
  String? sellStaffName;           //매출거래처 담당자
  String? sellStaffTel;            //매출거래처 담당자 연락처
  String? sellCustName;
  String? sellDeptName;
  String? sellCharge;              //매출운송비
  String? sellFee;                 //매출수수료
  String? sellWeight;              //매출중량
  String? sellWayPointMemo;        //경유비 메모
  String? sellWayPointCharge;      //경유비 금액
  String? sellStayMemo;            //대기료 메모
  String? sellStayCharge;          //대기료 금액
  String? sellHandWorkMemo;        //수작업비 메모
  String? sellHandWorkCharge;      //수작업비 금액
  String? sellRoundMemo;           //회차료 메모
  String? sellRoundCharge;         //회차료 금액
  String? sellOtherAddMemo;        //기타추가비 메모
  String? sellOtherAddCharge;      //기타추가비 금액
  String? custPayType;             //거래처 빠른지급여부

  /* 매입 정보 */
  String? allocId;                //매입 배차 ID
  String? allocState;            //배차상태
  String? allocStateName;
  String? buyCustId;            //매입 거래처 ID (물량 받는곳)
  String? buyDeptId;            //매입 부서 ID
  String? buyCustName;
  String? buyDeptName;
  String? buyStaff;            //매입거래처담당자 ID
  String? buyStaffName;            //매입거래처담당자 이름
  String? buyStaffTel;            //매입거래처 연락처
  String? buyCharge;                //매입운송비
  String? buyFee;                    //매입수수료
  String? allocDate;            //배차일 (매입 정보 지정일)

  /* 배차 차주 정보*/
  String? driverState;            //차주 배차 상태
  String? vehicId;                //차량 id
  String? driverId;            //차주 id
  String? carNum;                //차량번호
  String? driverName;            //차주명
  String? driverTel;        //차주연락처
  String? driverStateName;
  String? carMngName; //차량관리(정상,블랙리스트)
  String? carMngMemo; //차량관리메모

  String? receiptYn;            //인수증접수여부
  String? receiptPath;            //인수증 경로
  String? receiptDate;            //인수증접수일

  String? charge;              // 구간별계약단가

  String? startDate;           // 출발일
  String? finishDate;          // 도착일
  String? enterDate;           // 입차일

  String? payDate;             // 결제일

  String? linkCode;            // 정보망코드
  String? linkCodeName;        // 정보망코드이름

  String? linkType;            // 정보망코드
  String? buyLinkYn;           //정보망 배차 여부
  String? linkName;            //배차된 정보망 이름

  String? wayPointMemo;      //경유비 메모
  String? wayPointCharge;   //경유비 금액
  String? stayMemo;         //대기료 메모
  String? stayCharge;      //대기료 금액
  String? handWorkMemo;      //수작업비 메모
  String? handWorkCharge;   //수작업비 금액
  String? roundMemo;      //회차료 메모
  String? roundCharge;      //회차료 금액
  String? otherAddMemo;      //기타추가비 메모
  String? otherAddCharge;   //기타추가비 금액

  String? unitPrice;
  String? unitPriceType;
  String? unitPriceTypeName;

  String? custMngName;
  String? custMngMemo;

  String? payType;
  String? reqPayYN;
  String? reqPayDate;
  String? talkYn;
  List<StopPointModel>? orderStopList; // 경유지 목록
  String? reqStaffName;

  String? call24Cargo;
  String? manCargo;
  String? oneCargo;
  String? call24Charge;
  String? manCharge;
  String? oneCharge;

  OrderModel({
    this.orderId,                //오더 ID
    this.reqCustId,            //화주 거래처 ID
    this.reqCustName,            //화주 거래처명
    this.reqDeptId,            //화주 부서 ID
    this.reqDeptName,            //화주 부서명
    this.reqStaff,            //화주 담당자
    this.reqTel,                //화주 연락처
    this.reqAddr,                //화주 주소
    this.reqAddrDetail,        //화주 상세주소
    this.custId,                //화주 지정 운송,주선사 ID
    this.custName,
    this.deptId,                //화주 지정 운송,주선사 부서 Id
    this.deptName,
    this.inOutSctn,            //수출입구분(내수, 수출입)
    this.inOutSctnName,
    this.truckTypeCode,        //운송유형
    this.truckTypeName,
    this.sComName,            //상차지명
    this.sSido,                //상차지시도
    this.sGungu,                //상차지군구
    this.sDong,                //상차지동
    this.sAddr,                //상차지주소
    this.sAddrDetail,            //상차지상세주소
    this.sDate,                //상차일 (YYYY-MM-DD HH:mm:ss)
    this.sStaff,                //상차지담당자
    this.sTel,                //상차지 연락처
    this.sMemo,                //상차지메모
    this.eComName,            //하차지명
    this.eSido,                //하차지시도
    this.eGungu,                //하차지군구
    this.eDong,                //하차지 동
    this.eAddr,                //하차지 주소
    this.eAddrDetail,            //하차지 상세주소
    this.eDate,                //하차일 (YYYY-MM-DD HH:mm:ss)
    this.eStaff,                //하차지 담당자
    this.eTel,                //하차지 연락처
    this.eMemo,                //하차지 메모
    this.sLat,
    this.sLon,
    this.eLat,
    this.eLon,
    this.goodsName,            //화물정보
    this.goodsWeight,            //화물중량
    this.weightUnitCode,        //중량단위코드
    this.weightUnitName,        //중량단위이름
    this.goodsQty,            //화물수량
    this.qtyUnitCode,            //수량단위코드
    this.qtyUnitName,            //수량단위이름
    this.sWayCode,            //상차방법
    this.sWayName,            //상차방법
    this.eWayCode,            //하차방법
    this.eWayName,            //하차방법
    this.mixYn,                //혼적여부
    this.mixSize,                //혼적크기
    this.returnYn,            //왕복여부
    this.carTonCode,
    this.carTonName,
    this.carTypeCode,
    this.carTypeName,
    this.chargeType,            //운임구분코드(인수증.선착불)
    this.chargeTypeName,
    this.distance,
    this.time,
    this.reqMemo,                //화주 요청사항 (주선사/운송사 확인)
    this.driverMemo,            //차주 확인사항
    this.itemCode,            //운송품목코드
    this.itemName,            //운송품목코드
    this.orderState,
    this.orderStateName,
    this.regid,                   //등록 id
    this.regdate,                 //오더 등록일
    this.stopCount,                  //경유지
    this.sellAllocId,             //매출 배차 ID
    this.sellCustId,              //매출 거래처 ID
    this.sellDeptId,              //매출 부서 ID
    this.sellStaff,               //매출거래처 담당자
    this.sellStaffName,           //매출거래처 담당자
    this.sellStaffTel,            //매출거래처 담당자 연락처
    this.sellCustName,
    this.sellDeptName,
    this.sellCharge,              //매출운송비
    this.sellFee,                 //매출수수료
    this.sellWeight,              //매출중량
    this.sellWayPointMemo,        //경유비 메모
    this.sellWayPointCharge,      //경유비 금액
    this.sellStayMemo,            //대기료 메모
    this.sellStayCharge,          //대기료 금액
    this.sellHandWorkMemo,        //수작업비 메모
    this.sellHandWorkCharge,      //수작업비 금액
    this.sellRoundMemo,           //회차료 메모
    this.sellRoundCharge,         //회차료 금액
    this.sellOtherAddMemo,        //기타추가비 메모
    this.sellOtherAddCharge,      //기타추가비 금액
    this.custPayType,             //거래처 빠른지급여부
    this.allocId,                //매입 배차 ID
    this.allocState,            //배차상태
    this.allocStateName,
    this.buyCustId,            //매입 거래처 ID (물량 받는곳)
    this.buyDeptId,            //매입 부서 ID
    this.buyCustName,
    this.buyDeptName,
    this.buyStaff,            //매입거래처담당자 ID
    this.buyStaffName,            //매입거래처담당자 이름
    this.buyStaffTel,            //매입거래처 연락처
    this.buyCharge,                //매입운송비
    this.buyFee,                    //매입수수료
    this.allocDate,            //배차일 (매입 정보 지정일)
    this.driverState,            //차주 배차 상태
    this.vehicId,                //차량 id
    this.driverId,            //차주 id
    this.carNum,                //차량번호
    this.driverName,            //차주명
    this.driverTel,        //차주연락처
    this.driverStateName,
    this.carMngName, //차량관리(정상,블랙리스트)
    this.carMngMemo, //차량관리메모

    this.receiptYn,            //인수증접수여부
    this.receiptPath,            //인수증 경로
    this.receiptDate,            //인수증접수일

    this.charge,              // 구간별계약단가

    this.startDate,           // 출발일
    this.finishDate,          // 도착일
    this.enterDate,           // 입차일

    this.payDate,             // 결제일

    this.linkCode,            // 정보망코드
    this.linkCodeName,        // 정보망코드이름

    this.linkType,            // 정보망코드
    this.buyLinkYn,           //정보망 배차 여부
    this.linkName,            //배차된 정보망 이름
    this.wayPointMemo,      //경유비 메모
    this.wayPointCharge,   //경유비 금액
    this.stayMemo,         //대기료 메모
    this.stayCharge,      //대기료 금액
    this.handWorkMemo,      //수작업비 메모
    this.handWorkCharge,   //수작업비 금액
    this.roundMemo,      //회차료 메모
    this.roundCharge,      //회차료 금액
    this.otherAddMemo,      //기타추가비 메모
    this.otherAddCharge,   //기타추가비 금액
    this.unitPrice,
    this.unitPriceType,
    this.unitPriceTypeName,
    this.custMngName,
    this.custMngMemo,
    this.payType,
    this.reqPayYN,
    this.reqPayDate,
    this.talkYn,
    this.orderStopList, // 경유지 목록
    this.reqStaffName,

    this.call24Cargo,
    this.manCargo,
    this.oneCargo,
    this.call24Charge,
    this.manCharge,
    this.oneCharge
  });

  factory OrderModel.fromJSON(Map<String,dynamic> json) {
    OrderModel order = OrderModel(
        orderId: json['orderId'],
        //오더 ID
        reqCustId: json['reqCustId'],
        //화주 거래처 ID
        reqCustName: json['reqCustName'],
        //화주 거래처명
        reqDeptId: json['reqDeptId'],
        //화주 부서 ID
        reqDeptName: json['reqDeptName'],
        //화주 부서명
        reqStaff: json['reqStaff'],
        //화주 담당자
        reqTel: json['reqTel'],
        //화주 연락처
        reqAddr: json['reqAddr'],
        //화주 주소
        reqAddrDetail: json['reqAddrDetail'],
        //화주 상세주소
        custId: json['custId'],
        //화주 지정 운송,주선사 ID
        custName: json['custName'],
        deptId: json['deptId'],
        //화주 지정 운송,주선사 부서 Id
        deptName: json['deptName'],
        inOutSctn: json['inOutSctn'],
        //수출입구분(내수, 수출입)
        inOutSctnName: json['inOutSctnName'],
        truckTypeCode: json['truckTypeCode'],
        //운송유형
        truckTypeName: json['truckTypeName'],
        sComName: json['sComName'],
        //상차지명
        sSido: json['sSido'],
        //상차지시도
        sGungu: json['sGungu'],
        //상차지군구
        sDong: json['sDong'],
        //상차지동
        sAddr: json['sAddr'],
        //상차지주소
        sAddrDetail: json['sAddrDetail'],
        //상차지상세주소
        sDate: json['sDate'],
        //상차일 (YYYY-MM-DD HH:mm:ss)
        sStaff: json['sStaff'],
        //상차지담당자
        sTel: json['sTel'],
        //상차지 연락처
        sMemo: json['sMemo'],
        //상차지메모
        eComName: json['eComName'],
        //하차지명
        eSido: json['eSido'],
        //하차지시도
        eGungu: json['eGungu'],
        //하차지군구
        eDong: json['eDong'],
        //하차지 동
        eAddr: json['eAddr'],
        //하차지 주소
        eAddrDetail: json['eAddrDetail'],
        //하차지 상세주소
        eDate: json['eDate'],
        //하차일 (YYYY-MM-DD HH:mm:ss)
        eStaff: json['eStaff'],
        //하차지 담당자
        eTel: json['eTel'],
        //하차지 연락처
        eMemo: json['eMemo'],
        //하차지 메모
        sLat: double.parse((json['sLat'] ?? 0.0).toString()),
        sLon: double.parse((json['sLon'] ?? 0.0).toString()),
        eLat: double.parse((json['eLat'] ?? 0.0).toString()),
        eLon: double.parse((json['eLon'] ?? 0.0).toString()),
        goodsName: json['goodsName'],
        //화물정보
        goodsWeight: json['goodsWeight'].toString(),
        //화물중량
        weightUnitCode: json['weightUnitCode'],
        //중량단위코드
        weightUnitName: json['weightUnitName'],
        //중량단위이름
        goodsQty: json['goodsQty'],
        //화물수량
        qtyUnitCode: json['qtyUnitCode'],
        //수량단위코드
        qtyUnitName: json['qtyUnitName'],
        //수량단위이름
        sWayCode: json['sWayCode'],
        //상차방법
        sWayName: json['sWayName'],
        //상차방법
        eWayCode: json['eWayCode'],
        //하차방법
        eWayName: json['eWayName'],
        //하차방법
        mixYn: json['mixYn'],
        //혼적여부
        mixSize: json['mixSize'],
        //혼적크기
        returnYn: json['returnYn'],
        //왕복여부
        carTonCode: json['carTonCode'],
        carTonName: json['carTonName'],
        carTypeCode: json['carTypeCode'],
        carTypeName: json['carTypeName'],
        chargeType: json['chargeType'],
        //운임구분코드(인수증.선착불)
        chargeTypeName: json['chargeTypeName'],
        distance: double.parse((json['distance'] ?? 0.0).toString()),
        time: json['time'],
        reqMemo: json['reqMemo'],
        //화주 요청사항 (주선사/운송사 확인)
        driverMemo: json['driverMemo'],
        //차주 확인사항
        itemCode: json['itemCode'].toString(),
        //운송품목코드
        itemName: json['itemName'],
        //운송품목코드
        orderState: json['orderState'],
        orderStateName: json['orderStateName'],
        regid: json['regid'],
        //등록 id
        regdate: json['regdate'],
        //오더 등록일
        stopCount: json['stopCount'],
        //경유지

        /* 매출 정보  */
        sellAllocId: json['sellAllocId'],
        //매출 배차 ID
        sellCustId: json['sellCustId'],
        //매출 거래처 ID
        sellDeptId: json['sellDeptId'],
        //매출 부서 ID
        sellStaff: json['sellStaff'],
        //매출거래처 담당자
        sellStaffName: json['sellStaffName'],
        //매출거래처 담당자
        sellStaffTel: json['sellStaffTel'],
        //매출거래처 담당자 연락처
        sellCustName: json['sellCustName'],
        sellDeptName: json['sellDeptName'],
        sellCharge: json['sellCharge'].toString(),
        //매출운송비
        sellFee: json['sellFee'].toString(),
        //매출수수료
        sellWeight: json['sellWeight'],
        //매출중량
        sellWayPointMemo: json['sellWayPointMemo'],
        //경유비 메모
        sellWayPointCharge: json['sellWayPointCharge'],
        //경유비 금액
        sellStayMemo: json['sellStayMemo'],
        //대기료 메모
        sellStayCharge: json['sellStayCharge'],
        //대기료 금액
        sellHandWorkMemo: json['sellHandWorkMemo'],
        //수작업비 메모
        sellHandWorkCharge: json['sellHandWorkCharge'],
        //수작업비 금액
        sellRoundMemo: json['sellRoundMemo'],
        //회차료 메모
        sellRoundCharge: json['sellRoundCharge'],
        //회차료 금액
        sellOtherAddMemo: json['sellOtherAddMemo'],
        //기타추가비 메모
        sellOtherAddCharge: json['sellOtherAddCharge'],
        //기타추가비 금액
        custPayType: json['custPayType'],
        //거래처 빠른지급여부

        /* 매입 정보 */
        allocId: json['allocId'],
        //매입 배차 ID
        allocState: json['allocState'].toString(),
        //배차상태
        allocStateName: json['allocStateName'],
        buyCustId: json['buyCustId'],
        //매입 거래처 ID (물량 받는곳)
        buyDeptId: json['buyDeptId'],
        //매입 부서 ID
        buyCustName: json['buyCustName'],
        buyDeptName: json['buyDeptName'],
        buyStaff: json['buyStaff'],
        //매입거래처담당자 ID
        buyStaffName: json['buyStaffName'],
        //매입거래처담당자 이름
        buyStaffTel: json['buyStaffTel'],
        //매입거래처 연락처
        buyCharge: json['buyCharge'].toString(),
        //매입운송비
        buyFee: json['buyFee'].toString(),
        //매입수수료
        allocDate: json['allocDate'],
        //배차일 (매입 정보 지정일)

        /* 배차 차주 정보*/
        driverState: json['driverState'],
        //차주 배차 상태
        vehicId: json['vehicId'],
        //차량 id
        driverId: json['driverId'],
        //차주 id
        carNum: json['carNum'],
        //차량번호
        driverName: json['driverName'],
        //차주명
        driverTel: json['driverTel'],
        //차주연락처
        driverStateName: json['driverStateName'],
        carMngName: json['carMngName'],
        //차량관리(정상,블랙리스트)
        carMngMemo: json['carMngMemo'],
        //차량관리메모

        receiptYn: json['receiptYn'],
        //인수증접수여부
        receiptPath: json['receiptPath'],
        //인수증 경로
        receiptDate: json['receiptDate'],
        //인수증접수일

        charge: json['charge'],
        // 구간별계약단가

        startDate: json['startDate'],
        // 출발일
        finishDate: json['finishDate'],
        // 도착일
        enterDate: json['enterDate'],
        // 입차일

        payDate: json['payDate'],
        // 결제일

        linkCode: json['linkCode'],
        // 정보망코드
        linkCodeName: json['linkCodeName'],
        // 정보망코드이름

        linkType: json['linkType'],
        // 정보망코드
        buyLinkYn: json['buyLinkYn'],
        //정보망 배차 여부
        linkName: json['linkName'],
        //배차된 정보망 이름

        wayPointMemo: json['wayPointMemo'],
        //경유비 메모
        wayPointCharge: json['wayPointCharge'],
        //경유비 금액
        stayMemo: json['stayMemo'],
        //대기료 메모
        stayCharge: json['stayCharge'],
        //대기료 금액
        handWorkMemo: json['handWorkMemo'],
        //수작업비 메모
        handWorkCharge: json['handWorkCharge'],
        //수작업비 금액
        roundMemo: json['roundMemo'],
        //회차료 메모
        roundCharge: json['roundCharge'],
        //회차료 금액
        otherAddMemo: json['otherAddMemo'],
        //기타추가비 메모
        otherAddCharge: json['otherAddCharge'],
        //기타추가비 금액

        unitPrice: json['unitPrice'],
        unitPriceType: json['unitPriceType'],
        unitPriceTypeName: json['unitPriceTypeName'],

        custMngName: json['custMngName'],
        custMngMemo: json['custMngMemo'],

        payType: json['payType'],
        reqPayYN: json['reqPayYN'],
        reqPayDate: json['reqPayDate'],
        talkYn: json['talkYn'],
        reqStaffName:json['reqStaffName'],

        call24Cargo: json['call24Cargo'],
        manCargo: json['manCargo'],
        oneCargo: json['oneCargo'],
        call24Charge: json['call24Charge'],
        manCharge: json['manCharge'],
        oneCharge: json['oneCharge']
    );
    var list = json['orderStopList'] ?? List.empty(growable: true); // 경유지 목록
    if(list.length > 0) {
      List<StopPointModel> itemsList = list.map((i) => StopPointModel.fromJSON(i)).toList();
      order.orderStopList = itemsList;
    }else{
      order.orderStopList = List.empty(growable: true);
    }
    return order;
  }

  Map<String,dynamic> toMap() {
    return <String,dynamic>{
      "orderId": orderId,
      "reqCustId": reqCustId,
      "reqCustName": reqCustName,
      "reqDeptId": reqDeptId,
      "reqDeptName": reqDeptName,
      "reqStaff": reqStaff,
      "reqTel": reqTel,
      "reqAddr": reqAddr,
      "reqAddrDetail": reqAddrDetail,
      "custId": custId,
      "custName": custName,
      "deptId": deptId,
      "deptName": deptName,
      "inOutSctn": inOutSctn,
      "inOutSctnName": inOutSctnName,
      "truckTypeCode": truckTypeCode,
      "truckTypeName": truckTypeName,
      "sComName": sComName,
      "sSido": sSido,
      "sGungu": sGungu,
      "sDong": sDong,
      "sAddr": sAddr,
      "sAddrDetail": sAddrDetail,
      "sDate": sDate,
      "sStaff": sStaff,
      "sTel": sTel,
      "sMemo": sMemo,
      "eComName": eComName,
      "eSido": eSido,
      "eGungu": eGungu,
      "eDong": eDong,
      "eAddr": eAddr,
      "eAddrDetail": eAddrDetail,
      "eDate": eDate,
      "eStaff": eStaff,
      "eTel": eTel,
      "eMemo": eMemo,
      "sLat": sLat,
      "sLon": sLon,
      "eLat": eLat,
      "eLon": eLon,
      "goodsName": goodsName,
      "goodsWeight": goodsWeight,
      "weightUnitCode": weightUnitCode,
      "weightUnitName": weightUnitName,
      "goodsQty": goodsQty,
      "qtyUnitCode": qtyUnitCode,
      "qtyUnitName": qtyUnitName,
      "sWayCode": sWayCode,
      "sWayName": sWayName,
      "eWayCode": eWayCode,
      "eWayName": eWayName,
      "mixYn": mixYn,
      "mixSize": mixSize,
      "returnYn": returnYn,
      "carTonCode": carTonCode,
      "carTonName": carTonName,
      "carTypeCode": carTypeCode,
      "carTypeName": carTypeName,
      "chargeType": chargeType,
      "chargeTypeName": chargeTypeName,
      "distance": distance,
      "time": time,
      "reqMemo": reqMemo,
      "driverMemo": driverMemo,
      "itemCode": itemCode,
      "itemName": itemName,
      "orderState": orderState,
      "orderStateName": orderStateName,
      "regid": regid,
      "regdate": regdate,
      "stopCount": stopCount,
      "sellAllocId": sellAllocId,
      "sellCustId": sellCustId,
      "sellDeptId": sellDeptId,
      "sellStaff": sellStaff,
      "sellStaffName": sellStaffName,
      "sellStaffTel": sellStaffTel,
      "sellCustName": sellCustName,
      "sellDeptName": sellDeptName,
      "sellCharge": sellCharge,
      "sellFee": sellFee,
      "sellWeight": sellWeight,
      "sellWayPointMemo": sellWayPointMemo,
      "sellWayPointCharge": sellWayPointCharge,
      "sellStayMemo": sellStayMemo,
      "sellStayCharge": sellStayCharge,
      "sellHandWorkMemo": sellHandWorkMemo,
      "sellHandWorkCharge": sellHandWorkCharge,
      "sellRoundMemo": sellRoundMemo,
      "sellRoundCharge": sellRoundCharge,
      "sellOtherAddMemo": sellOtherAddMemo,
      "sellOtherAddCharge": sellOtherAddCharge,
      "custPayType": custPayType,
      "allocId": allocId,
      "allocState": allocState,
      "allocStateName": allocStateName,
      "buyCustId": buyCustId,
      "buyDeptId": buyDeptId,
      "buyCustName": buyCustName,
      "buyDeptName": buyDeptName,
      "buyStaff": buyStaff,
      "buyStaffName": buyStaffName,
      "buyStaffTel": buyStaffTel,
      "buyCharge": buyCharge,
      "buyFee": buyFee,
      "allocDate": allocDate,
      "driverState": driverState,
      "vehicId": vehicId,
      "driverId": driverId,
      "carNum": carNum,
      "driverName": driverName,
      "driverTel": driverTel,
      "driverStateName": driverStateName,
      "carMngName": carMngName,
      "carMngMemo": carMngMemo,
      "receiptYn": receiptYn,
      "receiptPath": receiptPath,
      "receiptDate": receiptDate,
      "charge": charge,
      "startDate": startDate,
      "finishDate": finishDate,
      "enterDate": enterDate,
      "payDate": payDate,
      "linkCode": linkCode,
      "linkCodeName": linkCodeName,
      "linkType": linkType,
      "buyLinkYn": buyLinkYn,
      "linkName": linkName,
      "wayPointMemo": wayPointMemo,
      "wayPointCharge": wayPointCharge,
      "stayMemo": stayMemo,
      "stayCharge": stayCharge,
      "handWorkMemo": handWorkMemo,
      "handWorkCharge": handWorkCharge,
      "roundMemo": roundMemo,
      "roundCharge": roundCharge,
      "otherAddMemo": otherAddMemo,
      "otherAddCharge": otherAddCharge,
      "unitPrice": unitPrice,
      "unitPriceType": unitPriceType,
      "unitPriceTypeName": unitPriceTypeName,
      "custMngName": custMngName,
      "custMngMemo": custMngMemo,
      "payType": payType,
      "reqPayYN": reqPayYN,
      "reqPayDate": reqPayDate,
      "talkYn": talkYn,
      "orderStopList": orderStopList,
      "reqStaffName":reqStaffName,
      "call24Cargo": call24Cargo,
      "manCargo": manCargo,
      "oneCargo": oneCargo,
      "call24Charge": call24Charge,
      "manCharge": manCharge,
      "oneCharge": oneCharge
    };
  }
}