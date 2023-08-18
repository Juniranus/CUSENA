import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/admin/login.dart';
import '../admin/newStudent.dart';
import '../forgetPassword.dart';
import '../leaders/postDashboard.dart';
import 'home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

Future<void> _signInWithEmailAndPassword(BuildContext context) async {
  try {
    setState(() {
      _isSigningIn = true;
    });
    final auth = FirebaseAuth.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    
    // Retrieve the user's role from Firestore
    final userRef = FirebaseFirestore.instance.collection('user');
    final userSnapshot = await userRef.doc(user!.uid).get();
    final role = userSnapshot.get('role'); // Assuming the role field is stored in Firestore

    // Navigate to the desired page based on the user's role
    if (role == 'leader') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostDashboard()),
      );
    } else if (role == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User not found'),
          content: const Text('Please check your credential and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User not found'),
          content: const Text('Please check your credential and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
  } finally {
    setState(() {
      _isSigningIn = false;
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
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent),
                  ),
                ),
              ),              
              Container(
                decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: 150,
                  height: 55,
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : () => _signInWithEmailAndPassword(context),
                  child: _isSigningIn
                      ? const CircularProgressIndicator()
                      : const Text('Sign in',
                      style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),),
                ),
              ),
               Padding(
                padding: const EdgeInsets.all(40),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Register here",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminAuth()),
                    );
                  },
                  child: const Text(
                    "Log in as admin",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey),
                  ),
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
