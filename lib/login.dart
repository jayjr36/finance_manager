// ignore_for_file: use_build_context_synchronously

import 'package:finance_manager/constants.dart';
import 'package:finance_manager/pinverification.dart';
import 'package:finance_manager/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isloading = false;
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        setState(() {
          isloading = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PinVerificationScreen()),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: LoadingOverlay(
          isLoading: isloading,
          progressIndicator: const CircularProgressIndicator(
            color: Colors.amber,
          ),
          child: Column(
            children: [
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: h * 0.1, horizontal: w * 0.1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Image.asset('assets/image1.png')),
                        Center(child: Image.asset('assets/image2.png')),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        const Text(
                          'WELCOME BACK',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 202, 202, 6)),
                        ),
                        const Text(
                          'Signin To Your Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: h * 0.05,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Constants().primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.3, vertical: h * 0.003)),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Create a new account',
                            style: TextStyle(
                                color: Color.fromARGB(255, 2, 40, 71)),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.15,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: _CenterCurveClipper(),
                child: Container(
                  height: h * 0.2,
                  width: w,
                  decoration: const BoxDecoration(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width / 2, 100, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
