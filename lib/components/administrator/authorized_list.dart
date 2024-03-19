import 'package:flutter/material.dart';
import 'package:agro/config.dart';
import 'package:agro/components/seller/manage_product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../../pages/image_details.dart';

class Product {
  final String local_id;
  final String name;
  int quantity;
  final String category;
  double price;
  bool isVerified;

  Product({
    required this.local_id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.price,
    this.isVerified = false,
  });
}

class ManageProductAdminAuthPage extends StatefulWidget {
  final String user_id;

  ManageProductAdminAuthPage({required this.user_id});

  @override
  _ManageProductAdminAuthPageState createState() => _ManageProductAdminAuthPageState(user_id);
}

class _ManageProductAdminAuthPageState extends State<ManageProductAdminAuthPage> {
  bool isFormExpanded = false;
  List<Product> products = [];
  List<String> dropdownItems = ['Verify','Stay Unverified'];
  String selectedDropdownItem = 'Verify';
  List<String> category_dropdownItems = ['All' ,'Grains', 'Vegetables', 'Fruits', 'Dairy', 'Others'];
  String? category_selectedDropdownItem = 'All'; // Initial value set to 'All'

  _ManageProductAdminAuthPageState(String user_id) {
    getData(user_id);
  }

  @override
  void initState() {
    super.initState();
    getData(widget.user_id);
  }

  void getData(String user_id) async {
    print("getData called in manage page with user_id: $user_id");
    try {
      var response = await http.get(
        Uri.parse(fetch_true_products),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<Product> fetchedProducts = (jsonDecode(response.body) as List)
            .map((data) => Product(
          local_id: data['local_id'] ?? '',
          name: data['name'] ?? '',
          quantity: data['quantity'] ?? 0,
          category: data['category'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(padding: EdgeInsets.only(
          top: 16.0,
          left: 50.0,
          right: 8.0,
          bottom: 16.0,
        ),
        child: Text('Authorized List')),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: category_selectedDropdownItem,
                onChanged: (String? newValue) {
                  setState(() {
                    category_selectedDropdownItem = newValue;
                  });
                },
                items: category_dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  int count = getCountForCategory(value);
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(child: Text('$value ($count)')),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              products.where((product) {
                bool matchesCategory = category_selectedDropdownItem == 'All' || product.category == category_selectedDropdownItem;
                // Add more conditions as needed
                return matchesCategory;
              }).isEmpty
                  ? const Center(child: Text('No products found matching the criteria.'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  bool matchesCategory = category_selectedDropdownItem == 'All' || products[index].category == category_selectedDropdownItem;
                  // Add more conditions as needed
                  if (matchesCategory) {
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
                      onDetails: (){
                        _getDetais(index);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getCountForCategory(String category) {
    if (category == 'All') {
      return products.length;
    }
    return products.where((product) => product.category == category).length;
  }


  void _addToDatabase(Product product) {
    // Add code to save the product to the database
    // Simulating verification status based on some condition
    product.isVerified = product.price > 0;
    print('Added to database: $product');
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
          content: Text('Does this product (${products[index].name}) violates the market? if yes then Delete it'),
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
  void _getDetais(int index){
    String local_id = products[index].local_id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailsPage(local_id: local_id,),
      ),
    );
  }
  void _deleteFromDatabase(Product product,int index) async{
    // Add code to delete the product from the database
    String productId = product.local_id;
    var response = await http.get(
      Uri.parse('$delete/$productId'),
      headers: {"Content-Type": "application/json"},
    );
    if(response.statusCode==200){
      _deleteProduct(index);
    }else{
      print('Something went wrong in deleteing');
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

  void _addProduct() async {
    String newName = nameController.text;
    int newQuantity = int.tryParse(quantityController.text) ?? 0;
    double newPrice = double.tryParse(priceController.text) ?? 0.0;

    if (newName.isNotEmpty && newQuantity > 0 && newPrice > 0) {
      String generateRandomCode() => '${Random().nextInt(100000000)}'.padLeft(8, '0');
      String randomCode = generateRandomCode();
      try {
        var addProductBody = {
          "local_id": randomCode,
          "name": newName,
          "quantity": newQuantity,
          "category": selectedCategory,
          "price": newPrice,
          "seller_id": seller_id
        };
        var response = await http.post(
          Uri.parse(add),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(addProductBody),
        );
        if (response.statusCode == 200) {
          print("Product added successfully");
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProductPage(user_id: seller_id)));
          // Fetch the updated list of products from the database
          _fetchUpdatedProductList();
        } else {
          print("Error happened");
        }
      } catch (err) {
        print(err);
      }

      // Clear the text fields and reset category after adding a product
      nameController.clear();
      quantityController.clear();
      priceController.clear();
      selectedCategory = 'Grains';
      _updateUnit();
    }
  }

// Method to fetch the updated list of products from the database
  void _fetchUpdatedProductList() async {

    print('$seller_products/$seller_id');
    try {
      var response = await http.get(
        Uri.parse('$seller_products/$seller_id'),
        headers: {"Content-Type": "application/json"},
      );
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        List<Product> updatedProducts = (jsonDecode(response.body) as List)
            .map((data) => Product(
          local_id: data['id'] ?? '',
          name: data['name'] ?? '',
          quantity: data['quantity'] ?? 0,
          category: data['category'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          isVerified: data['isVerified'] ?? false,
        ))
            .toList();
        // Access the 'products' list from the parent _ManageProductPageState
        (context as Element).markNeedsBuild();
        _ManageProductAdminAuthPageState parentState =
        context.findAncestorStateOfType<_ManageProductAdminAuthPageState>()!;
        parentState.setState(() {
          parentState.products = updatedProducts;
        });
      } else {
        print("Error fetching updated data:");
      }
    } catch (error) {
      print("Error fetching updated data: $error");
    }
  }

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
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Product',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(unit),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (per Kg/Litter)'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Text('Taka per $unit'),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  _updateUnit();
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}



class ProductListItem extends StatefulWidget {
  final Product product;
  final Function(Product) onUpdate;
  final Function() onDelete;
  final Function() onDetails;

  ProductListItem({
    required this.product,
    required this.onUpdate,
    required this.onDelete,
    required this.onDetails
  });

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  String get unit {
    switch (widget.product.category) {
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
      color: widget.product.isVerified ? Colors.green : Colors.red,
      child: ListTile(
        title: Text('${widget.product.name} - ${widget.product.quantity} $unit',style: const TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${widget.product.category}',style: const TextStyle(color: Colors.black)),
            Text('Price: ${widget.product.price} Taka per $unit',style: const TextStyle(color: Colors.black)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: widget.onDetails,
              style: ButtonStyle(
                // Setting the foreground color (icon color) to white
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
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
              onPressed: widget.onDelete,
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.all<Color>(Colors.white)
              ),
            )
          ],
        ),
      ),
    );
  }

  // Inside _ProductListItemState class
  void _editProduct(BuildContext context) {
    bool updatedStatus = widget.product.isVerified;
    String dropdownValue = updatedStatus ? 'Verify' : 'Stay Unverified';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: ${widget.product.name}'),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        updatedStatus = (dropdownValue == 'Verify');
                      });
                    },
                    items: <String>['Verify', 'Stay Unverified']
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
                    await _updateProductBackendCall(widget.product.local_id, updatedStatus);
                    widget.onUpdate(
                      Product(
                        local_id: widget.product.local_id,
                        name: widget.product.name,
                        quantity: widget.product.quantity,
                        category: widget.product.category,
                        price: widget.product.price,
                        isVerified: updatedStatus,
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


  Future<void> _updateProductBackendCall(String productId, bool updatedStatus) async {
    try {
      // Replace the URL and payload with your actual backend API endpoint and data
      var response = await http.put(
        Uri.parse('$update_product_status/$productId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'is_verified': updatedStatus,
        }),
      );

      if (response.statusCode == 200) {
        widget.onUpdate(
          Product(
            local_id: widget.product.local_id,
            name: widget.product.name,
            quantity: widget.product.quantity,
            category: widget.product.category,
            price: widget.product.price,
            isVerified: updatedStatus,
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
    home: ManageProductPage(user_id: ''),
  ));
}
