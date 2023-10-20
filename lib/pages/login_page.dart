import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controlador para editar el texto
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.message.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                // ignore: prefer_const_constructors
                /*const SizedBox(
                  height: 50,
                ),*/
                // ignore: prefer_const_constructors
                Image.asset(
                  'assets/logo1.png',
                  width: 200,
                ),

                //Welcome back message
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 20,
                ),
                const Text(
                  "Bienvenido de Nuevo!",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                //email textfield
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Correo',
                    obsecureText: false),

                //password textfield
                const SizedBox(height: 20),
                MyTextField(
                    controller: passwordTextController,
                    hintText: 'Contraseña',
                    obsecureText: true),

                const SizedBox(height: 20),

                //sign in button
                MyButton(onTap: signIn, text: 'Iniciar Sesion'),

                //go to register page
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "No eres miembro?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Registrate ahora.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
