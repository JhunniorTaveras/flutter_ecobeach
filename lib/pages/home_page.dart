import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/components/drawer.dart';
import 'package:socialmedia/components/text_field.dart';
//import 'package:socialmedia/helper/helper_methods.dart';
//import 'package:socialmedia/pages/profile_page.dart';
//import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textcontroller = TextEditingController();

  void postMessage() {
    if (textcontroller.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        "Nombre": currentUser.displayName,
        "UserEmail": currentUser.email,
        "Message": textcontroller.text,
        "TimeStamp": Timestamp.now(),
        //"Image": pickedFile,
        "Likes": [],
      });
    }

    setState(() {
      textcontroller.clear();
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("ECOBEACH"),
        backgroundColor: const Color.fromARGB(255, 13, 72, 161),
      ),
      drawer: MyDrawer(
        onSignOut: signOut,
      ),
      body: Center(
          child: Column(children: [
        Expanded(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("User Posts")
              .orderBy("TimeStamp", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index];
                    /*return Post(
                      message: post['Message'],
                      user: post['UserEmail'],
                      postId: post.id,
                      likes: List<String>.from(post['Likes'] ?? []),
                      time: formatDate(post["TimeStamp"]),
                      //image: post['Image'],
                    );*/
                    return;
                  });
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            children: [
              Expanded(
                child: MyTextField(
                  controller: textcontroller,
                  hintText: 'Que estas pensando?',
                  obsecureText: false,
                ),
              ),
              IconButton(
                  onPressed: postMessage,
                  icon: const Icon(Icons.arrow_circle_up)),
              IconButton(
                  onPressed: postMessage, icon: const Icon(Icons.image_search))
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        )
      ])),
    );
  }
}
