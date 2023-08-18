import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../service/authService.dart';
import 'login.dart';
import 'newNotice.dart';
import 'oldNotice.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auths = AuthService();
  late final CollectionReference userRef;
  late final Stream<QuerySnapshot> userStream;

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
    userRef = FirebaseFirestore.instance.collection('user');
    userStream = userRef.snapshots();
  }


  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return '';
    }
  }

void _updateSubscribedLeaders(String leaderUid, bool isSubscribed) {
  final String currentUserId = getCurrentUserId();
  final DocumentReference currentUserDoc = userRef.doc(currentUserId);

  if (isSubscribed) {
    userRef.doc(leaderUid)
        .update({
          'subscribers': FieldValue.arrayUnion([currentUserId]),
        })
        .then((_) => {
          print('User subscribed to the leader successfully.'),
          currentUserDoc.update({
            'subscribed_to': FieldValue.arrayUnion([leaderUid]),
          }).then((_) => print('Leader added to user\'s subscribed_to field.'))
              .catchError((error) => print('Error updating user\'s subscribed_to field: $error'))
        })
        .catchError((error) => print('Error subscribing to the leader: $error'));
  } else {
    userRef.doc(leaderUid)
        .update({
          'subscribers': FieldValue.arrayRemove([currentUserId]),
        })
        .then((_) => {
          print('User unsubscribed from the leader successfully.'),
          currentUserDoc.update({
            'subscribed_to': FieldValue.arrayRemove([leaderUid]),
          }).then((_) => print('Leader removed from user\'s subscribed_to field.'))
              .catchError((error) => print('Error updating user\'s subscribed_to field: $error'))
        })
        .catchError((error) => print('Error unsubscribing from the leader: $error'));
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
                MaterialPageRoute(builder: (context) => NewNotice()),
              );
            },
            icon: const Icon(
              Icons.notifications_active,
              semanticLabel: "New notice",
              color: Colors.red,
            ),
          ),
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
            ),
          ),
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
                final List<dynamic>? subscribers = usr['subscribers'];

                bool isCurrentUserSubscribed = false;
                if (subscribers != null && subscribers.contains(getCurrentUserId())) {
                  isCurrentUserSubscribed = true;
                }

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
                                ListTile(
                                  title: Text(
                                  (username ?? ''),
                                  style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.black,
                                  ),
                                ),
                                trailing: SwitchScreen(isSubscribed: isCurrentUserSubscribed, onToggle: (value) {
                                      _updateSubscribedLeaders(userId, value);
                                    },),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SwitchScreen extends StatefulWidget {
  SwitchScreen({Key? key, required this.isSubscribed, required this.onToggle}) : super(key: key);

  final bool isSubscribed;
  final ValueChanged<bool> onToggle;

  @override
  _SwitchScreenState createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool isSwitched = false;
  var textValue = 'Unsubscribed';

  @override
  void initState() {
    super.initState();
    isSwitched = widget.isSubscribed;
    textValue = isSwitched ? 'Subscribed' : 'Unsubscribed';
  }

  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      textValue = isSwitched ? 'Subscribed' : 'Unsubscribed';
    });
    widget.onToggle(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 2,
          child: Switch(
            onChanged: toggleSwitch,
            value: isSwitched,
            activeColor: Colors.red,
            inactiveThumbColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

