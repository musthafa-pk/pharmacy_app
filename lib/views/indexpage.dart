import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/views/RequestDelivery/RequestDelivery.dart';
import 'package:pharmacy_app/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/appColors.dart';
import '../api/firebase_api.dart';
import '../res/app_url.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/views/notifications.dart';

class IndexPage extends StatefulWidget {
   IndexPage( {super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late List<bool> expandedStates = [false,false,false];
  late List<Map<String, dynamic>> orders = []; // Store fetched orders
  late List<Map<String, dynamic>> filteredOrders=[]; // Store filtered orders
  bool isLoading = true; // Track loading state
  TextEditingController searchController = TextEditingController(); // Controller for the search field




  Future<List<Map<String, dynamic>>> fetchOrders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    String url = AppUrl.getorders;
    final Map<String, dynamic> body = {'chemistId': int.parse(userID.toString())};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch orders');
        }
      } else {
        throw Exception('Failed to connect to the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int quotationId, String status,int salesId,String userName) async {
    String url = AppUrl.respond;
    final Map<String, dynamic> body = {
      'quotationId': quotationId,
      'status': status,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('statuscode :${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {});
          Utils.flushBarSuccessMessage('Order status updated successfully', context);
          Utils.showQrPopup(context, salesId,userName);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update order status');
        }
      } else {
        throw Exception('Failed to connect to the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Utils.flushBarErrorMessage('Error updating order status: $e', context);
    }
  }

  void loadOrders() async {
    try {
      final fetchedOrders = await fetchOrders(); // Replace 4 with chemistId
      setState(() {
        orders = fetchedOrders;
        filteredOrders = orders; // Initially, all orders are shown
        expandedStates = List.generate(orders.length, (_) => false);
        isLoading = false;
      });
    } catch (error) {
      print('Error loading orders: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to filter orders based on the search query
  void filterOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) {
        return order['id'].toString().contains(query) ||
            order['created_date'].contains(query) ||
            order['product_amt'].toString().contains(query);
      }).toList();
    });
  }


  @override
  void initState() {
    super.initState();
    FirebaseApi().storeToken();
    loadOrders(); // Fetch orders when the page loads
    searchController.addListener(() {
      filterOrders(searchController.text); // Filter orders when the text changes
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose of the controller when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TextColorWhite,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width/2,
        child: InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => RequestOrderScreen(),));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(9),
              border: Border.all(width: 1,color: PRIMARY_COLOR)
            ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Request Delivery',style: TextStyle(
                        fontSize: 16,
                      color: PRIMARY_COLOR
                    ),),
                    Icon(Icons.delivery_dining,color: PRIMARY_COLOR,)
                  ],
                ),
              )),
        ),
      ),
      body: SafeArea(
        child:RefreshIndicator(
          color: PRIMARY_COLOR,
          onRefresh: ()async{
            loadOrders();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TextColorWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 10, top: 10),
                              hintText: 'Search...',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.notifications_active),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                        },
                        child: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? Center(child: CircularProgressIndicator(
                    color: PRIMARY_COLOR,
                  ))
                      : filteredOrders.isEmpty
                      ? const Center(child: Text('No orders available')):

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final isExpanded = expandedStates[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedStates[index] = !expandedStates[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: TextColorWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1, color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Customer Name   :',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(('${order['user'] == null ? 'N/A' :order['user']}'),
                                        style:  TextStyle(fontWeight: FontWeight.bold,color:PRIMARY_COLOR),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Prescribed By   :',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(('${order['doctorName'] == null ? 'N/A' :order['doctorName']}'),
                                        style:  TextStyle(fontWeight: FontWeight.bold,color: PRIMARY_COLOR),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Order No:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '#${order['id']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Date   :',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        Utils.formatDate('${order['created_date']}'),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Sales ID   :',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(('${order['sales_id']}'),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total amount:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '₹${order['product_amt']}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: PRIMARY_COLOR),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // if (isExpanded)
                                    AnimatedCrossFade(
                                      duration: const Duration(milliseconds: 300),
                                      crossFadeState: isExpanded?CrossFadeState.showSecond:
                                      CrossFadeState.showFirst,
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Product\'s',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            // Header Row
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'No',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Product',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'Qty',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // List of Products
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: order['productlist'].length,
                                              itemBuilder: (context, productIndex) {
                                                final product = order['productlist'][productIndex];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          '${productIndex + 1}',
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          '${product['productName']}',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          '${product['order_qty']}',
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  int quotationId = order['id']; // Get the quotation ID
                                                  String status = 'packed'; // Status to change to
                                                  int salesId = order['sales_id'];
                                                  String userName = order['user'] ?? '';

                                                  // Call the API to update the order status
                                                   updateOrderStatus(quotationId, status, salesId,userName);

                                                  setState(() {
                                                    // After successful update, you can modify the order or display a message
                                                    order['status'] = status;
                                                    loadOrders();
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: PRIMARY_COLOR,
                                                ),
                                                child: const Text('Ready to Ship'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
