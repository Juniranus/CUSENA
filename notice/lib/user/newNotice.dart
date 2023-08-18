import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/user/oldNotice.dart';
import 'package:notice/user/profile.dart';
import '../service/authService.dart';
import 'login.dart';

class NewNotice extends StatefulWidget {
  NewNotice({Key? key}) : super(key: key);

  @override
  _NewNoticeState createState() => _NewNoticeState();
}

class _NewNoticeState extends State<NewNotice> {
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
    noticesStream = noticesRef.snapshots();
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
        child:StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('user').doc(getCurrentUserId()).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!userSnapshot.hasData) {
              return const Center(
                child: Text(
                  "No new notice",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            final List<dynamic>? subscribedLeaders = userData?['subscribed_to'];

        return StreamBuilder<QuerySnapshot>(
          stream: noticesRef.where('uid', whereIn: subscribedLeaders).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "No  notice",
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
                final username = notice['username'];
                final image = notice['image_url'];
                final viewerIds = notice['viewerIds'] ?? [];

                if (viewerIds.contains(getCurrentUserId())) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        FittedBox(
                          child: SizedBox(
                            width: 530,
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
                                              fontSize: 20,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      notice.reference.update({'viewed': true}); 
                                      markNoticeAsViewed(notice.id);
                                    },
                                    child: const Text('Mark as Viewed'),
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
        );
  }),
    ));
  }

String getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    return '';
  }
}


  void markNoticeAsViewed(String noticeId) async {
  final userId = getCurrentUserId();
  final noticeDoc = noticesRef.doc(noticeId);

  // Get the current document snapshot
  final snapshot = await noticeDoc.get();

  // Retrieve the existing viewerIds field value or initialize it as an empty list if it doesn't exist
  final data = snapshot.data() as Map<String, dynamic>?; // Explicitly cast data to Map<String, dynamic>?

  final existingViewerIds = data?['viewerIds'] ?? [];


  // Check if the current user's ID is already in the viewerIds list
  if (!existingViewerIds.contains(userId)) {
    // Add the current user's ID to the viewerIds list
    existingViewerIds.add(userId);

    // Update the document with the modified viewerIds field
    await noticeDoc.update({'viewerIds': existingViewerIds});
  }
}

}

