import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agro/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class Product {
  final String id;
  final String name;
  int quantity;
  final String category;
  double price;
  bool isVerified;

  final String buyer_name;
  final String location;
  final String phone;
  final double total_amount;
  final String payment_status;
  final String delivery_status;
  final String order_date;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.price,
    this.isVerified = false,

    required this.buyer_name,
    required this.location,
    required this.phone,
    required this.payment_status,
    required this.delivery_status,
    required this.total_amount,
    required this.order_date
  });
}

class OrderPage extends StatefulWidget {
  final String user_id;

  OrderPage({required this.user_id});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Product> products = [];
  List<String> dropdownItems = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
  String? selectedDropdownItem = 'All'; // Initial value set to 'Processing'

  @override
  void initState() {
    super.initState();
    getData(widget.user_id);
  }

  void getData(String seller_id) async {
    print("getData called in manage page with user_id: $seller_id");
    try {
      var response = await http.get(
        Uri.parse('$orders/$seller_id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<Product> fetchedProducts = [];
        var responseData = jsonDecode(response.body);
        for (var order in responseData) {
          for (var cartItem in order['cartItems']) {
            var product = cartItem['product'];
            fetchedProducts.add(Product(
              id: product['id'] ?? '',
              name: product['name'] ?? '',
              quantity: product['quantity'] ?? 0,
              category: product['category'] ?? '',
              price: product['price']?.toDouble() ?? 0.0,
              isVerified: product['isVerified'] ?? false,
              buyer_name: order['billingDetails']['name'] ?? '',
              location: order['billingDetails']['location'] ?? '',
              phone: order['billingDetails']['phoneNumber'] ?? '',
              payment_status: order['paymentStatus'] ?? '',
              delivery_status: product['status'] ?? '',
              total_amount: order['total_amount']?.toDouble() ?? 0.0,
              order_date: order['createdAt'] ?? '',
            ));
          }
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Order'),
        actions: [
          DropdownButton<String>(
            key: UniqueKey(),
            value: selectedDropdownItem,
            items: dropdownItems.map((String value) {
              int count = getCountForStatus(value);
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$value ($count)'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDropdownItem = newValue;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              selectedDropdownItem == 'All' || products.any((product) => product.delivery_status == selectedDropdownItem) ?
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  if (selectedDropdownItem == 'All' || products[index].delivery_status == selectedDropdownItem) {
                    return ProductListItem(
                      product: products[index],
                      onUpdate: (Product updatedProduct) {
                        _updateInDatabase(updatedProduct);
                        setState(() {
                          products[index] = updatedProduct;
                        });
                      },
                      onDelete: () {
                        _confirmDeleteProduct(index);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ) :
              Center(
                child: Text('No items to display for ${selectedDropdownItem ?? 'selected value'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getCountForStatus(String status) {
    if (status == 'All') {
      return products.length;
    }
    return products.where((product) => product.delivery_status == status).length;
  }







  void _updateInDatabase(Product product) {
    // Add code to update the product in the database
    print('Updated in database: $product');
  }

  void _confirmDeleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete ${products[index].name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add database delete code here
                _deleteFromDatabase(products[index],index);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFromDatabase(Product product,int index) async{
    // Add code to delete the product from the database
    String productId = product.id;
    var response = await http.get(
      Uri.parse('$delete/$productId'),
      headers: {"Content-Type": "application/json"},
    );
    if(response.statusCode==200){
      _deleteProduct(index);
    }else{

    }
  }

  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }
}

class ProductForm extends StatefulWidget {
  final String user_id;
  final Function(Product) onProductAdded;

  ProductForm({required this.user_id, required this.onProductAdded});

  @override
  _ProductFormState createState() => _ProductFormState(user_id);
}

class _ProductFormState extends State<ProductForm> {
  String seller_id = "";

  _ProductFormState(String user_id) {
    seller_id = user_id;
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String selectedCategory = 'Grains';
  String unit = 'KG';

  List<String> categories = ['Grains', 'Vegetables', 'Fruits', 'Dairy', 'Others'];



  void _updateUnit() {
    switch (selectedCategory) {
      case 'Grains':
      case 'Vegetables':
        setState(() {
          unit = 'KG';
        });
        break;
      case 'Fruits':
        setState(() {
          unit = 'Pieces';
        });
        break;
      case 'Dairy':
        setState(() {
          unit = 'Litter';
        });
        break;
      case 'Others':
        setState(() {
          unit = 'Units';
        });
        break;
      default:
        setState(() {
          unit = '';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

        ),
      ),
    );
  }
}



class ProductListItem extends StatelessWidget {
  final Product product;
  final Function(Product) onUpdate;
  final Function() onDelete;

  ProductListItem({
    required this.product,
    required this.onUpdate,
    required this.onDelete,
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
      color: getStatusColor(product.delivery_status),
      child: ListTile(
        title: Text('${product.name} - ${product.quantity} $unit',style: const TextStyle(color: Colors.black,fontSize: 26),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${product.order_date}',style: const TextStyle(color: Colors.black,fontSize: 16),),
            Text('Category: ${product.category}',style: const TextStyle(color: Colors.black,fontSize: 16),),
            const Text(''),
            Text('Name: ${product.buyer_name}',style: const TextStyle(color: Colors.black,fontSize: 16),),
            Text('Phone: ${product.phone}',style: const TextStyle(color: Colors.black,fontSize: 16),),
            Text('Location: ${product.location}',style: const TextStyle(color: Colors.black,fontSize: 16),),
            const Text(''),
            Text('Price: ${product.price} Taka per $unit',style: const TextStyle(color: Colors.black,fontSize: 16),),
            Text('Total Price: ${product.total_amount} Taka ',style: const TextStyle(color: Colors.black,fontSize: 16),),
            Text('Delivery Status : ${product.delivery_status}',style: const TextStyle(color: Colors.black,fontSize: 16),),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _editProduct(context);
              },
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.all<Color>(Colors.white)
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.all<Color>(Colors.white)
              ),
            )
          ],
        ),
      ),
    );
  }


  Color getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.blue; // Assign blue color for 'Processing' status
      case 'Shipped':
        return Colors.yellow; // Assign orange color for 'Sent' status
      case 'Delivered':
        return Colors.green; // Assign green color for 'Delivered' status
      case 'Cancelled':
        return Colors.red; // Assign red color for 'Cancelled' status
      default:
        return Colors.grey; // Assign grey color for other/unknown status
    }
  }

  void _editProduct(BuildContext context) {
    String selectedStatus = 'Processing';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${product.buyer_name}'),
                  Text('Product: ${product.name}'),
                  Text('Quantity: ${product.quantity}'),
                  Text('Phone: ${product.phone}'),
                  Text('Price: ${product.total_amount}'),
                  Text('Location: ${product.location}'),
                  DropdownButton<String>(
                    value: selectedStatus,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                      });
                    },
                    items: <String>['Processing','Shipped', 'Delivered', 'Cancelled']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
                  onPressed: () async {
                    await _updateProductBackendCall(product.id, selectedStatus);
                    onUpdate(
                      Product(
                        id: product.id,
                        name: product.name,
                        quantity: product.quantity,
                        category: product.category,
                        price: product.price,
                        isVerified: product.isVerified,
                        buyer_name: product.buyer_name,
                        location: product.location,
                        phone: product.phone,
                        payment_status: product.payment_status,
                        delivery_status: selectedStatus,
                        total_amount: product.total_amount,
                        order_date: product.order_date, // Ensure formatting as needed
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _updateProductBackendCall(String productId, String selectedStatus) async {
    try {
      // Replace the URL and payload with your actual backend API endpoint and data
      var response = await http.post(
        Uri.parse('$update_order/$productId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'status': selectedStatus
        }),
      );

      if (response.statusCode == 200) {
        onUpdate(
          Product(
            id: product.id,
            name: product.name,
            quantity: product.quantity,
            category: product.category,
            price: product.price,
            isVerified: product.isVerified,
            buyer_name: product.buyer_name,
            location: product.location,
            phone: product.phone,
            payment_status: product.payment_status,
            delivery_status: selectedStatus,
            total_amount: product.total_amount,
            order_date: product.order_date,
          ),
        );
      }
    } catch (error) {
      print("Error updating product: $error");
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderPage(user_id: ''),
  ));
}
