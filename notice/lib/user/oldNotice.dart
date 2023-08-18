// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/user/profile.dart';

import '../service/authService.dart';
import 'login.dart';
import 'newNotice.dart';

class OldNotice extends StatefulWidget {
  OldNotice({Key? key}) : super(key: key);

  @override
  _OldNoticeState createState() => _OldNoticeState();
}

class _OldNoticeState extends State<OldNotice> {
  final AuthService _auths = AuthService();
  late final CollectionReference noticesRef;
  late final Stream<QuerySnapshot> noticesStream;

  Future<void> logout() async {
    try {
       _auths.logout();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

    Future<void> logoutconfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    noticesRef = FirebaseFirestore.instance.collection('notice');
    // Filter the notices that have been viewed by the current user
    noticesStream = noticesRef
        .where('viewerIds', arrayContains: getCurrentUserId())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("./images/cuc.png"),
                    scale: 1,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter)),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 20,
        toolbarHeight: 70,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewNotice()),
                );
              },
              icon: const Icon(
                Icons.notifications_active,
                semanticLabel: "New notice",
                color: Colors.red,
              )),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OldNotice()),
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                semanticLabel: "Old notice",
                color: Colors.grey,
              )),
              IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              icon: const Icon(
                Icons.person,
                semanticLabel: "Profile",
                color: Colors.black87,
              )),
              IconButton(
            onPressed: () {
              logoutconfirmation();
            },
            icon: const Icon(
              Icons.logout,
              semanticLabel: "LogOut",
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: noticesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "No viewed notice",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            );
          }

          final viewedNotices = snapshot.data!.docs;

          return ListView.builder(
            itemCount: viewedNotices.length,
            itemBuilder: (context, index) {
              final notice = viewedNotices[index];
              final text = notice['text'];
              final username = notice['username'];
              final image = notice['image_url'];

              return Padding(
                padding: const EdgeInsets.all(5),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      FittedBox(
                        child: SizedBox(
                          width: 550,
                          child: Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage("./images/cu.png"),
                                                  scale: 1,
                                                  fit: BoxFit.contain,
                                                  )),
                                        ),
                                    ),
                                      Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    (username ?? ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                  ],
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 450),
                                    child: Column(
                                      children: [
                                        if (image != null)
                                          Image.network(
                                            image,
                                            fit: BoxFit.contain,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 450),
                                    child: Column(
                                      children: [
                                        Text(
                                          text ?? '',
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return '';
    }
  }
}
