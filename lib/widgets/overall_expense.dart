// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../pages/expense_page.dart';
import '../constants.dart';
import '../db_helper.dart';

class OverallExpenses extends StatefulWidget {
  final VoidCallback onTransactionUpdated;

  const OverallExpenses({super.key, required this.onTransactionUpdated});

  @override
  OverallExpensesState createState() => OverallExpensesState();
}

class OverallExpensesState extends State<OverallExpenses> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final dbHelper = DBHelper();
    transactions = await dbHelper.fetchTransactions();
    setState(() {
      // Update the state with the new transactions
    }); // Update the UI
  }

  void navigateToExpensePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensePage()),
    );

    if (result == true) {
      fetchTransactions(); // Refresh transactions and update the pie chart
    }
  }

  // Helper function to build the dataMap from expense transactions
  Map<String, double> _buildDataMap() {
    Map<String, double> dataMap = {};

    for (var category in expenseCategories) {
      // Sum up all expense transactions for each category
      double totalAmount = transactions
          .where((transaction) =>
              transaction['category'] == category &&
              transaction['isExpense'] == 1) // Only expenses
          .fold(0.0, (sum, transaction) {
        double amount = transaction['amount'] is double
            ? transaction['amount']
            : double.tryParse(transaction['amount'].toString()) ?? 0.0;
        return sum + amount;
      });

      if (totalAmount > 0) {
        dataMap[category] = totalAmount;
      }
    }

    return dataMap;
  }

  // Helper function to generate the color list based on dataMap keys
  List<Color> _getColorList(Map<String, double> dataMap) {
    return dataMap.keys
        .map((category) => categoryColors[category] ?? Colors.cyan)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Generate the dynamic dataMap and color list
    Map<String, double> dataMap = _buildDataMap();
    List<Color> colorList = _getColorList(dataMap);

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Container(
        height: screenHeight * 0.40,
        child: Card(
          color: const Color.fromARGB(255, 241, 229, 245),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.05, horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Overall Expenses',
                  style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: dataMap.isNotEmpty
                      ? PieChart(
                          dataMap: dataMap,
                          colorList: colorList,
                          chartRadius: screenWidth * 0.5,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 15,
                          legendOptions: LegendOptions(
                            legendShape: BoxShape.circle,
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            legendTextStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            chartValueStyle: TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                            showChartValuesInPercentage: true,
                            showChartValueBackground: false,
                          ),
                          initialAngleInDegree: 0,
                        )
                      : Center(child: Text('No expenses recorded')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
