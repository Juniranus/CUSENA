import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notice/user/login.dart';
// ignore: import_of_legacy_library_into_null_safe
import '../service/authService.dart';
import 'editUser.dart';
import 'login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'newHead.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _auths = AuthService();
  late Query<Map<String, dynamic>> userRef;
  late Stream<QuerySnapshot<Map<String, dynamic>>> userStream;

  @override
  void initState() {
    super.initState();
    userRef = FirebaseFirestore.instance.collection('user');
    userStream = userRef.snapshots();
  }

  void showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete user'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteUser(userId);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete'),
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

Future<void> deleteUser(String userId) async {
  try {

    final noticesRef = FirebaseFirestore.instance.collection('notice').where('userId', isEqualTo: userId);
    final snapshot = await noticesRef.get();

    final batch = FirebaseFirestore.instance.batch();
    final storage = FirebaseStorage.instance;

    await FirebaseFirestore.instance.collection('user').doc(userId).delete();
    
    snapshot.docs.forEach((doc) {
      batch.delete(doc.reference);
      final imageUrl = doc['image_url'];
      if (imageUrl != null) {
        final fileName = imageUrl.split('/').last;
        final imageRef = storage.ref().child('notices').child(fileName);
        imageRef.delete();
      }
    });

    await batch.commit();
  } catch (e) {
    print('Error deleting user and notices: $e');
  }
}


  void navigateToEditUserPage(String userId, String username,String email,  String password, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(userId: userId,email: email, password: password,  role: role, username: username),
      ),
    );
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
                MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
              );
            },
            icon: const Icon(
              Icons.add,
              semanticLabel: "New Head User",
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
          stream: userRef.where('role', isEqualTo: 'leader').snapshots(), // 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "No user",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final usr = users[index];
                final email = usr['email'];
                final role = usr['role'];
                final password = usr['password'];
                final username = usr['username'];
                final userId = usr.id;

                return Slidable(
                  startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              showDeleteConfirmationDialog(context, userId);
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
                              navigateToEditUserPage(userId, username, email, password, role);
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
                                  Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    (username ?? ''),
                                    style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: Colors.black,
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
                                            email ?? '',
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