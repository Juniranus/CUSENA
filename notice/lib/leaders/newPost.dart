// @dart=2.9

// ignore_for_file: prefer_is_empty, file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notice/leaders/postDashboard.dart';
import '../service/authService.dart';
import '../uploadImg.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController descriptionController = TextEditingController();


  String description;
  final formKey = GlobalKey<FormState>();

  final AuthService _auths = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  PickedFile image;
  String imageUrl;

  clear() {
    descriptionController.text = '';
  }

  Future<String> _uploadImage(File file) async {
  final storage = FirebaseStorage.instance;
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final uploadTask = storage.ref().child('notice-img/$fileName').putFile(file);
  final snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}

  Future<void> _uploadNotice() async{
  final noticeRef = FirebaseFirestore.instance.collection('notice');
  final uid = FirebaseAuth.instance.currentUser.uid;
  final username = FirebaseAuth.instance.currentUser.displayName;
  final newDocRef = noticeRef.doc();
  await newDocRef.set(
    {
      'text': descriptionController.text,
      'created_at': FieldValue.serverTimestamp(),
      'uid': uid,
      'username': username,
      'image_url': imageUrl,
      "viewed": false,
      'viewerIds': [],
    }
  );
}

Future<File> getImage(ImageSource media) async {
  var img = await ImagePicker().getImage(source: media);
  if (img != null) {
    final file = File(img.path);
    final imageUrl = await _uploadImage(file);
    setState(() {
      image = img;
      this.imageUrl = imageUrl;
    });
  }else{
    image = null;
    this.imageUrl = "";
  }
  return File(image?.path);
}



  form() {
    return Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              TextFormField(
                style: const TextStyle(fontSize: 20),
                controller: descriptionController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Anouncement',
                  hintText: 'Anouncement',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                maxLines: 50,
                minLines: 5,
                validator: (val) =>
                    val?.length == 0 ? 'Enter anouncement' : null,
                onSaved: (val) => description = val,
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () => _uploadNotice().then((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostDashboard()),
                );
              }).catchError((error) {
                print('Error during upload: $error');
              }),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: 300,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Create Post",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "New post",
          ),
        ),
        elevation: 20,
        toolbarHeight: 70,
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
           FittedBox(
            child: SizedBox(
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: FittedBox(
                    child: SizedBox(width: 300, child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              getImage(ImageSource.gallery);
            },
            child: const Text('Upload Photo'),
          ),
          const SizedBox(
            height: 10,
          ),
          image != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(image.path,
                              fit: BoxFit.contain, width: 200, height: 200)
                          : Image.file(File(image?.path),
                              fit: BoxFit.contain, width: 200, height: 200)),
                )
              : const Text(
                  "No Image",
                  style: TextStyle(fontSize: 20),
                ),
        ],
      ),
    ))),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Column(
              children: [
                FittedBox(
                  child: SizedBox(width: 450, child: form()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
