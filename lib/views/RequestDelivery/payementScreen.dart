
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String cus_name;
  final String phoneNumber;
  final String remarks;
  final int pincode;
  final  List<File> images;
  final dynamic address;
  final double lat;
  final double lng;

  PaymentScreen({
    required this.cus_name,
    required this.phoneNumber,
    required this.remarks,
    required this.pincode,
    required this.images,
    required this.address,
    required this.lat,
    required this.lng,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}


class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController totalAmount =TextEditingController();
  final FocusNode amountNode = FocusNode();
  final FocusNode nextNode = FocusNode();
  final FocusNode codNode = FocusNode();
  final FocusNode prepaidNode = FocusNode();
  final FocusNode finishNode = FocusNode();

  String _paymentType = "cod";

  // Future<void> createOrder(BuildContext context) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userID = preferences.getString('userID');
  //   final url = Uri.parse(AppUrl.requestDelivery); // Adjust the endpoint as needed
  //
  //   var uri = Uri.parse(AppUrl.requestDelivery); // Change to your API URL
  //
  //
  //
  //   print('userID....:$userID');
  //   // Validate Total Amount
  //   final amountText = totalAmount.text.trim();
  //   if (amountText.isEmpty) {
  //     Utils.flushBarErrorMessage('Please enter the total amount',context);
  //     return;
  //   }
  //
  //   if (int.parse(amountText.toString()) <= 0) {
  //     Utils.flushBarErrorMessage( 'Amount must be greater than zero',context);
  //     return;
  //   }
  //   // Send lat/lng as a JSON-encoded string in the "deliverAddress" key
  //   List<Map<String, dynamic>> addressData = [
  //     {"address":"${widget.address}","lat": widget.lat, "lng": widget.lng}
  //   ];
  //   Map<String, dynamic> requestBody = {
  //
  //     "name": widget.cus_name,
  //     "deliverAddress":jsonEncode(addressData),
  //     "phone_no,": widget.phoneNumber,
  //     "payment_type":_paymentType,
  //     "total_amount": totalAmount.text,
  //     "remarks": widget.remarks,
  //     "pincode": widget.pincode,
  //     "pharmacy_id": int.parse(userID.toString())
  //
  //   };
  //
  //   var request = http.MultipartRequest("POST", uri);
  //
  //   request.fields["data"] = jsonEncode(requestBody);
  //
  //   // Add image files
  //   // for (int i = 0; i < widget.images.length; i++) {
  //   //   request.files.add(await http.MultipartFile.fromPath(
  //   //     "images",
  //   //     widget.images[i].path,
  //   //   ));
  //   // }
  //   for (var file in widget.images) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         "images", // Must match Multer's upload.array("images")
  //         file.path,
  //       ),
  //     );
  //   }
  //
  //
  //
  //       // request.fields["deliverAddress"] = jsonEncode(addressData); // Convert to JSON string
  //   // print('adddd:${jsonEncode(addressData)}');
  //
  //   try {
  //
  //     var response = await request.send();
  //     final responseBody = await response.stream.bytesToString();
  //     print("Status Code: ${response.statusCode}");
  //     print("Response Body: $responseBody");
  //     // final response = await http.post(
  //     //   url,
  //     //   headers: {"Content-Type": "application/json"},
  //     //   // body: jsonEncode(requestBody),
  //     // );
  //     // print('body :${jsonEncode(requestBody)}');
  //     // print('resss:${response.body}');
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Utils.toastMessage('Order created successfully');
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage(),));
  //       Utils.flushBarSuccessMessage('Order created successfully', context);
  //     } else {
  //       Utils.flushBarErrorMessage('Failed to create order', context);
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }
  ///aaaaaaaaaaaa
  // Future<void> createOrder(BuildContext context) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userID = preferences.getString('userID');
  //   final url = AppUrl.requestDelivery;
  //
  //   print('User ID: $userID');
  //
  //   // Validate total amount
  //   final amountText = totalAmount.text.trim();
  //   if (amountText.isEmpty) {
  //     Utils.flushBarErrorMessage('Please enter the total amount', context);
  //     return;
  //   }
  //
  //   if (int.parse(amountText) <= 0) {
  //     Utils.flushBarErrorMessage('Amount must be greater than zero', context);
  //     return;
  //   }
  //
  //   // Prepare address data
  //   // List<Map<String, dynamic>> addressData = [
  //   //   {"address": widget.address, "lat": widget.lat, "lng": widget.lng}
  //   // ];
  //   List<Map<String, dynamic>> addressData2 = [
  //     {"lat": widget.lat, "lng": widget.lng}
  //   ];
  //
  //   List<String> imageUrls = [];
  //
  //   // Prepare request JSON data
  //   final jsonData = {
  //     "data": {
  //       "name": widget.cus_name,
  //       "deliverLocation":addressData2,
  //       "deliverAddress": widget.address,
  //       "phone_no": widget.phoneNumber,
  //       "payment_type": _paymentType,
  //       "total_amount": amountText,
  //       "remarks": widget.remarks,
  //       "pincode": widget.pincode,
  //       "pharmacy_id": int.parse(userID.toString())
  //     }
  //   };
  //
  //   print('jsonData is00000000000:$jsonData');
  //
  //   var request = http.MultipartRequest("POST", Uri.parse(url));
  //   request.fields["data"] = jsonEncode({
  //     ...?jsonData['data'],
  //     "prescription": {
  //       for (int i = 0; i < imageUrls.length; i++) "image${i + 1}": imageUrls[i],
  //     },
  //   });
  //
  //   // Attach images
  //   for (var file in widget.images) {
  //     var multipartFile = await http.MultipartFile.fromPath("images", file.path);
  //     request.files.add(multipartFile);
  //   }
  //
  //   try {
  //     print('jsonData is:$jsonData');
  //     var response = await request.send();
  //     final responseBody = await response.stream.bytesToString();
  //
  //     print("Status Code: ${response.statusCode}");
  //     print("Response Body: $responseBody");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Utils.toastMessage('Order created successfully');
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomePage()),
  //       );
  //       Utils.flushBarSuccessMessage('Order created successfully', context);
  //     } else {
  //       Utils.flushBarErrorMessage(
  //           'Error: ${jsonDecode(responseBody)['message'] ?? 'Failed to create order'}', context);
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Network error occurred")),
  //     );
  //   }
  // }

  Future<void> createOrder(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    final url = AppUrl.requestDelivery;

    print('User ID: $userID');

    // Validate total amount
    final amountText = totalAmount.text.trim();
    if (amountText.isEmpty || int.parse(amountText) <= 0) {
      Utils.flushBarErrorMessage('Please enter a valid total amount', context);
      return;
    }

    // Prepare location data
    List<Map<String, dynamic>> addressData2 = [
      {"lat": widget.lat, "lng": widget.lng}
    ];

    final jsonData = {
      "data": {
        "name": widget.cus_name,
        "deliverLocation": addressData2,
        "deliverAddress": widget.address,
        "phone_no": widget.phoneNumber,
        "payment_type": _paymentType,
        "total_amount": amountText,
        "remarks": widget.remarks,
        "pincode": widget.pincode,
        "pharmacy_id": int.parse(userID.toString()),
      }
    };

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields["data"] = jsonEncode(jsonData["data"]);

    // ✅ Attach images correctly
    for (var file in widget.images) {
      var multipartFile = await http.MultipartFile.fromPath("images", file.path);
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.toastMessage('Order created successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        Utils.flushBarSuccessMessage('Order created successfully', context);
      } else {
        Utils.flushBarErrorMessage(
            'Error: ${jsonDecode(responseBody)['message'] ?? 'Failed to create order'}',
            context);
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error occurred")),
      );
    }
  }


  // Future<void> requestDelivery() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userID = preferences.getString('userID');
  //   try {
  //     var uri = Uri.parse(AppUrl.requestDelivery); // Change to your API URL
  //     var request = http.MultipartRequest("POST", uri);
  //
  //     // Add text fields
  //     request.fields["name"] = widget.cus_name;
  //     request.fields["phone_no"] = widget.phoneNumber;
  //     request.fields["pincode"] = widget.pincode.toString();
  //     request.fields["remarks"] =widget.remarks;
  //     request.fields["payment_type"] = _paymentType;
  //     request.fields["pharmacy_id"] = userID.toString(); // Replace with dynamic pharmacy ID
  //
  //     // Send lat/lng as a JSON-encoded string in the "deliverAddress" key
  //     List<Map<String, dynamic>> addressData = [
  //       {"lat": widget.lat, "lng": widget.lng}
  //     ];
  //
  //     request.fields["deliverAddress"] = jsonEncode(addressData); // Convert to JSON string
  //
  //
  //     // Add image files
  //     for (var file in widget.images) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           "images", // Must match Multer's upload.array("images")
  //           file.path,
  //         ),
  //       );
  //     }
  //
  //     var response = await request.send();
  //     var responseData = await http.Response.fromStream(response);
  //
  //     if (response.statusCode == 200) {
  //       var jsonResponse = jsonDecode(responseData.body);
  //       if (jsonResponse["success"] == true) {
  //         print("Delivery Request Successful: ${jsonResponse["message"]}");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Delivery request placed successfully!")),
  //         );
  //       } else {
  //         print("Error: ${jsonResponse["message"]}");
  //       }
  //     } else {
  //       print("Failed: ${responseData.body}");
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount'),
            SizedBox(height: 8),
            TextField(
              controller: totalAmount,
              focusNode: amountNode,
              keyboardType: TextInputType.number,
              onSubmitted: (v){
                Utils.fieldFocusChange(context, amountNode, nextNode);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Payment Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                RadioListTile<String>(
                  focusNode: codNode,
                  title: Text("Cash on Delivery (COD)"),
                  value: "cod",
                  groupValue: _paymentType,
                  activeColor: PRIMARY_COLOR,
                  onChanged: (value) {
                    setState(() {
                      _paymentType = value!;
                      Utils.fieldFocusChange(context, codNode, finishNode);
                    });
                  },
                ),
                RadioListTile<String>(
                  focusNode: prepaidNode,
                  title: Text("Prepaid"),
                  value: "prepaid",
                  groupValue: _paymentType,
                  activeColor: PRIMARY_COLOR,
                  onChanged: (value) {
                    setState(() {
                      _paymentType = value!;
                      Utils.fieldFocusChange(context, prepaidNode, finishNode);
                    });
                  },
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                focusNode: finishNode,
                onPressed: () {
                  // print('ssss:${widget.lat}');
                  // print('ssss:${widget.lng}');
                  createOrder(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Finish',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
