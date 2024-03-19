import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buy_product.dart';
import 'package:agro/config.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:agro/components/buyer/cart_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class BillingAddressPage extends StatefulWidget {
  final String userId;
  final List<Product> cartItems;
  final double total_amount;

  const BillingAddressPage({
    Key? key,
    required this.userId,
    required this.cartItems,
    required this.total_amount,
  }) : super(key: key);

  @override
  _BillingAddressPageState createState() => _BillingAddressPageState();
}

class _BillingAddressPageState extends State<BillingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String location = '';
  String phoneNumber = '';
  double courierCharge = 200.0; // Example fixed courier charge

  bool isValidBangladeshiPhoneNumber(String phoneNumber) {
    RegExp phoneRegex = RegExp(r'^(\+8801|01)[1-9]\d{8}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  Future<void> submitOrder() async {
    if (name.isEmpty || location.isEmpty || phoneNumber.isEmpty) {
      _showInsufficientValueDialog("Please fill in all fields");
      return;
    }

    if (!isValidBangladeshiPhoneNumber(phoneNumber)) {
      _showInsufficientValueDialog("Please enter a valid phone number");
      return;
    }

    // Implement your logic to submit the order
    // Convert cartItems to a format suitable for your backend
    List<Map<String, dynamic>> cartItemsJson =
    widget.cartItems.map((item) => item.toJson()).toList();

    var orderData = {
      'userId': widget.userId,
      'cartItems': cartItemsJson,
      'billingDetails': {
        'name': name,
        'location': location,
        'phoneNumber': phoneNumber,
        'courierCharge': courierCharge,
      },
      'total_amount': widget.total_amount
    };

    // Example POST request, adjust URL and headers as needed
    var response = await http.post(
      Uri.parse(create_order),
      headers: {"Content-Type": "application/json"},
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      // Handle success
      var order_id = response.body;

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Order Receipt', style: const pw.TextStyle(fontSize: 34)),
                pw.Text('Order ID: $order_id', style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 30),
                pw.Text('Name: $name', style: const pw.TextStyle(fontSize: 28)),
                pw.Text('Location: $location', style: const pw.TextStyle(fontSize: 24)),
                pw.Text('Phone Number: $phoneNumber', style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('Products:', style: const pw.TextStyle(fontSize: 34)),
                ...widget.cartItems.map(
                      (item) => pw.Text(
                    '${item.name} - Quantity: ${item.quantity} - Price: BDT ${item.price}',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Total Product Amount: BDT ${widget.total_amount + courierCharge} (PAID)',
                    style: const pw.TextStyle(fontSize: 24)),
                pw.Text('Courier Charge: BDT $courierCharge (COD)', style: const pw.TextStyle(fontSize: 24)),

                pw.SizedBox(height: 40),
                pw.Text('Courier Company Will Contact you shortly.', style: const pw.TextStyle(fontSize: 24)),
                pw.Text('Thanks from Agro-Farm App', style: const pw.TextStyle(fontSize: 24)),
              ],
            );
          },
        ),
      );

      try {
        final output = await getTemporaryDirectory();
        final file = File("${output.path}/Order_Receipt.pdf");
        await file.writeAsBytes(await pdf.save());
        OpenFile.open(file.path);
      } catch (e) {
        print("Error saving file: $e");
      }
    } else {
      // Handle failure
      print('Failed to submit order');
    }
  }

  void _showInsufficientValueDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insufficient Value Selected'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing Information"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Trigger logout confirmation dialog instead of going back
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CartPage(user_id: widget.userId)));
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Name'), onSaved: (value) => name = value!),
              TextFormField(decoration: const InputDecoration(labelText: 'Location (In Details)'), onSaved: (value) => location = value!),
              TextFormField(decoration: const InputDecoration(labelText: 'Phone Number'), onSaved: (value) => phoneNumber = value!),
              // Display courier charge, no input required
              ListTile(title: Text('Courier Charge: $courierCharge (May vary based on quantity and location)')),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    submitOrder();
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
