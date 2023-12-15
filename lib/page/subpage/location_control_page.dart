import 'dart:collection';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/location_model.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class LocationControlPage extends StatefulWidget {

  OrderModel order_vo;

  LocationControlPage({Key? key,required this.order_vo}):super(key:key);

  _LocationControlPageState createState() => _LocationControlPageState();
}


class _LocationControlPageState extends State<LocationControlPage>{
  late KakaoMapController? mapController;

  final controller = Get.find<App>();

  final mData = OrderModel().obs;
  final mList = List.empty(growable: true).obs;

  final isRefresh = true.obs;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  ProgressDialog? pr;


  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      pr = Util.networkProgress(context);
      if(widget.order_vo != null) {
        mData.value = widget.order_vo;
      }

      await initMap();
    });

  }

  Future<void> initMap() async {
    await getLocation();
  }

  Future<void> getLocation() async {
    if(!isRefresh.value) {
      Util.toast("새로고침은 10초에 한 번만 가능합니다.");
      return;
    }

    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    mList.value = List.empty(growable: true);
    await pr?.show();
    await DioService.dioClient(header: true).getLocation(
        user.authorization,
        mData.value.orderId
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getLocation() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,"${_response.resultMap}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            try {
              var list = _response.resultMap?["data"] as List;
              List<LocationModel> itemsList = list.map((i) => LocationModel.fromJSON(i)).toList();
              if(itemsList.length > 0){
                mList.addAll(itemsList);
              }
            } catch (e) {
              print("getLocation() List Add Error => $e");
              Util.toast("위치 정보를 저장시키는 중에 오류가 발생하였습니다.");
            }
          } else {
            Util.toast("위치 정보를 가져오는 중에 오류가 발생하였습니다.");
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getLocation() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getLocation() getOrder Default => ");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return  WillPopScope(
        onWillPop: () async {
          return Future((){
            FBroadcast.instance().broadcast(Const.INTENT_ORDER_DETAIL_REFRESH);
            return true;
          });
        } ,
        child: Scaffold(
          backgroundColor: styleWhiteCol,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
              child: AppBar(
                centerTitle: true,
                title: Text(
                    Strings.of(context)?.get("location_control_title")??"위치관제_",
                    style: CustomStyle.appBarTitleFont(
                        styleFontSize16, styleWhiteCol)),
                leading: IconButton(
                  onPressed: () {
                    FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                    Navigator.of(context).pop();
                  },
                  color: styleWhiteCol,
                  icon: const Icon(Icons.arrow_back),
                ),
              )),
          body: SafeArea(
              child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
                    child: Container(
                      child: KakaoMap(
                        onMapCreated: ((controller) async {

                          setState(() {
                            print("응애응애 => ${widget.order_vo.sAddr} // ${widget.order_vo.sAddrDetail} // ${widget.order_vo.sDong}");
                            List<LatLng> bounds = List.empty(growable: true);
                            if(widget.order_vo.sLat.isNull != true && widget.order_vo.sLon.isNull != null) {
                              bounds.add(LatLng(widget.order_vo.sLat!, widget.order_vo.sLon!));
                              markers.add(Marker(
                                  markerId: widget.order_vo.sComName ?? "상차지",
                                  markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/blue_b.png',
                                  latLng: LatLng(widget.order_vo.sLat!, widget.order_vo.sLon!),
                                  infoWindowContent: '<div style="float:center; margin:5px; font: bold normal 0.7em 돋움체;">${widget.order_vo.sComName??"상차지"}</div>',
                                /*'<div class="wrap">' +
                                      '    <div class="info">' +
                                      '        <div class="title" style="float:center; margin:5px; font: bold normal 0.7em 돋움체;">' +
                                      '            ${widget.order_vo.sComName ?? "상차지"}' +
                                      '            <div class="close" onclick="closeOverlay()" title="닫기"></div>' +
                                      '        </div>' +
                                      '        <div class="body">' +
                                      '            <div class="desc">' +
                                      '                <div class="ellipsis" style="float:center; margin:5px; font: normal 0.7em 돋움체;">${widget.order_vo.sAddr}</div>' +
                                      '                <div class="jibun ellipsis" style="float:center; margin:5px; font: normal 0.7em 돋움체;">${widget.order_vo.sAddrDetail}</div>' +
                                      '            </div>' +
                                      '        </div>' +
                                      '    </div>' +
                                      '</div>'*/
                              ));
                            }

                            if(widget.order_vo.eLat.isNull != true && widget.order_vo.eLon.isNull != null) {
                              bounds.add(LatLng(widget.order_vo.eLat!, widget.order_vo.eLon!));
                              markers.add(Marker(
                                markerId: widget.order_vo.eComName??"하차지",
                                markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/red_b.png',
                                latLng: LatLng(widget.order_vo.eLat!, widget.order_vo.eLon!),
                                infoWindowContent: '<div style="float:center; margin:5px; font: bold normal 0.7em 돋움체;">${widget.order_vo.eComName??"하차지"}</div>',
                                /*
                                * '<div class="wrap">' +
                                    '    <div class="info">' +
                                    '        <div class="title" style="float:center; margin:5px; font: bold normal 0.7em 돋움체;">' +
                                    '            ${widget.order_vo.eComName ?? "하차지"}' +
                                    '            <div class="close" onclick="closeOverlay()" title="닫기"></div>' +
                                    '        </div>' +
                                    '        <div class="body">' +
                                    '            <div class="desc">' +
                                    '                <div class="ellipsis" style="float:center; margin:5px; font: normal 0.7em 돋움체;">${widget.order_vo.eAddr}</div>' +
                                    '                <div class="jibun ellipsis" style="float:center; margin:5px; font: normal 0.7em 돋움체;">${widget.order_vo.eAddrDetail}</div>' +
                                    '            </div>' +
                                    '        </div>' +
                                    '    </div>' +
                                    '</div>'*/
                              ));
                            }

                            // 이동 경로 표시
                            polylines.add(
                              Polyline(
                                polylineId: 'polyline_${polylines.length}',
                                points: [
                                  LatLng(widget.order_vo.sLat!, widget.order_vo.sLon!),
                                  LatLng(widget.order_vo.eLat!, widget.order_vo.eLon!),
                                ],
                                strokeColor: Colors.red,
                              ),
                            );

                            mapController = controller;
                            //mapController?.addOverlayMapTypeId(MapType.traffic); //교통정보
                            mapController?.fitBounds(bounds);
                            mapController?.setBounds();
                          });

                        }),

                        currentLevel: 18,
                        center: LatLng(35.81588719434526, 128.10472746046923),
                        markers: markers.toList(),
                        zoomControl: false,
                        polylines: polylines.toList(),

                        onMarkerTap: (markerId, latLng, zoomLevel) {
                          setState(() {
                            mapController?.setLevel(zoomLevel);
                            mapController?.panTo(latLng);
                          });
                        },
                      ),
                    ),
                  )
              )
          ),
        )
    );


  }
}