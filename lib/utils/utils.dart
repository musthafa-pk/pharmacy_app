import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/views/loginPage.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Utils {

  static final storage = FlutterSecureStorage();
  static var isLoggedIn = false;

  // next field focused in textField
  static fieldFocusChange(
      BuildContext context,
      FocusNode current,
      FocusNode nextFocus,){
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  static toastMessage(String message){
    Fluttertoast.showToast(msg: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );}
  static flushBarErrorMessage(String message , BuildContext context){
    showFlushbar(context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        positionOffset: 20,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        icon: const Icon(Icons.error ,size: 28,color: Colors.white,),
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        backgroundColor: Colors.red,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
      )..show(context),
    );}
  static flushBarSuccessMessage(String message , BuildContext context){
    showFlushbar(context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        positionOffset: 20,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        icon: const Icon(Icons.error ,size: 28,color: Colors.white,),
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        backgroundColor: PRIMARY_COLOR,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
      )..show(context),
    );}

  static Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // User chose not to exit
              },
              child: Text('Cancel',style: TextStyle(color: TextColorWhite),),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // User chose to exit
              },
              child:  Text('Exit',style: TextStyle(color: TextColorWhite)),
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final userId = await storage.read(key: 'userId');
    final password = await storage.read(key: 'password');
    return {'userId': userId, 'password': password};
  }

  static void logout(BuildContext context) async {
    await storage.deleteAll();
    isLoggedIn = false;
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
    flushBarSuccessMessage('Logged Out...!', context);
  }
  static String formatDate(String dateString) {
    try {
      // Parse the string to DateTime
      DateTime parsedDate = DateTime.parse(dateString); // Assuming the date is in a valid format (e.g., 'yyyy-MM-dd')

      // Format the DateTime to 'ddMMyy' format
      String formattedDate = DateFormat('dd-MM-yy').format(parsedDate);

      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }

  static Future<void> getUserDataFromLocalStorage() async {
    try {
      // Read the userData from local storage
      final userDataJson = await Utils.storage.read(key: 'userData');

      if (userDataJson != null) {
        // Decode the JSON string into a Dart map
        final Map<String, dynamic> userData = jsonDecode(userDataJson);

        // Print the entire user data
        print('User Data from Local Storage: $userData');

        // Optionally, access individual fields
        print('User Name: ${userData['name']}');
        print('User Email: ${userData['email']}');
        // Add other fields based on your API response structure
      } else {
        print('No user data found in local storage.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  static void showQrPopup(BuildContext context, int qrData,String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('QR Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start  ,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: qrData.toString(),
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text('${userName.toUpperCase()}'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Close',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
              onPressed: () {
               Utils.printQrCode(qrData.toString());
              },
              child: Text(
                'Print',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: TextColorWhite),
              ),
            ),
          ],
        );
      },
    );
  }
  static Future<void> printQrCode(String qrData) async {
    final pdf = pw.Document();

    // Define custom page size (e.g., 3 inches by 2 inches)
    final customPageSize = PdfPageFormat(3 * PdfPageFormat.inch, 2 * PdfPageFormat.inch);

    pdf.addPage(
      pw.Page(
        pageFormat: customPageSize,
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min, // Fit content vertically
            children: [
              pw.Container(
                width: 100, // Adjust QR code width
                height: 100, // Adjust QR code height
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 5), // Spacing between QR code and text
              pw.Text(
                'USER NAME HERE',
                style: pw.TextStyle(
                  fontSize: 12, // Adjust font size for smaller print
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Send the PDF to a printer with the specified page size
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Function to format notification date
  static String formatNotificationDate(String createdDate) {
    final DateTime notificationDate = DateTime.parse(createdDate).toLocal();
    final DateTime currentDate = DateTime.now();

    final Duration difference = currentDate.difference(notificationDate);

    if (difference.inDays < 1) {
      // If within 24 hours, show in hours or minutes
      if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } else {
      // If more than a day, show the formatted date and time
      return DateFormat('dd MMM yyyy, hh:mm a').format(notificationDate);
    }
  }

}
