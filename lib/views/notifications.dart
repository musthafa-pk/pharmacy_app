import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/notificationModel.dart';
import '../utils/utils.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications on init
  }

  // Function to fetch notifications from the API
  Future<void> fetchNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    final url = Uri.parse(AppUrl.getNotifications);
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "pharmacyId":int.parse(userID.toString())
          }),);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] && !data['error']) {
          final List<dynamic> fetchedData = data['data'];
          setState(() {
            notifications = fetchedData
                .map((item) => NotificationModel.fromJson(item))
                .toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to fetch notifications");
      }
    } catch (e) {
      print(e); // Handle errors properly in a production app
    }
  }

  // Function to mark a notification as seen via API
  Future<void> markAsSeenAPI(int notificationId, int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    final url = Uri.parse(AppUrl.seennotifi);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "pharmacyId": int.parse(userID.toString()),
          "notificationId": notificationId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            notifications[index].seen = true;
          });
        }
      } else {
        throw Exception("Failed to update seen status");
      }
    } catch (e) {
      print(e); // Handle errors properly in a production app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextColorWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.seen
                      ? PRIMARY_COLOR
                      : Colors.blue,
                  child: Icon(
                    notification.seen
                        ? Icons.check
                        : Icons.notifications,
                    color: Colors.white,
                  ),
                ),
                title: Text(notification.message),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.seen ? 'Seen' : 'Unseen',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          Utils.formatNotificationDate(notification.createdDate.toString()), // Use the helper function
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
                onTap: () {
                  showNotificationDialog(notification, index);
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }

  Future<void> showNotificationDialog(NotificationModel notification, int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: Text(notification.message),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close',style: TextStyle(color: TextColorWhite),),
            ),
          ],
        );
      },
    );

    // Mark the notification as seen after closing the dialog
    markAsSeenAPI(notification.id, index);
  }

}
