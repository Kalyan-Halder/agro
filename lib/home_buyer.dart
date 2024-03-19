import 'package:agro/components/buyer/buy_product.dart';
import 'package:agro/components/buyer/cart_page.dart';
import 'package:agro/components/buyer/order_list_buyer.dart';
import 'package:agro/pages/verify_email.dart';
import 'package:dio/dio.dart';
import 'package:agro/pages/verify_email.dart';
import 'package:agro/pages/login_page.dart';
import 'package:agro/components/seller/manage_product.dart';
import 'package:agro/components/seller/order_list_seller.dart';
import 'package:agro/components/seller/totall_top_sales.dart';
import 'package:agro/about_page.dart';
import 'package:flutter/material.dart';
import 'package:agro/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'components/seller/chat_screen.dart';

class MyHomePage_Buyer extends StatefulWidget {
  final String user_id;

  MyHomePage_Buyer({required this.user_id});

  @override
  State<MyHomePage_Buyer> createState() => _MyHomePage_BuyerState();
}

class _MyHomePage_BuyerState extends State<MyHomePage_Buyer> {
  var data;
  final List<CardData> cards = [
    CardData(title: 'Buy Product', image: 'buy.png',state:"buy"),
    CardData(title: 'Cart Items', image: 'cart.png',state:"cart"),
    CardData(title: 'Order Status', image: 'order.png',state:"order"),
    CardData(title: 'Top Products', image: 'graph.png',state:"sales"),
    CardData(title: 'Support', image: 'support.png',state:"help"),
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
                text: 'Home (Buyer)\n',
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
        padding: const EdgeInsets.all(10),
        child: Center(
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
                  if(cards[index].state == "buy"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BuyProductPage(user_id:widget.user_id)));
                  }else if(cards[index].state == "cart"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(user_id: widget.user_id,)));
                  }else if(cards[index].state == "order"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPageBuyer(user_id:widget.user_id)));
                  }else if(cards[index].state == "sales"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalProductSalesPage(user_id: '',)));
                  }else if(cards[index].state == "about"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                  }else if(cards[index].state == "help"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
                  }
                  print('Card tapped: ${cards[index].title}');
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image (replace 'assets/' with your actual image path)
                      Image.asset(
                        'assets/icons/${cards[index].image}',
                        height: 80.0,
                      ),
                      const SizedBox(height: 8.0),
                      // Title
                      Text(
                        cards[index].title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),

    );
  }
}

class CardData {
  final String title;
  final String image;
  final String state;

  CardData({required this.title, required this.image,required this.state});
}
