import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:pharmacy_app/views/collectionsPage.dart';
import 'package:pharmacy_app/views/pastorders.dart';
import 'package:pharmacy_app/views/productListPage.dart';
import 'package:pharmacy_app/views/profilePage.dart';
import '../Constants/appColors.dart';
import '../utils/utils.dart';
import 'indexpage.dart';
import 'orderFulfillment.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    Utils.getSavedCredentials();
    super.initState();
  }

  int currentIndex = 0;

  final List<Widget> pages = [
    IndexPage(),
    ProductListPage(), // Centered item
    PastOrdersPage(),
    ProfilePage(),
    Collectionspage(),
    OrderFulfillmentPage(),
  ];


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{
        final shouldExit = await Utils.showExitConfirmationDialog(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: Container(
          height: 80, // Increased height for labels
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Equal spacing
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 0 ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                      color: currentIndex == 0 ? PRIMARY_COLOR : Colors.grey,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Orders',
                      style: TextStyle(
                        color: currentIndex == 0 ? PRIMARY_COLOR : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // History Item
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/shop.png',
                      color: currentIndex == 1 ? PRIMARY_COLOR :Colors.grey,scale: 4.9,),
                    SizedBox(height: 5),
                    Text(
                      'Product',
                      style: TextStyle(
                        color: currentIndex == 1 ? PRIMARY_COLOR : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Center Item
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sync,
                      color: currentIndex == 2 ? PRIMARY_COLOR : Colors.grey,
                      size: 24,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Past Orders',
                      style: TextStyle(
                        color: currentIndex == 2 ? PRIMARY_COLOR : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Collection Item
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 4;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIndex == 4 ? Icons.account_balance_wallet: Icons.account_balance_wallet_outlined,
                      color: currentIndex == 4 ? PRIMARY_COLOR : Colors.grey,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Collections',
                      style: TextStyle(
                        color: currentIndex == 4 ? PRIMARY_COLOR : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 3;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 15,
                      backgroundColor: PRIMARY_COLOR,
                      child: Icon(Icons.person,color: Colors.white,),),
                    SizedBox(height: 5),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: currentIndex == 3 ? PRIMARY_COLOR : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
