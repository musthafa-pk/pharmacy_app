// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:web_socket_channel/io.dart';
// class DeliveryBoyScreen extends StatefulWidget {
//   @override
//   _DeliveryBoyScreenState createState() => _DeliveryBoyScreenState();
// }
//
// class _DeliveryBoyScreenState extends State<DeliveryBoyScreen> {
//   String? paymentLink;
//   String orderId = "1";
//   final channel = IOWebSocketChannel.connect('ws://192.168.1.5:3003');
//
//   @override
//   void initState() {
//     super.initState();
//     listenForPayments();
//   }
//
//   void generatePaymentQR() async {
//     try {
//       print('Sending request to backend...');
//
//       final response = await http.post(
//         Uri.parse("http://192.168.1.5:3003/generate-payment"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"amount": 500, "orderId": "test123"}),
//       );
//
//       if (response.statusCode == 200) {
//         try {
//           final responseData = jsonDecode(response.body);
//
//           if (responseData['success']) {
//             setState(() {
//               paymentLink = responseData['paymentLink'];
//             });
//             print('Payment link: $paymentLink');
//           } else {
//             print('API Error: ${responseData['error']}');
//           }
//         } catch (e) {
//           print('JSON Parsing Error: $e');
//         }
//       } else {
//         print('Request failed with status: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//
//   void listenForPayments() {
//     channel.stream.listen((message) {
//       final data = jsonDecode(message);
//       if (data['order_id'] == orderId && data['status'] == 'Paid') {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSuccessScreen(),));
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Delivery Boy")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: generatePaymentQR,
//               child: Text("Generate Payment QR"),
//             ),
//             if (paymentLink != null)
//               Column(
//                 children: [
//                   SizedBox(height: 20),
//                   SizedBox(
//                     width: 200, // Set a proper width
//                     child: QrImageView(
//                       data: "https://razorpay.com/pay/$paymentLink",
//                       size: 200,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text("Scan QR to Pay"),
//                 ],
//               ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class OrderSuccessScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Payment Successful")),
//       body: Center(child: Text("Order Paid! Moving to Next Step...")),
//     );
//   }
// }