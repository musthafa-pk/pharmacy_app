import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:printing/printing.dart';
import '../../Constants/appColors.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/utils.dart';

class PastOrdersPage extends StatefulWidget {
  @override
  _PastOrdersPageState createState() => _PastOrdersPageState();
}

class _PastOrdersPageState extends State<PastOrdersPage> {
  List<Map<String, dynamic>> pastOrders = [];
  bool isLoading = true; // For shimmer effect
  // late List<bool> expandedStates;
  late List<bool> expandedStates = [false,false,false];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    fetchPastOrders(); // Fetch orders on initialization
    expandedStates = [];
  }

  Future<void> fetchPastOrders() async {
    setState(() {
      isLoading = true; // Start shimmer
    });

    try {
      // Body for the API request
      final Map<String, dynamic> requestBody = {"chemistId": 4};

      // Make an HTTP POST request
      final response = await http.post(
        Uri.parse(AppUrl.confirmedOrders),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          // Update the past orders list
          setState(() {
            pastOrders = List<Map<String, dynamic>>.from(responseBody['data']);
            expandedStates = List.generate(pastOrders.length, (_) => false);
          });
        } else {
          // Handle failure response
          throw Exception(responseBody['message'] ?? "Failed to fetch orders.");
        }
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching past orders: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop shimmer
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextColorWhite,
        automaticallyImplyLeading: false,
        title: Text('Past Orders'),
      ),
      body: SafeArea(
        child: isLoading
            ? _buildShimmerEffect() // Show shimmer while loading
            : pastOrders.isEmpty
            ? Center(child: Text('No Orders Available')) // Show empty message
            : _buildOrdersList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: pastOrders.length,
      itemBuilder: (context, index) {
        final order = pastOrders[index];
        final isExpanded = expandedStates[index];

        final int orderId = order['id'] as int;
        final int salesId = order['sales_id'];
        final String rawOrderDate = order['created_date'] as String;
        final String orderStatus = order['status'] as String;
        final String amount = order['price'] as String;
        final String userName = order['userName'] as String;
        // final String doctor = order['doctor_name'] as String;

        // Use the formatDate function to format the order date
        final String formattedDate = Utils.formatDate(rawOrderDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              expandedStates[index] = !expandedStates[index];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: orderStatus == 'packed' ? Colors.green : Colors.red,
                      child: Icon(
                        orderStatus == 'packed' ? Icons.check : Icons.cancel,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Order #$orderId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $formattedDate'), // Display formatted date
                        Text('Order $orderStatus'),
                        Text('Sales ID $salesId'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text('Prescribed By'),
                        //     Text('${doctor ?? ''}'),
                        //   ],
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text('User'),
                        //     Text('${userName ?? ''}'),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount:'),
                            Text('₹${amount}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: PRIMARY_COLOR),),
                          ],
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: isExpanded?CrossFadeState.showSecond:
                          CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product\'s',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                // Header Row
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'No',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Product',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Qty',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // List of Products
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: order['productlist'].length,
                                  itemBuilder: (context, productIndex) {
                                    final product = order['productlist'][productIndex];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${productIndex + 1}',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              '${product['productName']}',
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${product['order_qty']}',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Track Order',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                // Stepper Widget
                                Stepper(
                                  physics: NeverScrollableScrollPhysics(),
                                  currentStep: currentStep,
                                  onStepTapped: (step) {
                                    // Handle step tap
                                    setState(() {
                                      currentStep = step;
                                    });
                                  },
                                  steps: [
                                    Step(
                                      title: const Text('Order Placed'),
                                      subtitle: Text(order['created_date']),
                                      content: Text(order['created_date']),
                                      isActive: currentStep >= 0,
                                    ),
                                    Step(
                                      title: const Text('Order Dispatched'),
                                      subtitle: Text(order['created_date']),
                                      content: Text(order['created_date']),
                                      isActive: currentStep >= 1,
                                    ),
                                    Step(
                                      title: const Text('Order Delivered'),
                                      subtitle: Text(order['created_date']),
                                      content: Text(order['created_date']),
                                      isActive: currentStep >= 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 15,
                    child: InkWell(
                      onTap: () {
                        Utils.showQrPopup(context, salesId,userName); // Pass the orderId as string
                      },
                      child: SizedBox(
                        child: QrImageView(
                          data: orderId.toString(), // QR code now contains the orderId
                          version: QrVersions.auto,
                          size: 75.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12)
          ),
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _printQrCode(String qrData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Container(
            width: 200,
            height: 200,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );

    // Send the PDF to a printer
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
