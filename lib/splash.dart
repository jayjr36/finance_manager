import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:finance_manager/main.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return EasySplashScreen(
      logo: Image.asset('assets/image1.png',),
      //title: const Text(
        //"Hakikisha Maendeleo Ya Kasi",
        // style: TextStyle(
        //   fontSize: 12,
        //   color: Colors.black,
        //   letterSpacing: 3,
        //   fontWeight: FontWeight.normal,
        // ),
      //),
      backgroundColor: Colors.amber,
      showLoader: true,
      loadingText: const Text("Welcome"),
      navigator: const AuthenticationWrapper(),
      durationInSeconds: 5,
      logoWidth: h*0.2,
    );
  }
}