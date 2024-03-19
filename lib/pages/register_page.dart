import 'package:agro/pages/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:agro/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController nidController = TextEditingController();

  bool _empty_field = false;
  bool _isNotValid_email = false;
  bool _isNotValid_nid = false;
  bool _isNotValid_phone = false;
  bool _isNotValid_password = false;
  bool _missmatched_password = false;

  final List<String> userRoles = ['Seller', 'Buyer', 'Administrator'];
  final List<String>  location = [
    'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogura', 'Brahmanbaria', 'Chandpur', 'Chattogram',
    'Chuadanga', 'Comilla', 'Cox\'s Bazar', 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni', 'Gaibandha', 'Gazipur', 'Gopalganj',
    'Habiganj', 'Jamalpur', 'Jashore (Jessore)', 'Jhalokathi', 'Jhenaidah', 'Joypurhat', 'Khagrachari', 'Khulna', 'Kishoreganj',
    'Kushtia', 'Lakshmipur', 'Lalmonirhat', 'Madaripur', 'Magura', 'Manikganj', 'Meherpur', 'Moulvibazar', 'Munshiganj', 'Mymensingh',
    'Naogaon', 'Narail', 'Narayanganj', 'Narsingdi', 'Natore', 'Netrokona', 'Nilphamari', 'Noakhali', 'Pabna', 'Panchagarh',
    'Patuakhali', 'Pirojpur', 'Rajbari', 'Rajshahi', 'Rangamati', 'Rangpur', 'Satkhira', 'Shariatpur', 'Sherpur', 'Sirajganj',
    'Sunamganj', 'Sylhet', 'Tangail', 'Thakurgaon'
  ];

  String selectedUserRole = 'Seller'; // Initialize with the first role
  String selectedLocation = 'Dhaka';


  void signUserUp() async {
     if (emailController.text.isNotEmpty && nidController.text.isNotEmpty && passwordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty && selectedLocation.isNotEmpty && nameController.text.isNotEmpty  && selectedUserRole.isNotEmpty) {
       setState(() {
         _empty_field = false;
         _isNotValid_email = false;
         _isNotValid_nid = false;
         _isNotValid_phone = false;
         _isNotValid_password = false;
         _missmatched_password = false;
       });
       //check if the data is valid or not

       bool isMatchedPassword(String password,String confirmPassword){
         if(password == confirmPassword){
           return true;
         }else{
           return false;
         }
       }

       bool isValidEmail(String email) {
         // Define a regular expression for a valid email address
         RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
         return emailRegex.hasMatch(email);
       }

       bool isValidBangladeshiPhoneNumber(String phoneNumber) {
         // Define a regular expression for a valid Bangladeshi phone number
         RegExp phoneRegex = RegExp(r'^(\+8801|01)[1-9]\d{8}$');
         return phoneRegex.hasMatch(phoneNumber);
       }

       bool isValidNIDNumber(String nidNumber) {
         // Define a regular expression for a valid 18-digit NID number
         RegExp nidRegex = RegExp(r'^\d{10}$');
         return nidRegex.hasMatch(nidNumber);
       }

       bool isValidPassword(String password) {
         // Check for a minimum of 8 characters
         return password.length >= 8;
       }
       if(!isValidEmail(emailController.text)){
         setState(() {
           _isNotValid_email = true;
         });
       }if(!isValidBangladeshiPhoneNumber(phoneController.text)){
         setState(() {
           _isNotValid_phone = true;
         });
       }if(!isValidNIDNumber(nidController.text)){
         setState(() {
           _isNotValid_nid = true;
         });
       }if(!isValidPassword(passwordController.text)){
         setState(() {
           _isNotValid_password = true;
         });
       }if(!isMatchedPassword(passwordController.text,confirmPasswordController.text)){
         setState(() {
           _missmatched_password = true;
         });
       }
       if(isValidEmail(emailController.text) && isValidBangladeshiPhoneNumber(phoneController.text) && isValidNIDNumber(nidController.text) && isValidPassword(passwordController.text) && isMatchedPassword(passwordController.text,confirmPasswordController.text)){
         var registerBody = {
           "name":nameController.text,
           "email":emailController.text,
           "nid":nidController.text,
           "phone":phoneController.text,
           "password":passwordController.text,
           "cpassword":confirmPasswordController.text,
           "location": selectedLocation,
           "role":selectedUserRole
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

         var response = await http.post(Uri.parse(register),
             headers:{"Content-Type":"application/json"},
             body:jsonEncode(registerBody)
         );
         if(response.statusCode==200){
           //removing the loading
           Navigator.of(context).pop();
           Navigator.push(context,MaterialPageRoute(builder: (context)=>VerifyEmailPage(message1: "Verify Your Email", message2: "",destination: "login_page")));
         }else if(response.statusCode==422){
           //removing the loading
           Navigator.of(context).pop();
           //Navigator.push(context,MaterialPageRoute(builder: (context)=>VerifyEmailPage(message1: "Verify Your Email", message2: "",destination: "login_page")));
           setState(() {
             _isNotValid_email = true;
           });
           print("Error happened");
         }
       }
     }else{
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.add_reaction,
                  size: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please Join us',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your Name/Organization",
                        ),
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      TextField(
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
                          errorText: (_isNotValid_email ? "Enter Valid email that no previous account with us" : null),
                          hintText: "Enter your email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nidController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          errorText: (_isNotValid_nid ? "Enter Valid NID" : null),
                          fillColor: Colors.white,
                          hintText: "Enter NID number",
                        ),
                        keyboardType: TextInputType.phone,
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorText:  (_isNotValid_phone ? "Enter Valid Phone Number" : null),
                          hintText: "Enter your phone number",
                        ),
                        keyboardType: TextInputType.phone,
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          errorText:  (_isNotValid_password ? "Enter 8 character password" : (_missmatched_password ? "Password Mismatch" : null)),
                          fillColor: Colors.white,
                          hintText: "Enter your password",
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: (_isNotValid_password ? "Enter 8 character password" : (_missmatched_password ? "Password Mismatch" : null)),
                          hintText: "Confirm your password",
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedLocation,
                    icon:const  Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLocation = newValue!;
                      });
                    },
                    items: location.map<DropdownMenuItem<String>>((String value) {
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedUserRole,
                    icon:const  Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
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
                const SizedBox(height: 10),
                GestureDetector(
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
                          // Your logic here
                          signUserUp();
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      child: const Text("Sign in"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(message: "Welcome back !!!",),
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
