import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/leaders/postDashboard.dart';
import 'package:notice/user/oldNotice.dart';
import 'package:notice/user/profile.dart';

import 'newNotice.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 100, 10, 60),
          child: Center(child: Column( children: [
            const Padding(
                     padding: EdgeInsets.fromLTRB(20, 30, 0, 20),
                     child: Text(
                     'Welcome to CUSENA.',
                     style: TextStyle(
                       fontSize: 45,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                                 ),
                   ),
                   const Padding(
                     padding: EdgeInsets.fromLTRB(20, 0, 0, 50),
                     child: Text(
                     'Stay connected with activities and evets on central university campus',
                     style: TextStyle(
                       fontSize: 18,
                       color: Colors.black87,
                     ),
                                 ),
                   ),
                Center(
                    child: FittedBox(
                      child: SizedBox(
                        width: 650,
                        height: 350,
                        child: Center(
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                image: DecorationImage(
                                    image: AssetImage("./images/img.png"),
                                    scale: 1,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter)),
                          ),
                        ),
                      ),
                    ),
                  ),
                    TextButton(
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          final user = await FirebaseFirestore.instance
                              .collection('user')
                              .doc(currentUser.uid)
                              .get();
                          final role = user['role']; // Replace 'role' with the key for the user's role field in the database
                          if (role == 'student') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NewNotice()), // Replace 'AdminPage' with the page for admin users
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PostDashboard()), // Replace 'UserPage' with the page for regular users
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        width: 200,
                        height: 50,
                        child: const Center(
                          child: Text(
                            "View posts",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
      
                const Center(
                  child: Padding(
                       padding: EdgeInsets.all(40),
                       child: Text(
                       'Where dreams are born',
                       style: TextStyle(
                         fontSize: 15,
                         fontWeight: FontWeight.bold,
                         color: Colors.black54,
                       ),
                                   ),
                     ),
                ),
          ],),),
        ),
      )
    );
  }
}
