import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/admin/dashboard.dart';
import 'package:notice/user/newNotice.dart';

import '../user/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

      // Store user details in Firestore
      final userRef = FirebaseFirestore.instance.collection('user');
      await userRef.doc(userId).set({
        'username': username,
        'email': email,
        'password': password,
        'role': 'student',
        'subscribed_to': [],
      });

      // Navigate to the dashboard or appropriate screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: FittedBox(
              child: SizedBox(
                width: 450,
                child: Column(
                  children: [
                    Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: 400,
                      height: 200,
                      child: Center(
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              image: DecorationImage(
                                  image: AssetImage("./images/cuc.png"),
                                  scale: 1,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.topCenter)),
                        ),
                      ),
                    ),
                  ),
                ),
                    const Text("Register Student", 
                    style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.black87),),
                    
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
),
);
}
}
