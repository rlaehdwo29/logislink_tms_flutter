import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logislink_tms_flutter/common/model/notice_model.dart';
import 'package:logislink_tms_flutter/common/strings.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/config_url.dart';

class AppBarNoticeDetailPage extends StatefulWidget {

  NoticeModel item;

  AppBarNoticeDetailPage(this.item, {Key? key}):super(key: key);

  _AppBarNoticeDetailPageState createState() => _AppBarNoticeDetailPageState();
}

class _AppBarNoticeDetailPageState extends State<AppBarNoticeDetailPage> {
  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  ProgressDialog? pr;
  late String myUrl;
  double progress = 0;

  @override
  void initState(){
    super.initState();

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;

    myUrl = SERVER_URL + URL_NOTICE_DETAIL + widget.item.boardSeq.toString();

  }

  Future<bool> _goBack(BuildContext context) async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {

    pr = Util.networkProgress(context);
    return SafeArea(
        child: Scaffold(
      backgroundColor: styleWhiteCol,
      appBar: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("drawer_menu_notice")??"공지사항_",
                style: CustomStyle.appBarTitleFont(
                    styleFontSize16, styleWhiteCol)
            ),
            toolbarHeight: 50.h,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: styleWhiteCol,
              icon: Icon(Icons.arrow_back,size: 24.h),
            ),
          ),
      body: WillPopScope(
            onWillPop: () => _goBack(context),
        child: Column(children: <Widget>[
      progress < 1.0
      ? LinearProgressIndicator(value: progress, color: Colors.blue)
            : Container(),
          Expanded(
        child: Stack(
          children: [
            InAppWebView(
          key: webViewKey,
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
            if (progress == 100) {pullToRefreshController.endRefreshing();}
            setState(() {this.progress = progress / 100;});
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
                        Navigator.of(context).pop();
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
    )
    ));
  }

}