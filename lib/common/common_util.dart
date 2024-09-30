import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';


class ReturnMap {
  String? status;
  String? message;
  String? path;
  Map<String,dynamic>? resultMap;

  ReturnMap({this.message,this.path,this.resultMap,this.status});

  factory ReturnMap.fromJSON(Map<String,dynamic> json){
    return ReturnMap(
      status: json['status'],
      message: json['message'],
      path: json['path'],
      resultMap: json['resultMap'],
    );
  }
}

openOkBox(BuildContext context, String msg,String okTxt, Function() okEvent) {
  return openDialogBox(context,
      msg,
      InkWell(
          onTap: okEvent,
          child: Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
            decoration: BoxDecoration(
              color: main_color,
              border: CustomStyle.borderAllBase(),
            ),
            child: Text(
              okTxt,
              style: CustomStyle.whiteFont15B(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
  );
}

openCommonConfirmBox(BuildContext context, String msg, String cancelTxt,
    String okTxt, Function() cancelEvent, Function() okEvent) {
  return openDialogBox(
    context,
    msg,
    Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: cancelEvent,
              child: Container(
                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.3,
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8.0)),
                decoration: const BoxDecoration(
                  color: light_gray1,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                  cancelTxt,
                  style: CustomStyle.blackFont(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.05,
            ),
            InkWell(
              onTap: okEvent,
              child: Container(
                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.3,
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8.0)),
                decoration: const BoxDecoration(
                  color: renew_main_color2,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                  okTxt,
                  style: CustomStyle.whiteFont(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
    ),
  );
}

openDialogBox(BuildContext context, String msg, Widget button) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
            contentPadding: EdgeInsets.all(CustomStyle.getWidth(15.0)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                      Icons.info,
                      size: 48,
                      color: Color(0xffC7CBDE)
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(10)),
                    margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: msg,
                        style: CustomStyle.alertMsgFont(),
                      ),
                    ),
                  ),
                  button,
                ],
              ),
            )
          ),
        );
      });
}

openSnakBar(
    {required BuildContext context,
      required ScaffoldMessengerState state,
      required String msg,
      bool closeBtn = false,
      required Function() currTapEvent,
      required Function() callback}) {
  final _snackBar = SnackBar(
    duration: Duration(milliseconds: 1500),
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
    backgroundColor: styleSubCol,
    content: InkWell(
      onTap: currTapEvent,
      child: Container(
        child: Row(
          children: <Widget>[
            closeBtn
                ? Image.asset(
              "assets/image/circle_check_false.png",
              width: CustomStyle.getWidth(17.0),
              height: CustomStyle.getHeight(17.0),
              color: styleBaseCol1,
            )
                : Container(width: 0, height: 0),
            closeBtn
                ? CustomStyle.sizedBoxWidth(5.0)
                : Container(width: 0, height: 0),
            Expanded(
              child: Text(
                msg,
                style: CustomStyle.baseColFont(),
              ),
            ),
            closeBtn
                ? InkWell(
              onTap: callback,
              child: Image.asset(
                "assets/image/cancle.png",
                width: CustomStyle.getWidth(13.0),
                height: CustomStyle.getHeight(13.0),
                color: styleBaseCol1,
              ),
            )
                : Container(width: 0, height: 0),
          ],
        ),
      ),
    ),
  );
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  } else if (state != null) {
    state.showSnackBar(_snackBar);
  }
}