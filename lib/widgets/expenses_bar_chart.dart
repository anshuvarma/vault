import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../pages/expense_page.dart';
import '../db_helper.dart';

class ExpensesBarChart extends StatefulWidget {
  final VoidCallback onTransactionUpdated;

  const ExpensesBarChart({super.key, required this.onTransactionUpdated});

  @override
  ExpensesBarChartState createState() => ExpensesBarChartState();
}

class ExpensesBarChartState extends State<ExpensesBarChart> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final dbHelper = DBHelper();
    transactions = await dbHelper.fetchTransactions();
    setState(() {});
  }

  void navigateToExpensePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensePage()),
    );

    if (result == true) {
      fetchTransactions();
    }
  }

  /// Aggregate expenses based on account type (Cash, Card, UPI)
  Map<String, double> _buildAccountDataMap() {
    Map<String, double> dataMap = {
      'Cash': 0.0,
      'Card': 0.0,
      'UPI': 0.0,
    };

    for (var transaction in transactions) {
      if (transaction['isExpense'] == 1) {
        String account =
            transaction['account']?.toString().trim().toLowerCase() ?? 'cash';

        // Normalize account names to match predefined keys
        if (account.contains('card')) {
          account = 'Card';
        } else if (account.contains('upi')) {
          account = 'UPI';
        } else {
          account = 'Cash'; // Default to Cash if unknown
        }

        double amount = (transaction['amount'] is double)
            ? transaction['amount']
            : double.tryParse(transaction['amount'].toString()) ?? 0.0;

        dataMap[account] = (dataMap[account] ?? 0.0) + amount;
      }
    }

    return dataMap;
  }

  /// Build bar groups for the Bar Chart
  List<BarChartGroupData> _buildBarGroups(Map<String, double> dataMap) {
    List<String> accountTypes = ['Cash', 'Card', 'UPI'];
    List<Color> barColors = [
      Color.fromARGB(255, 229, 123, 158),
      Color.fromARGB(255, 142, 152, 208),
      Color.fromARGB(255, 119, 188, 198)
    ];

    return List.generate(accountTypes.length, (index) {
      String account = accountTypes[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataMap[account] ?? 0.0,
            color: barColors[index],
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Map<String, double> dataMap = _buildAccountDataMap();
    List<BarChartGroupData> barGroups = _buildBarGroups(dataMap);

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: SizedBox(
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
                  child: dataMap.values.any((amount) => amount > 0)
                      ? BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    List<String> accountTypes = [
                                      'Cash',
                                      'Card',
                                      'UPI'
                                    ];
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < accountTypes.length) {
                                      return Text(
                                        accountTypes[value.toInt()],
                                        style: TextStyle(fontSize: 12),
                                      );
                                    }
                                    return SizedBox();
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
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
