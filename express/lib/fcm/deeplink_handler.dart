import 'dart:async';
import 'package:flutter/material.dart';


bool isFullScreenNotification = false;

class DeepLinkHandler {

  static void navigate(Map message, {bool isAccepted = false}) {
    Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      // if (splashLoaded) {
        destination(message, isAccepted: isAccepted);
        t.cancel();
      // }
    });
  }



  static destination(Map message, {bool isAccepted = false}) async {
    debugPrint("Inside deeplink destination ---------------> ${message.toString()}");
  }

  /// Nav **********************************************************************

}
