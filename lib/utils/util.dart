import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as enc;

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
          backgroundColor: main_color,
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
    if (won == null || won.isEmpty || won.length > 8) return "0";
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

  static String getAllDate2(String? date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date!);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyy-MM-dd E",'ko').format(DateTime.parse(d));
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

}
