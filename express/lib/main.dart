import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviewx/webviewx.dart';

void main() {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late WebViewXController webViewController;
  bool loading = true;

  @override
  Widget build(BuildContext context) {

    return WillPopScope(child: Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xff327dbe),centerTitle: true,titleSpacing: 100,title: Image.asset('images/logo.png', fit: BoxFit.contain,),),
        body: WebViewX(
          initialContent: 'http://track1.expressit.com.sa/mobile/index.php',
          initialSourceType: SourceType.url,
          onWebViewCreated: (controller) => webViewController = controller,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          onWebResourceError: (_){},
          onPageFinished: (_){},
          onPageStarted: (_){},
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


}
