import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import '../Constants/appColors.dart';
import '../res/app_url.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  bool isLoading = false; // Track loading state for profile fetching
  bool isEditing = false; // Track if the profile is being edited
  Map<String, dynamic> profileData = {}; // Store profile data

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    fetchProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = AppUrl.profile; // Replace with your profile fetching API URL
      final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      body:jsonEncode({
        "chemistId":4
      }) ,);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');  // Log the response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']==true) {
          setState(() {
            profileData = data['data'];
            nameController.text = profileData['name'] ?? '';
            emailController.text = profileData['email'] ?? '';
            phoneController.text = profileData['phone_no'] ?? '';
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load profile: ${data['message']}'); // Log more specific error
        }
      } else {
        throw Exception('Failed to fetch profile data: ${response.statusCode}'); // More specific error
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> saveProfileChanges() async {
    try {
      // Example: Send updated profile data to the server
      final response = await http.post(
        Uri.parse(AppUrl.profile), // Replace with the update profile URL
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "phone_no": phoneController.text,
          // Add any other fields as necessary
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            isEditing = false; // Switch back to view mode
          });
          // Optionally, show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          throw Exception('Failed to update profile');
        }
      } else {
        throw Exception('Failed to save profile changes');
      }
    } catch (e) {
      print('Error saving profile changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving profile changes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: PRIMARY_COLOR,
        title: const Text('Profile',style: TextStyle(color: Colors.white),),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child:  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: Text(
                      '${nameController.text[0].toUpperCase()}',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(controller: nameController, label: 'Name'),
                  const SizedBox(height: 16),
                  _buildTextField(controller: emailController, label: 'Email'),
                  const SizedBox(height: 16),
                  _buildTextField(controller: phoneController, label: 'Mobile'),
                  const SizedBox(height: 32),
                  isEditing
                      ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfileChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = true; // Switch to edit mode
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: isEditing, // Disable the text fields if not editing
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
