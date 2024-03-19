import 'package:agro/pages/login_page.dart';
import 'package:agro/pages/update_user.dart';
import 'package:flutter/material.dart';
import 'package:agro/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';
import 'package:agro/pages/verify_token.dart';

class VerifyEmailPage extends StatefulWidget {
  String message1,message2,destination;
  VerifyEmailPage({required this.message1,required this.message2,required this.destination});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  // text editing controllers
  TextEditingController emailController = TextEditingController();
  bool _isNotValid = false;

  // Forget user method
  void resetPass() async {
    if (emailController.text.isNotEmpty) {

      var forgotBody = {
        "email": emailController.text,
      };

      //ADDING a loading circle
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal), // Modern color
                    strokeWidth: 5.0,
                    semanticsLabel: 'Loading',
                  ),
                ],
              ),
            ),
          );
        },
      );


      var response = await http.post(
        Uri.parse(send_mail),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(forgotBody),
      );

      if (response.statusCode == 200) {
        // Password reset email sent successfully
        print('Password reset email sent!');
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyTokenPage(destination:widget.destination,email:emailController.text)));
      } else {
        // Handle errors, display a message to the user, etc.
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage(message1: "Try Again", message2: "Something Went Wrong", destination: "")));
      }
    } else {
      setState(() {
        _isNotValid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // logo
              const Icon(
                Icons.lock,
                size: 200,
              ),
              const SizedBox(height: 20),
              Text(
                widget.message1,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              Text(
                widget.message2,//dynamic message here
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),

              // username textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _isNotValid ? "Enter Valid Info" : null,
                    hintText: "Enter Email Address",
                  ),
                  obscureText: false,
                ),
              ),

              const SizedBox(height: 10),

              // sign in button
              GestureDetector(
                onTap: resetPass,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        resetPass();
                      },
                      child: const Text(
                        "Send Verification Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go Signup',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    child: const Text("Sign Up"),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterPage(),
                        ),
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
