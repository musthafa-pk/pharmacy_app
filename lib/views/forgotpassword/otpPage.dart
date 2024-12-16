import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:pharmacy_app/views/forgotpassword/newPasswordPage.dart';

class OTPPage extends StatefulWidget {
  final String email;

  const OTPPage({Key? key, required this.email}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Function to call API for OTP verification
  Future<void> verifyOTP(int pharmacyId, String otp) async {
    final url = Uri.parse(AppUrl.verifyOTP); // Replace with your actual API endpoint
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "pharmacyId": pharmacyId,
          "otp": int.parse(otp)
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          // Navigate to the next page or show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP Verified Successfully!')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewPasswordPage(pharmacyId: pharmacyId),)); // Replace with the next page route
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Invalid OTP')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to verify OTP. Try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle OTP submission
  void submitOTP() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      verifyOTP(5, otpController.text); // Replace 5 with the actual pharmacyId if dynamic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Enter the 6-digit OTP sent to your email:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // OTP Input Field
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PRIMARY_COLOR),
                      ),
                      counterText: "", // Hides the max length counter
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      } else if (value.length != 5) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, color: TextColorWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
