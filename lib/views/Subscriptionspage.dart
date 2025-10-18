import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../Constants/appColors.dart';
import 'PayementPage.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedPlan = 3; // Default selected plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color:PRIMARY_COLOR),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              child:Lottie.asset('assets/lottie/payement.json'),
              // child: Image.asset("assets/lottie/payement.json"), // Replace with your illustration
            ),
            SizedBox(height: 20),
            Text(
              "Upgrade to Premium",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Unlimited Delivery and more!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlan(12, "SAVE 66%", "\₹1.00/mt"),
                _buildPlan(3, "SAVE 33%", "\₹2.00/mt"),
                _buildPlan(1, "", "\₹3.00/mt"),
              ],
            ),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                // Navigate to Payment Page with selected plan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(amount: _getPrice(selectedPlan)),
                  ),
                );
              },
              child: Text(
                "Get $selectedPlan Month / ${_getPrice(selectedPlan)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }

  Widget _buildPlan(int months, String discount, String price) {
    bool isSelected = selectedPlan == months;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = months;
        });
      },
      child: Container(
        width: 120,
        height: 120,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? PRIMARY_COLOR : Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? PRIMARY_COLOR_LIGHT : Colors.white,
        ),
        child: Column(
          children: [
            if (discount.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(color: PRIMARY_COLOR, borderRadius: BorderRadius.circular(20)),
                child: Text(discount, style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            SizedBox(height: 5),
            Text(
              "$months months",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(price, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  String _getPrice(int months) {
    switch (months) {
      case 12:
        return "1.00";
      case 3:
        return "2.00";
      case 1:
      default:
        return "3.00";
    }
  }
}
