import 'dart:io';
import 'package:express/servers_sheet.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webviewx/webviewx.dart';

import 'fcm/fcm_helper.dart';
import 'fcm/local_notifications_helper.dart';
import 'firebase_helper.dart';


/// Global Vars ******************************
final messaging = FirebaseMessaging.instance;
// FCM background callback
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await FirebaseHelper.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set status bar color to transparent
      statusBarIconBrightness: Brightness.dark, // Set status bar icons to black
    ),
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  /// init notification ******************************************
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initLocalNotifications(flutterLocalNotificationsPlugin);
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  FCMHelper().requestFCMIOSPermissions();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FCMHelper().onMessageReceived();
  FCMHelper().initRemoteMessage();
  FCMHelper().onTokenChange();
  // });

  /// run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFbd751b),
        primaryColorDark: const Color(0xFFbd751b)
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late WebViewXController webViewController;
  bool loading = true;
  Server selectedServer = Server.track1;
  String? customText;

  @override
  Widget build(BuildContext context) {

    return WillPopScope(child: Scaffold(
      key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(backgroundColor: const Color(0xff327dbe),centerTitle: true,titleSpacing: 100, actions: [
          InkWell(
            onTap: ()=> _openOptionsSheet(context),
            child: const Padding(
              padding: EdgeInsetsDirectional.only(end: 16),
              child: Icon(Icons.more_vert, color: Colors.white,),
            ),
          )
        ],title: Image.asset('images/logo.png', fit: BoxFit.contain,),),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: WebViewX(
              initialContent: selectedServer == Server.custom? customText! : selectedServer.server,
              initialSourceType: SourceType.url,
              onWebViewCreated: (controller) => webViewController = controller,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              onWebResourceError: (_){},
              onPageFinished: (_){},
              onPageStarted: (_){},
            ),
          ),
        )
    ), onWillPop: ()async{
      if(await webViewController.canGoBack()){
        webViewController.goBack();
        return Future.value(false);
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return Future.value(false);
    });
  }

/// Logic ***********************************************************************
  _openOptionsSheet(BuildContext context)async{
    dynamic result = await showModalBottomSheet(context: context, builder: (_)=> ServersSheet(init: selectedServer, customText: customText?.replaceAll('https://', ''),), isScrollControlled: true, useSafeArea: true);
    if(result == null) return;
    if(selectedServer == result['server']) return;
    selectedServer = result['server'];
    if(selectedServer == Server.custom){
      customText = result['customText'];
    }
    Fluttertoast.showToast(
      msg: 'جاري تحميل الرابط',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    await webViewController.clearCache();
    webViewController.loadContent(selectedServer == Server.custom? customText! : selectedServer.server, SourceType.url);
    setState(() {});
  }
}

enum Server{
  track1(server: 'https://track1.expressit.com.sa/mobile', title: 'سيرفر 1 - Server 1'),
  track2(server: 'https://track2.expressit.com.sa/mobile', title: 'سيرفر 2 - Server 2'),
  track3(server: 'https://track3.expressit.com.sa/mobile', title: 'سيرفر 3 - Server 3'),
  custom(server: '', title: 'مخصص - Custom');
  final String server, title;
  const Server({required this.server, required this.title});
}
