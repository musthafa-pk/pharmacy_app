import 'package:flutter/material.dart';
import 'package:pharmacy_app/views/profilePage.dart';
import 'package:shimmer/shimmer.dart';
import '../../Constants/appColors.dart';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../Constants/appColors.dart';

class OrderFulfillmentPage extends StatefulWidget {
  @override
  _OrderFulfillmentPageState createState() => _OrderFulfillmentPageState();
}

class _OrderFulfillmentPageState extends State<OrderFulfillmentPage> {
  bool isLoading = true;
  List<OrderModel> ordersToFulfill = [];
  List<bool> expandedList = [];

  @override
  void initState() {
    super.initState();
    // Simulate fetching data
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        ordersToFulfill = mockOrders(); // Replace with actual data fetching
        expandedList = List.generate(ordersToFulfill.length, (index) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Orders to Fulfill'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // Navigate to ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: PRIMARY_COLOR,
                child: Text(
                  'M',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TextColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? _buildShimmer()
            : ordersToFulfill.isEmpty
            ? const Center(
          child: Text(
            'No Orders',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : _buildOrderList(),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5, // Placeholder count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1, color: Colors.grey.shade300),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10, width: 100),
                    SizedBox(height: 10),
                    SizedBox(height: 10, width: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: ordersToFulfill.length,
      itemBuilder: (context, index) {
        final order = ordersToFulfill[index];
        final isExpanded = expandedList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                expandedList[index] = !expandedList[index];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1, color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderInfoRow('Order No:', '#0000${order.id}'),
                    _buildOrderInfoRow('Date:', '2024-11-01'),
                    _buildOrderInfoRow(
                      'Total:',
                      'Rs 300.0',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 10),
                    if (isExpanded) _buildProductDetails(order),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        isHighlighted
            ? Container(
          decoration: BoxDecoration(
            color: Colors.blue, // Replace with PRIMARY_COLOR
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
            : Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProductDetails(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.productList.length,
          itemBuilder: (context, index) {
            final product = order.productList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 1, child: Text('${index + 1}', textAlign: TextAlign.center)),
                  Expanded(flex: 4, child: Text(product.productName)),
                  Expanded(flex: 2, child: Text('${product.orderQty}', textAlign: TextAlign.center)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<OrderModel> mockOrders() {
    return [
      OrderModel(
        id: 1,
        productList: [
          ProductModel(productName: 'Paracetamol', orderQty: 2),
          ProductModel(productName: 'Cough Syrup', orderQty: 1),
        ],
      ),
      OrderModel(
        id: 2,
        productList: [
          ProductModel(productName: 'Vitamin C', orderQty: 3),
        ],
      ),
    ];
  }
}

class OrderModel {
  final int id;
  final List<ProductModel> productList;

  OrderModel({required this.id, required this.productList});
}

class ProductModel {
  final String productName;
  final int orderQty;

  ProductModel({required this.productName, required this.orderQty});
}
