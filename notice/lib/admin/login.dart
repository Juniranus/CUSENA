import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notice/admin/dashboard.dart';
import 'package:notice/user/newNotice.dart';

class AdminAuth extends StatefulWidget {
  const AdminAuth({Key? key}) : super(key: key);

  @override
  _AdminAuthState createState() => _AdminAuthState();
}

class _AdminAuthState extends State<AdminAuth> {
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
    
    // Check if the user exists in the collection
    final userRef = FirebaseFirestore.instance.collection('user');
    final userSnapshot = await userRef.doc(user!.uid).get();
    if (userSnapshot.exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unauthorize access'),
          content: const Text('You are not an administrator.'),
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
      
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  } on FirebaseAuthException catch (e) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
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
                const SizedBox(height: 20.0),
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
