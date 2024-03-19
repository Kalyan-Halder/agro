import 'dart:convert';
import 'package:agro/home_buyer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'billing_address_page.dart';
import 'buy_product.dart';
import 'package:agro/config.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
import 'package:flutter/src/material/card.dart' as MaterialCard;
import 'package:agro/components/buyer/buy_product.dart';

class CartPage extends StatefulWidget {
  final String user_id;

  CartPage({required this.user_id});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartItems = [];

  Map<String, dynamic>? paymentIntentData;

  @override
  void initState() {
    super.initState();
    getData(widget.user_id);
  }

  void getData(String user_id) async {
    try {
      var response1 = await http.get(
        Uri.parse('$get_cart_details/$user_id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response1.statusCode == 200) {
        var data = jsonDecode(response1.body);

        List<Product> fetchedCartItems = data.map<Product>((item) {
          return Product(
            id: item['_id'],
            local_id: item['product']['local_id'],
            name: item['product']['name'],
            quantity: item['product']['quantity'],
            category: item['product']['category'],
            price: item['product']['price'].toDouble(),
            seller_id: item['product']['seller_id'],
            isVerified: item['product']['isVerified'],
          );
        }).toList();

        setState(() {
          cartItems = fetchedCartItems;
        });
      } else {
        print("Error fetching cart data: ${response1.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void deleteCartItem(String userId, String cartItemId) async {
    try {
      var response = await http.get(
        Uri.parse('$delete_cart/$userId/$cartItemId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        getData(widget.user_id);
      } else {
        print("Error deleting cart item: ${response.statusCode}");
      }
    } catch (error) {
      print("Error deleting cart item: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Trigger logout confirmation dialog instead of going back
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => BuyProductPage(user_id: widget.user_id)));
          },
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemWidget(
                    product: cartItems[index],
                    onDelete: () {
                      _showDeleteConfirmationDialog(context, cartItems[index]);
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        height: 126,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total: ${calculateTotalCost(cartItems)} taka Only',
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyProductPage(
                          user_id: widget.user_id,),
                    ),
                  );
                },
                child: const Icon(Icons.arrow_circle_left),
              ),
              ElevatedButton(
                onPressed: () {
                  _goToAnotherPage();
                },
                child: const Icon(Icons.home),
              ),
              ElevatedButton(
                onPressed: () async {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillingAddressPage(
                          userId: widget.user_id,
                          cartItems: cartItems,
                          total_amount: calculateTotalCost(cartItems)),
                    ),
                  );*/
                  await _proceedToPayment();
                },
                child: const Icon(Icons.payment),
              )
            ],
          ),
        ]),
      ),
    );
  }

  double calculateTotalCost(List<Product> cartItems) {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _proceedToPayment() async {
    try {
      var amount = calculateTotalCost(cartItems);


      if(amount>0){

        var amountInCents = (amount * 100).toInt();

        Map<String, dynamic>? body = {
          'amount': amountInCents.toString(),
          'currency': 'USD',
          'payment_method_types[]': 'card',
          'description': 'Description of goods/services being exported'
        };
        var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer sk_test_51Okp0VCxHjTTIp5d7gF3DZjoCs3mDjao9Q25Bkob4oBaFkbMqL0AzgCPvDDhWJDWLeogzByIzSfkzJPC7TsNS11Z009ZrVsymX',
            'Content-type': 'application/x-www-form-urlencoded'
          },
        );
        paymentIntentData = json.decode(response.body.toString());
        print(paymentIntentData);

      }else{

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('No Item Selected')),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error initializing PaymentSheet: $e");
    }
    var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: 'US', currencyCode: 'US', testEnv: true);
    await Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData!['client_secret'],
                style: ThemeMode.light,
                merchantDisplayName: "Agro-Market",
                googlePay: gpay))
        .then((value) => {});

    try {
      await Stripe.instance.presentPaymentSheet().then((value) => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillingAddressPage(
                    userId: widget.user_id,
                    cartItems: cartItems,
                    total_amount: calculateTotalCost(cartItems)),
              ),
            )
          });
    } catch (error) {
      print(error.toString());
    }
  }

  void _goToAnotherPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage_Buyer(user_id: widget.user_id)),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this item from your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                deleteCartItem(widget.user_id, cartItem.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final Product product;
  final Function() onDelete;

  CartItemWidget({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return MaterialCard.Card(
      // Use MaterialCard.Card instead of Card
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
            '${product.name} - ${product.quantity} ${getUnit(product.category)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product.category}'),
            Text(
                'Price: ${product.price} Taka per ${getUnit(product.category)}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
          style: ButtonStyle(
              iconColor: MaterialStateProperty.all<Color>(Colors.red)),
        ),
      ),
    );
  }

  String getUnit(String category) {
    switch (category) {
      case 'Grains':
      case 'Vegetables':
        return 'KG';
      case 'Fruits':
        return 'Pieces';
      case 'Dairy':
        return 'Litter';
      case 'Others':
        return 'Units';
      default:
        return '';
    }
  }
}
