import 'dart:convert';
import 'package:agro/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageDetailsPage extends StatefulWidget {
  final String local_id;

  ImageDetailsPage({Key? key, required this.local_id}) : super(key: key);

  @override
  _ImageDetailsPageState createState() => _ImageDetailsPageState();
}

class _ImageDetailsPageState extends State<ImageDetailsPage> {
  String? imageBase64;
  String? description;
  String? name;
  int? price;
  String? date_of;
  String? date;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageDetails();
  }

  Future<void> fetchImageDetails() async {
    try {
      var localId = widget.local_id;
      final response = await http.get(Uri.parse('$get_image/$localId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          imageBase64 = data['image'];
          description = data['description'];
          name = data['name'];
          price = data['price'];
          date_of = data['date_of'];
          date = data['date'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load image details');
      }
    } catch (error) {
      print('Error fetching image details: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details of ($name)'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageBase64 != null
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Price: ${price.toString()}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[900], fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),
              Image.memory(
                base64Decode(imageBase64!),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              const SizedBox(height: 20),
              const Text(
                "Details:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description ?? 'No description available',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date of product collection:',
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date_of ?? 'No date found',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Posted: ',
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date ?? 'No date found',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load image'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
