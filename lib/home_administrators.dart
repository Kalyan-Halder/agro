import 'package:dio/dio.dart';
import 'package:agro/pages/login_page.dart';
import 'package:agro/components/administrator/all_list.dart';
import 'package:agro/components/administrator/manage_product_Admin.dart';
import 'package:agro/components/administrator/authorized_list.dart';
import 'package:flutter/material.dart';
import 'package:agro/config.dart';
import 'package:agro/components/seller/chat_screen.dart';
import 'package:agro/components/seller/order_list_seller.dart';
import 'package:agro/components/seller/top_sales.dart';
import 'package:agro/components/seller/totall_top_sales.dart';
import 'package:agro/about_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyHomePage_Administrator extends StatefulWidget {
  final String user_id;

  MyHomePage_Administrator({required this.user_id});

  @override
  State<MyHomePage_Administrator> createState() => _MyHomePage_AdministratorState();
}

class _MyHomePage_AdministratorState extends State<MyHomePage_Administrator> {

  List<String> dropdownItems = ['All' ,'Grains', 'Vegetables', 'Fruits', 'Dairy', 'Others'];
  String? selectedDropdownItem = 'All'; // Initial value set to 'All'

  var data;
  final List<CardData> cards = [
    CardData(title: 'All', image: 'confirm1.png',state:"all"),
    CardData(title: 'Unauthorized', image: 'pending.png',state:"product"),
    CardData(title: 'Authorized List', image: 'confirm2.png',state:"order"),
    CardData(title: 'Market Stats', image: 'sales.png',state:"market"),
    CardData(title: 'Chat', image: 'support.png',state:"help"),
    CardData(title: 'About', image: 'about.png',state:"about"),
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    print("getData called with user_id: ${widget.user_id}");
    try {
      var response = await http.get(
          Uri.parse('$user/${widget.user_id}'),
          headers: {"Content-Type": "application/json"}
      );
      setState(() {
        // Store the fetched data in the class-level variable
        data = jsonDecode(response.body);
      });
      // Process the response data as needed
    } catch (error) {
      print("Error fetching data: $error");
      // Handle errors as needed
    }
  }

  //logout  code
  Future<void> logoutCurrentUser(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Remove only user-specific preferences
    await prefs.remove('user_id');
    await prefs.remove('user_role');

    // After clearing the preferences, navigate the user to the LoginPage
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage(message: 'You Have Been Logged Out',))); // Make sure LoginPage is imported and available
  }

  Future<void> showLogoutConfirmationDialog(BuildContext context) async {
    // Show dialog asking user to confirm logout
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User presses "No"
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User presses "Yes"
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ??
        false; // Assuming "No" as default action if the dialog is dismissed

    // If the user confirmed, proceed with the logout
    if (confirmed) {
      await logoutCurrentUser(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Home (Administrator)\n',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              TextSpan(
                text: '${data?['name']}',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Trigger logout confirmation dialog instead of going back
            showLogoutConfirmationDialog(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.logout,
                size: 30,
                color: Colors.red,
              ),
              onPressed: () {
                // Show confirmation dialog before logging out
                showLogoutConfirmationDialog(context);
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 36.0,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(cards[index].state == "product"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProductAdminPage(user_id:widget.user_id)));
                }else if(cards[index].state == "order"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProductAdminAuthPage(user_id: widget.user_id,)));
                }else if(cards[index].state == "market"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalProductSalesPage(user_id: widget.user_id)));
                }else if(cards[index].state == "all"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAllAdminPage(user_id: widget.user_id)));
                }else if(cards[index].state == "about"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                }else if(cards[index].state == "help"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
                }
                print('Card tapped: ${cards[index].state}');
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/${cards[index].image}',
                      height: 80.0,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      cards[index].title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CardData {
  final String title;
  final String image;
  final String state;
  CardData({required this.title, required this.image, required this.state});
}
