import 'package:agro/home_administrators.dart';
import 'package:agro/home_buyer.dart';
import 'package:agro/pages/verify_email.dart';
import 'package:agro/pages/update_user.dart';
import 'package:flutter/material.dart';
import 'package:agro/pages/register_page.dart';
import 'package:agro/home_seller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  String message;

  LoginPage({required this.message});

  @override
   _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isNotValid = false;
  bool _empty_field = false;
  bool _isNotValid_email = false;

  // Dropdown menu
  final List<String> userRoles = ['Seller', 'Buyer', 'Administrator'];
  String selectedUserRole = 'Seller'; // Initialize with the first role



  // sign user in method
  void logUserIn() async {

    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      setState(() {
        _empty_field = false;
        _isNotValid_email = false;
      });
      bool isValidEmail(String email) {
        print(email);
        // Define a regular expression for a valid email address
        RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        return emailRegex.hasMatch(email);
      }
      if(!isValidEmail(emailController.text)){
        setState(() {
          _isNotValid_email = true;
        });
      }
      if(isValidEmail(emailController.text)){

        var loginBody = {
          "email_nid": emailController.text,
          "password": passwordController.text,
          "role": selectedUserRole, // Include selected user role in the request
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
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(loginBody),
        );
        if(response.statusCode==301){
          Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage(message1: "Please Verify Email", message2: "",destination: "home_page")));
        }
        if (response.statusCode==200) {
          final Map<String, dynamic> userLogin = json.decode(response.body);

          //removing the loading
          Navigator.of(context).pop();


          String userId = userLogin['user_id'];
          String userRole = selectedUserRole;



          Future<void> _saveLoginInformation(String userId, String userRole) async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_id', userId);
            await prefs.setString('user_role', userRole);
          }
          // Call the function to save login information
          await _saveLoginInformation(userId, userRole);

          if(selectedUserRole == 'Seller'){
            emailController.text = "";
            passwordController.text = "";
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage_Seller(user_id:userLogin['user_id'])));
          }else if(selectedUserRole == "Buyer"){
            emailController.text = "";
            passwordController.text = "";
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage_Buyer(user_id:userLogin['user_id'])));
          }else if(selectedUserRole == "Administrator"){
            emailController.text = "";
            passwordController.text = "";
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage_Administrator(user_id:userLogin['user_id'])));
          }

        } else if(response.statusCode==404){
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(message: "Invalid Credintial!!!")));
        }
      }
    } else {
      setState(() {
        _empty_field = true;
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
              const SizedBox(height: 10),
              // logo
              const Icon(
                Icons.lock,
                size: 200,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                  widget.message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 25),
              // username text-field
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
                    errorText: (_isNotValid_email ? "Enter Valid Email" : null),
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
                  controller: passwordController,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password ",
                  ),
                  obscureText: true,
                ),
              ),

              const SizedBox(height: 10),

              // Dropdown menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField<String>(
                  value: selectedUserRole,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUserRole = newValue!;
                    });
                  },
                  items: userRoles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Select User Role',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyEmailPage(message1:"Reset Your Password",message2:"",destination: "update_page")));
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateUserPage(email:"kalyankantihalder02@gmail.com")));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              Column(
                children: [
                  if (_empty_field)
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        "All fields need to be filled",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Add other widgets below if needed
                ],
              ),
              const SizedBox(height: 15),
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
                        "Sign In",
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

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[900],
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                    ),
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
