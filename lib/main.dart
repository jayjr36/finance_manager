import 'package:finance_manager/expense.dart';
import 'package:finance_manager/home.dart';
import 'package:finance_manager/register.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEZESHA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 137, 152, 1)),
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}