import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/cust_user_model.dart';
import 'package:logislink_tms_flutter/common/model/sido_area_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:dio/dio.dart';

class ShowCodeDialogWidget {
  final BuildContext context;
  final String mTitle;
  final String codeType;
  final String? mFilter;
  final void Function(CodeModel?,String) callback;


  ShowCodeDialogWidget({required this.context, required this.mTitle, required this.codeType,this.mFilter, required this.callback});

  List<CodeModel> getCodeList() {
    List<CodeModel>? mList = SP.getCodeList(codeType);
    if (codeType == Const.CHARGE_TYPE_CD) {
      mList?.removeAt(1);
    }
    if (codeType == Const.ORDER_STATE_CD) {
      mList?.insert(0, CodeModel(code: "",codeName:  "전체"));
    }
    if (codeType == Const.ALLOC_STATE_CD) {
      mList?.insert(0, CodeModel(code: "",codeName:  "전체"));
    }
    if (codeType == Const.DRIVER_STATE) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "01",codeName:  "배차"));
      mList.add(CodeModel(code: "12",codeName:  "입차"));
      mList.add(CodeModel(code: "04",codeName:  "출발"));
      mList.add(CodeModel(code: "05",codeName:  "도착"));
      mList.add(CodeModel(code: "21",codeName:  "취소"));
    }
    if (codeType == Const.ORDER_SEARCH) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "carNum",codeName:  "차량번호"));
      mList.add(CodeModel(code: "driverName", codeName: "차주명"));
      mList.add(CodeModel(code: "sellCustName", codeName: "거래처명"));
    }
    if (codeType == Const.USE_YN) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "Y",codeName:  "사용"));
      mList.add(CodeModel(code: "N",codeName:  "미사용"));
    }
    return mList!;
  }

  Future<List<CodeModel>> getSidoArea() async {
    List<CodeModel> mList = List.empty(growable: true);
    Logger logger = Logger();
    await DioService.dioClient(header: true).getSidoArea(mFilter).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getSidoArea() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<SidoAreaModel> itemsList = list.map((i) => SidoAreaModel.fromJSON(i)).toList();
            for(var item in itemsList) {
              mList.add(CodeModel(code: item.areaCd,codeName: item.sigun));
            }
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getSidoArea() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getSidoArea() getOrder Default => ");
          break;
      }
    });
    return mList;
  }

  Future<List<CodeModel>> getDeptUser() async {
    final controller = Get.find<App>();
    UserModel? user = await controller.getUserInfo();
    List<CodeModel> mList = List.empty(growable: true);
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCustUser(user.authorization,user.custId,mFilter
    ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getDeptUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<CustUserModel> itemsList = list.map((i) => CustUserModel.fromJSON(i)).toList();
            mList.add(CodeModel(code: "",codeName: "전체"));
            for(var item in itemsList) {
              mList.add(CodeModel(code: item.userId,codeName: item.userName));
            }
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getDeptUser() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getDeptUser() getOrder Default => ");
          break;
      }
    });
    return mList;
  }

  Future<List<CodeModel>> getCodeFilter() async {
    List<CodeModel> mList = List.empty(growable: true);
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCodeDetail(codeType,mFilter).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCodeFilter() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if (_response.resultMap?["data"] != null) {
            var list = _response.resultMap?["data"] as List;
            List<CodeModel> itemsList = list.map((i) => CodeModel.fromJSON(i)).toList();
            mList.addAll(itemsList);
          }
        }else{
          openOkBox(context,"${_response.resultMap?["msg"]}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getCodeFilter() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCodeFilter() getOrder Default => ");
          break;
      }
    });
    return mList;
  }

  Future<void> showDialog() async {
    var mList = List.empty(growable: true);
    if(mFilter?.isEmpty == true) {
      mList.addAll(getCodeList());
    } else {
      if(codeType == Const.SIDO_AREA) {
        mList = await getSidoArea();
      }else if(codeType == Const.DEPT_USER) {
        mList = await getDeptUser();
      }else{
        mList = await getCodeFilter();
      }
    }

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              mTitle,
              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.of(context).pop();
                      //SystemNavigator.pop();
                    });
                  },
                  icon: const Icon(Icons.close, size: 30)
              )
            ],
            automaticallyImplyLeading: false,
          ),
          body: GridView.builder(
              itemCount: mList?.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                childAspectRatio: (1 / .65),
                mainAxisSpacing: 2, //수평 Padding
                crossAxisSpacing: 2, //수직 Padding
              ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      callback(mList?[index], codeType);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.of(context).pop();
                        //SystemNavigator.pop();
                      });
                    },
                    child: Container(
                        height: CustomStyle.getHeight(70.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                ),
                                right: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Center(
                          child: Text(
                            "${mList?[index].codeName}",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01,
                                font_weight: FontWeight.w600),
                          ),
                        )
                    )
                );
              }
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: "Barrier",
      barrierColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}