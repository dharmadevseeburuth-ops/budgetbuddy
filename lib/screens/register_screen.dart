import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Password"), obscureText: true),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                String result = await Provider.of<AuthProvider>(context, listen: false)
                    .register(emailController.text, passController.text);

                if (result == "success") {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Registered successfully")));

                  Navigator.pop(context);
                } else if (result == "exists") {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Email already exists")));
                } else if (result == "email_invalid") {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Invalid email format")));
                } else if (result == "invalid") {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Fill all fields")));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Something went wrong")));
                }
              },
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}