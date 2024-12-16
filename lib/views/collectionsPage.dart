import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pharmacy_app/Constants/appColors.dart';

class Collectionspage extends StatefulWidget {
  const Collectionspage({super.key});

  @override
  State<Collectionspage> createState() => _CollectionspageState();
}

class _CollectionspageState extends State<Collectionspage> {
  double walletBalance = 1250.75; // Example balance
  double grandTotal = 7220.0; // Example grand total from API
  List<double> totalAmounts = [1440, 1420, 840, 800, 1900, 820]; // Example data

  // List of months
  List<String> filters = [
    'Jan - Mar',
    'Apr - Jun',
    'Jul - Sep',
    'Oct - Dec',
  ];
  String selectedFilter = 'Jan - Mar';

  // Filtered data based on selection
  List<double> filteredAmounts = [];

  @override
  void initState() {
    super.initState();
    filteredAmounts = totalAmounts; // Initialize with all data
  }
  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      // Example logic for filtering data
      switch (filter) {
        case 'Jan - Mar':
          filteredAmounts = totalAmounts.sublist(0, 3); // First 3 months
          break;
        case 'Apr - Jun':
          filteredAmounts = totalAmounts.sublist(3, 6); // Next 3 months
          break;
        case 'Jul - Sep':
          filteredAmounts = [0, 0, 0]; // Placeholder data for now
          break;
        case 'Oct - Dec':
          filteredAmounts = [0, 0, 0]; // Placeholder data for now
          break;
        default:
          filteredAmounts = totalAmounts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Collections', style: TextStyle(color: TextColorWhite)),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: Column(
        children: [
          // Wallet Balance Section
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
                  'Wallet Balance',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Months:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: filters.map((String filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (String? newFilter) {
                    if (newFilter != null) {
                      applyFilter(newFilter);
                    }
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 10,),

          // Bar Chart Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 2000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    // tooltipDecoration: BoxDecoration(
                    //   color: Colors.blueAccent, // Tooltip background color
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        'Day ${value.toInt() + 1}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                borderData: FlBorderData(show: false),
                barGroups: totalAmounts
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: PRIMARY_COLOR,
                      width: 16,
                    ),
                  ],
                ))
                    .toList(),
              ),
            )

          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }
}
