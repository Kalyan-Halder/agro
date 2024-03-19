import 'package:agro/home_administrators.dart';
import 'package:agro/home_buyer.dart';
import 'package:agro/pages/login_page.dart';
import 'package:agro/pages/verify_email.dart';
import 'package:agro/pages/update_user.dart';
import 'package:flutter/material.dart';
import 'package:agro/pages/register_page.dart';
import 'package:agro/home_seller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';

class VerifyTokenPage extends StatefulWidget {
  String destination,email;
  VerifyTokenPage({required this.destination,required this.email});

  @override
  _VerifyTokenPageState createState() => _VerifyTokenPageState();
}

class _VerifyTokenPageState extends State<VerifyTokenPage> {

  late TextEditingController emailController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    emailController = TextEditingController(text: widget.email);
  }
  // text editing controllers
  TextEditingController textController = TextEditingController();
  bool _isNotValid = false;


  // sign user in method
  void logUserIn() async {
    if (emailController.text.isNotEmpty && textController.text.isNotEmpty) {
      var loginBody = {
        "email": emailController.text,
        "token": textController.text,
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
        Uri.parse(verify),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginBody),
      );
      //check condition of the status code
      if(response.statusCode==200){
        //removing the loading screen
        Navigator.of(context).pop();
        print(widget.destination);
        if(widget.destination=='login_page'){
           Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(message: "Verification Successful",)));
        }else if(widget.destination=='home_page'){
           Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(message: "Verification Successful",)));
        }else if(widget.destination=='update_page'){
           Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateUserPage(email:emailController.text)));
        }
      }else if(response.statusCode==404){
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage(message1:"Please Re-enter",message2: "Something Went wrong!!",destination: "")));
      }else if(response.statusCode==300){
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage(message1:"Please Re-enter",message2: "Token Has Expired!",destination: "")));
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
              const SizedBox(height: 40),
              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 40),
              Text(
                'Verify Yourself.\nWe have sent you an email with a unique token.\nProvide the code along with the email.\n'
                    'The token will be invalid after 3 minutes\n of creation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

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
                    hintText: "Email / NID",
                  ),
                  obscureText: false,
                ),
              ),

              const SizedBox(height: 10),

              // password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: textController,
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
                    hintText: "Token",
                  ),
                  obscureText: false,
                ),
              ),

              const SizedBox(height: 10),


              // sign in button
              GestureDetector(
                onTap: logUserIn,
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
                        logUserIn();
                      },
                      child: const Text(
                        "Verify",
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
                    'Not a member?',
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
