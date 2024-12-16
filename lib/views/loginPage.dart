import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/views/homepage.dart';
import 'package:pharmacy_app/views/forgotpassword/recoverPassword.dart';
import '../Constants/appColors.dart';
import '../api/firebase_api.dart';
import '../res/app_url.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userIdController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final FocusNode userIdFocusNode = FocusNode();

  final FocusNode passwordFocusNode = FocusNode();

  bool rememberMe = false;

  bool isPasswordVisible = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    Future<void> storeToken(int id) async {
      String? fcmToken = await FirebaseApi().initNOtification();
      final url = Uri.parse(AppUrl.storeToken); // Replace with your API endpoint

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": id,
            "token": fcmToken,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success']) {
            print('Token stored successfully!');
          } else {
            print('Failed to store token: ${data['message'] ?? 'Unknown error'}');
          }
        } else {
          print('Failed to store token. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while storing token: $e');
      }
    }

    // Pre-fill credentials if saved
    Utils.getSavedCredentials().then((credentials) {
      if (credentials['userId'] != null && credentials['password'] != null) {
        userIdController.text = credentials['userId']!;
        passwordController.text = credentials['password']!;
        rememberMe = true;
      }
    });

    Future<void> login(String userId, String password, bool rememberMe) async {
      isLoading = true;

      try {
        // Make an HTTP POST request to the login endpoint
        final response = await http.post(
          Uri.parse(AppUrl.login),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userid': userId,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          // Check if the response indicates success
          if (responseBody['success'] == true) {
            if (rememberMe) {
              // Save credentials securely if "Remember Me" is selected
              await Utils.storage.write(key: 'userId', value: userId);
              await Utils.storage.write(key: 'password', value: password);
              Utils.getUserDataFromLocalStorage();
              FirebaseApi().storeToken(4);
            } else {
              // Clear stored credentials
              await Utils.storage.deleteAll();
            }

            // Extract and store user data from the response
            final userData = responseBody['data'];
            await Utils.storage.write(key: 'userData', value: jsonEncode(userData));
            print('local storage user data :${Utils.storage.read(key: 'userData')}');

            Utils.isLoggedIn = true;
          } else {
            throw Exception(responseBody['message'] ?? 'Login failed');
          }
        } else {
          throw Exception('Error: ${response.statusCode}');
        }
      } catch (e) {
        // Handle exceptions
        Utils.isLoggedIn = false;
        rethrow;
      } finally {
        isLoading = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/image1.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User ID',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    TextField(
                      controller: userIdController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.person_2_outlined,color:TextColorBlack,),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                          color: PRIMARY_COLOR
                      )
                    ),
                          border: OutlineInputBorder(),
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                        TextField(
                      controller: passwordController,
                      obscureText: isPasswordVisible, // Toggle password visibility
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: PRIMARY_COLOR),
                        ),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            isPasswordVisible = isPasswordVisible;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                            Checkbox(
                          checkColor:TextColorWhite,
                          activeColor: PRIMARY_COLOR,
                          value: rememberMe,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                rememberMe = value;
                              });
                            }
                          },
                        ),
                        Text('Remember Me'),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RecoverPasswordPage(),));
                      },
                        child: Text('Recover Password',style: TextStyle(color: TextColorPurple,
                        fontWeight: FontWeight.bold),))
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width/1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      onPressed: () async {
                        try{
                          await login(
                            userIdController.text,
                            passwordController.text,
                            rememberMe
                          ).catchError((error){
                            print('Login failed..!:$error');
                          });
                        }catch(e){
                          Utils.toastMessage('Login Failed ${e.toString()}');
                        }
                        if (Utils.isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
                          Utils.flushBarSuccessMessage('Hi, Welcome back...!', context);
                        } else {
                          Utils.toastMessage('Login Failed , Invalid credentials');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Login',style: TextStyle(
                          color:TextColorWhite
                        ),),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                // RichText(
                //   text: TextSpan(
                //     text: "Don't have an account? ",
                //     style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // Normal text style
                //     children: [
                //       TextSpan(
                //         text: 'Register Now!',
                //         style: TextStyle(
                //           color: PRIMARY_COLOR, // Highlighted text color
                //           fontWeight: FontWeight.bold,
                //         ),
                //         recognizer: TapGestureRecognizer()
                //           ..onTap = () {
                //             // Navigate to the registration page
                //             // Get.to(() => RegistrationPage());
                //           },
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 25,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
