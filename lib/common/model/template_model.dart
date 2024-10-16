import 'dart:convert';
import 'dart:core';

import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/template_stop_point_model.dart';

class TemplateModel extends ReturnMap {
  String? templateId;           // 탬플릿ID
  String? templateTitle;        //탬플릿 제목
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
  String? eAddrDetail;            //하차지
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
  String? regid;                   //등록 id
  String? regdate;                 //오더 등록일
  int? stopCount;                  //경유지

  /* 매출 정보  */
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
  String? buyCharge;                //매입운송비
  String? buyFee;                    //매입수수료

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
  List<TemplateStopPointModel>? templateStopList; // 경유지 목록
  String? reqStaffName;

  String? call24Cargo;
  String? manCargo;
  String? oneCargo;
  String? call24Charge;
  String? manCharge;
  String? oneCharge;

  String? useYn;

  TemplateModel({
    this.templateTitle,        //탬플릿 제목
    this.templateId,           //탬플릿ID
    this.reqCustId,            //화주 거래처 ID
    this.reqCustName,          //화주 거래처명
    this.reqDeptId,            //화주 부서 ID
    this.reqDeptName,          //화주 부서명
    this.reqStaff,             //화주 담당자
    this.reqTel,               //화주 연락처
    this.reqAddr,              //화주 주소
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
    this.stopCount,                  //경유지

    this.sellCustId, 			//매출 거래처 ID
    this.sellDeptId,  			//매출 부서 ID
    this.sellStaff, 			//매출거래처 담당자
    this.sellStaffName,  		//매출거래처 담당자
    this.sellStaffTel,  		//매출거래처 담당자 연락처
    this.sellCustName,
    this.sellDeptName,
    this.sellCharge, 			//매출운송비
    this.sellFee, 				//매출수수료
    this.sellWeight, 			//매출중량
    this.sellWayPointMemo, 		//경유비 메모
    this.sellWayPointCharge, 	//경유비 금액
    this.sellStayMemo, 			//대기료 메모
    this.sellStayCharge, 		//대기료 금액
    this.sellHandWorkMemo, 		//수작업비 메모
    this.sellHandWorkCharge, 	//수작업비 금액
    this.sellRoundMemo, 		//회차료 메모
    this.sellRoundCharge, 		//회차료 금액
    this.sellOtherAddMemo, 		//기타추가비 메모
    this.sellOtherAddCharge, 	//기타추가비 금액
    this.custPayType, 			//거래처 빠른지급여부

    this.buyCharge,                //매입운송비
    this.buyFee,                    //매입수수료

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
    this.templateStopList, // 경유지 목록
    this.reqStaffName,

    this.call24Cargo,
    this.manCargo,
    this.oneCargo,
    this.call24Charge,
    this.manCharge,
    this.oneCharge,

    this.useYn
  });

  factory TemplateModel.fromJSON(Map<String,dynamic> json) {
    TemplateModel order = TemplateModel(
        templateTitle: json['templateTitle'],
        //오더 ID
        templateId: json['templateId'],
        //탬플릿 ID
        reqCustId: json['reqCustId'],
        //화주 거래처 ID
        reqCustName: json['reqCustName']??"",
        //화주 거래처명
        reqDeptId: json['reqDeptId']??"",
        //화주 부서 ID
        reqDeptName: json['reqDeptName']??"",
        //화주 부서명
        reqStaff: json['reqStaff']??"",
        //화주 담당자
        reqTel: json['reqTel']??"",
        //화주 연락처
        reqAddr: json['reqAddr']??"",
        //화주 주소
        reqAddrDetail: json['reqAddrDetail']??"",
        //화주 상세주소
        custId: json['custId']??"",
        //화주 지정 운송,주선사 ID
        custName: json['custName']??"",
        deptId: json['deptId']??"",
        //화주 지정 운송,주선사 부서 Id
        deptName: json['deptName']??"",
        inOutSctn: json['inOutSctn']??"",
        //수출입구분(내수, 수출입)
        inOutSctnName: json['inOutSctnName']??"",
        truckTypeCode: json['truckTypeCode']??"",
        //운송유형
        truckTypeName: json['truckTypeName']??"",
        sComName: json['sComName']??"",
        //상차지명
        sSido: json['sSido']??"",
        //상차지시도
        sGungu: json['sGungu']??"",
        //상차지군구
        sDong: json['sDong']??"",
        //상차지동
        sAddr: json['sAddr']??"",
        //상차지주소
        sAddrDetail: json['sAddrDetail']??"",
        //상차지상세주소
        sDate: json['sDate']??"",
        //상차일
        sStaff: json['sStaff']??"",
        //상차지담당자
        sTel: json['sTel']??"",
        //상차지 연락처
        sMemo: json['sMemo']??"",
        //상차지메모
        eComName: json['eComName']??"",
        //하차지명
        eSido: json['eSido']??"",
        //하차지시도
        eGungu: json['eGungu']??"",
        //하차지군구
        eDong: json['eDong']??"",
        //하차지 동
        eAddr: json['eAddr']??"",
        //하차지 주소
        eAddrDetail: json['eAddrDetail']??"",
        //하차지 상세주소
        eDate: json['eDate']??"",
        //하차일
        eStaff: json['eStaff']??"",
        //하차지 담당자
        eTel: json['eTel']??"",
        //하차지 연락처
        eMemo: json['eMemo']??"",
        //하차지 메모
        sLat: double.parse((json['sLat'] ?? 0.0).toString()),
        sLon: double.parse((json['sLon'] ?? 0.0).toString()),
        eLat: double.parse((json['eLat'] ?? 0.0).toString()),
        eLon: double.parse((json['eLon'] ?? 0.0).toString()),
        goodsName: json['goodsName']??"",
        //화물정보
        goodsWeight: (json['goodsWeight']??0.0).toString(),
        //화물중량
        weightUnitCode: json['weightUnitCode']??"",
        //중량단위코드
        weightUnitName: json['weightUnitName']??"",
        //중량단위이름
        goodsQty: (json['goodsQty']??0).toString(),
        //화물수량
        qtyUnitCode: json['qtyUnitCode']??"",
        //수량단위코드
        qtyUnitName: json['qtyUnitName']??"",
        //수량단위이름
        sWayCode: json['sWayCode']??"",
        //상차방법
        sWayName: json['sWayName']??"",
        //상차방법
        eWayCode: json['eWayCode']??"",
        //하차방법
        eWayName: json['eWayName']??"",
        //하차방법
        mixYn: json['mixYn']??"",
        //혼적여부
        mixSize: json['mixSize']??"",
        //혼적크기
        returnYn: json['returnYn']??"",
        //왕복여부
        carTonCode: json['carTonCode']??"",
        carTonName: json['carTonName']??"",
        carTypeCode: json['carTypeCode']??"",
        carTypeName: json['carTypeName']??"",
        chargeType: json['chargeType']??"",
        //운임구분코드(인수증.선착불)
        chargeTypeName: json['chargeTypeName']??"",
        distance: json['distance']??0.0,
        time: json['time'],
        reqMemo: json['reqMemo']??"",
        //화주 요청사항 (주선사/운송사 확인)
        driverMemo: json['driverMemo']??"",
        //차주 확인사항
        itemCode: json['itemCode']??"",
        //운송품목코드
        itemName: json['itemName']??"",
        //오더 등록일
        stopCount: json['stopCount']??"",
        //경유지

        sellCustId : json['sellCustId']??"",
        //매출거래처ID
        sellDeptId : json['sellDeptId']??"",
        //매출 부서 ID
        sellStaff : json['sellStaff']??"",
        //매출거래처 담당자
        sellStaffName : json['sellStaffName']??"",
        //매출거래처 담당자
        sellStaffTel : json['sellStaffTel']??"",
        //매출거래처 담당자 연락처
        sellCustName : json['sellCustName']??"",
        //매출거래처이름
        sellDeptName : json['sellDeptName']??"",
        //매출거래처 부서명
        sellCharge : (json['sellCharge']??0).toString(),
        //매출운송비
        sellFee : (json['sellFee']??0).toString(),
        //매출수수료
        sellWeight : (json['sellWeight']??0).toString(),
        //매출중량
        sellWayPointMemo : json['sellWayPointMemo']??"",
        //경유비 메모
        sellWayPointCharge : (json['sellWayPointCharge']??0).toString(),
        //경유비 금액
        sellStayMemo : json['sellStayMemo']??"",
        //대기료 메모
        sellStayCharge : (json['sellStayCharge']??0).toString(),
        //대기료 금액
        sellHandWorkMemo : json['sellHandWorkMemo']??"",
        //수작업비 메모
        sellHandWorkCharge : (json['sellHandWorkCharge']??0).toString(),
        //수작업비 금액
        sellRoundMemo : json['sellRoundMemo']??"",
        //회차료 메모
        sellRoundCharge : (json['sellRoundCharge']??0).toString(),
        //회차료 금액
        sellOtherAddMemo : json['sellOtherAddMemo']??"",
        //기타추가비 메모
        sellOtherAddCharge : (json['sellOtherAddCharge']??0).toString(),
        //기타추가비 금액
        custPayType : json['custPayType']??"",
        //거래처 빠른지급여부
        buyCharge : (json['buyCharge']??0).toString(),
        //매입운송비
        buyFee : (json['buyFee']??0).toString(),
        //매입수수료

        wayPointMemo: json['wayPointMemo']??"",
        //경유비 메모
        wayPointCharge: (json['wayPointCharge']??0).toString(),
        //경유비 금액
        stayMemo: json['stayMemo']??"",
        //대기료 메모
        stayCharge: (json['stayCharge']??0).toString(),
        //대기료 금액
        handWorkMemo: json['handWorkMemo']??"",
        //수작업비 메모
        handWorkCharge: (json['handWorkCharge']??0).toString(),
        //수작업비 금액
        roundMemo: json['roundMemo']??"",
        //회차료 메모
        roundCharge: (json['roundCharge']??0).toString(),
        //회차료 금액
        otherAddMemo: json['otherAddMemo']??"",
        //기타추가비 메모
        otherAddCharge: (json['otherAddCharge']??0).toString(),
        //기타추가비 금액

        unitPrice: (json['unitCharge']??0).toString(),
        unitPriceType: json['unitPriceType']??"",
        unitPriceTypeName: json['unitPriceTypeName']??"",

        custMngName: json['custMngName']??"",
        custMngMemo: json['custMngMemo']??"",

        payType: json['payType']??"",
        reqPayYN: json['reqPayYN']??"",
        reqPayDate: json['reqPayDate']??"",
        talkYn: json['talkYn']??"",
        reqStaffName:json['reqStaffName']??"",

        call24Cargo: json['call24Cargo']??"",
        manCargo: json['manCargo']??"",
        oneCargo: json['oneCargo']??"",
        call24Charge: (json['call24Charge']??0).toString(),
        manCharge: (json['manCharge']??0).toString(),
        oneCharge: (json['oneCharge']??0).toString(),

        useYn: json['useYn']
    );
    var list = json['templateStopList']??"[]"; // 경유지 목록
    if(list != "[]") {
      var jsonList = jsonDecode(list);
      List<TemplateStopPointModel> itemsList = jsonList.map((i) => TemplateModel.fromJSON(i)).toList();
      order.templateStopList = itemsList;
    }else{
      order.templateStopList = List.empty(growable: true);
    }
    return order;
  }

  Map<String,dynamic> toJson() {
    return {
      "templateTitle" : templateTitle,
      "templateId" : templateId,
      "reqCustId" : reqCustId,
      "reqCustName" : reqCustName,
      "reqDeptId" : reqDeptId,
      "reqDeptName" : reqDeptName,
      "reqStaff" : reqStaff,
      "reqTel" : reqTel,
      "reqAddr" : reqAddr,
      "reqAddrDetail" : reqAddrDetail,
      "custId" : custId,
      "custName" : custName,
      "deptId" : deptId,
      "deptName" : deptName,
      "inOutSctn" : inOutSctn,
      "inOutSctnName" : inOutSctnName,
      "truckTypeCode" : truckTypeCode,
      "truckTypeName" : truckTypeName,
      "sComName" : sComName,
      "sSido" : sSido,
      "sGungu" : sGungu,
      "sDong" : sDong,
      "sAddr" : sAddr,
      "sAddrDetail" : sAddrDetail,
      "sDate" : sDate,
      "sStaff" : sStaff,
      "sTel" : sTel,
      "sMemo" : sMemo,
      "eComName" : eComName,
      "eSido" : eSido,
      "eGungu" : eGungu,
      "eDong" : eDong,
      "eAddr" : eAddr,
      "eAddrDetail" : eAddrDetail,
      "eDate" : eDate,
      "eStaff" : eStaff,
      "eTel" : eTel,
      "eMemo" : eMemo,
      "sLat" : sLat,
      "sLon" : sLon,
      "eLat" : eLat,
      "eLon" : eLon,
      "goodsName" : goodsName,
      "goodsWeight" : goodsWeight,
      "weightUnitCode" : weightUnitCode,
      "weightUnitName" : weightUnitName,
      "goodsQty" : goodsQty,
      "qtyUnitCode" : qtyUnitCode,
      "qtyUnitName" : qtyUnitName,
      "sWayCode" : sWayCode,
      "sWayName" : sWayName,
      "eWayCode" : eWayCode,
      "eWayName" : eWayName,
      "mixYn" : mixYn,
      "mixSize" : mixSize,
      "returnYn" : returnYn,
      "carTonCode" : carTonCode,
      "carTonName" : carTonName,
      "carTypeCode" : carTypeCode,
      "carTypeName" : carTypeName,
      "chargeType" : chargeType,
      "chargeTypeName" : chargeTypeName,
      "distance" : distance,
      "time" : time,
      "reqMemo" : reqMemo,
      "driverMemo" : driverMemo,
      "itemCode" : itemCode,
      "itemName" : itemName,
      "stopCount" : stopCount,
      "sellCustId" : sellCustId,
      "sellDeptId" : sellDeptId,
      "sellStaff" : sellStaff,
      "sellStaffName" : sellStaffName,
      "sellStaffTel" : sellStaffTel,
      "sellCustName" : sellCustName,
      "sellDeptName" : sellDeptName,
      "sellCharge" : sellCharge,
      "sellFee" : sellFee,
      "sellWeight" : sellWeight,
      "sellWayPointMemo" : sellWayPointMemo,
      "sellWayPointCharge" : sellWayPointCharge,
      "sellStayMemo" : sellStayMemo,
      "sellStayCharge" : sellStayCharge,
      "sellHandWorkMemo" : sellHandWorkMemo,
      "sellHandWorkCharge" : sellHandWorkCharge,
      "sellRoundMemo" : sellRoundMemo,
      "sellRoundCharge" : sellRoundCharge,
      "sellOtherAddMemo" : sellOtherAddMemo,
      "sellOtherAddCharge" : sellOtherAddCharge,
      "custPayType" : custPayType,
      "buyCharge" : buyCharge,
      "buyFee" : buyFee,
      "wayPointMemo" : wayPointMemo,
      "wayPointCharge" : wayPointCharge,
      "stayMemo" : stayMemo,
      "stayCharge" : stayCharge,
      "handWorkMemo" : handWorkMemo,
      "handWorkCharge" : handWorkCharge,
      "roundMemo" : roundMemo,
      "roundCharge" : roundCharge,
      "otherAddMemo" : otherAddMemo,
      "otherAddCharge" : otherAddCharge,
      "unitPrice" : unitPrice,
      "unitPriceType" : unitPriceType,
      "unitPriceTypeName" : unitPriceTypeName,
      "custMngName" : custMngName,
      "custMngMemo" : custMngMemo,
      "payType" : payType,
      "reqPayYN" : reqPayYN,
      "reqPayDate" : reqPayDate,
      "talkYn" : talkYn,
      "templateStopList" : templateStopList,
      "reqStaffName" : reqStaffName,
      "call24Cargo" : call24Cargo,
      "manCargo" : manCargo,
      "oneCargo" : oneCargo,
      "call24Charge" : call24Charge,
      "manCharge" : manCharge,
      "oneCharge" : oneCharge,
      "useYn" : useYn,
    };
  }

  Map<String,dynamic> toMap() {
    return <String,dynamic>{
      "templateTitle": templateTitle,
      "templateId": templateId,
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
      "regid": regid,
      "regdate": regdate,
      "stopCount": stopCount,
      "sellCustId" : sellCustId,
      "sellDeptId" : sellDeptId,
      "sellStaff" : sellStaff,
      "sellStaffName" : sellStaffName,
      "sellStaffTel" : sellStaffTel,
      "sellCustName" : sellCustName,
      "sellDeptName" : sellDeptName,
      "sellCharge" : sellCharge,
      "sellFee" : sellFee,
      "sellWeight" : sellWeight,
      "sellWayPointMemo" : sellWayPointMemo,
      "sellWayPointCharge" : sellWayPointCharge,
      "sellStayMemo" : sellStayMemo,
      "sellStayCharge" : sellStayCharge,
      "sellHandWorkMemo" : sellHandWorkMemo,
      "sellHandWorkCharge" : sellHandWorkCharge,
      "sellRoundMemo" : sellRoundMemo,
      "sellRoundCharge" : sellRoundCharge,
      "sellOtherAddMemo" : sellOtherAddMemo,
      "sellOtherAddCharge" : sellOtherAddCharge,
      "custPayType" : custPayType,
      "buyCharge" : buyCharge,
      "buyFee" : buyFee,
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
      "payType": payType,
      "reqPayYN": reqPayYN,
      "reqPayDate": reqPayDate,
      "talkYn": talkYn,
      "templateStopList": jsonEncode(templateStopList??List.empty(growable: true)),
      "reqStaffName":reqStaffName,
      "call24Cargo": call24Cargo,
      "manCargo": manCargo,
      "oneCargo": oneCargo,
      "call24Charge": call24Charge,
      "manCharge": manCharge,
      "oneCharge": oneCharge,
      "useYn": useYn
    };
  }
}