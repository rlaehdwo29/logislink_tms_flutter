import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'kakao_rest.g.dart';

@RestApi(baseUrl: KAKAO_URL)
abstract class KakaoRest {
  factory KakaoRest(Dio dio,{String baseUrl}) = _KakaoRest;

  /**
   * 주소 검색
   */
  @FormUrlEncoded()
  @POST(URL_KAKAO_ADDRESS)
  Future<HttpResponse> getGeoAddress(
      @Header("Authorization") String? Authorization,
      @Field("query") String? query
      );


}