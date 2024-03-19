import 'package:flutter/material.dart';
import 'package:agro/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';

class UpdateUserPage extends StatefulWidget {
  String email;
  UpdateUserPage({required this.email});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();

}
class _UpdateUserPageState extends State<UpdateUserPage> {

  var data;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool _empty_field = false;
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

  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    print(widget.email);
    try{
      var loginBody = {
        "email": widget.email,
      };
      var response = await http.post(
        Uri.parse(user),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginBody),
      );
      setState(() {
        // Store the fetched data in the class-level variable
        data = jsonDecode(response.body);
      });
    }catch(error){
      print("Error fetching data: $error");
    }
  }

  void userUpdate() async {
    if (confirmPasswordController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      setState(() {
        _empty_field = false;
        _isNotValid_phone = false;
        _isNotValid_password = false;
        _missmatched_password = false;
      });
      bool isMatchedPassword(String password,String confirmPassword){
        if(password == confirmPassword){
          return true;
        }else{
          return false;
        }
      }
      bool isValidPassword(String password) {
        // Check for a minimum of 8 characters
        return password.length >= 8;
      }


      if(!isValidPassword(passwordController.text)){
        setState(() {
          _isNotValid_password = true;
        });
      }
      if(!isMatchedPassword(passwordController.text,confirmPasswordController.text)){
        setState(() {
          _missmatched_password = true;
        });
      }

      if(isValidPassword(passwordController.text) && isMatchedPassword(passwordController.text,confirmPasswordController.text)){
        var updateBody = {
          "_id": '${data?['_id']}',
          "email":'${data?['email']}',
          "name":nameController.text.isEmpty ? '${data?['name']}' : nameController.text,
          "phone":phoneController.text.isEmpty ? '${data?['phone']}' :phoneController.text,
          "password":passwordController.text.isEmpty? '${data?['password']}':passwordController.text,
          "cpassword":confirmPasswordController.text.isEmpty? '${data?['password']}':confirmPasswordController.text,
          "location": selectedLocation.isEmpty?'${data?['location']}' :selectedLocation,
          "role":selectedUserRole.isEmpty ? '${data?['role']}' : selectedUserRole
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


        var response = await http.post(Uri.parse(update_user),
            headers:{"Content-Type":"application/json"},
            body:jsonEncode(updateBody)
        );
        if(response.statusCode == 200){
          //removing the loading
          Navigator.of(context).pop();

          Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage(message: "User Updated Successfully",)));
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
                  Icons.supervised_user_circle_outlined,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 46,
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
                          hintText: '${data?['name']}',
                        ),
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
                          fillColor: Colors.white,
                          errorText:  (_isNotValid_password ? "Enter 8 character password" : (_missmatched_password ? "Password Mismatch" : null)),
                          hintText: "Enter New password",
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
                          hintText: "Confirm New password",
                          errorText: (_isNotValid_password ? "Enter 8 character password" : (_missmatched_password ? "Password Mismatch" : null)),
                        ),
                        obscureText: true,
                      )
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
                          "Passwords missing",
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
                          userUpdate();
                        },
                        child: const Text(
                          "Update Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      child: const Text("Sign in"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(message: 'Welcome back you\'ve been missed!',),
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
