import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'juso_rest.g.dart';

@RestApi(baseUrl: JUSO_URL)
abstract class JusoRest {
  factory JusoRest(Dio dio,{String baseUrl}) = _JusoRest;

  /**
   * 주소 검색
   */
  @FormUrlEncoded()
  @POST(URL_JUSO)
  Future<HttpResponse> getJuso(@Field("confmKey") String? confmKey,
      @Field("currentPage") String? currentPage,
      @Field("countPerPage") String? countPerPage,
      @Field("keyword") String? keyword,
      @Field("resultType") String? resultType);

}