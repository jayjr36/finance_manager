import 'package:finance_manager/expense.dart';
import 'package:finance_manager/home.dart';
import 'package:finance_manager/login.dart';
import 'package:finance_manager/pinverification.dart';
import 'package:finance_manager/register.dart';
import 'package:finance_manager/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCkJEYMkVaemP2jTeAambDVr0bq2f8zKnc", 
      appId: "1:601097694658:android:58762c587dbb35073ffa5b", 
      messagingSenderId: "601097694658", 
      projectId: "hostelchat-1"
      ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEZESHA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 137, 152, 1)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } else {
            return const PinVerificationScreen();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
