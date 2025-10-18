import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Collectionspage extends StatefulWidget {
  const Collectionspage({super.key});

  @override
  State<Collectionspage> createState() => _CollectionspageState();
}

class _CollectionspageState extends State<Collectionspage> {
  List<dynamic> dayWiseResponse = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedMonth = DateTime.now().month.toString(); // Set to current month
  String selectedYear = DateTime.now().year.toString(); // Set to current year

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from API
  Future<void> fetchData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = await preferences.getString('userID');
    String apiUrl = AppUrl.orderSummery; // Replace with your API URL
    const Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> requestBody = {
      "chemistId": int.parse(userID.toString()),
      // "month": '${selectedMonth.padLeft(2, '0')}/$selectedYear', // Format month and year
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );
      print('rereee:${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            dayWiseResponse = data['dayWiseResponse'];
            isLoading = false;
          });
        } else {
          throw Exception('Data fetch unsuccessful');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Collections', style: TextStyle(color: TextColorWhite)),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Failed to load data'))
          : Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: PRIMARY_COLOR,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Collections',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${dayWiseResponse.fold<int>(0, (prev, element) => prev + (element['totalAmount'] as int))}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Spacer(),
          // Month Selection Dropdown
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       const Text(
          //         'Select Month:',
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       DropdownButton<String>(
          //         value: selectedMonth,
          //         items: List.generate(12, (index) {
          //           final monthValue = (index + 1).toString();
          //           final monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][index];
          //           return DropdownMenuItem<String>(
          //             value: monthValue,
          //             child: Text(monthName),
          //           );
          //         }),
          //         onChanged: (String? newMonth) {
          //           if (newMonth != null) {
          //             setState(() {
          //               selectedMonth = newMonth;
          //               isLoading = true;
          //             });
          //             fetchData();
          //           }
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          //
          // const SizedBox(height: 20),
          //
          // // Year Selection Dropdown
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       const Text(
          //         'Select Year:',
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       DropdownButton<String>(
          //         value: selectedYear,
          //         items: List.generate(51, (index) {
          //           final yearValue = (DateTime.now().year + index).toString(); // Generate next 50 years
          //           return DropdownMenuItem<String>(
          //             value: yearValue,
          //             child: Text(yearValue),
          //           );
          //         }),
          //         onChanged: (String? newYear) {
          //           if (newYear != null) {
          //             setState(() {
          //               selectedYear = newYear;
          //               isLoading = true;
          //             });
          //             fetchData();
          //           }
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 20),

          // Bar Chart Section
          Container(
            height: 250,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dayWiseResponse
                    .map((e) => e['totalAmount'])
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Remove left-side values
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= dayWiseResponse.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          dayWiseResponse[index]['date'].toString().split('-')[2], // Show day
                          style: const TextStyle(color: Colors.black),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false), // Remove dotted lines
                borderData: FlBorderData(show: false),
                barGroups: dayWiseResponse
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value['totalAmount'].toDouble(),
                      color: PRIMARY_COLOR,
                      width: 16,
                    ),
                  ],
                ))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
