import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:agro/config.dart'; // Ensure this path is correct for your project

class ProductSalesPage extends StatefulWidget {
  final String user_id;

  ProductSalesPage({required this.user_id});

  @override
  _ProductSalesPageState createState() => _ProductSalesPageState();
}

class _ProductSalesPageState extends State<ProductSalesPage> {
  Future<List<Map<String, int>>> fetchProductData() async {
    var response = await http.get(
      Uri.parse('$get_graph/${widget.user_id}'), // Replace '$get_graph' with your actual endpoint
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, int>>((item) {
        String productName = item['product_name'];
        int count = item['count'];
        return {productName: count};
      }).toList();
    } else {
      throw Exception('Failed to load product data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Sales (Seller)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.grey[100], // Background color of the page
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, int>>>(
          future: fetchProductData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return BarChart(
                BarChartData(
                  maxY: _findMaxY(snapshot.data!) * 1.2,
                  barGroups: _buildBarGroups(snapshot.data!),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) => _bottomTitles(value, meta, snapshot.data!),
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _leftTitles,
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _findMaxY(snapshot.data!) / 5 > 0 ? _findMaxY(snapshot.data!) / 5 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.blueGrey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String productName = snapshot.data![group.x.toInt()].keys.first;
                        return BarTooltipItem(
                          '$productName\n${rod.toY}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    enabled: true,
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<Map<String, int>> productData) {
    final List<List<Color>> gradients = [
      [Colors.purple, Colors.purpleAccent],
      [Colors.blue, Colors.blueAccent],
      [Colors.green, Colors.lightGreen],
      [Colors.orange, Colors.deepOrange],
      [Colors.red, Colors.redAccent],
    ];

    return productData.asMap().map((index, product) {
      final productName = product.keys.first;
      final productQuantity = product[productName]!.toDouble();
      final gradientIndex = index % gradients.length;

      return MapEntry(
        index,
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: productQuantity,
              gradient: LinearGradient(
                colors: gradients[gradientIndex],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }).values.toList();
  }

  double _findMaxY(List<Map<String, int>> productData) {
    double maxY = productData.fold<double>(0, (max, p) => math.max(max, p.values.first.toDouble()));
    return maxY > 0 ? maxY * 1.2 : 10; // Ensure a sensible default if maxY is 0
  }

  Widget _bottomTitles(double value, TitleMeta meta, List<Map<String, int>> productData) {
    final index = value.toInt();
    if (index >= 0 && index < productData.length) {
      String productName = productData[index].keys.first;
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(productName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
      );
    }
    return const Text('');
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    return Text('${value.toInt()}', style: const TextStyle(color: Colors.grey));
  }
}
