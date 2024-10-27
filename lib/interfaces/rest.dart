
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' ;

part 'rest.g.dart';

@RestApi(baseUrl: SERVER_URL)
abstract class Rest {
  factory Rest(Dio dio,{String baseUrl}) = _Rest;

  /**
   * 공통코드
   */
  @FormUrlEncoded()

  @POST(URL_CODE_LIST)
  Future<HttpResponse> getCodeList(@Field("gcode") String? gcode);

  /**
   * 공통코드 상세
   */
  @FormUrlEncoded()
  @POST(URL_CODE_LIST)
  Future<HttpResponse> getCodeDetail(@Field("gcode") String? gcode,
      @Field("filter1") String? filter1);

  /**
   * 버전코드
   */
  @FormUrlEncoded()
  @POST(URL_VERSION_CODE)
  Future<HttpResponse> getVersion(@Field("versionKind") String? versionKind);

  /**
   * 로그인
   */
  @FormUrlEncoded()
  @POST(URL_MEMBER_LOGIN)
  Future<HttpResponse> login(@Field("userId") String? userId,
      @Field("passwd") String? passwd);



  @POST(URL_CHECK_LOGIN_TIME)
  Future<HttpResponse> loginTimeUpdate(@Header("Authorization") String? Authorization);


  /**
   * 사용자 정보
   */

  @POST(URL_USER_INFO)
  Future<HttpResponse> getUserInfo(@Header("Authorization") String? Authorization);

  /**
   * 사용자 정보 수정
   */
  @FormUrlEncoded()
  @POST(URL_USER_UPDATE)
  Future<HttpResponse> userUpdate(@Header("Authorization") String? Authorization,
      @Field("passwd") String? passwd,
      @Field("telnum") String? telnum,
      @Field("email") String? email,
      @Field("mobile") String? mobile);

  /**
   * 사용자 RPA 정보 수정
   */
  @FormUrlEncoded()
  @POST(URL_USER_RPA_UPDATE)
  Future<HttpResponse> userRpaInfoUpdate(
      @Header("Authorization") String? Authorization,
      @Field("call24Yn") String? call24Yn,
      @Field("link24Id") String? link24Id,
      @Field("link24Pass") String? link24Pass,
      @Field("man24Id") String? man24Id,
      @Field("man24Pass") String? man24Pass,
      @Field("one24Id") String? one24Id,
      @Field("one24Pass") String? one24Pass
  );


  /**
   * 기기 정보 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_DEVICE_UPDATE)
  Future<HttpResponse> deviceUpdate(@Header("Authorization") String? Authorization,
      @Field("pushYn") String pushYn,
      @Field("talkYn") String talkYn,
      @Field("pushId") String pushId,
      @Field("deviceModel") String deviceModel,
      @Field("deviceOs") String deviceOs,
      @Field("appVersion") String appVersion);

  /**
   * 기기 로그인 알림톡 전송
   */
  @FormUrlEncoded()
  @POST(URL_LOGIN_ALARM)
  Future<HttpResponse> smsSendLoginService(@Header("Authorization") String? Authorization,
      @Field("mobile")String? mobile,
      @Field("userName")String? userName,
      @Field("userId")String? userId,
      @Field("sendTime")String? sendTime,
      @Field("loginBrowser")String? loginBrowser,
      @Field("loginTime")String? loginTime);

  /**
   * 오더 목록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrder(
      @Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("dayOption") String? dayOption,
      @Field("orderState") String? orderState,
      @Field("rpaState") String? rpaState,
      @Field("staffName") String? staffName,
      @Field("pageNo") int? pageNo,
      @Field("searchColumn") String? searchColumn,
      @Field("searchValue") String? searchValue
      );

  /**
   * 기존 거래 목록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getRecentOrder(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("pageNo") int? pageNo);

  /**
   * 오더 상세
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrderDetail(@Header("Authorization") String? Authorization,
      @Field("sellAllocId") String? sellAllocId);

  /**
   * 탬플릿 리스트
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_LIST)
  Future<HttpResponse> getTemplateList(@Header("Authorization") String? Authorization);

  /**
   * 탬플릿 상세
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_LIST)
  Future<HttpResponse> getTemplateDetail(@Header("Authorization") String? Authorization,
      @Field("templateId") String? templateId);

  /**
   * 탬플릿 경유지 리스트
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_STOP_LIST)
  Future<HttpResponse> getTemplateStopList(@Header("Authorization") String? Authorization,
      @Field("templateId") String? templateId);

  /*
    *  오더 상세(Link 선택시)
    */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrderList2(@Header("Authorization") String? Authorization,
      @Field("allocId") String? allocId,
      @Field("orderId") String? orderId);

  /**
   * 차량 위치 관제
   */
  @FormUrlEncoded()
  @POST(URL_LBS)
  Future<HttpResponse> getLocation(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * 경유지 목록
   */
  @FormUrlEncoded()
  @POST(URL_STOP_POINT_LIST)
  Future<HttpResponse> getStopPoint(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * 오더 등록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_REG)
  Future<HttpResponse> orderReg(@Header("Authorization") String? Authorization,
      @Field("sellCustName") String? reqCustName,
      @Field("reqCustId") String? reqCustId,
      @Field("reqDeptId") String? reqDeptId,
      @Field("reqStaff") String? reqStaff, @Field("reqTel") String? reqTel,
      @Field("reqAddr") String? reqAddr, @Field("reqAddrDetail") String? reqAddrDetail,
      @Field("custId") String? custId, @Field("deptId") String? deptId,
      @Field("inOutSctn") String? inOutSctn, @Field("truckTypeCode") String? truckTypeCode,
      @Field("sComName") String? sComName, @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu, @Field("sDong") String? sDong,
      @Field("sAddr") String? sAddr, @Field("sAddrDetail") String? sAddrDetail,
      @Field("sDate") String? sDate, @Field("sStaff") String? sStaff,
      @Field("sTel") String? sTel, @Field("sMemo") String? sMemo,
      @Field("eComName") String? eComName, @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu, @Field("eDong") String? eDong,
      @Field("eAddr") String? eAddr, @Field("eAddrDetail") String? eAddrDetail,
      @Field("eDate") String? eDate, @Field("eStaff") String? eStaff,
      @Field("eTel") String? eTel, @Field("eMemo") String? eMemo,
      @Field("sLat") double? sLat, @Field("sLon") double? sLon,
      @Field("eLat") double? eLat, @Field("eLon") double? eLon,
      @Field("goodsName") String? goodsName, @Field("goodsWeight") double? goodsWeight,
      @Field("weightUnitCode") String? weightUnitCode, @Field("goodsQty") String? goodsQty,
      @Field("qtyUnitCode") String? qtyUnitCode, @Field("sWayCode") String? sWayCode,
      @Field("eWayCode") String? eWayCode, @Field("mixYn") String? mixYn,
      @Field("mixSize") String? mixSize, @Field("returnYn") String? returnYn,
      @Field("carTonCode") String? carTonCode, @Field("carTypeCode") String? carTypeCode,
      @Field("chargeType") String? chargeType,
      @Field("unitPriceType") String? unitPriceType,
      @Field('unitCharge') int? unitCharge,
      @Field("distance") double? distance,
      @Field("sTimeFreeYN") String? sTimeFreeYN, @Field("eTimeFreeYN") String? eTimeFreeYN,
      @Field("time") int? time, @Field("reqMemo") String? reqMemo,
      @Field("driverMemo") String? driverMemo, @Field("itemCode") String? itemCode,
      @Field("sellCharge") int? sellCharge, @Field("sellFee") int? sellFee,
      @Field("orderStopList") String? orderStopList, @Field("buyStaff") String? buyStaff,
      @Field("buyStaffTel") String? buyStaffTel, @Field("sellWayPointMemo") String? sellWayPointMemo,
      @Field("sellWayPointCharge") String? sellWayPointCharge, @Field("sellStayMemo") String? sellStayMemo,
      @Field("sellStayCharge") String? sellStayCharge, @Field("sellHandWorkMemo") String? sellHandWorkMemo,
      @Field("sellHandWorkCharge") String? sellHandWorkCharge, @Field("sellRoundMemo") String? sellRoundMemo,
      @Field("sellRoundCharge") String? sellRoundCharge, @Field("sellOtherAddMemo") String? sellOtherAddMemo,
      @Field("sellOtherAddCharge") String? sellOtherAddCharge, @Field("sellWeight") String? sellWeight,
      @Field("talkYn") String? talkYn,

      @Field("call24Cargo") String? call24Cargo,
      @Field("manCargo") String? manCargo,
      @Field("oneCargo") String? oneCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("manCharge") String? manCharge,
      @Field("oneCharge") String? oneCharge
      );

  /**
   * 탬플릿 등록
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_REG)
  Future<HttpResponse> templateReg(
      @Header("Authorization") String? Authorization,
      @Field("templateTitle") String? templateTitle,
      @Field("reqCustName") String? reqCustName,
      @Field("reqCustId") String? reqCustId,
      @Field("reqDeptName") String? reqDeptName,
      @Field("reqDeptId") String? reqDeptId,
      @Field("reqStaff") String? reqStaff, @Field("sellStaffName") String? sellStaffName, @Field("reqTel") String? reqTel,
      @Field("reqAddr") String? reqAddr, @Field("reqAddrDetail") String? reqAddrDetail,
      @Field("custId") String? custId, @Field("deptId") String? deptId,
      @Field("inOutSctn") String? inOutSctn, @Field("inOutSctnName") String? inOutSctnName, @Field("truckTypeCode") String? truckTypeCode, @Field("truckTypeName") String? truckTypeName,
      @Field("sComName") String? sComName, @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu, @Field("sDong") String? sDong,
      @Field("sAddr") String? sAddr, @Field("sAddrDetail") String? sAddrDetail,
      @Field("sDate") String? sDate, @Field("sStaff") String? sStaff,
      @Field("sTel") String? sTel, @Field("sMemo") String? sMemo,
      @Field("eComName") String? eComName, @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu, @Field("eDong") String? eDong,
      @Field("eAddr") String? eAddr, @Field("eAddrDetail") String? eAddrDetail,
      @Field("eDate") String? eDate, @Field("eStaff") String? eStaff,
      @Field("eTel") String? eTel, @Field("eMemo") String? eMemo,
      @Field("sLat") double? sLat, @Field("sLon") double? sLon,
      @Field("eLat") double? eLat, @Field("eLon") double? eLon,
      @Field("goodsName") String? goodsName, @Field("goodsWeight") double? goodsWeight,
      @Field("weightUnitCode") String? weightUnitCode, @Field("weightUnitName") String? weightUnitName, @Field("goodsQty") double? goodsQty,
      @Field("qtyUnitCode") String? qtyUnitCode, @Field("qtyUnitName") String? qtyUnitName, @Field("sWayCode") String? sWayCode, @Field("sWayName") String? sWayName,
      @Field("eWayCode") String? eWayCode,@Field("eWayName") String? eWayName, @Field("mixYn") String? mixYn,
      @Field("mixSize") String? mixSize, @Field("returnYn") String? returnYn,
      @Field("carTonCode") String? carTonCode,@Field("carTonName") String? carTonName, @Field("carTypeCode") String? carTypeCode, @Field("carTypeName") String? carTypeName,
      @Field("chargeType") String? chargeType, @Field("chargeTypeName") String? chargeTypeName,
      @Field("unitPriceType") String? unitPriceType,@Field('unitCharge') int? unitCharge,@Field("unitPriceTypeName") String? unitPriceTypeName,
      @Field("distance") String? distance,
      @Field("time") int? time, @Field("reqMemo") String? reqMemo,
      @Field("driverMemo") String? driverMemo, @Field("itemCode") String? itemCode, @Field("itemName") String? itemName ,
      @Field("sellCharge") int? sellCharge, @Field("sellFee") int? sellFee,
      @Field("templateStopList") String? templateStopList, @Field("buyStaff") String? buyStaff,
      @Field("buyStaffTel") String? buyStaffTel, @Field("sellWayPointMemo") String? sellWayPointMemo,
      @Field("sellWayPointCharge") int? sellWayPointCharge, @Field("sellStayMemo") String? sellStayMemo,
      @Field("sellStayCharge") int? sellStayCharge, @Field("sellHandWorkMemo") String? sellHandWorkMemo,
      @Field("sellHandWorkCharge") int? sellHandWorkCharge, @Field("sellRoundMemo") String? sellRoundMemo,
      @Field("sellRoundCharge") int? sellRoundCharge, @Field("sellOtherAddMemo") String? sellOtherAddMemo,
      @Field("sellOtherAddCharge") int? sellOtherAddCharge, @Field("sellWeight") String? sellWeight,
      @Field("talkYn") String? talkYn,

      @Field("call24Cargo") String? call24Cargo,
      @Field("manCargo") String? manCargo,
      @Field("oneCargo") String? oneCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("manCharge") String? manCharge,
      @Field("oneCharge") String? oneCharge
      );

  /**
   * 탬플릿 수정
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_REG)
  Future<HttpResponse> templateMod(
      @Header("Authorization") String? Authorization,
      @Field("templateId") String? templateId,
      @Field("reqCustName") String? reqCustName,
      @Field("reqCustId") String? reqCustId,
      @Field("reqDeptName") String? reqDeptName,
      @Field("reqDeptId") String? reqDeptId,
      @Field("reqStaff") String? reqStaff, @Field("sellStaffName") String? sellStaffName, @Field("reqTel") String? reqTel,
      @Field("reqAddr") String? reqAddr, @Field("reqAddrDetail") String? reqAddrDetail,
      @Field("custId") String? custId, @Field("deptId") String? deptId,
      @Field("inOutSctn") String? inOutSctn, @Field("inOutSctnName") String? inOutSctnName, @Field("truckTypeCode") String? truckTypeCode, @Field("truckTypeName") String? truckTypeName,
      @Field("sComName") String? sComName, @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu, @Field("sDong") String? sDong,
      @Field("sAddr") String? sAddr, @Field("sAddrDetail") String? sAddrDetail,
      @Field("sDate") String? sDate, @Field("sStaff") String? sStaff,
      @Field("sTel") String? sTel, @Field("sMemo") String? sMemo,
      @Field("eComName") String? eComName, @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu, @Field("eDong") String? eDong,
      @Field("eAddr") String? eAddr, @Field("eAddrDetail") String? eAddrDetail,
      @Field("eDate") String? eDate, @Field("eStaff") String? eStaff,
      @Field("eTel") String? eTel, @Field("eMemo") String? eMemo,
      @Field("sLat") double? sLat, @Field("sLon") double? sLon,
      @Field("eLat") double? eLat, @Field("eLon") double? eLon,
      @Field("goodsName") String? goodsName, @Field("goodsWeight") double? goodsWeight,
      @Field("weightUnitCode") String? weightUnitCode, @Field("weightUnitName") String? weightUnitName, @Field("goodsQty") double? goodsQty,
      @Field("qtyUnitCode") String? qtyUnitCode, @Field("qtyUnitName") String? qtyUnitName, @Field("sWayCode") String? sWayCode, @Field("sWayName") String? sWayName,
      @Field("eWayCode") String? eWayCode,@Field("eWayName") String? eWayName, @Field("mixYn") String? mixYn,
      @Field("mixSize") String? mixSize, @Field("returnYn") String? returnYn,
      @Field("carTonCode") String? carTonCode,@Field("carTonName") String? carTonName, @Field("carTypeCode") String? carTypeCode, @Field("carTypeName") String? carTypeName,
      @Field("chargeType") String? chargeType, @Field("chargeTypeName") String? chargeTypeName,
      @Field("unitPriceType") String? unitPriceType,@Field('unitCharge') int? unitCharge,@Field("unitPriceTypeName") String? unitPriceTypeName,
      @Field("distance") String? distance,
      @Field("time") int? time, @Field("reqMemo") String? reqMemo,
      @Field("driverMemo") String? driverMemo, @Field("itemCode") String? itemCode, @Field("itemName") String? itemName ,
      @Field("sellCharge") int? sellCharge, @Field("sellFee") int? sellFee,
      @Field("templateStopList") String? templateStopList, @Field("buyStaff") String? buyStaff,
      @Field("buyStaffTel") String? buyStaffTel, @Field("sellWayPointMemo") String? sellWayPointMemo,
      @Field("sellWayPointCharge") int? sellWayPointCharge, @Field("sellStayMemo") String? sellStayMemo,
      @Field("sellStayCharge") int? sellStayCharge, @Field("sellHandWorkMemo") String? sellHandWorkMemo,
      @Field("sellHandWorkCharge") int? sellHandWorkCharge, @Field("sellRoundMemo") String? sellRoundMemo,
      @Field("sellRoundCharge") int? sellRoundCharge, @Field("sellOtherAddMemo") String? sellOtherAddMemo,
      @Field("sellOtherAddCharge") int? sellOtherAddCharge, @Field("sellWeight") String? sellWeight,
      @Field("talkYn") String? talkYn,

      @Field("call24Cargo") String? call24Cargo,
      @Field("manCargo") String? manCargo,
      @Field("oneCargo") String? oneCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("manCharge") String? manCharge,
      @Field("oneCharge") String? oneCharge
      );

  /**
   * 탬플릿 삭제
   */
  @FormUrlEncoded()
  @POST(URL_USER_TEMPLATE_DEL)
  Future<HttpResponse> templateDel(
      @Header("Authorization") String? Authorization,
      @Field("templateDelList") String? templateDelList,
  );

  /**
   * 오더 수정
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_MOD)
  Future<HttpResponse> orderMod(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("sellCustName") String? reqCustName,
      @Field("reqCustId") String? reqCustId,
      @Field("reqDeptId") String? reqDeptId,
      @Field("reqStaff") String? reqStaff, @Field("reqTel") String? reqTel,
      @Field("reqAddr") String? reqAddr, @Field("reqAddrDetail") String? reqAddrDetail,
      @Field("custId") String? custId, @Field("deptId") String? deptId,
      @Field("inOutSctn") String? inOutSctn, @Field("truckTypeCode") String? truckTypeCode,
      @Field("sComName") String? sComName, @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu, @Field("sDong") String? sDong,
      @Field("sAddr") String? sAddr, @Field("sAddrDetail") String? sAddrDetail,
      @Field("sDate") String? sDate, @Field("sStaff") String? sStaff,
      @Field("sTel") String? sTel, @Field("sMemo") String? sMemo,
      @Field("eComName") String? eComName, @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu, @Field("eDong") String? eDong,
      @Field("eAddr") String? eAddr, @Field("eAddrDetail") String? eAddrDetail,
      @Field("eDate") String? eDate, @Field("eStaff") String? eStaff,
      @Field("eTel") String? eTel, @Field("eMemo") String? eMemo,
      @Field("sLat") double? sLat, @Field("sLon") double? sLon,
      @Field("eLat") double? eLat, @Field("eLon") double? eLon,
      @Field("orderState") String? orderState,
      @Field("goodsName") String? goodsName, @Field("goodsWeight") double? goodsWeight,
      @Field("weightUnitCode") String? weightUnitCode, @Field("goodsQty") String? goodsQty,
      @Field("qtyUnitCode") String? qtyUnitCode, @Field("sWayCode") String? sWayCode,
      @Field("eWayCode") String? eWayCode, @Field("mixYn") String? mixYn,
      @Field("mixSize") String? mixSize, @Field("returnYn") String? returnYn,
      @Field("carTonCode") String? carTonCode, @Field("carTypeCode") String? carTypeCode,
      @Field("chargeType") String? chargeType,
      @Field("unitPriceType") String? unitPriceType,
      @Field('unitCharge') int? unitCharge,
      @Field("distance") double? distance,
      @Field("time") int? time, @Field("reqMemo") String? reqMemo,
      @Field("driverMemo") String? driverMemo, @Field("itemCode") String? itemCode,
      @Field("sellCharge") int? sellCharge, @Field("sellFee") int? sellFee,
      @Field("orderStopList") String? orderStopList, @Field("buyStaff") String? buyStaff,
      @Field("buyStaffTel") String? buyStaffTel, @Field("sellWayPointMemo") String? sellWayPointMemo,
      @Field("sellWayPointCharge") String? sellWayPointCharge, @Field("sellStayMemo") String? sellStayMemo,
      @Field("sellStayCharge") String? sellStayCharge, @Field("sellHandWorkMemo") String? sellHandWorkMemo,
      @Field("sellHandWorkCharge") String? sellHandWorkCharge, @Field("sellRoundMemo") String? sellRoundMemo,
      @Field("sellRoundCharge") String? sellRoundCharge, @Field("sellOtherAddMemo") String? sellOtherAddMemo,
      @Field("sellOtherAddCharge") String? sellOtherAddCharge, @Field("sellWeight") String? sellWeight,
      @Field("talkYn") String? talkYn,

      @Field("call24Cargo") String? call24Cargo,
      @Field("manCargo") String? manCargo,
      @Field("oneCargo") String? oneCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("manCharge") String? manCharge,
      @Field("oneCharge") String? oneCharge
      );

  /**
   * 오더 취소
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_CANCEL)
  Future<HttpResponse> cancelOrder(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("orderState") String? orderState,
      @Field("call24Cargo") String? call24Cargo,
      @Field("oneCargo") String? oneCargo,
      @Field("manCargo") String? manCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("oneCharge") String? oneCharge,
      @Field("manCharge") String? manCharge
      );
  /**
   * 오더 취소 재 등록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_STATE)
  Future<HttpResponse> stateOrder(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("orderState") String? orderState,
      @Field("call24Cargo") String? call24Cargo,
      @Field("oneCargo") String? oneCargo,
      @Field("manCargo") String? manCargo,
      @Field("call24Charge") String? call24Charge,
      @Field("oneCharge") String? oneCharge,
      @Field("manCharge") String? manCharge
      );


  /**
   * 배차
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_ALLOC_REG)
  Future<HttpResponse> orderAlloc(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("sellStaff") String? sellStaff,
      @Field("sellStaffTel") String? sellStaffTel,
      @Field("buyCustId") String? buyCustId,
      @Field("buyDeptId") String? buyDeptId,
      @Field("buyStaff") String? buyStaff,
      @Field("buyStaffTel") String? buyStaffTel,
      @Field("allocCharge") String? allocCharge,
      @Field("allocFee") String? allocFee,
      @Field("vehicId") String? vehicId,
      @Field("driverId") String? driverId,
      @Field("carNum") String? carNum,
      @Field("carTonCode") String? carTonCode,
      @Field("carTypeCode") String? carTypeCode,
      @Field("driverName") String? driverName,
      @Field("driverTel") String? driverTel,
      @Field("driverMemo") String? driverMemo,
      @Field("wayPointMemo") String? wayPointMemo,
      @Field("wayPointCharge") String? wayPointCharge,
      @Field("stayMemo") String? stayMemo,
      @Field("stayCharge") String? stayCharge,
      @Field("handWorkMemo") String? handWorkMemo,
      @Field("handWorkCharge") String? handWorkCharge,
      @Field("roundMemo") String? roundMemo,
      @Field("roundCharge") String? roundCharge,
      @Field("otherAddMemo") String? otherAddMemo,
      @Field("otherAddCharge") String? otherAddCharge,
      @Field("payType") String? payType,
      @Field("talkYn") String? talkYn,
      @Field("buyDriverUpload") String? buyDriverUpload);

  /**
   * 차량 직접 배차
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_ALLOC_REG)
  Future<HttpResponse> orderAllocReg(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("sellStaff") String? sellStaff,
      @Field("sellStaffTel") String? sellStaffTel,
      @Field("vehicId") String? vehicId,
      @Field("driverId") String? driverId,
      @Field("carNum") String? carNum,
      @Field("carTonCode") String? carTonCode,
      @Field("carTypeCode") String? carTypeCode,
      @Field("driverName") String? driverName,
      @Field("driverTel") String? driverTel);

  /**
   * 배차 상태 변경
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_ALLOC_STATE)
  Future<HttpResponse> setAllocState(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("allocState") String? allocState);

  /**
   * 인수증 목록
   */
  @FormUrlEncoded()
  @POST(URL_RECEIPT_LIST)
  Future<HttpResponse> getReceipt(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * 정보망 등록
   */
  @FormUrlEncoded()
  @POST(URL_SEND_LINK)
  Future<HttpResponse> sendLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("linkType") String? linkType,
      @Field("linkStatus") String? linkStatus,
      @Field("fare") String? fare,
      @Field("fee") String? fee,
      @Field("command") String? command,
      @Field("payDate") String? payDate,
      @Field("chargeTypeCode") String? chargeTypeCode,
      @Field("cargodsc") String? cargodsc);

  /**
   * 정보망 목록
   */
  @FormUrlEncoded()
  @POST(URL_LINK_LIST)
  Future<HttpResponse> getLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * 정보망 오더, 배차 취소
   */
  @FormUrlEncoded()
  @POST(URL_SEND_LINK)
  Future<HttpResponse> cancelLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("command") String? command,
      @Field("linkType") String? linkType,
      @Field("linkStatus") String? linkStatus);

  /**
   * 정보망 일괄 취소
   */
  @FormUrlEncoded()
  @POST(URL_LINK_CANCEL)
  Future<HttpResponse> cancelAllLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);


  /**
   * New: 정보망 배차확정
   */
  @FormUrlEncoded()
  @POST(UIRL_LINK_RPA_CONFIRM)
  Future<HttpResponse> confirmNewLink(
      @Header("Authorization") String? Authorization,
      @Field("linkOrderId") String? linkOrderId,
      @Field("linkAllocCharge") String? linkAllocCharge,
      @Field("linkCode") String? linkCode,
      @Field("linkCarNum") String? linkCarNum,
      @Field("linkCarType") String? linkCarType,
      @Field("linkCarTon") String? linkCarTon,
      @Field("linkDriverName") String? linkDriverName,
      @Field("linkDriverTel") String? linkDriverTel);

  /**
   * New: 정보망 수정(개별)
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_MOD)
  Future<HttpResponse> modNewLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("linkCharge") String? linkCharge,
      @Field("orderState") String? orderState,
      @Field("linkId") String? linkId,
      @Field("allocChargeYn") String? allocChargeYn);

  /**
   * New: 정보망 취소(개별)
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_CANCEL)
  Future<HttpResponse> cancelNewLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("linkCharge") String? linkCharge,
      @Field("orderState") String? orderState,
      @Field("linkId") String? linkId);

  /**
   * New: 정보망 현황 : 24시콜, 화물맨, 원콜 현황 List
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_STATUS)
  Future<HttpResponse> statusNewLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * New: 정보망 계정 정보
   */
  @FormUrlEncoded()
  @POST(URL_LINK_USER_INFO)
  Future<HttpResponse> rpaLinkInfo(@Header("Authorization") String? Authorization);

  /**
   * New: 정보망 현황 : 기본 데이터
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_CURRENT)
  Future<HttpResponse> currentNewLink(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);


  /**
   * New: 정보망 현황 : 정보망 각 상태 및 금액 얼마 있는지 만 추출 - orderId
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_STATUS_SUB)
  Future<HttpResponse> currentNewLinkSub(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * New: 정보망 현황 : 정보망 각 상태 및 금액 얼마 있는지 만 추출 - allocId
   */
  @FormUrlEncoded()
  @POST(URL_LINK_RPA_STATUS_ALLOC)
  Future<HttpResponse> currentNewLinkAlloc(@Header("Authorization") String? Authorization,
      @Field("allocId") String? allocId);


  /**
   * New: 정보망 현황 : 정보망 상태 유무 확인
   */

  @POST(URL_RPA_USE_YN)
  Future<HttpResponse> rpaUseYn(@Header("Authorization") String? Authorization);


  /**
   * 차량 검색
   */
  @FormUrlEncoded()
  @POST(URL_CAR_LIST)
  Future<HttpResponse> getCar(@Header("Authorization") String? Authorization,
      @Field("carNum") String? carNum);

  /**
   * 주소지 목록
   */
  @FormUrlEncoded()
  @POST(URL_ADDR_LIST)
  Future<HttpResponse> getAddr(@Header("Authorization") String? Authorization,
      @Field("addrName") String? addrName);

  /**
   * KAKAO Lat,Lon 데이터 가져오기
   */
  @GET(URL_KAKAO_ADDRESS)
  Future<HttpResponse> getLatLon(@Header("Authorization") String? Authorization,
      @Field("addrName") String? addrName);

  /**
   * 주소지 등록
   */
  @FormUrlEncoded()
  @POST(URL_ADDR_REG)
  Future<HttpResponse> regAddr(@Header("Authorization") String? Authorization,
      @Field("addrSeq") int? addrSeq,
      @Field("addrName") String? addrName,
      @Field("addr") String? addr,
      @Field("addrDetail") String? addrDetail,
      @Field("lat") String? lat,
      @Field("lon") String? lon,
      @Field("staffName") String? staffName,
      @Field("staffTel") String? staffTel,
      @Field("orderMemo") String? orderMemo,
      @Field("sido") String? sido,
      @Field("gungu") String? gungu,
      @Field("dong") String? dong);

  /**
   * 주소지 삭제
   */
  @FormUrlEncoded()
  @POST(URL_ADDR_DEL)
  Future<HttpResponse> deleteAddr(@Header("Authorization") String? Authorization,
      @Field("addrSeq") int? addrSeq);

  /**
   * 거래처 목록
   */
  @FormUrlEncoded()
  @POST(URL_CUSTOMER_LIST)
  Future<HttpResponse> getCustomer(@Header("Authorization") String? Authorization,
      @Field("sellBuySctn") String? sellBuySctn,
      @Field("custName") String? custName,
      @Field("telnum") String? telnum);

  /**
   * 거래처 담당자 목록
   */
  @FormUrlEncoded()
  @POST(URL_CUST_USER_LIST)
  Future<HttpResponse> getCustUser(@Header("Authorization") String? Authorization,
      @Field("custId") String? custId,
      @Field("deptId") String? deptId);
  /**
   * 운송사 지정 담당자 목록
   */
  @FormUrlEncoded()
  @POST(URL_CUST_USER_LIST2)
  Future<HttpResponse> getCustUser2(@Header("Authorization") String? Authorization,
      @Field("custId") String? custId,
      @Field("deptId") String? deptId);

  /**
   * 구간별계약단가
   */
  @FormUrlEncoded()

  @POST(URL_FRT_COST)
  Future<HttpResponse> getCost(@Header("Authorization") String? Authorization,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("buyCustId") String? buyCustId,
      @Field("buyDeptId") String? buyDeptId,
      @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu,
      @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu,
      @Field("carTonCode") String? carTonCode);

  /**
   * 부서 목록
   */

  @POST(URL_DEPT_LIST)
  Future<HttpResponse> getDeptList(@Header("Authorization") String? Authorization);

  /**
   * 오더&배차현황
   */
  @FormUrlEncoded()

  @POST(URL_MONITOR_ORDER)
  Future<HttpResponse> getMonitorOrder(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("deptId") String? deptId,
      @Field("userId") String? userId);

  /**
   * 부서별손익
   */
  @FormUrlEncoded()

  @POST(URL_MONITOR_DEPT_PROFIT)
  Future<HttpResponse> getMonitorDeptProfit(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("deptId") String? deptId);

  /**
   * 거래처별손익
   */
  @FormUrlEncoded()

  @POST(URL_MONITOR_CUST_PROFIT)
  Future<HttpResponse> getMonitorCustProfit(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("deptId") String? deptId);

  /**
   * 업무초기값
   */

  @POST(URL_OPTION)
  Future<HttpResponse> getOption(@Header("Authorization") String? Authorization);

  /**
   * 업무초기값 설정 - 화주 정보
   */
  @FormUrlEncoded()

  @POST(URL_OPTION_UPDATE)
  Future<HttpResponse> setOptionRequest(@Header("Authorization") String? Authorization,
      @Field("reqYn") String? reqYn,
      @Field("reqCustId") String? reqCustId,
      @Field("reqDeptId") String? reqDeptId,
      @Field("reqStaffId") String? reqStaffId,
      @Field("reqTel") String? reqTel,
      @Field("reqAddr") String? reqAddr,
      @Field("reqAddrDetail") String? reqAddrDetail,
      @Field("reqMemo") String? reqMemo);

  /**
   * 업무초기값 설정 - 상차지 정보
   */
  @FormUrlEncoded()

  @POST(URL_OPTION_UPDATE)
  Future<HttpResponse> setOptionAddr(@Header("Authorization") String? Authorization,
      @Field("sAreaYn") String? sAreaYn,
      @Field("sComName") String? sComName,
      @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu,
      @Field("sDong") String? sDong,
      @Field("sAddr") String? sAddr,
      @Field("sAddrDetail") String? sAddrDetail,
      @Field("sStaff") String? sStaff,
      @Field("sTel") String? sTel,
      @Field("sMemo") String? sMemo,
      @Field("sLat") double? sLat,
      @Field("sLon") double? sLon);

  /**
   * 업무초기값 설정 - 화물 정보
   */
  @FormUrlEncoded()

  @POST(URL_OPTION_UPDATE)
  Future<HttpResponse> setOptionCargo(@Header("Authorization") String? Authorization,
      @Field("goodsYn") String? goodsYn,
      @Field("inOutSctn") String? inOutSctn,
      @Field("truckTypeCode") String? truckTypeCode,
      @Field("carTypeCode") String? carTypeCode,
      @Field("carTonCode") String? carTonCode,
      @Field("itemCode") String? itemCode,
      @Field("goodsName") String? goodsName,
      @Field("goodsWeight") String? goodsWeight,
      @Field("sWayCode") String? sWayCode,
      @Field("eWayCode") String? eWayCode);

  /**
   * 업무초기값 설정 - 운임 정보
   */
  @FormUrlEncoded()

  @POST(URL_OPTION_UPDATE)
  Future<HttpResponse> setOptionCharge(@Header("Authorization") String? Authorization,
      @Field("sellYn") String? sellYn,
      @Field("unitPriceType") String? unitPriceType,
      @Field("sellCharge") String? sellCharge,
      @Field("unitCharge") String? unitCharge);

  /**
   * 업무초기값 설정 - 배차 정보
   */
  @FormUrlEncoded()

  @POST(URL_OPTION_UPDATE)
  Future<HttpResponse> setOptionTrans(@Header("Authorization") String? Authorization,
      @Field("buyYn") String? buyYn,
      @Field("buyCharge") String? buyCharge,
      @Field("driverMemo") String? driverMemo);

  /**
   * 단가표 값 조회(일반)
   */
  @FormUrlEncoded()

  @POST(URL_TMS_UNIT_CHARGE)
  Future<HttpResponse> getTmsUnitCharge(@Header("Authorization") String? Authorization,
      @Field("ChargeType") String? ChargeType,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu,
      @Field("sDong") String? sDong,
      @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu,
      @Field("eDong") String? eDong,
      @Field("carTonCode") String? carTonCode,
      @Field("carTypeCode") String? carTypeCode,
      @Field("sDate") String? sDate,
      @Field("eDate") String? eDate);

  /**
   * 단가표 가져오기(운송사 지정 시)
   */
  @FormUrlEncoded()

  @POST(URL_TMS_UNIT_COMP_CHARGE)
  Future<HttpResponse> getTmsUnitCompCharge(@Header("Authorization") String? Authorization,
      @Field("ChargeType") String? ChargeType,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId,
      @Field("buyCustId") String? buyCustId,
      @Field("buyDeptId") String? buyDeptId,
      @Field("sSido") String? sSido,
      @Field("sGungu") String? sGungu,
      @Field("sDong") String? sDong,
      @Field("sComName") String? sComName,
      @Field("eSido") String? eSido,
      @Field("eGungu") String? eGungu,
      @Field("eDong") String? eDong,
      @Field("carTonCode") String? carTonCode,
      @Field("carTypeCode") String? carTypeCode,
      @Field("sDate") String? sDate,
      @Field("eDate") String? eDate,
      @Field("eComName") String? eComName,
      @Field("unitPriceType") String? unitPriceType);

  /**
   * 단가표 Count
   */
  @FormUrlEncoded()

  @POST(URL_TMS_UNIT_CNT)
  Future<HttpResponse> getTmsUnitCnt(@Header("Authorization") String? Authorization,
      @Field("buyCustId") String? buyCustId,
      @Field("buyDeptId") String? buyDeptId,
      @Field("sellCustId") String? sellCustId,
      @Field("sellDeptId") String? sellDeptId);

  /**
   * 원콜 Point Result
   */

  @POST(URL_TMS_POINT_RESULT)
  Future<HttpResponse> getTmsPointResult(@Header("Authorization") String? Authorization);

  /**
   * 원콜 Point Information
   */

  @POST(URL_TMS_POINT_USER_INFO)
  Future<HttpResponse> getTmsUserPointInfo(@Header("Authorization") String? Authorization);

  /**
   * 원콜 Point Info 리스트
   */
  @FormUrlEncoded()

  @POST(URL_TMS_POINT_USER_LIST)
  Future<HttpResponse> getTmsUserPointList(@Header("Authorization") String? Authorization,
      @Field("pageNo") int? pageNo);

  /**
   * RPA 로그인 정보 Flag
   */

  @POST(URL_RPA_LINK_FLAG)
  Future<HttpResponse> getLinkFlag(@Header("Authorization") String? Authorization);


  /**
   * 공지사항
   */

  @POST(URL_NOTICE)
  Future<HttpResponse> getNotice(@Header("Authorization") String? Authorization);

  /**
   * 공지사항 최신
   */
  @FormUrlEncoded()

  @POST(URL_NOTICE)
  Future<HttpResponse> getNotice_new(@Header("Authorization") String? Authorization,
      @Field("isNew") String? isNew);

  /**
   * 알림
   */

  @POST(URL_NOTIFICATION)
  Future<HttpResponse> getNotification(@Header("Authorization") String? Authorization);

  /**
   * 주소 검색(도로명주소 API)
   */
  @FormUrlEncoded()
  @POST(URL_JUSO)
  Future<HttpResponse> getJuso(@Field("confmKey") String? confmKey,
      @Field("currentPage") String? currentPage,
      @Field("countPerPage") String? countPerPage,
      @Field("keyword") String? keyword,
      @Field("resultType") String? resultType);

  /**
   * 주소 검색(카카오 API)
   */
  @GET(URL_KAKAO_ADDRESS)
  Future<HttpResponse> getGeoAddress(@Header("Authorization") String? Authorization,
      @Query("query") String? query);


  /**
   * 시/군/구 검색
   */
  @FormUrlEncoded()
  @POST(URL_SIDO_AREA)
  Future<HttpResponse> getSidoArea(@Field("sido") String? sido);

  /**
   * ID 찾기
   */
  @FormUrlEncoded()
  @POST(URL_FIND_ID)
  Future<HttpResponse> findId(@Field("userName") String? userName,
      @Field("userPhone") String? userPhone);

  /**
   * 비밀번호 찾기
   */
  @FormUrlEncoded()
  @POST(URL_FIND_PWD)
  Future<HttpResponse> findPwd(@Field("userId") String? userId,
      @Field("userName") String? userName,
      @Field("userPhone") String? userPhone);

  ///////////////////////////////////////////////////////////////////////
  // 약관 동의
  ///////////////////////////////////////////////////////////////////////

  /**
   * 약관 동의 확인(ID)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_ID)
  Future<HttpResponse> getTermsUserAgree(
      @Header("Authorization") String Authorization,
      @Field("userId") String? userId);

  /**
   * 약관 동의 확인(전화번호)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_TEL)
  Future<HttpResponse> getTermsTelAgree(
      @Header("Authorization") String? Authorization,
      @Field("tel") String? tel);

  /**
   * 약관 동의 업데이트(필수, 선택항목)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_INSERT)
  Future<HttpResponse> insertTermsAgree(
      @Header("Authorization") String? Authorization,
      @Field("userId") String? userName,
      @Field("tel") String? tel,
      @Field("necessary") String? necessary,
      @Field("selective") String? selective,
      @Field("version") String? termsVersion
      );

  /**
   * 약관 동의 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_UPDATE)
  Future<HttpResponse> updateTermsAgree(
      @Header("Authorization") String? Authorization,
      @Field("userId") String? userId,
      @Field("necessary") String? necessary,
      @Field("selective") String? selective
      );

  /**
   * 지번 검색
   */
  @FormUrlEncoded()
  @POST(URL_JIBUN)
  Future<HttpResponse> getJibun(@Field("fullAddr") String? fullAddr);


}