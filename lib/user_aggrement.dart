import 'package:flutter/material.dart';
import 'package:agro/onbording.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import your specific page here

class UserAgreementPage extends StatefulWidget {
  @override
  _UserAgreementPageState createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  bool _agreedToTerms = false;

  Future<void> _setAgreedToTerms(bool newValue) async {
    setState(() {
      _agreedToTerms = newValue;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('agreed_to_terms', newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("User Agreement")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Terms and Conditions text or widget here
            const Expanded(
              child: SingleChildScrollView(
                child: Text("By checking this box, you acknowledge that you have read, understood, and agree to be bound by the Agro-Farm Market System's Terms of Use and Privacy Policy. You agree to comply with all applicable laws and regulations related to your use of our application. You affirm that you are of legal age to enter into this agreement. If you do not agree to these terms, do not use the Agro-Farm Market System app."),
              ),
            ),
            const Text(
              'If you agree with us , We Can:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildFeatureTile('Share Contacts among users'),
            buildFeatureTile('Send email to you'),
            buildFeatureTile('Save Product data to your local device'),
            buildFeatureTile('Administrative people can contact you'),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (bool? newValue) {
                    _setAgreedToTerms(newValue!);
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => !_agreedToTerms ? null : Navigator.of(context).push(MaterialPageRoute(builder: (context) => Onbording())), // Update with your specific page
                    child: const Text("I agree to the terms and conditions."),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agreedToTerms ? () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Onbording())) : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (!_agreedToTerms) return Colors.grey; // Disabled color
                    return Theme.of(context).secondaryHeaderColor; // Regular color
                  },
                ),
              ), // Update with your specific page
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
Widget buildFeatureTile(String feature) {
  return ListTile(
    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
    title: Text(feature, style: const TextStyle(fontSize: 16)),
  );
}
