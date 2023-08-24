import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/components/button.dart';
import 'package:socialmedia/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nombreCompletoTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    if (passwordTextController.text.length < 12) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("La contraseñas debe tener minimo 12 caracteres!"),
              ));
      return;
    }

    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Las contraseñas no coinciden!"),
              ));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      /*FirebaseAuth.instance.currentUser!
          .updateDisplayName(nombreCompletoTextController.text);*/

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': nombreCompletoTextController,
        'bio': 'Empty bio...'
      });

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
            padding: const EdgeInsets.symmetric(horizontal: 200.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                // ignore: prefer_const_constructors
                /*const SizedBox(
                  height: 50,
                ),*/
                // ignore: prefer_const_constructors
                Icon(
                  Icons.lock,
                  size: 100,
                ),

                //Welcome back message
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 35,
                ),
                const Text(
                  "Crear cuenta",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                //email textfield
                MyTextField(
                    controller: nombreCompletoTextController,
                    hintText: 'Nombre Completo',
                    obsecureText: false),

                //password textfield
                const SizedBox(height: 10),

                //email textfield
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Correo Electronico',
                    obsecureText: false),

                //password textfield
                const SizedBox(height: 10),

                MyTextField(
                    controller: passwordTextController,
                    hintText: 'Contraseña nueva',
                    obsecureText: true),

                //password textfield
                const SizedBox(height: 10),

                MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: 'Confirmar contraseña',
                    obsecureText: true),

                const SizedBox(height: 25),

                //sign in button
                MyButton(onTap: signUp, text: 'Registrarte'),

                //go to register page
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ya tienes una cuenta?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Iniciar Sesion.",
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
