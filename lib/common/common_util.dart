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
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: cancelEvent,
            child: Container(
              padding:
              EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
              decoration: BoxDecoration(
                color: cancel_btn,
              ),
              child: Text(
                cancelTxt,
                style: CustomStyle.whiteFont(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: okEvent,
            child: Container(
              padding:
              EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
              decoration: BoxDecoration(
                color: main_color,
              ),
              child: Text(
                okTxt,
                style: CustomStyle.whiteFont(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
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
                  borderRadius: BorderRadius.all(Radius.circular(0.0))
              ),
            insetPadding: EdgeInsets.all(CustomStyle.getHeight(10.0)),
            contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(CustomStyle.getWidth(30.0)),
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
                "assets/image/close.png",
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