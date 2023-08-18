import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class EditNoticePage extends StatefulWidget {
  final String noticeId;
  final String text;
  final String imageUrl;

  EditNoticePage({required this.noticeId, required this.text, required this.imageUrl});

  @override
  _EditNoticePageState createState() => _EditNoticePageState();
}

class _EditNoticePageState extends State<EditNoticePage> {
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descriptionController.text = widget.text;
  }

  String imageUrl = ''; // Provide a default value

  Future<String> _uploadImage(File file) async {
    final storage = FirebaseStorage.instance;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadTask = storage.ref().child('notice-img/$fileName').putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

Future<void> _updateNotice() async {
  final noticeRef = FirebaseFirestore.instance.collection('notice');
  final docSnapshot = await noticeRef.doc(widget.noticeId).get();
  if (docSnapshot.exists && docSnapshot.data() != null) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    data['text'] = descriptionController.text;
    if (imageUrl.isNotEmpty) {
      data['image_url'] = imageUrl;
    } 
    await noticeRef.doc(widget.noticeId).set(data);
  }
}


  Future<File?> getImage(ImageSource media) async {
    var img = await ImagePicker().getImage(source: media);
    if (img != null) {
      final file = File(img.path);
      final imageUrl = await _uploadImage(file);
      setState(() {
        this.imageUrl = imageUrl;
      });
    }
    return img != null ? File(img.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Edit post",
          ),
        ),
        elevation: 20,
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const Padding(padding: EdgeInsets.all(15)),
              ElevatedButton(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                child: const Text('Change Image'),
              ),
              const SizedBox(
                height: 10,
              ),
              imageUrl.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: 200,
                                height: 200,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: 200,
                                height: 200,
                              ),
                      ),
                    )
                  : const Text(
                      "No Image",
                      style: TextStyle(fontSize: 20),
                    ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                style: const TextStyle(fontSize: 20),
                controller: descriptionController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Announcement',
                  hintText: 'Announcement',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                maxLines: 50,
                minLines: 5,
                validator: (val) => val?.length == 0 ? 'Enter announcement' : null,
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () async {
                  await _updateNotice();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  width: 300,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
