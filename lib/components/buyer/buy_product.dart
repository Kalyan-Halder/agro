import 'package:agro/home_buyer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';
import 'package:agro/pages/image_details.dart';
import 'cart_page.dart';

void main() {
  runApp(MaterialApp(
    home: BuyProductPage(user_id: ''),
  ));
}

class Product {
  final String id;
  final String local_id;
  final String name;
  int quantity;
  final String category;
  double price;
  final String seller_id;
  bool isVerified;

  Product({
    required this.id,
    required this.local_id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.price,
    required this.seller_id,
    this.isVerified = false,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'local_id': local_id,
    'name': name,
    'quantity': quantity,
    'category': category,
    'price': price,
    'seller_id': seller_id,
    'isVerified': isVerified,
  };
}

class BuyProductPage extends StatefulWidget {
  final String user_id;

  BuyProductPage({required this.user_id});

  @override
  _BuyProductPageState createState() => _BuyProductPageState(user_id);
}

class _BuyProductPageState extends State<BuyProductPage> {
  List<Product> products = [];
  List<Product> cartItems = [];
  int uniqueProductsInCart = 0; // Number of unique products in the cart

  List<String> dropdownItems = ['All' ,'Grains', 'Vegetables', 'Fruits', 'Dairy', 'Others'];
  String? selectedDropdownItem = 'All'; // Initial value set to 'All'

  String? selectedVerificationItem = 'Verified'; // Initial value set to 'All'
  List<String> verificationItems = ['All', 'Verified', 'Not Verified'];

  _BuyProductPageState(String user_id) {
    getData(user_id);
  }

  @override
  void initState() {
    super.initState();
    getData(widget.user_id);
  }

  void getData(String user_id) async {
    // Your original data fetching logic goes here
    print("GetData is called");
    try {
      var response = await http.get(
        Uri.parse(product_lsit),
        headers: {"Content-Type": "application/json"},
      );
      var response1 = await http.get(
        Uri.parse('$get_cart_digit/$user_id'),
        headers: {"Content-Type": "application/json"},
      );
      if(response1.statusCode==200){
        var length = jsonDecode(response1.body);
        setState(() {
          uniqueProductsInCart = length;
        });
      }
      if (response.statusCode == 200) {
        List<Product> fetchedProducts = (jsonDecode(response.body) as List)
            .map((data) => Product(
          id: data['_id'] ?? '',
          local_id: data['local_id'] ?? '',
          name: data['name'] ?? '',
          quantity: data['quantity'] ?? 0,
          category: data['category'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          seller_id: data['seller_id'] ?? '',
          isVerified: data['isVerified'] ?? false,
        ))
            .toList();

        setState(() {
          products = fetchedProducts;
        });
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _confirmBuyProduct(int index) {
    TextEditingController quantityController = TextEditingController();
    int availableQuantity = products[index].quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buy Product'),
          content: Column(
            children: [
              const Text('Enter Quantity:'),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int selectedQuantity = int.tryParse(quantityController.text) ?? 1;
                if (selectedQuantity > availableQuantity) {
                  // Wrong input, show error popup
                  Navigator.pop(context); // Close the current dialog
                  _showErrorPopup('Invalid Quantity', 'Selected quantity exceeds available quantity.');
                } else {
                  // Proceed to buy
                  _buyProduct(products[index], selectedQuantity);
                  Navigator.pop(context);
                }
              },
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );
  }
  void _getDetails(int index){
       String local_id = products[index].local_id;
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => ImageDetailsPage(local_id: local_id,),
         ),
       );
  }

  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _buyProduct(Product product, int quantity) async{
    Product selectedProduct = Product(
      id: product.id,
      local_id: product.local_id,
      name: product.name,
      quantity: quantity,
      category: product.category,
      price: product.price,
      seller_id: product.seller_id,
      isVerified: product.isVerified,
    );

    try {
      var cartBody = {
        "buyer_id": widget.user_id,
        "cart_items": [
          {
            "product": {
              "id": selectedProduct.id,
              "local_id": selectedProduct.local_id,
              "name": selectedProduct.name,
              "quantity": selectedProduct.quantity,
              "category": selectedProduct.category,
              "price": selectedProduct.price,
              "seller_id" : selectedProduct.seller_id,
              "isVerified": bool.fromEnvironment(selectedProduct.isVerified.toString()),
            }
          }
        ]
      };

      var response = await http.post(
        Uri.parse(add_to_cart),
        headers: {"Content-Type": "application/json"},
          body:jsonEncode(cartBody)
      );

      if (response.statusCode == 201) {
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }

    if (!cartItems.contains(selectedProduct)) {
      setState(() {
        cartItems.add(selectedProduct);
        uniqueProductsInCart++;
      });
    }
    /*
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems, user_id: widget.user_id),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage_Buyer(user_id: widget.user_id)));
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 44.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage(user_id: widget.user_id)),
                  );
                },
              ),
              if (uniqueProductsInCart > 0)
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 8.0,
                    child: Text(
                      uniqueProductsInCart.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDropdownItem,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDropdownItem = newValue;
                        });
                      },
                      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                        int count = getCountForCategory(value);
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(child: Text('$value ($count)')),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing between dropdowns
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedVerificationItem,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVerificationItem = newValue;
                        });
                      },
                      items: verificationItems.map<DropdownMenuItem<String>>((String value) {
                        int count = getCountForVerifiedStatus(value);
                        return DropdownMenuItem<String>(
                          value: value,
                          child:Center(child: Text('$value ($count)'),),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              products.where((product) {
                bool matchesCategory = selectedDropdownItem == 'All' || product.category == selectedDropdownItem;
                bool matchesVerification = selectedVerificationItem == 'All' ||
                    (selectedVerificationItem == 'Verified' && product.isVerified) ||
                    (selectedVerificationItem == 'Not Verified' && !product.isVerified);
                return matchesCategory && matchesVerification;
              }).isEmpty
                  ? const Center(child: Text('No products found matching the criteria.'))
                  : Column(
                children: products.where((product) {
                  bool matchesCategory = selectedDropdownItem == 'All' || product.category == selectedDropdownItem;
                  bool matchesVerification = selectedVerificationItem == 'All' ||
                      (selectedVerificationItem == 'Verified' && product.isVerified) ||
                      (selectedVerificationItem == 'Not Verified' && !product.isVerified);
                  return matchesCategory && matchesVerification;
                }).map((product) {
                  return ProductListItem(
                    product: product,
                    onBuy: () {
                      _confirmBuyProduct(products.indexOf(product));
                    },
                    onDetails: (){
                      _getDetails(products.indexOf(product));
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getCountForVerifiedStatus(String status) {
    switch (status) {
      case 'All':
        return products.length;
      case 'Verified':
        return products.where((product) => product.isVerified).length;
      case 'Not Verified':
        return products.where((product) => !product.isVerified).length;
      default:
        return 0;
    }
  }

  int getCountForCategory(String category) {
    if (category == 'All') {
      return products.length;
    }
    return products.where((product) => product.category == category).length;
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;
  final Function() onBuy;
  final Function() onDetails;

  ProductListItem({
    required this.product,
    required this.onBuy,
    required this.onDetails
  });

  String get unit {
    switch (product.category) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: product.isVerified ? Colors.green : Colors.red,
      child: ListTile(
        title: Text('${product.name} - ${product.quantity} $unit'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product.category}'),
            Text('Price: ${product.price} Taka per $unit'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: onBuy,
              style: ButtonStyle(
                // Setting the foreground color (icon color) to white
                foregroundColor: MaterialStateProperty.all(Colors.white),
                // If you want to set the background color, use backgroundColor instead:
                // backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
            const SizedBox(width: 8.0), // Add some space between the buttons
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: onDetails,
              style: ButtonStyle(
                // Setting the foreground color (icon color) to white
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelectionPage extends StatelessWidget {
  final Function(int) onConfirm;

  QuantitySelectionPage({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    TextEditingController quantityController = TextEditingController();

    return AlertDialog(
      title: const Text('Buy Product'),
      content: Column(
        children: [
          const Text('Enter Quantity:'),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            int selectedQuantity = int.tryParse(quantityController.text) ?? 1;
            onConfirm(selectedQuantity);
            Navigator.pop(context);
          },
          child: const Text('Buy'),
        ),
      ],
    );
  }
}
