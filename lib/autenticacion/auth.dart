import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../order_traking_page.dart';
import 'login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const OrderTrackingPage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
