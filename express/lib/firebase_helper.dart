import 'package:firebase_core/firebase_core.dart';

class FirebaseHelper {
  //init firebase app
  static init() async {
    await Firebase.initializeApp(
    );
  }
}
