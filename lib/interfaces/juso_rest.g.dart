// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'juso_rest.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _JusoRest implements JusoRest {
  _JusoRest(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'https://www.juso.go.kr';
  }

  final Dio _dio;

  String? baseUrl;

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
