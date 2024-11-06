import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logislink_tms_flutter/common/app.dart';
import 'package:logislink_tms_flutter/common/string_locale_delegate.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:logislink_tms_flutter/constants/const.dart';
import 'package:logislink_tms_flutter/db/appdatabase.dart';
import 'package:logislink_tms_flutter/page/bridge_page.dart';
import 'package:logislink_tms_flutter/provider/appbar_service.dart';
import 'package:logislink_tms_flutter/provider/notification_service.dart';
import 'package:logislink_tms_flutter/provider/order_service.dart';
import 'package:logislink_tms_flutter/provider/receipt_service.dart';
import 'package:provider/provider.dart';
import 'package:logislink_tms_flutter/utils/util.dart' as app_util;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late AppDataBase database;

Future<void> main() async{
  final binding = WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch(e) {
    print("Failed to initialize Firebase: $e");
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: 'assets/env/.env');
  AuthRepository.initialize(appKey: dotenv.env['APP_KEY'] ?? '');

  //Firebase Setting
  if (!kIsWeb) {
    channel = AndroidNotificationChannel(
      Const.PUSH_SERVICE_CHANNEL_ID, // id
      '로지스링크 주선사/운송사용', // title
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  database = AppDataBase();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _openHandleMessage(initialMessage);
    }
    FirebaseMessaging.onMessage.listen(_messageHandle);
    FirebaseMessaging.onMessageOpenedApp.listen(_openHandleMessage);
  }

  void _messageHandle(RemoteMessage message) {
    print("fcm onMessage msg : ${message.notification}");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  }

  void _openHandleMessage(RemoteMessage message) {
    print("fcm opendApp msg : ${message.messageId}");
    if(message.data.isNotEmpty){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (message.data["link_page"] == "config") {

        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(App());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationService>(
            create:(_) => NotificationService()),
        ChangeNotifierProvider<OrderService>(
            create:(_) => OrderService()),
        ChangeNotifierProvider<AppbarService>(
            create: (_) => AppbarService()),
        ChangeNotifierProvider<ReceiptService>(
          create: (_) => ReceiptService())
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: ScreenUtilInit(
          designSize: const Size(360, 750),
          builder: (_,child) => MaterialApp(
            title: 'logislink_tms_flutter',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              StringLocaleDelegate(),
            ],
            supportedLocales: const [
              Locale('ko','KR')
            ],
            locale: const Locale('ko'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: ThemeData.light()
                  .appBarTheme
                  .copyWith(backgroundColor: light_gray24),
              primaryColor: light_gray24,
              textTheme: TextTheme(bodyLarge: CustomStyle.baseFont()),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'NotoSansKR',
            ),
            themeMode: ThemeMode.system,
            home: GetBuilder<App>(
              init: App(),
              builder: (_) {
                app_util.Util.settingInfo();
                return const BridgePage();
              },
            ),
          ),
        ),
      ),
    );
  }
}
