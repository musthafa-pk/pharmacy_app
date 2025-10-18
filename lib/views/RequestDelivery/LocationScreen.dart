import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_webservices/places.dart' as webservices;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/views/RequestDelivery/payementScreen.dart';

class DeliveryLocationScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String remarks;
  final List<File> images;

  DeliveryLocationScreen({
    required this.name,
    required this.phone,
    required this.remarks,
    required this.images,
  });

  @override
  _DeliveryLocationScreenState createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  GoogleMapController? mapController;
  LatLng? selectedLocation;
  bool isLoading = false;
  List<Map<String, dynamic>> locationAddress = [];
  var selectedAddressData;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    _updateLocation(LatLng(position.latitude, position.longitude));
  }

  Future<void> _updateLocation(LatLng location) async {
    setState(() {
      selectedLocation = location;
      latController.text = location.latitude.toString();
      lngController.text = location.longitude.toString();
      isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          addressController.text =
          "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}";
          pincodeController.text = placemarks[0].postalCode ?? '';

          latController.text = location.latitude.toString();
          lngController.text = location.longitude.toString();
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    } finally {
      setState(() => isLoading = false);
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(location));
      }
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
          'Delivery Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.buildGooglePlacesTextField(
                      label: 'Search Address',
                      addressController: addressController,
                      pincodeController: pincodeController,
                      onAddressSelected: (selectedAddress)async{
                        print('Selected Address: $selectedAddress');
                        if (selectedAddress != null) {
                          setState(() {
                            selectedAddressData = selectedAddress;
                            latController.text = selectedAddress['latitude'].toString();
                            lngController.text = selectedAddress['longitude'].toString();
                          });
                        }
                      }),
                  SizedBox(height: 16),
                  Text('Pin Code'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
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
                        return 'Please enter the pin code';
                      } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Enter a valid 6-digit pin code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),
                  selectedLocation != null
                      ? Container(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: selectedLocation!,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('selected-location'),
                          position: selectedLocation!,
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      onTap: (LatLng pos) {
                        _updateLocation(pos);
                      },
                    ),
                  )
                      : Center(
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(""),
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print('images:${widget.images}');
                            print('address:${locationAddress}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  pincode: int.parse(pincodeController.text),
                                  cus_name: widget.name,
                                  phoneNumber: widget.phone,
                                  remarks: widget.remarks,
                                  images: widget.images,
                                  address: addressController.text,
                                  lat: double.tryParse(latController.text) ?? 0.0,
                                  lng: double.tryParse(lngController.text) ?? 0.0,
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
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 500,
              right: 16,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: PRIMARY_COLOR,
                child: Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
