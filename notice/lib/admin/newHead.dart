import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/admin/dashboard.dart';
import 'package:notice/user/newNotice.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    try {
      setState(() {
        _isRegistering = true;
      });
      final auth = FirebaseAuth.instance;
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        
      );
      
      // Get the user ID from the created credential
      final userId = credential.user?.uid;

      await credential.user?.updateProfile(displayName: username);

      // Store user details in Firestore
      final userRef = FirebaseFirestore.instance.collection('user');
      await userRef.doc(userId).set({
        'username': username,
        'email': email,
        'password': password,
        'role': 'leader',
        'subscribers': [],
      });

      // Navigate to the dashboard or appropriate screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } on FirebaseAuthException catch (e) {
      // Error handling code...
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "New leader",
          ),
        ),
        elevation: 20,
        toolbarHeight: 70,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 0 ,0),
          child: FittedBox(
            child: SizedBox(
              width: 450,
              child: Column(
                children: [                    
                const SizedBox(height: 20),
                ListTile(
                                leading: const Icon(Icons.person),
                                title: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                labelText: 'Username',
                ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                return 'Please enter your username';
                }
                return null;
                },
                ),
                              ),
                ListTile(
              leading: const Icon(Icons.email),
              title: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email.';
                }
                return null;
              },
            ),
            ),
              ListTile(
              leading: const Icon(Icons.lock),
              title: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                width: 150,
                height: 55,
              child: ElevatedButton(
                    onPressed: _isRegistering
                    ? null
                    : () {
                    if (_formKey.currentState!.validate()) {
                    _registerWithEmailAndPassword(context);
                    }
                    },
                    child: _isRegistering
                    ? const CircularProgressIndicator(
                    color: Colors.white,
                    )
                    : const Text('Register'),
                    ),
            ),


],
),
),
),
),
),
);
}
}
