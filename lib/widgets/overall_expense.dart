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
                  'The Cost of Living: Food, Shopping, & More',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold),
                ),
                // SizedBox(height: 0.3,),
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
                            legendPosition: LegendPosition.left,
                            legendTextStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            chartValueStyle: TextStyle(
                                fontSize: 12.0,
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

// Bar chart code

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../pages/expense_page.dart';
// import '../db_helper.dart';

// class OverallExpenses extends StatefulWidget {
//   final VoidCallback onTransactionUpdated;

//   const OverallExpenses({super.key, required this.onTransactionUpdated});

//   @override
//   OverallExpensesState createState() => OverallExpensesState();
// }

// class OverallExpensesState extends State<OverallExpenses> {
//   List<Map<String, dynamic>> transactions = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchTransactions();
//   }

//   Future<void> fetchTransactions() async {
//     final dbHelper = DBHelper();
//     transactions = await dbHelper.fetchTransactions();
//     setState(() {});
//   }

//   void navigateToExpensePage() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ExpensePage()),
//     );

//     if (result == true) {
//       fetchTransactions();
//     }
//   }

//   /// Aggregate expenses based on account type (Cash, Card, UPI)
//   Map<String, double> _buildAccountDataMap() {
//     Map<String, double> dataMap = {
//       'Cash': 0.0,
//       'Card': 0.0,
//       'UPI': 0.0,
//     };

//     for (var transaction in transactions) {
//       if (transaction['isExpense'] == 1) {
//         String account =
//             transaction['account']?.toString().trim().toLowerCase() ?? 'cash';

//         // Normalize account names to match predefined keys
//         if (account.contains('card')) {
//           account = 'Card';
//         } else if (account.contains('upi')) {
//           account = 'UPI';
//         } else {
//           account = 'Cash'; // Default to Cash if unknown
//         }

//         double amount = (transaction['amount'] is double)
//             ? transaction['amount']
//             : double.tryParse(transaction['amount'].toString()) ?? 0.0;

//         dataMap[account] = (dataMap[account] ?? 0.0) + amount;
//       }
//     }

//     return dataMap;
//   }

//   /// Build bar groups for the Bar Chart
//   List<BarChartGroupData> _buildBarGroups(Map<String, double> dataMap) {
//     List<String> accountTypes = ['Cash', 'Card', 'UPI'];
//     List<Color> barColors = [Colors.blue, Colors.green, Colors.orange];

//     return List.generate(accountTypes.length, (index) {
//       String account = accountTypes[index];
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: dataMap[account] ?? 0.0,
//             color: barColors[index],
//             width: 18,
//             borderRadius: BorderRadius.circular(6),
//           ),
//         ],
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     Map<String, double> dataMap = _buildAccountDataMap();
//     List<BarChartGroupData> barGroups = _buildBarGroups(dataMap);

//     return Padding(
//       padding: EdgeInsets.all(screenWidth * 0.02),
//       child: Container(
//         height: screenHeight * 0.40,
//         child: Card(
//           color: const Color.fromARGB(255, 241, 229, 245),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 4,
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//                 vertical: screenWidth * 0.05, horizontal: screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   'Expenses by Account Type',
//                   style: TextStyle(
//                       fontSize: screenWidth * 0.05,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 Expanded(
//                   child: dataMap.values.any((amount) => amount > 0)
//                       ? BarChart(
//                           BarChartData(
//                             barGroups: barGroups,
//                             titlesData: FlTitlesData(
//                               leftTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   reservedSize: 40,
//                                   getTitlesWidget: (value, meta) {
//                                     return Text(
//                                       value.toInt().toString(),
//                                       style: TextStyle(fontSize: 12),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     List<String> accountTypes = [
//                                       'Cash',
//                                       'Card',
//                                       'UPI'
//                                     ];
//                                     if (value.toInt() >= 0 &&
//                                         value.toInt() < accountTypes.length) {
//                                       return Text(
//                                         accountTypes[value.toInt()],
//                                         style: TextStyle(fontSize: 12),
//                                       );
//                                     }
//                                     return SizedBox();
//                                   },
//                                   reservedSize: 30,
//                                 ),
//                               ),
//                             ),
//                             borderData: FlBorderData(show: false),
//                             gridData: FlGridData(show: false),
//                           ),
//                         )
//                       : Center(child: Text('No expenses recorded')),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
