import 'package:finance_manager/constants.dart';
import 'package:finance_manager/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({super.key});

  @override
  PinVerificationScreenState createState() => PinVerificationScreenState();
}

class PinVerificationScreenState extends State<PinVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();

  Future<void> _verifyPin() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String savedPin = userDoc['pin'];
        if (_pinController.text == savedPin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.1, horizontal: w * 0.1),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(child: Image.asset('assets/image1.png')),
              Center(child: Image.asset('assets/image2.png')),
              SizedBox(
                height: h * 0.1,
              ),
              TextFormField(
                controller: _pinController,
                decoration:
                    const InputDecoration(labelText: 'Enter 6-digit PIN'),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Please enter a 6-digit PIN';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                 style: ElevatedButton.styleFrom(
                            backgroundColor: Constants().primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.3, vertical: h * 0.003)),
                child: const Text('Verify PIN',  style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'))
            ],
          ),
        ),
      ),
    );
  }
}
