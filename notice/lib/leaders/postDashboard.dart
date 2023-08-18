// ignore_for_file: import_of_legacy_library_into_null_safe, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notice/leaders/editPost.dart';
import '../service/authService.dart';
import '../user/login.dart';
import 'newPost.dart';

class PostDashboard extends StatefulWidget {
  PostDashboard({Key? key}) : super(key: key);

  @override
  _PostDashboardState createState() => _PostDashboardState();
}

class _PostDashboardState extends State<PostDashboard> {
  final AuthService _auths = AuthService();
  late Query<Map<String, dynamic>> noticesRef;
  late Stream<QuerySnapshot<Map<String, dynamic>>> noticesStream;

    Future<void> deleteNotice(String noticeId) async {
    try {
      await FirebaseFirestore.instance.collection('notice').doc(noticeId).delete();
      print('Notice deleted successfully!');
    } catch (e) {
      print('Error deleting notice: $e');
    }
  }

    Future<void> showDeleteConfirmationDialog(BuildContext context, String noticeId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Notice'),
          content: Text('Are you sure you want to delete this notice?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Call the deleteNotice function when delete button is pressed
                deleteNotice(noticeId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

void navigateToEditNoticePage(String noticeId, String text, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditNoticePage(
        noticeId: noticeId,
        text: text,
        imageUrl: imageUrl,
      ),
    ),
  );
}

  @override
  void initState() {
    super.initState();
    final currentUserId = getCurrentUser();
    noticesRef = FirebaseFirestore.instance
        .collection('notice')
        .where('uid', isEqualTo: currentUserId);
    noticesStream = noticesRef.snapshots();
  }

  String getCurrentUser() {
    final currentUserId = FirebaseAuth.instance.currentUser;
    if (currentUserId != null )
    {
      return currentUserId.uid;
    }else{
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                alignment: Alignment.topCenter,
              ),
            ),
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
                MaterialPageRoute(builder: (context) => const CreatePost()),
              );
            },
            icon: const Icon(
              Icons.add,
              semanticLabel: "New Post",
              color: Colors.black87,
            ),
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(1),
        child: StreamBuilder<QuerySnapshot>(
          stream: noticesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "No notice",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            final notices = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                final text = notice['text'];
                final image = notice['image_url'];
                final username = notice['username'];
                final noticeId = notice.id;

                return Slidable(
                  startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              showDeleteConfirmationDialog(context, noticeId);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          )
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              navigateToEditNoticePage(noticeId, text, image);
                            },
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          )
                        ],
                      ),
                  child: Padding(
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
                                        maxWidth: 450,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            text ?? '',
                                            style: const TextStyle(
                                              fontSize: 30,
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
                ));
              },
            );
          },
        ),
      ),
    );
  }
}



