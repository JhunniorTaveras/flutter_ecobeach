import 'package:flutter/material.dart';
import 'package:socialmedia/autenticacion/auth.dart';
//import 'package:socialmedia/autenticacion/login_or_register.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyC94cVtspHIs2pM_ejHBaF3B7LjkwHGtxY',
        appId: '1:872681089036:web:59ea5c59d05e6558ece629',
        messagingSenderId: '872681089036',
        projectId: 'red-social-727ea'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ECOBEACH',
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
