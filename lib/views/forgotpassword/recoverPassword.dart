import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/res/app_url.dart';
import 'package:pharmacy_app/views/forgotpassword/otpPage.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({Key? key}) : super(key: key);

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Function to handle password recovery
  Future<void> handlePasswordRecovery() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(AppUrl.recoverypassword); // Replace with your API endpoint
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"email": emailController.text}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success']) {
            // Navigate to OTP Page on success
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPPage(email: emailController.text),
              ),
            );
          } else {
            // Show failure popup
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(data['message'] ?? 'Something went wrong'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Show failure popup for server error
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to send recovery email'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Show error popup for exceptions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Error occurred. Try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextColorWhite,
        title: const Text('Recover Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Image.asset('assets/images/wrong-password.png'),
                    ),
                  ),
                  const Text(
                    "Forgot Your Password?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your registered email address, and we'll send you an OTP to reset your password.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder:  OutlineInputBorder(
                          borderSide: BorderSide(color: PRIMARY_COLOR)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      } else if (!RegExp(
                          r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handlePasswordRecovery,
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
                          :  Text(
                        "Send Recovery Email",
                        style:
                        TextStyle(fontSize: 16, color: TextColorWhite),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to login page
                      },
                      child: Text(
                        "Back to Login",
                        style: TextStyle(
                          color: PRIMARY_COLOR,
                          fontWeight: FontWeight.bold,
                        ),
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


