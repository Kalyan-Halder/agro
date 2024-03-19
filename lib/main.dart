import 'package:agro/home_administrators.dart';
import 'package:agro/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:agro/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agro/home_buyer.dart';
import 'package:agro/home_seller.dart';
import 'package:agro/user_aggrement.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51Okp0VCxHjTTIp5dkAPA16YAnAxeLTp6LOkWlwnmVHB428w6CYjRLuaiwuCPVlfsL2rgdGPhU6rL3ZhnwgW6Gn6y00zWmMQE0J";
  final loginStatus = await getLoginStatus();
  runApp(MyApp(loginStatus: loginStatus));
}

Future<Map<String, dynamic>> getLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  String? userRole = prefs.getString('user_role');
  bool hasAgreedToTerms = prefs.getBool('agreed_to_terms') ?? false;

  return {
    'isLoggedIn': userId != null && userRole != null,
    'userId': userId ?? '',
    'userRole': userRole ?? '',
    'hasAgreedToTerms': hasAgreedToTerms,
  };
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> loginStatus;

  MyApp({Key? key, required this.loginStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: determineHomePage(),
    );
  }

  Widget determineHomePage() {
    if(!loginStatus['isLoggedIn'] && loginStatus['hasAgreedToTerms']){
       //return LoginPage(message: "Please Login");
      return WelcomePage();
    }else if (!loginStatus['isLoggedIn'] && !loginStatus['hasAgreedToTerms']) {
      return UserAgreementPage();
    }

    switch (loginStatus['userRole']) {
      case 'Seller':
        return MyHomePage_Seller(user_id: loginStatus['userId']);
      case 'Buyer':
        return MyHomePage_Buyer(user_id: loginStatus['userId']);
      case 'Administrator':
        return MyHomePage_Administrator(user_id: loginStatus['userId']);
      default:
        return UserAgreementPage();
    }
  }

}
