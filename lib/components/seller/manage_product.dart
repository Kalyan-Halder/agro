import 'package:flutter/material.dart';
import 'package:agro/config.dart';
import 'package:agro/components/seller/manage_product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

class ManageProductPage extends StatefulWidget {
  final String user_id;

  ManageProductPage({required this.user_id});

  @override
  _ManageProductPageState createState() => _ManageProductPageState(user_id);
}

class _ManageProductPageState extends State<ManageProductPage> {
  bool isFormExpanded = false;
  List<Product> products = [];

  _ManageProductPageState(String user_id) {
    getData(user_id);
  }

  @override
  void initState() {
    super.initState();
    getData(widget.user_id);
  }


  void getData(String user_id) async {
    print("getData called in manage page with user_id: $user_id");


    //ADDING a loading circle
    try {
      var response = await http.get(
        Uri.parse('$seller_products/$user_id'),
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


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpansionTile(
                title: const Text('Add Product'),
                initiallyExpanded: isFormExpanded,
                onExpansionChanged: (value) {
                  setState(() {
                    isFormExpanded = value;
                  });
                },

                children: [
                  ProductForm(
                    user_id: widget.user_id,
                    onProductAdded: (Product newProduct) {
                      _addToDatabase(newProduct);
                      setState(() {
                        products.add(newProduct);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
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
                },
              ),
            ],
          ),
        ),
      ),

    );
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

  //for description and image
  TextEditingController imageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  String selectedCategory = 'Grains';
  String unit = 'KG';

  List<String> categories = ['Grains', 'Vegetables', 'Fruits', 'Dairy', 'Others'];

  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Newly declared variable for storing picked image

  void _addProduct() async {
    String newName = nameController.text;
    int newQuantity = int.tryParse(quantityController.text) ?? 0;
    double newPrice = double.tryParse(priceController.text) ?? 0.0;
    String description = descriptionController.text;
    String date = dateController.text;


    if (newName.isNotEmpty && newQuantity > 0 && newPrice > 0 && description.isNotEmpty && (_image != null) && date.isNotEmpty) {
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



        var response = await http.post(
          Uri.parse(add),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(addProductBody),
        );

        if (response.statusCode == 200) {
          print("Product added successfully");
          var responseData = jsonDecode(response.body);

          //begin the photo and description upload
          if (_image != null) {
            // Get the image path from the XFile
            String imagePath = _image!.path;

            // Create a multipart request
            var request = http.MultipartRequest('POST', Uri.parse(set_image_dis));

            // Add the image file to the request
            request.files.add(await http.MultipartFile.fromPath('image', imagePath));

            // Add the description as a field in the request
            request.fields['local_id'] = responseData['local_id'];
            request.fields['description'] = description;
            request.fields['date_of'] = date;



            // Send the request
            var response = await request.send();

            // Check the response status
            if (response.statusCode == 200) {
              Navigator.pop(context);
              print('Data uploaded successfully');
            } else {
              print('Data upload failed');
            }
          }



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

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
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
        _ManageProductPageState parentState =
        context.findAncestorStateOfType<_ManageProductPageState>()!;
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
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),

            TextField(
              controller: descriptionController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Date of The Product Storage'),
            ),
            const SizedBox(height: 26.0),
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




class ProductListItem extends StatelessWidget {
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
        title: Text('${product.name} - ${product.quantity} $unit',
            style: product.isVerified ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.white)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product.category}',
                style: product.isVerified ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.white)
            ),
            Text('Price: ${product.price} Taka per $unit',
                style: product.isVerified ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.white)
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: onDetails,
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

  void _editProduct(BuildContext context) {
    int updatedQuantity = product.quantity;
    double updatedPrice = product.price;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${product.name}'),
              TextField(
                onChanged: (value) {
                  updatedQuantity = int.tryParse(value) ?? product.quantity;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Quantity'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  updatedPrice = double.tryParse(value) ?? product.price;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Price (per KG/Litter)'),
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
                await _updateProductBackendCall(product.local_id, updatedQuantity, updatedPrice);
                onUpdate(
                  Product(
                    local_id: product.local_id,
                    name: product.name,
                    quantity: updatedQuantity,
                    category: product.category,
                    price: updatedPrice,
                    isVerified: false,
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
  }

  Future<void> _updateProductBackendCall(String productId, int updatedQuantity, double updatedPrice) async {
    try {
      // Replace the URL and payload with your actual backend API endpoint and data
      var response = await http.put(
        Uri.parse('$update_product/$productId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'quantity': updatedQuantity,
          'price': updatedPrice,
        }),
      );

      if (response.statusCode == 200) {
        onUpdate(
          Product(
            local_id: product.local_id,
            name: product.name,
            quantity: updatedQuantity,
            category: product.category,
            price: updatedPrice,
            isVerified: product.isVerified,
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
