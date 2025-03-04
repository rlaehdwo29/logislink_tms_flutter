// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _Rest implements Rest {
  _Rest(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://192.168.53.51:9080';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<HttpResponse<dynamic>> getCodeList(gcode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'gcode': gcode};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/code/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCodeDetail(
    gcode,
    filter1,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'gcode': gcode,
      'filter1': filter1,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/code/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getVersion(versionKind) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'versionKind': versionKind};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/version/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setEventLog(
    userId,
    menu_url,
    menu_name,
    mobile_type,
    app_version,
    loginYn,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'userId': userId,
      'menu_url': menu_url,
      'menu_name': menu_name,
      'mobile_type': mobile_type,
      'app_version': app_version,
      'loginYn': loginYn,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/insert/eventLog',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> login(
    userId,
    passwd,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'userId': userId,
      'passwd': passwd,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/login/A',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> loginTimeUpdate(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/user/login/timeUpdate',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getUserInfo(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/user/info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> userUpdate(
    Authorization,
    passwd,
    telnum,
    email,
    mobile,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'passwd': passwd,
      'telnum': telnum,
      'email': email,
      'mobile': mobile,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> userRpaInfoUpdate(
    Authorization,
    call24Yn,
    link24Id,
    link24Pass,
    man24Id,
    man24Pass,
    one24Id,
    one24Pass,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'call24Yn': call24Yn,
      'link24Id': link24Id,
      'link24Pass': link24Pass,
      'man24Id': man24Id,
      'man24Pass': man24Pass,
      'one24Id': one24Id,
      'one24Pass': one24Pass,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/rpa/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> deviceUpdate(
    Authorization,
    pushYn,
    talkYn,
    pushId,
    deviceModel,
    deviceOs,
    appVersion,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'pushYn': pushYn,
      'talkYn': talkYn,
      'pushId': pushId,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      'appVersion': appVersion,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/device/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> smsSendLoginService(
    Authorization,
    mobile,
    userName,
    userId,
    sendTime,
    loginBrowser,
    loginTime,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'mobile': mobile,
      'userName': userName,
      'userId': userId,
      'sendTime': sendTime,
      'loginBrowser': loginBrowser,
      'loginTime': loginTime,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/notice/talk/smsSendLoginService',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrder(
    Authorization,
    fromDate,
    toDate,
    dayOption,
    orderState,
    deptState,
    rpaState,
    staffName,
    pageNo,
    searchColumn,
    searchValue,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'dayOption': dayOption,
      'orderState': orderState,
      'deptState': deptState,
      'rpaState': rpaState,
      'staffName': staffName,
      'pageNo': pageNo,
      'searchColumn': searchColumn,
      'searchValue': searchValue,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/list/A/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getRecentOrder(
    Authorization,
    fromDate,
    toDate,
    sellCustId,
    sellDeptId,
    pageNo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'pageNo': pageNo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/list/A/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrderDetail(
    Authorization,
    sellAllocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'sellAllocId': sellAllocId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/list/A/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTemplateList(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/templateList',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTemplateDetail(
    Authorization,
    templateId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'templateId': templateId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/templateList',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTemplateStopList(
    Authorization,
    templateId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'templateId': templateId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/templateStopList',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrderList2(
    Authorization,
    allocId,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'allocId': allocId,
      'orderId': orderId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/list/A/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getLocation(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderlbs/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getStopPoint(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderstop/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> orderReg(
    Authorization,
    reqCustName,
    reqCustId,
    reqDeptId,
    reqStaff,
    reqTel,
    reqAddr,
    reqAddrDetail,
    custId,
    deptId,
    inOutSctn,
    truckTypeCode,
    sComName,
    sSido,
    sGungu,
    sDong,
    sAddr,
    sAddrDetail,
    sDate,
    sStaff,
    sTel,
    sMemo,
    eComName,
    eSido,
    eGungu,
    eDong,
    eAddr,
    eAddrDetail,
    eDate,
    eStaff,
    eTel,
    eMemo,
    sLat,
    sLon,
    eLat,
    eLon,
    goodsName,
    goodsWeight,
    weightUnitCode,
    goodsQty,
    qtyUnitCode,
    sWayCode,
    eWayCode,
    mixYn,
    mixSize,
    returnYn,
    carTonCode,
    carTypeCode,
    chargeType,
    unitPriceType,
    unitCharge,
    distance,
    sTimeFreeYN,
    eTimeFreeYN,
    time,
    reqMemo,
    driverMemo,
    itemCode,
    sellCharge,
    sellFee,
    orderStopList,
    buyStaff,
    buyStaffTel,
    sellWayPointMemo,
    sellWayPointCharge,
    sellStayMemo,
    sellStayCharge,
    sellHandWorkMemo,
    sellHandWorkCharge,
    sellRoundMemo,
    sellRoundCharge,
    sellOtherAddMemo,
    sellOtherAddCharge,
    sellWeight,
    talkYn,
    call24Cargo,
    manCargo,
    oneCargo,
    call24Charge,
    manCharge,
    oneCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sellCustName': reqCustName,
      'reqCustId': reqCustId,
      'reqDeptId': reqDeptId,
      'reqStaff': reqStaff,
      'reqTel': reqTel,
      'reqAddr': reqAddr,
      'reqAddrDetail': reqAddrDetail,
      'custId': custId,
      'deptId': deptId,
      'inOutSctn': inOutSctn,
      'truckTypeCode': truckTypeCode,
      'sComName': sComName,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sAddr': sAddr,
      'sAddrDetail': sAddrDetail,
      'sDate': sDate,
      'sStaff': sStaff,
      'sTel': sTel,
      'sMemo': sMemo,
      'eComName': eComName,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'eAddr': eAddr,
      'eAddrDetail': eAddrDetail,
      'eDate': eDate,
      'eStaff': eStaff,
      'eTel': eTel,
      'eMemo': eMemo,
      'sLat': sLat,
      'sLon': sLon,
      'eLat': eLat,
      'eLon': eLon,
      'goodsName': goodsName,
      'goodsWeight': goodsWeight,
      'weightUnitCode': weightUnitCode,
      'goodsQty': goodsQty,
      'qtyUnitCode': qtyUnitCode,
      'sWayCode': sWayCode,
      'eWayCode': eWayCode,
      'mixYn': mixYn,
      'mixSize': mixSize,
      'returnYn': returnYn,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'chargeType': chargeType,
      'unitPriceType': unitPriceType,
      'unitCharge': unitCharge,
      'distance': distance,
      'sTimeFreeYN': sTimeFreeYN,
      'eTimeFreeYN': eTimeFreeYN,
      'time': time,
      'reqMemo': reqMemo,
      'driverMemo': driverMemo,
      'itemCode': itemCode,
      'sellCharge': sellCharge,
      'sellFee': sellFee,
      'orderStopList': orderStopList,
      'buyStaff': buyStaff,
      'buyStaffTel': buyStaffTel,
      'sellWayPointMemo': sellWayPointMemo,
      'sellWayPointCharge': sellWayPointCharge,
      'sellStayMemo': sellStayMemo,
      'sellStayCharge': sellStayCharge,
      'sellHandWorkMemo': sellHandWorkMemo,
      'sellHandWorkCharge': sellHandWorkCharge,
      'sellRoundMemo': sellRoundMemo,
      'sellRoundCharge': sellRoundCharge,
      'sellOtherAddMemo': sellOtherAddMemo,
      'sellOtherAddCharge': sellOtherAddCharge,
      'sellWeight': sellWeight,
      'talkYn': talkYn,
      'call24Cargo': call24Cargo,
      'manCargo': manCargo,
      'oneCargo': oneCargo,
      'call24Charge': call24Charge,
      'manCharge': manCharge,
      'oneCharge': oneCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/write/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> templateReg(
    Authorization,
    templateTitle,
    reqCustName,
    reqCustId,
    reqDeptName,
    reqDeptId,
    reqStaff,
    sellStaffName,
    reqTel,
    reqAddr,
    reqAddrDetail,
    custId,
    deptId,
    inOutSctn,
    inOutSctnName,
    truckTypeCode,
    truckTypeName,
    sComName,
    sSido,
    sGungu,
    sDong,
    sAddr,
    sAddrDetail,
    sDate,
    sStaff,
    sTel,
    sMemo,
    eComName,
    eSido,
    eGungu,
    eDong,
    eAddr,
    eAddrDetail,
    eDate,
    eStaff,
    eTel,
    eMemo,
    sLat,
    sLon,
    eLat,
    eLon,
    goodsName,
    goodsWeight,
    weightUnitCode,
    weightUnitName,
    goodsQty,
    qtyUnitCode,
    qtyUnitName,
    sWayCode,
    sWayName,
    eWayCode,
    eWayName,
    mixYn,
    mixSize,
    returnYn,
    carTonCode,
    carTonName,
    carTypeCode,
    carTypeName,
    chargeType,
    chargeTypeName,
    unitPriceType,
    unitCharge,
    unitPriceTypeName,
    distance,
    time,
    reqMemo,
    driverMemo,
    itemCode,
    itemName,
    sellCharge,
    sellFee,
    templateStopList,
    buyStaff,
    buyStaffTel,
    sellWayPointMemo,
    sellWayPointCharge,
    sellStayMemo,
    sellStayCharge,
    sellHandWorkMemo,
    sellHandWorkCharge,
    sellRoundMemo,
    sellRoundCharge,
    sellOtherAddMemo,
    sellOtherAddCharge,
    sellWeight,
    talkYn,
    call24Cargo,
    manCargo,
    oneCargo,
    call24Charge,
    manCharge,
    oneCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'templateTitle': templateTitle,
      'reqCustName': reqCustName,
      'reqCustId': reqCustId,
      'reqDeptName': reqDeptName,
      'reqDeptId': reqDeptId,
      'reqStaff': reqStaff,
      'sellStaffName': sellStaffName,
      'reqTel': reqTel,
      'reqAddr': reqAddr,
      'reqAddrDetail': reqAddrDetail,
      'custId': custId,
      'deptId': deptId,
      'inOutSctn': inOutSctn,
      'inOutSctnName': inOutSctnName,
      'truckTypeCode': truckTypeCode,
      'truckTypeName': truckTypeName,
      'sComName': sComName,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sAddr': sAddr,
      'sAddrDetail': sAddrDetail,
      'sDate': sDate,
      'sStaff': sStaff,
      'sTel': sTel,
      'sMemo': sMemo,
      'eComName': eComName,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'eAddr': eAddr,
      'eAddrDetail': eAddrDetail,
      'eDate': eDate,
      'eStaff': eStaff,
      'eTel': eTel,
      'eMemo': eMemo,
      'sLat': sLat,
      'sLon': sLon,
      'eLat': eLat,
      'eLon': eLon,
      'goodsName': goodsName,
      'goodsWeight': goodsWeight,
      'weightUnitCode': weightUnitCode,
      'weightUnitName': weightUnitName,
      'goodsQty': goodsQty,
      'qtyUnitCode': qtyUnitCode,
      'qtyUnitName': qtyUnitName,
      'sWayCode': sWayCode,
      'sWayName': sWayName,
      'eWayCode': eWayCode,
      'eWayName': eWayName,
      'mixYn': mixYn,
      'mixSize': mixSize,
      'returnYn': returnYn,
      'carTonCode': carTonCode,
      'carTonName': carTonName,
      'carTypeCode': carTypeCode,
      'carTypeName': carTypeName,
      'chargeType': chargeType,
      'chargeTypeName': chargeTypeName,
      'unitPriceType': unitPriceType,
      'unitCharge': unitCharge,
      'unitPriceTypeName': unitPriceTypeName,
      'distance': distance,
      'time': time,
      'reqMemo': reqMemo,
      'driverMemo': driverMemo,
      'itemCode': itemCode,
      'itemName': itemName,
      'sellCharge': sellCharge,
      'sellFee': sellFee,
      'templateStopList': templateStopList,
      'buyStaff': buyStaff,
      'buyStaffTel': buyStaffTel,
      'sellWayPointMemo': sellWayPointMemo,
      'sellWayPointCharge': sellWayPointCharge,
      'sellStayMemo': sellStayMemo,
      'sellStayCharge': sellStayCharge,
      'sellHandWorkMemo': sellHandWorkMemo,
      'sellHandWorkCharge': sellHandWorkCharge,
      'sellRoundMemo': sellRoundMemo,
      'sellRoundCharge': sellRoundCharge,
      'sellOtherAddMemo': sellOtherAddMemo,
      'sellOtherAddCharge': sellOtherAddCharge,
      'sellWeight': sellWeight,
      'talkYn': talkYn,
      'call24Cargo': call24Cargo,
      'manCargo': manCargo,
      'oneCargo': oneCargo,
      'call24Charge': call24Charge,
      'manCharge': manCharge,
      'oneCharge': oneCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/write/template',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> templateMod(
    Authorization,
    templateId,
    reqCustName,
    reqCustId,
    reqDeptName,
    reqDeptId,
    reqStaff,
    sellStaffName,
    reqTel,
    reqAddr,
    reqAddrDetail,
    custId,
    deptId,
    inOutSctn,
    inOutSctnName,
    truckTypeCode,
    truckTypeName,
    sComName,
    sSido,
    sGungu,
    sDong,
    sAddr,
    sAddrDetail,
    sDate,
    sStaff,
    sTel,
    sMemo,
    eComName,
    eSido,
    eGungu,
    eDong,
    eAddr,
    eAddrDetail,
    eDate,
    eStaff,
    eTel,
    eMemo,
    sLat,
    sLon,
    eLat,
    eLon,
    goodsName,
    goodsWeight,
    weightUnitCode,
    weightUnitName,
    goodsQty,
    qtyUnitCode,
    qtyUnitName,
    sWayCode,
    sWayName,
    eWayCode,
    eWayName,
    mixYn,
    mixSize,
    returnYn,
    carTonCode,
    carTonName,
    carTypeCode,
    carTypeName,
    chargeType,
    chargeTypeName,
    unitPriceType,
    unitCharge,
    unitPriceTypeName,
    distance,
    time,
    reqMemo,
    driverMemo,
    itemCode,
    itemName,
    sellCharge,
    sellFee,
    templateStopList,
    buyStaff,
    buyStaffTel,
    sellWayPointMemo,
    sellWayPointCharge,
    sellStayMemo,
    sellStayCharge,
    sellHandWorkMemo,
    sellHandWorkCharge,
    sellRoundMemo,
    sellRoundCharge,
    sellOtherAddMemo,
    sellOtherAddCharge,
    sellWeight,
    talkYn,
    call24Cargo,
    manCargo,
    oneCargo,
    call24Charge,
    manCharge,
    oneCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'templateId': templateId,
      'reqCustName': reqCustName,
      'reqCustId': reqCustId,
      'reqDeptName': reqDeptName,
      'reqDeptId': reqDeptId,
      'reqStaff': reqStaff,
      'sellStaffName': sellStaffName,
      'reqTel': reqTel,
      'reqAddr': reqAddr,
      'reqAddrDetail': reqAddrDetail,
      'custId': custId,
      'deptId': deptId,
      'inOutSctn': inOutSctn,
      'inOutSctnName': inOutSctnName,
      'truckTypeCode': truckTypeCode,
      'truckTypeName': truckTypeName,
      'sComName': sComName,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sAddr': sAddr,
      'sAddrDetail': sAddrDetail,
      'sDate': sDate,
      'sStaff': sStaff,
      'sTel': sTel,
      'sMemo': sMemo,
      'eComName': eComName,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'eAddr': eAddr,
      'eAddrDetail': eAddrDetail,
      'eDate': eDate,
      'eStaff': eStaff,
      'eTel': eTel,
      'eMemo': eMemo,
      'sLat': sLat,
      'sLon': sLon,
      'eLat': eLat,
      'eLon': eLon,
      'goodsName': goodsName,
      'goodsWeight': goodsWeight,
      'weightUnitCode': weightUnitCode,
      'weightUnitName': weightUnitName,
      'goodsQty': goodsQty,
      'qtyUnitCode': qtyUnitCode,
      'qtyUnitName': qtyUnitName,
      'sWayCode': sWayCode,
      'sWayName': sWayName,
      'eWayCode': eWayCode,
      'eWayName': eWayName,
      'mixYn': mixYn,
      'mixSize': mixSize,
      'returnYn': returnYn,
      'carTonCode': carTonCode,
      'carTonName': carTonName,
      'carTypeCode': carTypeCode,
      'carTypeName': carTypeName,
      'chargeType': chargeType,
      'chargeTypeName': chargeTypeName,
      'unitPriceType': unitPriceType,
      'unitCharge': unitCharge,
      'unitPriceTypeName': unitPriceTypeName,
      'distance': distance,
      'time': time,
      'reqMemo': reqMemo,
      'driverMemo': driverMemo,
      'itemCode': itemCode,
      'itemName': itemName,
      'sellCharge': sellCharge,
      'sellFee': sellFee,
      'templateStopList': templateStopList,
      'buyStaff': buyStaff,
      'buyStaffTel': buyStaffTel,
      'sellWayPointMemo': sellWayPointMemo,
      'sellWayPointCharge': sellWayPointCharge,
      'sellStayMemo': sellStayMemo,
      'sellStayCharge': sellStayCharge,
      'sellHandWorkMemo': sellHandWorkMemo,
      'sellHandWorkCharge': sellHandWorkCharge,
      'sellRoundMemo': sellRoundMemo,
      'sellRoundCharge': sellRoundCharge,
      'sellOtherAddMemo': sellOtherAddMemo,
      'sellOtherAddCharge': sellOtherAddCharge,
      'sellWeight': sellWeight,
      'talkYn': talkYn,
      'call24Cargo': call24Cargo,
      'manCargo': manCargo,
      'oneCargo': oneCargo,
      'call24Charge': call24Charge,
      'manCharge': manCharge,
      'oneCharge': oneCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/write/template',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> templateDel(
    Authorization,
    templateDelList,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'templateDelList': templateDelList};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/delete/template',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> orderMod(
    Authorization,
    orderId,
    reqCustName,
    reqCustId,
    reqDeptId,
    reqStaff,
    reqTel,
    reqAddr,
    reqAddrDetail,
    custId,
    deptId,
    inOutSctn,
    truckTypeCode,
    sComName,
    sSido,
    sGungu,
    sDong,
    sAddr,
    sAddrDetail,
    sDate,
    sStaff,
    sTel,
    sMemo,
    eComName,
    eSido,
    eGungu,
    eDong,
    eAddr,
    eAddrDetail,
    eDate,
    eStaff,
    eTel,
    eMemo,
    sLat,
    sLon,
    eLat,
    eLon,
    orderState,
    goodsName,
    goodsWeight,
    weightUnitCode,
    goodsQty,
    qtyUnitCode,
    sWayCode,
    eWayCode,
    mixYn,
    mixSize,
    returnYn,
    carTonCode,
    carTypeCode,
    chargeType,
    unitPriceType,
    unitCharge,
    distance,
    sTimeFreeYN,
    eTimeFreeYN,
    time,
    reqMemo,
    driverMemo,
    itemCode,
    sellCharge,
    sellFee,
    orderStopList,
    buyStaff,
    buyStaffTel,
    sellWayPointMemo,
    sellWayPointCharge,
    sellStayMemo,
    sellStayCharge,
    sellHandWorkMemo,
    sellHandWorkCharge,
    sellRoundMemo,
    sellRoundCharge,
    sellOtherAddMemo,
    sellOtherAddCharge,
    sellWeight,
    talkYn,
    call24Cargo,
    manCargo,
    oneCargo,
    call24Charge,
    manCharge,
    oneCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'sellCustName': reqCustName,
      'reqCustId': reqCustId,
      'reqDeptId': reqDeptId,
      'reqStaff': reqStaff,
      'reqTel': reqTel,
      'reqAddr': reqAddr,
      'reqAddrDetail': reqAddrDetail,
      'custId': custId,
      'deptId': deptId,
      'inOutSctn': inOutSctn,
      'truckTypeCode': truckTypeCode,
      'sComName': sComName,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sAddr': sAddr,
      'sAddrDetail': sAddrDetail,
      'sDate': sDate,
      'sStaff': sStaff,
      'sTel': sTel,
      'sMemo': sMemo,
      'eComName': eComName,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'eAddr': eAddr,
      'eAddrDetail': eAddrDetail,
      'eDate': eDate,
      'eStaff': eStaff,
      'eTel': eTel,
      'eMemo': eMemo,
      'sLat': sLat,
      'sLon': sLon,
      'eLat': eLat,
      'eLon': eLon,
      'orderState': orderState,
      'goodsName': goodsName,
      'goodsWeight': goodsWeight,
      'weightUnitCode': weightUnitCode,
      'goodsQty': goodsQty,
      'qtyUnitCode': qtyUnitCode,
      'sWayCode': sWayCode,
      'eWayCode': eWayCode,
      'mixYn': mixYn,
      'mixSize': mixSize,
      'returnYn': returnYn,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'chargeType': chargeType,
      'unitPriceType': unitPriceType,
      'unitCharge': unitCharge,
      'distance': distance,
      'sTimeFreeYN': sTimeFreeYN,
      'eTimeFreeYN': eTimeFreeYN,
      'time': time,
      'reqMemo': reqMemo,
      'driverMemo': driverMemo,
      'itemCode': itemCode,
      'sellCharge': sellCharge,
      'sellFee': sellFee,
      'orderStopList': orderStopList,
      'buyStaff': buyStaff,
      'buyStaffTel': buyStaffTel,
      'sellWayPointMemo': sellWayPointMemo,
      'sellWayPointCharge': sellWayPointCharge,
      'sellStayMemo': sellStayMemo,
      'sellStayCharge': sellStayCharge,
      'sellHandWorkMemo': sellHandWorkMemo,
      'sellHandWorkCharge': sellHandWorkCharge,
      'sellRoundMemo': sellRoundMemo,
      'sellRoundCharge': sellRoundCharge,
      'sellOtherAddMemo': sellOtherAddMemo,
      'sellOtherAddCharge': sellOtherAddCharge,
      'sellWeight': sellWeight,
      'talkYn': talkYn,
      'call24Cargo': call24Cargo,
      'manCargo': manCargo,
      'oneCargo': oneCargo,
      'call24Charge': call24Charge,
      'manCharge': manCharge,
      'oneCharge': oneCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/update/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> cancelOrder(
    Authorization,
    orderId,
    orderState,
    call24Cargo,
    oneCargo,
    manCargo,
    call24Charge,
    oneCharge,
    manCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'orderState': orderState,
      'call24Cargo': call24Cargo,
      'oneCargo': oneCargo,
      'manCargo': manCargo,
      'call24Charge': call24Charge,
      'oneCharge': oneCharge,
      'manCharge': manCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/cancel',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> stateOrder(
    Authorization,
    orderId,
    orderState,
    call24Cargo,
    oneCargo,
    manCargo,
    call24Charge,
    oneCharge,
    manCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'orderState': orderState,
      'call24Cargo': call24Cargo,
      'oneCargo': oneCargo,
      'manCargo': manCargo,
      'call24Charge': call24Charge,
      'oneCharge': oneCharge,
      'manCharge': manCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/state',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> orderAlloc(
    Authorization,
    orderId,
    sellCustId,
    sellDeptId,
    sellStaff,
    sellStaffTel,
    buyCustId,
    buyDeptId,
    buyStaff,
    buyStaffTel,
    allocCharge,
    allocFee,
    vehicId,
    driverId,
    carNum,
    carTonCode,
    carTypeCode,
    driverName,
    driverTel,
    driverMemo,
    wayPointMemo,
    wayPointCharge,
    stayMemo,
    stayCharge,
    handWorkMemo,
    handWorkCharge,
    roundMemo,
    roundCharge,
    otherAddMemo,
    otherAddCharge,
    payType,
    talkYn,
    buyDriverUpload,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'sellStaff': sellStaff,
      'sellStaffTel': sellStaffTel,
      'buyCustId': buyCustId,
      'buyDeptId': buyDeptId,
      'buyStaff': buyStaff,
      'buyStaffTel': buyStaffTel,
      'allocCharge': allocCharge,
      'allocFee': allocFee,
      'vehicId': vehicId,
      'driverId': driverId,
      'carNum': carNum,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'driverName': driverName,
      'driverTel': driverTel,
      'driverMemo': driverMemo,
      'wayPointMemo': wayPointMemo,
      'wayPointCharge': wayPointCharge,
      'stayMemo': stayMemo,
      'stayCharge': stayCharge,
      'handWorkMemo': handWorkMemo,
      'handWorkCharge': handWorkCharge,
      'roundMemo': roundMemo,
      'roundCharge': roundCharge,
      'otherAddMemo': otherAddMemo,
      'otherAddCharge': otherAddCharge,
      'payType': payType,
      'talkYn': talkYn,
      'buyDriverUpload': buyDriverUpload,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/alloc/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> orderAllocReg(
    Authorization,
    orderId,
    allocId,
    sellCustId,
    sellDeptId,
    sellStaff,
    sellStaffTel,
    vehicId,
    driverId,
    carNum,
    carTonCode,
    carTypeCode,
    driverName,
    driverTel,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'sellStaff': sellStaff,
      'sellStaffTel': sellStaffTel,
      'vehicId': vehicId,
      'driverId': driverId,
      'carNum': carNum,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'driverName': driverName,
      'driverTel': driverTel,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/alloc/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setAllocState(
    Authorization,
    orderId,
    allocId,
    allocState,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'allocState': allocState,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/alloc/state',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getReceipt(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderfile/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> sendLink(
    Authorization,
    orderId,
    linkType,
    linkStatus,
    fare,
    fee,
    command,
    payDate,
    chargeTypeCode,
    cargodsc,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'linkType': linkType,
      'linkStatus': linkStatus,
      'fare': fare,
      'fee': fee,
      'command': command,
      'payDate': payDate,
      'chargeTypeCode': chargeTypeCode,
      'cargodsc': cargodsc,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderLink/write/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getLink(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderLink/list/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> cancelLink(
    Authorization,
    orderId,
    allocId,
    command,
    linkType,
    linkStatus,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'command': command,
      'linkType': linkType,
      'linkStatus': linkStatus,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderLink/write/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> cancelAllLink(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/orderLink/cancel/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> confirmNewLink(
    Authorization,
    linkOrderId,
    linkAllocCharge,
    linkCode,
    linkCarNum,
    linkCarType,
    linkCarTon,
    linkDriverName,
    linkDriverTel,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'linkOrderId': linkOrderId,
      'linkAllocCharge': linkAllocCharge,
      'linkCode': linkCode,
      'linkCarNum': linkCarNum,
      'linkCarType': linkCarType,
      'linkCarTon': linkCarTon,
      'linkDriverName': linkDriverName,
      'linkDriverTel': linkDriverTel,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/confirmLink',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> modNewLink(
    Authorization,
    orderId,
    linkCharge,
    orderState,
    linkId,
    allocChargeYn,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'linkCharge': linkCharge,
      'orderState': orderState,
      'linkId': linkId,
      'allocChargeYn': allocChargeYn,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/modLink',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> cancelNewLink(
    Authorization,
    orderId,
    linkCharge,
    orderState,
    linkId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'linkCharge': linkCharge,
      'orderState': orderState,
      'linkId': linkId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/cancelLink',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> statusNewLink(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/linkStatus',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> rpaLinkInfo(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/linkInfo',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> currentNewLink(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/linkCurrent',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> currentNewLinkSub(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/rpa/getOrderStatusSub',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> currentNewLinkAlloc(
    Authorization,
    allocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'allocId': allocId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/rpa/getOrderStatusAlloc',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> rpaUseYn(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/rpa/useYn',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCar(
    Authorization,
    carNum,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'carNum': carNum};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/vehic',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getAddr(
    Authorization,
    addrName,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'addrName': addrName};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/addr',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getLatLon(
    Authorization,
    addrName,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'addrName': addrName};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/v2/local/search/address.json',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> regAddr(
    Authorization,
    addrSeq,
    addrName,
    addr,
    addrDetail,
    lat,
    lon,
    staffName,
    staffTel,
    orderMemo,
    sido,
    gungu,
    dong,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'addrSeq': addrSeq,
      'addrName': addrName,
      'addr': addr,
      'addrDetail': addrDetail,
      'lat': lat,
      'lon': lon,
      'staffName': staffName,
      'staffTel': staffTel,
      'orderMemo': orderMemo,
      'sido': sido,
      'gungu': gungu,
      'dong': dong,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/addr/write',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> deleteAddr(
    Authorization,
    addrSeq,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'addrSeq': addrSeq};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/addr/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCustomer(
    Authorization,
    sellBuySctn,
    custName,
    telnum,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sellBuySctn': sellBuySctn,
      'custName': custName,
      'telnum': telnum,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCustUser(
    Authorization,
    custId,
    deptId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'custId': custId,
      'deptId': deptId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCustUser2(
    Authorization,
    custId,
    deptId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'custId': custId,
      'deptId': deptId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/list2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCost(
    Authorization,
    sellCustId,
    sellDeptId,
    buyCustId,
    buyDeptId,
    sSido,
    sGungu,
    eSido,
    eGungu,
    carTonCode,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'buyCustId': buyCustId,
      'buyDeptId': buyDeptId,
      'sSido': sSido,
      'sGungu': sGungu,
      'eSido': eSido,
      'eGungu': eGungu,
      'carTonCode': carTonCode,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/customer/frtCost',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getDeptList(
    Authorization,
    sellCustId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'sellCustId': sellCustId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/dept/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getMonitorOrder(
    Authorization,
    fromDate,
    toDate,
    deptId,
    userId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'deptId': deptId,
      'userId': userId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/monitor/arrangeOrder/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getMonitorDeptProfit(
    Authorization,
    fromDate,
    toDate,
    deptId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'deptId': deptId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/monitor/deptProfit/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getMonitorCustProfit(
    Authorization,
    fromDate,
    toDate,
    deptId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'deptId': deptId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/monitor/custProfit/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOption(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/user/option',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOptionRequest(
    Authorization,
    reqYn,
    reqCustId,
    reqDeptId,
    reqStaffId,
    reqTel,
    reqAddr,
    reqAddrDetail,
    reqMemo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'reqYn': reqYn,
      'reqCustId': reqCustId,
      'reqDeptId': reqDeptId,
      'reqStaffId': reqStaffId,
      'reqTel': reqTel,
      'reqAddr': reqAddr,
      'reqAddrDetail': reqAddrDetail,
      'reqMemo': reqMemo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/option/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOptionAddr(
    Authorization,
    sAreaYn,
    sComName,
    sSido,
    sGungu,
    sDong,
    sAddr,
    sAddrDetail,
    sStaff,
    sTel,
    sMemo,
    sLat,
    sLon,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sAreaYn': sAreaYn,
      'sComName': sComName,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sAddr': sAddr,
      'sAddrDetail': sAddrDetail,
      'sStaff': sStaff,
      'sTel': sTel,
      'sMemo': sMemo,
      'sLat': sLat,
      'sLon': sLon,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/option/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOptionCargo(
    Authorization,
    goodsYn,
    inOutSctn,
    truckTypeCode,
    carTypeCode,
    carTonCode,
    itemCode,
    goodsName,
    goodsWeight,
    sWayCode,
    eWayCode,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'goodsYn': goodsYn,
      'inOutSctn': inOutSctn,
      'truckTypeCode': truckTypeCode,
      'carTypeCode': carTypeCode,
      'carTonCode': carTonCode,
      'itemCode': itemCode,
      'goodsName': goodsName,
      'goodsWeight': goodsWeight,
      'sWayCode': sWayCode,
      'eWayCode': eWayCode,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/option/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOptionCharge(
    Authorization,
    sellYn,
    unitPriceType,
    sellCharge,
    unitCharge,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sellYn': sellYn,
      'unitPriceType': unitPriceType,
      'sellCharge': sellCharge,
      'unitCharge': unitCharge,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/option/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOptionTrans(
    Authorization,
    buyYn,
    buyCharge,
    driverMemo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'buyYn': buyYn,
      'buyCharge': buyCharge,
      'driverMemo': driverMemo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/user/option/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsUnitCharge(
    Authorization,
    ChargeType,
    sellCustId,
    sellDeptId,
    sSido,
    sGungu,
    sDong,
    eSido,
    eGungu,
    eDong,
    carTonCode,
    carTypeCode,
    sDate,
    eDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'ChargeType': ChargeType,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'sDate': sDate,
      'eDate': eDate,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/tms/unitcharge.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsUnitCompCharge(
    Authorization,
    ChargeType,
    sellCustId,
    sellDeptId,
    buyCustId,
    buyDeptId,
    sSido,
    sGungu,
    sDong,
    sComName,
    eSido,
    eGungu,
    eDong,
    carTonCode,
    carTypeCode,
    sDate,
    eDate,
    eComName,
    unitPriceType,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'ChargeType': ChargeType,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
      'buyCustId': buyCustId,
      'buyDeptId': buyDeptId,
      'sSido': sSido,
      'sGungu': sGungu,
      'sDong': sDong,
      'sComName': sComName,
      'eSido': eSido,
      'eGungu': eGungu,
      'eDong': eDong,
      'carTonCode': carTonCode,
      'carTypeCode': carTypeCode,
      'sDate': sDate,
      'eDate': eDate,
      'eComName': eComName,
      'unitPriceType': unitPriceType,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/tms/unitCompCharge.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsUnitCnt(
    Authorization,
    buyCustId,
    buyDeptId,
    sellCustId,
    sellDeptId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'buyCustId': buyCustId,
      'buyDeptId': buyDeptId,
      'sellCustId': sellCustId,
      'sellDeptId': sellDeptId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/order/unitCnt.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsPointResult(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/point/selectPointResult',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsUserPointInfo(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/point/selectUserPointInfo',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTmsUserPointList(
    Authorization,
    pageNo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'pageNo': pageNo};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/point/selectUserPointList',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getLinkFlag(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/order/rpa/getLinkFlag',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotice(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/notice/board/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotice_new(
    Authorization,
    isNew,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'isNew': isNew};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/notice/board/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotification(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/cust/notice/push/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getJuso(
    confmKey,
    currentPage,
    countPerPage,
    keyword,
    resultType,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'confmKey': confmKey,
      'currentPage': currentPage,
      'countPerPage': countPerPage,
      'keyword': keyword,
      'resultType': resultType,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/addrlink/addrLinkApi.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getGeoAddress(
    Authorization,
    query,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'query': query};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/v2/local/search/address.json',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getSidoArea(sido) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'sido': sido};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/area/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> findId(
    userName,
    userPhone,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'userName': userName,
      'userPhone': userPhone,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/search/id',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> findPwd(
    userId,
    userName,
    userPhone,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cust/search/pw',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTermsUserAgree(
    Authorization,
    userId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'userId': userId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/AgreeUserIndex',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTermsTelAgree(
    Authorization,
    tel,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'tel': tel};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/AgreeTelIndex',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> insertTermsAgree(
    Authorization,
    userName,
    tel,
    necessary,
    selective,
    termsVersion,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'userId': userName,
      'tel': tel,
      'necessary': necessary,
      'selective': selective,
      'version': termsVersion,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/insertTermsAgree',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> updateTermsAgree(
    Authorization,
    userId,
    necessary,
    selective,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'userId': userId,
      'necessary': necessary,
      'selective': selective,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/updateTermsAgree',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getJibun(fullAddr) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'fullAddr': fullAddr};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/jibunlist/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getInsure(
    buyAmt,
    sDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'buyAmt': buyAmt,
      'sDate': sDate,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/insure/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
