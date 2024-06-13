// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/constants.dart';
import 'package:finance_manager/dailyinput.dart';
import 'package:finance_manager/spendingsbydate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    User? user = FirebaseAuth.instance.currentUser;
    String? name;
    String? email;
    Future<void> getname() async {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        name = userDoc['username'] ?? 'Failed to get name';
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    @override
    void initState() {
      super.initState();
      getname();
    }

    email = user!.email ?? 'Failed to get email';
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: deviceHeight * 0.2,
            decoration: BoxDecoration(color: Constants().primaryColor),
            child: Center(
              child: Image.asset(
                'assets/image1.png',
                height: deviceHeight * 0.2,
              ),
            ),
          ),
          ListTile(
            title: Center(child: Text(name ?? 'name not found', style: Constants().boldFont,)),
          ),
          ListTile(
            title: Center(child: Text(email, style: Constants().boldFont,)),
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailySpendingByDateScreen(),
                  ),
                );
              },
              child: const Text('Spendings By Date')),
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyExpenseScreen(),
                  ),
                );
              },
              child: const Text('Daily records'))
        ],
      ),
    );
  }
}
