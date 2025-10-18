import 'dart:io'; // Import File class
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/views/RequestDelivery/LocationScreen.dart';

class RequestOrderScreen extends StatefulWidget {
  @override
  _RequestOrderScreenState createState() => _RequestOrderScreenState();
}

class _RequestOrderScreenState extends State<RequestOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode remarksNode = FocusNode();
  final FocusNode nextNode = FocusNode();

  // List<File> prescriptionImages = [];
  // final ImagePicker _picker = ImagePicker();

  // File? selectedFile;
  List<File> _selectedFiles = [];

  // Function to pick an image file
  // Future<void> pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null) {
  //     setState(() {
  //       selectedFile = File(result.files.single.path!);
  //     });
  //   }
  // }

  // Future<void> pickImages() async {
  //   final List<XFile>? images = await _picker.pickMultiImage();
  //   if (images != null) {
  //     setState(() {
  //       prescriptionImages = images.map((image) => File(image.path)).toList();
  //     });
  //   }
  // }


  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    try {
      final List<XFile>? pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null) {
        if (pickedFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You can only select up to 5 images.")),
          );
          return;
        }

        setState(() {
          _selectedFiles = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      print("Error picking files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting files")),
      );
    }
  }

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
          'Request Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Name'),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        focusNode: nameNode,
                        onFieldSubmitted: (v) {
                          Utils.fieldFocusChange(context, nameNode, phoneNode);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('Phone No'),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: phoneController,
                        focusNode: phoneNode,
                        keyboardType: TextInputType.phone,
                        onFieldSubmitted: (v) {
                          Utils.fieldFocusChange(context, phoneNode, remarksNode);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('Remarks'),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: remarksController,
                        focusNode: remarksNode,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _pickFiles,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _selectedFiles.isEmpty ? 'Upload Prescription' : 'Change Prescription',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Display selected image preview
                      if (_selectedFiles.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              'Selected Prescription:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            if (_selectedFiles.isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _selectedFiles.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  File file = entry.value;

                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          file,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // Delete button
                                      Positioned(
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => _removeFile(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.close, size: 18, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  ElevatedButton(
                    focusNode: nextNode,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryLocationScreen(
                              name: nameController.text,
                              phone: phoneController.text,
                              remarks: remarksController.text,
                              images: _selectedFiles, // Pass image path
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
