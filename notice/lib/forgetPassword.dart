import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String _statusMessage = '';
  bool _issent = false;

  void _resetPassword() async {
    final String email = _emailController.text.trim();
    

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _statusMessage = 'Password reset email sent. Please check your inbox.';
        _issent = true;
      });
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: Unable to send password reset email. Please check email and try again.';
        _issent = false;
      });
      print('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 100, 0 , 0),
              child: Center(
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
            ),
            const Padding(
                   padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                   child: Text(
                   'Forgot password.',
                   style: TextStyle(
                     fontSize: 25,
                     fontWeight: FontWeight.bold,
                     color: Colors.black87,
                   ),
                               ),
                 ),
                 const Padding(
                   padding: EdgeInsets.fromLTRB(20, 0, 0, 50),
                   child: Text(
                   'Enter your valid email linked to your account to receive a password reset link',
                   style: TextStyle(
                     fontSize: 15,
                     color: Colors.black87,
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
            SizedBox(height: 16.0),
            Container(
                decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: 150,
                  height: 55,
                  child:ElevatedButton(
                  onPressed: _resetPassword, 
                  child: _issent
                      ? const CircularProgressIndicator()
                      : const Text('Reset',
                      style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),),
                ),),
            SizedBox(height: 16.0),
            Text(_statusMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
