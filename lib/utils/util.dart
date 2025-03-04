import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/common_util.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/notice_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/provider/dio_service.dart';
import 'package:logislink_tms_flutter/utils/sp.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:dio/dio.dart';

class Util {


  static String booleanToYn(bool value) {
    if (value) {
      return "Y";
    } else {
      return "N";
    }
  }

  static toast(String? msg) {
    return Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: text_color_01,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static Future<String> getVersionName() async {
    try {
      var package_info = await PackageInfo.fromPlatform();
      return package_info.version;
    } catch (e) {
    return Const.APP_VERSION;
    }
  }

  static Future<void> setEventLog(String menuUrl, String menuName, {String? loginYn}) async {
    Logger logger = Logger();
    UserModel? user = await App().getUserInfo();
    var app_version = await Util.getVersionName();
    await DioService.dioClient(header: true).setEventLog(
        user.userId,
        menuUrl,
        menuName,
        "T${Platform.isAndroid ? "A" : "I"}",
        app_version,
        loginYn??"N"
    ).then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("setEventLog() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if(response.resultMap?["result"] == true) {

        }else{
          toast(response.resultMap?["msg"]);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setEventLog() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setEventLog() Error Default => ");
          break;
      }
    });
  }

  static ProgressDialog? networkProgress(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal,
        isDismissible: false,
        showLogs: false,
        customBody: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(CustomStyle.getWidth(8.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: CustomStyle.getWidth(50.0),
                  height: CustomStyle.getHeight(50.0),
                  child: Container(
                      child: CircularProgressIndicator(
                        // valueColor: AlwaysStoppedAnimation<Color>(styleBaseCol1),
                      )),
                )
              ],
            )));
    pr.style(backgroundColor: Colors.transparent, elevation: 0.0);
    // pr.style(
    //     message: null,

    //     progressWidgetAlignment: Alignment.center,
    //     progressWidget: Container(
    //         color: Colors.transparent,
    //         padding: EdgeInsets.all(8.0),
    //         child: CircularProgressIndicator()),
    //     messageTextStyle: CustomStyle.baseFont());
    return pr;
  }

  static snackbar(BuildContext context, String msg){
    final controller = Get.find<App>();
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: CustomStyle.getWidth(20.0),
            right: CustomStyle.getWidth(20.0),
            bottom: CustomStyle.getHeight(20.0),
          ),
          padding: EdgeInsets.only(
            left: CustomStyle.getWidth(10.0),
            right: CustomStyle.getWidth(10.0),
            top: CustomStyle.getHeight(14.0),
            bottom: CustomStyle.getHeight(14.0),
          ),
          backgroundColor: controller.renew_value.value ? renew_main_color2 : main_color,
          content: SizedBox(
            child: Text(
              msg,
              style: CustomStyle.whiteFont(),
            ),
          ),
        )
    );
  }

  static String encryption(String pwd) {
    var bytes = utf8.encode(pwd); // data being hashed
    Digest digest = sha256.convert(bytes);
    var hash = digest.bytes;
    StringBuffer hexString = StringBuffer();
    for (int i = 0; i < hash.length; i++) {
      String hex =(0xff & hash[i]).toRadixString(16);
      if(hex.length == 1) hexString.write('0');
      hexString.write(hex);
    }

    return hexString.toString();
  }

  static Future<String> dataEncryption(String value) async {

    String file = await rootBundle.loadString('assets/raw/key.txt');
    var b = utf8.encode(file);
    var keyBytes = Uint8List(16);
    String mIv = "";

    for(var i in keyBytes){
      mIv = mIv + i.toString();
    }

    var len = b.length;

    if(len > keyBytes.lengthInBytes) len = keyBytes.length;
    List.copyRange(b,0, keyBytes, 0, len);

    final key = enc.Key.fromUtf8(file);
    final iv = enc.IV.fromUtf8(mIv);

    final encrypter = enc.Encrypter(enc.AES(key,mode: enc.AESMode.cbc,padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(value, iv: iv);
    //var result = await Aespack.encrypt(value, file, mIv);
    return encrypted.base64;
  }

  static Future<String> dataDecode(String value) async {

    String file = await rootBundle.loadString('assets/raw/key.txt');
    var b = utf8.encode(file);
    var keyBytes = Uint8List(16);
    String mIv = "";

    for(var i in keyBytes){
      mIv = mIv + i.toString();
    }

    var len = b.length;

    if(len > keyBytes.lengthInBytes) len = keyBytes.length;
    List.copyRange(b,0, keyBytes, 0, len);

    final key = enc.Key.fromUtf8(file);
    final iv = enc.IV.fromUtf8(mIv);

    final encrypter = enc.Encrypter(enc.AES(key,mode: enc.AESMode.cbc,padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(value, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  static String? makeString(String? _string){
    if(_string == null || _string == ""){
      return "-";
    }
    return _string;
  }


  static String makeDistance(num? d) {
    int? result = d?.round();
    if(d == 0) {
      return "";
    }else{
      return "${result}km";
    }
  }

  static String makeTime(int? min) {
    if(min == 0) {
      return "0분";
    }
    int hour = Duration(minutes: min!).inHours;
    int minute = Duration(minutes: min).inMinutes - Duration(hours: hour).inMinutes;
    String time = "";
    if(hour == 0) {
      time = "$minute분";
    }else{
      time = "$hour시간$minute분";
    }
    return time;
  }

  static bool ynToBoolean(String? value) {
    return value != null ? "Y" == value : false;
  }


  static Color getOrderStateColor(String? state) {
    switch(state) {
      case "01":
      case "12":
        return order_state_01;
      case "04":
        return order_state_04;
      case "05":
        return order_state_05;
      case "09":
        return order_state_09;
      default:
        return order_state_01;
    }
  }

  static String getTextDate(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  static String getDate(DateTime? calendar){
    return DateFormat("yyyyMMdd").format(calendar!);
  }

  static Future<void> settingInfo() async {
    final controller = Get.find<App>();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // Device 정보 세팅
    Map<String,dynamic> device = <String, dynamic>{};
    if (Platform.isAndroid) {
      AndroidDeviceInfo info  = await deviceInfo.androidInfo;
      device = {
        "model":info.model,
        "deviceOs": "Android ${info.version.sdkInt}",
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      device = {
        "model":info.data['utsname']['machine'],
        "deviceOs": "${info.systemName} ${info.systemVersion}"
      };
    } else {
      device = {
        "model": Platform.isLinux?"Linux":Platform.isMacOS?"Mac":Platform.isWindows?"Window":"unknown",
        "deviceOs": "unknown"
      };
    }
    controller.device_info.value = device;

    // App 정보 세팅
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String,dynamic> app = {
      "appName":packageInfo.appName,
      "packageName":packageInfo.packageName,
      "version":packageInfo.version,
      "buildNumber":packageInfo.buildNumber
    };
    controller.app_info.value = app;
  }

  static String getInCodeCommaWon(String? won) {
    if (won == null || won == "" || won.length > 8) return "0";
    double inValues = double.parse(won);
    NumberFormat Commas = NumberFormat("#,###");
    return Commas.format(inValues);
  }

  static String getPercent(int val1, int val2) {
    return "${Util.getInCodePercent(val1,val2)} %";
  }

  static double getInCodePercent(int val1, int val2){
    if(val1 == 0 || val2 == 0) {
      return 0.0;
    }
    double result = ((val1 / val2 * 1000) / 10.0).roundToDouble();
    return result;
  }

  static call(String? call_Num){
    launch("tel://${call_Num}");
  }

  static String pointDate(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    if(date == null) {
      return "00:00:00";
    }
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }
    return "${DateFormat("yy-MM-dd HH:mm:ss").format(d!)}";
  }

  static String splitSDate(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    if(date == null) {
      return "00:00:00";
    }
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }

    if(DateFormat("HH:mm:ss").format(d!) == "00:00:00") {
      return "${DateFormat("MM.dd").format(d!)} 오늘";
    }else{
      return DateFormat("MM.dd HH:mm").format(d!);
    }
  }

  static String splitSDateType2(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    if(date == null) {
      return "00:00:00";
    }
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }
      return DateFormat("MM-dd HH:mm").format(d!);
  }

  static String splitEDate(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    if(date == null) {
      return "00:00:00";
    }
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }

    if(DateFormat("HH:mm:ss").format(d!) == "00:00:00") {
      return "${DateFormat("MM.dd").format(d!)} 당일";
    }else{
      return DateFormat("MM.dd HH:mm").format(d!);
    }
  }

  static String splitEDateType2(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    if(date == null) {
      return "00:00:00";
    }
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }

      return DateFormat("MM-dd HH:mm").format(d!);
  }

  static String splitDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyy-MM-dd").format(DateTime.parse(d));
  }

  static String splitTime(String date) {
    if(date == ""){
     return "00:00";
    }else {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss", 'ko');
      DateTime dateTime = DateTime.parse(date);
      String d = dateFormat.format(dateTime);
      return DateFormat("HH:mm").format(DateTime.parse(d));
    }
  }

  static String mergeAllDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMddHHmmss").format(DateTime.parse(d));
  }

  static String mergeDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMdd").format(DateTime.parse(d));
  }

  static String mergeTime(String date) {
    DateFormat dateFormat = DateFormat("HH:mm",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("HHmm").format(DateTime.parse(d));
  }

  static String getYoDate2(DateTime date) {
    DateFormat dateFormat = DateFormat("HH:mm",'ko');
    return dateFormat.format(date);
  }

  static String getYoDate(DateTime calendar) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd E",'ko');
    return dateFormat.format(calendar);
  }

  static String getAllDate(DateTime calendar) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(calendar);
  }

  static String getAllDate1(DateTime calendar) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    return dateFormat.format(calendar);
  }

  static String getAllDate2(String? date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date!);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyy-MM-dd E",'ko').format(DateTime.parse(d));
  }

  static String getAllDate3(DateTime calendar) {
    DateFormat dateFormat = DateFormat("MM-dd HH:mm");
    return dateFormat.format(calendar);
  }

  static int getTotalPage(int total) {
    if(total == 0) return 0;
    int totalPage;
    int size = 20;
    totalPage = (total / size).ceil().toInt();
    return totalPage;
  }

  static String makePhoneNumber(String? phone) {
    if(phone == null || phone.isEmpty) {
      return phone??"";
    }else{
      return makeHyphenPhoneNumber(phone);
    }
  }

  static makeHyphenPhoneNumber(String phone) {
    if(!phone.contains("\\-")){
      if(phone.length == 10) {
        if(phone.startsWith("02")){
          phone = "${phone.substring(0,2)}-${phone.substring(2,6)}-${phone.substring(6)}";
        }else{
          phone = "${phone.substring(0,3)}-${phone.substring(3,6)}-${phone.substring(6)}";
        }
      }else if(phone.length == 11) {
        phone = "${phone.substring(0,3)}-${phone.substring(3,7)}-${phone.substring(7)}";
      }
    }
    return phone;
  }

  static bool equalsCharge(String text) {
    if(text != null) {
      return !(text == "0");
    }else{
      return false;
    }
  }

  static bool checkTonOver(String carTon, String goodsWeight) {
    double car = (((double.parse(carTon) * 1.1) * 10) / 10.0).roundToDouble();
    double goods = double.parse(goodsWeight);
    return car >= goods;
  }

  static bool regexCarNumber(String num) {
    RegExp regExp = RegExp(r'^[가-힣ㄱ-ㅎㅏ-ㅣ\\x20]{2}\\d{2}[아,바,사,자\\x20]\d{4}$');
    return regExp.hasMatch(num);
  }

  static String getDateCalToStr(DateTime? calendar, String? newPatten){
    return DateFormat(newPatten).format(calendar!);
  }

  static notificationDialog(BuildContext context,String pageName,GlobalKey webviewKey) async {
    final controller = Get.find<App>();
    var first_screen = await SP.getFirstScreen(context);
    if(first_screen == pageName) {
      if(!controller.isIsNoticeOpen.value) {
        controller.isIsNoticeOpen.value = true;
        await getNotice(context, pageName, webviewKey);
      }
    }else{
      return;
    }
  }

  static Future<void> getNotice(BuildContext context,String pageName,GlobalKey webviewKey) async {
    final controller = Get.find<App>();
    var app = await controller.getUserInfo();
    Logger logger = Logger();
    await DioService.dioClient(header: true).getNotice(app.authorization).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("Util getNotice() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<NoticeModel> itemsList = list.map((i) => NoticeModel.fromJSON(i)).toList();
            if(itemsList.isNotEmpty) {
              NoticeModel data = itemsList[0];
              var read_notice = await SP.getInt(Const.KEY_READ_NOTICE,defaultValue: 0)??0;
              if(data.boardSeq! > read_notice){
                openNotiDialog(context,pageName,webviewKey,data.boardSeq);
              }
            }
          }catch(e) {
            print("Util getNotice() Error => $e");
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("Util getNotice() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("Util getNotice() Error Default => ");
          break;
      }
    });
  }


  static openNotiDialog(BuildContext context,String pageName,GlobalKey webviewKey, int? seq){
    InAppWebViewController? webViewController;
    PullToRefreshController? pullToRefreshController;
    double _progress = 0;

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.red),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));}
      },
    ))!;
    String myUrl = SERVER_URL + URL_NOTICE_DETAIL + seq.toString();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0))
                  ),
                  content: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(children: <Widget>[
                        _progress < 1.0
                            ? LinearProgressIndicator(value: _progress, color: Colors.red)
                            : Container(),
                        Expanded(
                          child: Stack(
                            children: [
                              InAppWebView(
                                key: webviewKey,
                                initialUrlRequest: URLRequest(url: WebUri(myUrl)),
                                initialOptions: InAppWebViewGroupOptions(
                                  crossPlatform: InAppWebViewOptions(
                                      javaScriptCanOpenWindowsAutomatically: true,
                                      javaScriptEnabled: true,
                                      useOnDownloadStart: true,
                                      useOnLoadResource: true,
                                      useShouldOverrideUrlLoading: true,
                                      mediaPlaybackRequiresUserGesture: true,
                                      allowFileAccessFromFileURLs: true,
                                      allowUniversalAccessFromFileURLs: true,
                                      verticalScrollBarEnabled: true,
                                      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'
                                  ),
                                  android: AndroidInAppWebViewOptions(
                                      useHybridComposition: true,
                                      allowContentAccess: true,
                                      builtInZoomControls: true,
                                      thirdPartyCookiesEnabled: true,
                                      allowFileAccess: true,
                                      supportMultipleWindows: true
                                  ),
                                  ios: IOSInAppWebViewOptions(
                                    allowsInlineMediaPlayback: true,
                                    allowsBackForwardNavigationGestures: true,
                                  ),
                                ),
                                pullToRefreshController: pullToRefreshController,
                                onLoadStart: (InAppWebViewController controller, uri) {
                                  setState(() {myUrl = uri.toString();});
                                },
                                onLoadStop: (InAppWebViewController controller, uri) {
                                  setState(() {myUrl = uri.toString();});
                                },
                                onProgressChanged: (controller, progress) {
                                  if (progress == 100) {pullToRefreshController?.endRefreshing();}
                                  setState(() {_progress = progress / 100;});
                                },
                                androidOnPermissionRequest: (controller, origin, resources) async {
                                  return PermissionRequestResponse(
                                      resources: resources,
                                      action: PermissionRequestResponseAction.GRANT);
                                },
                                onWebViewCreated: (InAppWebViewController controller) {
                                  webViewController = controller;
                                },
                                onCreateWindow: (controller, createWindowRequest) async{
                                  showDialog(
                                    context: context, builder: (context) {
                                    return AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(0.0))
                                      ),
                                      content: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: 400,
                                        child: InAppWebView(
                                          // Setting the windowId property is important here!
                                          windowId: createWindowRequest.windowId,
                                          initialOptions: InAppWebViewGroupOptions(
                                            android: AndroidInAppWebViewOptions(
                                              builtInZoomControls: true,
                                              thirdPartyCookiesEnabled: true,
                                            ),
                                            crossPlatform: InAppWebViewOptions(
                                                cacheEnabled: true,
                                                javaScriptEnabled: true,
                                                userAgent: "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
                                            ),
                                            ios: IOSInAppWebViewOptions(
                                              allowsInlineMediaPlayback: true,
                                              allowsBackForwardNavigationGestures: true,
                                            ),
                                          ),
                                          onCloseWindow: (controller) async{
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ),);
                                  },
                                  );
                                  return true;
                                },
                              )
                            ],
                          ),
                        ),
                      ])
                  ),
                  backgroundColor: main_color,
                  actionsPadding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10),horizontal: CustomStyle.getWidth(10)),
                  actions: [
                    InkWell(
                        onTap: (){
                          SP.putInt(Const.KEY_READ_NOTICE, seq!);
                          Navigator.of(context).pop();
                        },
                        child:SizedBox(
                          child:Text(
                            "  다시 열지 않음  ",
                            style: CustomStyle.CustomFont(styleFontSize16, Colors.white,font_weight: FontWeight.w600),
                          ),
                        )
                    ),
                    InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child:Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                          child:Text(
                            "  닫기  ",
                            style: CustomStyle.CustomFont(styleFontSize16, Colors.white,font_weight: FontWeight.w600),
                          ),
                        )
                    )

                  ],
                );
              }
          );
        }
    );
  }

}
