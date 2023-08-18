// ignore_for_file: file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  

  Future createHead(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInAdmin(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void logout() async {
    await _firebaseAuth.signOut();
  }

  

}

