import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/views/Subscriptionspage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false; // Toggle for notifications
  bool _darkModeEnabled = false; // Toggle for dark mode

  Future<void> _handleNotificationPermission(bool enable) async {
    if (enable) {
      // Request notification permission
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() {
          _notificationsEnabled = true;
        });
      } else {
        setState(() {
          _notificationsEnabled = false;
        });
        _showPermissionDeniedDialog();
      }
    } else {
      // Turn off notification permission
      bool permissionDisabled = await openAppSettings();
      if (permissionDisabled) {
        setState(() {
          _notificationsEnabled = false;
        });
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Notification permission is required to enable notifications. Please grant the permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextColorWhite,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Settings Section
            const Text(
              'Profile Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text('Edit Profile'),
            //   onTap: () {
            //     // Navigate to profile editing page
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // Navigate to change password page
              },
            ),
            const Divider(),

            // App Preferences Section
            const Text(
              'App Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              secondary: const Icon(Icons.notifications),
              activeColor: PRIMARY_COLOR,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _handleNotificationPermission(value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode,),
              activeColor: PRIMARY_COLOR,
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            const Divider(),

            // General Section
            const Text(
              'General',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // ListTile(
            //   leading: const Icon(Icons.language),
            //   title: const Text('Language'),
            //   subtitle: const Text('English'), // Example language
            //   onTap: () {
            //     // Open language selection dialog or page
            //   },
            // ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('About App'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('App Name: Pharmacy App'),
                        SizedBox(height: 8),
                        Text('Version: 1.0.0'),
                        SizedBox(height: 8),
                        Text(
                          'This app helps manage orders, track medications, '
                              'and provide an efficient pharmacy management system.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                showHelpAndSupportPopup(context);
              },
            ),
            const Divider(),

            // Account Section
            const Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Utils.logout(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Subscription'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage(),));
              },
            ),
          ],
        ),
      ),
    );
  }

  void showHelpAndSupportPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('Email Us'),
                  subtitle: const Text('support@example.com'),
                  onTap: () {
                    // Add email functionality (e.g., launch mail client)
                  },
                ),
                const Divider(),
                ListTile(
                  leading:  Icon(Icons.phone, color: PRIMARY_COLOR),
                  title: const Text('Call Us'),
                  subtitle: const Text('+91-1234567890'),
                  onTap: () {
                    // Add call functionality
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.web, color: Colors.deepPurple),
                  title: const Text('Visit Website'),
                  subtitle: const Text('www.example.com'),
                  onTap: () {
                    // Add website navigation functionality
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.call, color: Colors.white),
                  ),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('Tap to open WhatsApp'),
                  onTap: () async {
                    final Uri whatsappUri = Uri(
                      scheme: 'https',
                      host: 'wa.me', // WhatsApp's short-link API
                      path: '919544688490', // Replace with a valid phone number
                    );

                    try {
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(
                          whatsappUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw 'Could not launch WhatsApp';
                      }
                    } catch (e) {
                      print('Error launching WhatsApp: $e');
                    }
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close',style: TextStyle(color: TextColorWhite),),
            ),
          ],
        );
      },
    );
  }
}
