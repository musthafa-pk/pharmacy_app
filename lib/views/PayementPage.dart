import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:upi_india/upi_india.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching UPI Intent

class PaymentPage extends StatefulWidget {
  final String amount;
  PaymentPage({required this.amount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps; // Store the list of available UPI apps
  String upiId = "9544688490@ybl"; // Replace with your UPI ID
  String receiverName = "MOHAMED MUSTHAFA P K";
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _fetchUpiApps();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startRazorpayPayment() {
    var options = {
      'key': '0wSFwp2PXBRkkrn9MpHaBVnp', // Replace with your Razorpay API key
      'amount': (double.parse(widget.amount) * 100).toInt(),
      'name': 'Pharmacy App',
      'description': 'Order Payment',
      'prefill': {'contact': '9544688490', 'email': 'mmusthafa270@gmail.com'},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showPaymentStatusDialog("Error", "Failed to start Razorpay: $e");
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          txnId: response.paymentId,
          txnRef: response.orderId,
        ),
      ),
    );
  }
  void _handleRazorpayFailure(PaymentFailureResponse response) {
    _showPaymentStatusDialog("Failed", response.message ?? "Transaction failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showPaymentStatusDialog("Wallet Used", response.walletName ?? "Unknown wallet");
  }

  Future<void> _fetchUpiApps() async {
    try {
      List<UpiApp> availableApps = await _upiIndia.getAllUpiApps();
      if (mounted) {
        setState(() => apps = availableApps);
      }
    } catch (e) {
      print("Error fetching UPI apps: $e");
      if (mounted) {
        _showPaymentStatusDialog("Error", "Couldn't fetch payment apps");
      }
    }
  }

  Future<void> _launchUPIPayment(UpiApp app) async {
    try {
      UpiResponse? response = await _upiIndia.startTransaction(
        app: app,
        receiverUpiId: upiId,
        receiverName: receiverName,
        transactionRefId: "${DateTime.now().millisecondsSinceEpoch}",
        transactionNote: "Pharmacy subscription",
        amount: double.parse(widget.amount),
        currency: "INR",
      );
      _handlePaymentResponse(response);
    } catch (e) {
      _showPaymentStatusDialog("Error", "Payment failed: ${e.toString()}");
    }
  }

  // 🌟 NEW FUNCTION: Launch UPI Intent for any installed UPI app
  // Future<void> _launchUPIIntent() async {
  //   String transactionRefId = "${DateTime.now().millisecondsSinceEpoch}";
  //   String upiUri = "upi://pay?pa=$upiId&pn=$receiverName&tid=${DateTime.now().millisecondsSinceEpoch}&tr=$transactionRefId&tn=Payment&am=${widget.amount}&cu=INR";
  //
  //   if (await canLaunch(upiUri)) {
  //     await launch(upiUri);
  //   } else {
  //     _showPaymentStatusDialog("Error", "No UPI app found to complete the payment.");
  //   }
  // }

  Future<void> _launchUPIIntent() async {
    final uri = Uri.parse(
      'upi://pay?pa=${Uri.encodeComponent(upiId)}'
          '&pn=${Uri.encodeComponent(receiverName)}'
          '&am=${widget.amount}'
          '&cu=INR'
          '&tn=${Uri.encodeComponent("Payment for Order")}',
    );

    try {
      final success = await launchUrl(uri);
      if (!success) {
        _showPaymentStatusDialog("Error", "No UPI app available");
      }
    } catch (e) {
      _showPaymentStatusDialog("Error", "Failed to launch UPI: $e");
    }
  }

  void _handlePaymentResponse(UpiResponse? response) {
    if (!mounted) return;

    if (response == null) {
      _showPaymentStatusDialog("Failed", "Transaction cancelled");
      return;
    }

    switch (response.status) {
      case UpiPaymentStatus.SUCCESS:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              txnId: response.transactionId,
              txnRef: response.transactionRefId,
            ),
          ),
        );
        break;
      case UpiPaymentStatus.SUBMITTED:
        _showPaymentStatusDialog("Pending", "Payment submitted");
        break;
      case UpiPaymentStatus.FAILURE:
        _showPaymentStatusDialog("Failed", response.responseCode ?? "Unknown error");
        break;
      default:
        _showPaymentStatusDialog("Unknown", "Unexpected response");
    }
  }

  void _showPaymentStatusDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
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
        title: Text("Payment ₹${widget.amount}"),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: apps == null
          ? Center(child: CircularProgressIndicator())
          : apps!.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No UPI apps found"),
          ElevatedButton(
            onPressed: _launchUPIIntent,
            child: Text("Try Generic UPI Payment"),
          ),
        ],
      )
          : ListView(
        children: [
          ...apps!.map((app) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.memory(app.icon),
              title: Text(app.name),
              onTap: () => _launchUPIPayment(app),
            ),
          )),
          ListTile(
            leading: Icon(Icons.qr_code),
            title: Text("Pay via Razorpay"),
            onTap: _startRazorpayPayment,
          ),
          ListTile(
            leading: Icon(Icons.more_horiz),
            title: Text("Other Payment Methods"),
            onTap: _launchUPIIntent,
          ),
        ],
      ),
    );
  }
}


// Success Page with Transaction Details
class PaymentSuccessPage extends StatelessWidget {
  final String? txnId;
  final String? txnRef;

  PaymentSuccessPage({this.txnId, this.txnRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Successful"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/profiledone1.json',
              height: 183,
              width: 189,
            ),
            SizedBox(height: 20),
            Text(
              "Your payment was successful!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Transaction ID: $txnId", style: TextStyle(fontSize: 16)),
            Text("Reference No: $txnRef", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
