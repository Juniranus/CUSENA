import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notice/user/home.dart';
import 'package:notice/user/login.dart';
import 'package:notice/leaders/postDashboard.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      backgroundColor: Colors.red,
      seconds: 3,
      navigateAfterSeconds: checkAuthentication(),
      loadingText: const Text(
        "Powered By: JeJuDu Solutions",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      loaderColor: Colors.white,
    );
  }

  Widget checkAuthentication() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null) {
      return Home();
    } else {
      return const AuthScreen();
    }
  }
}
