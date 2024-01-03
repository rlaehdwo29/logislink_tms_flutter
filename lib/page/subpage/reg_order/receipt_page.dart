import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/order_model.dart';
import 'package:logislink_tms_flutter/common/model/receipt_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/page/subpage/receipt_detail_page.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/provider/receipt_service.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceiptPage extends StatefulWidget{
  OrderModel? order_vo;

  ReceiptPage({Key? key,this.order_vo}):super(key: key);

  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage>{
  final controller = Get.find<App>();
  final receiptList = List.empty(growable: true).obs;
  final ImagePicker? _picker = ImagePicker();
  dynamic _pickImageError;
  final _mediaFileList = List.empty(growable: true).obs;
  ProgressDialog? pr;

  Future<void> _displayPickImageDialog(BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  Future<void> showAlbum(ImageSource imageSource) async {
    await _displayPickImageDialog(context,
            (double? maxWidth, double? maxHeight, int? quality) async {
          try {
            final XFile? pickedFile = await _picker?.pickImage(
              source: imageSource,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              imageQuality: 50,
            );
            if (pickedFile == null) return null;

          } catch (e) {
            setState(() {
              _pickImageError = e;
            });
          }
        });
  }

  Future<void> showPermissionDialog(ImageSource imageSource) async {
    var permission = "";
    if(imageSource == ImageSource.camera) {
      permission = "카메라";
    }else if(imageSource == ImageSource.gallery){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        if (info.version.sdkInt >= 29) {
          permission = "사진 및 동영상";
        }else{
          permission = "저장소";
        }
      }else{
        permission = "사진";
      }
    }else {
      permission = "해당";
    }
    return openOkBox(
        context,
        "${permission} 권한을 허용으로 설정해주세요.",
        Strings.of(context)?.get("confirm")??"Not Found",
            () async {
          Navigator.of(context).pop(false);
          await openAppSettings();
        }
    );
  }

  Future<void> checkPermission(ImageSource imageSource) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      if (info.version.sdkInt >= 29) {
        var permissionStatus;
        if(imageSource == ImageSource.camera){
          permissionStatus = await Permission.camera.status;
        }else{
          permissionStatus = await Permission.photos.status;
        }
        if (permissionStatus != PermissionStatus.granted) {
          if (permissionStatus == PermissionStatus.permanentlyDenied || permissionStatus == PermissionStatus.denied) {
            showPermissionDialog(imageSource);
          } else {
            if(imageSource == ImageSource.camera){
              await Permission.camera.request();
            }else{
              await Permission.photos.request();
            }
          }
        } else {
          await showAlbum(imageSource);
        }

      } else {
        var permissionStatus;
        if(imageSource == ImageSource.camera){
          permissionStatus = await Permission.camera.status;
        }else{
          permissionStatus = await Permission.storage.status;
        }

        if (permissionStatus != PermissionStatus.granted) {
          if (permissionStatus == PermissionStatus.permanentlyDenied || permissionStatus == PermissionStatus.denied) {
            showPermissionDialog(imageSource);
          } else {
            if(imageSource == ImageSource.camera){
              await Permission.camera.request();
            }else{
              await Permission.storage.request();
            }
          }
        } else {
          await showAlbum(imageSource);
        }
      }
    }else{
      var permissionStatus;
      if(imageSource == ImageSource.camera){
        permissionStatus = await Permission.camera.status;
      }else{
        permissionStatus = await Permission.photos.status;
      }
      if (permissionStatus != PermissionStatus.granted) {
        if (permissionStatus == PermissionStatus.permanentlyDenied || permissionStatus == PermissionStatus.denied) {
          showPermissionDialog(imageSource);
        } else {
          if(imageSource == ImageSource.camera){
            await Permission.camera.request();
          }else{
            await Permission.photos.request();
          }
        }
      } else {
        await showAlbum(imageSource);
      }
    }
  }

  Future<void> getReceiptList () async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    receiptList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getReceipt(app.authorization,  widget.order_vo?.orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("receipt_page.dart getReceipt() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<ReceiptModel> itemsList = list.map((i) => ReceiptModel.fromJSON(i)).toList();
          receiptList?.addAll(itemsList);
        }
      }else{
        receiptList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("receipt_page.dart getReceipt() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("receipt_page.dart getReceipt() Error Default => ");
          break;
      }
    });
  }

  Widget getReceipt() {
    return Expanded(
        child: receiptList.isNotEmpty ? Container(
            padding: const EdgeInsets.all(5.0),
            color: main_background,
            child: GridView.builder(
              itemCount: receiptList.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                childAspectRatio: (1 / .90),
                mainAxisSpacing: 8, //수평 Padding
                crossAxisSpacing: 8, //수직 Padding
              ),
              itemBuilder: (BuildContext context, int index) {
                var filename =
                    SERVER_URL + RECEIPT_PATH + receiptList?[index].fileName;
                return InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ReceiptDetailPage(item: receiptList[index])
                            ));
                          },
                          child: Image.network(
                            filename,
                            fit: BoxFit.cover,
                          )
                      );
              },
            )) : const SizedBox()
    );
  }

  Widget getReceiptFuture() {
    final receiptService = Provider.of<ReceiptService>(context);
    return FutureBuilder(
        future: receiptService.getReceipt(context, widget.order_vo?.orderId),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            print("getReceiptFuture() has Data! => ${snapshot.data}");
            if(receiptList.isNotEmpty) receiptList.value = List.empty(growable: true);
            receiptList.addAll(snapshot.data);
            for(var receiptItem in receiptList){
              XFile _xFile = XFile(receiptItem.filePath,name: receiptItem.fileName);
            }
            return getReceipt();
          } else if(snapshot.hasError) {
            print("getReceiptFuture() Error! => ${snapshot.error}");
            return Container();
          }
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':200});
          return false;
        } ,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
                centerTitle: true,
                title: Center(
                  child: Text(
                    "인수증",
                    style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
                  )
                ),
                toolbarHeight: 50.h,
                leading: IconButton(
                  onPressed: (){
                    Navigator.of(context).pop({'code':200});
                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.arrow_back, size: 24.h, color: styleWhiteCol),
                ),
              ),
          body: SafeArea(
             child: Container(
                 width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                 height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height,
              child: getReceiptFuture()
             )
          ),
        )
    );
  }

}
typedef OnPickImageCallback = void Function(double? maxWidth, double? maxHeight, int? quality);