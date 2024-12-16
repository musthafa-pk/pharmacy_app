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
  late List<bool> expandedStates;


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

        final int orderId = order['id'] as int;
        final int salesId = order['sales_id'];
        final String rawOrderDate = order['created_date'] as String;
        final String orderStatus = order['status'] as String;
        final String amount = order['price'] as String;
        final String userName = order['userName'] as String;

        // Use the formatDate function to format the order date
        final String formattedDate = Utils.formatDate(rawOrderDate);

        return Card(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount:'),
                        Text('₹${amount}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: PRIMARY_COLOR),),
                      ],
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
