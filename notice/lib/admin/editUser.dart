import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final String username;
  final String password;
  final String role;
  final String email;

  EditUserPage({required this.userId,required this.email, required this.password, required this.role, required this.username});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.username;
    passwordController.text = widget.password;
    roleController.text = widget.role;
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Edit leader",
          ),
        ),
        elevation: 20,
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 80, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                style: TextStyle(fontSize: 20),
                controller: usernameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter username' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                style: TextStyle(fontSize: 20),
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter password' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                style: TextStyle(fontSize: 20),
                controller: roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                  hintText: 'Enter role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter role' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                style: TextStyle(fontSize: 20),
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  // Save the edited user to Firestore
                  await FirebaseFirestore.instance.collection('user').doc(widget.userId).update({
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'role': roleController.text,
                    'email': emailController.text,
                  });
      
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  width: 300,
                  height: 60,
                  child: Center(
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
