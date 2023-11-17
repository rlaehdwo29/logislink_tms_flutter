import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_util.dart';

mixin CommonMainWidget {
  WillPopScope
  mainWidget(context, {required Widget child}) {
    return WillPopScope(
      onWillPop: () async {
        /*openCommonConfirmBox(
            context,
            Strings.of(context)?.get('msg_basic_exit_app') ?? "Error!!",
            Strings.of(context)?.get("no") ?? "Error!!",
            Strings.of(context)?.get("yes") ?? "Error!!",
                () {Navigator.of(context).pop(false);},
                () {SystemNavigator.pop();}
        );*/
        SystemNavigator.pop();
        return false;
      },
      child: child,
    );
  }
}
