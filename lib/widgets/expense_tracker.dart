// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, unused_field, unused_element, use_build_context_synchronously, use_function_type_syntax_for_parameters, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vault/widgets/bottom_nav_bar.dart';
import 'package:vault/widgets/overall_expense.dart';
import 'package:vault/widgets/recent_transaction.dart';
import 'package:vault/widgets/recent_transaction_list.dart';
import '../constants.dart';
import '../db_helper.dart';
import '../pages/expense_page.dart';
import '../pages/new_transaction_page.dart';
import 'expenses_bar_chart.dart';

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<RecentTransactionsState> recentTransactionsKey =
      GlobalKey<RecentTransactionsState>();
  final GlobalKey<OverallExpensesState> overallExpenseKey =
      GlobalKey<OverallExpensesState>();
  final GlobalKey<ExpensesBarChartState> expensesBarChartKey =
      GlobalKey<ExpensesBarChartState>();
  final TextEditingController _amountController = TextEditingController();
  bool isExpense = true;
  String selectedCategory = '';
  String selectedSource = '';
  DateTime selectedDate = DateTime.now();
  String selectedAccount = '';
  List<Map<String, dynamic>> newTransactions = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    print("Loading transactions...");
    final data = await dbHelper.fetchTransactions();
    if (!mounted) {
      print("Widget is not mounted, skipping setState.");
      return;
    }
    setState(() {
      newTransactions = data.reversed.toList();
      print("Transactions updated.");
    });
  }

  void refreshTransactions() {
    if (!mounted) return;

    recentTransactionsKey.currentState?.refreshTransactionList();
    overallExpenseKey.currentState?.fetchTransactions();
    _loadTransactions();
    expensesBarChartKey.currentState?.fetchTransactions();
    _loadTransactions();
    print("Transactions refreshed.");
  }

  Future<void> _deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    refreshTransactions();
    deleteDialog(context);
  }

  void onItemTapped(int index) async {
    if (index == 1) {
      // Navigate to ExpensePage and await result
      final result = await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ExpensePage()),
      );

      // If any changes were made on ExpensePage, refresh transactions
      if (result != null && result) {
        refreshTransactions();
      }
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh transactions when returning to the app
      refreshTransactions();
    }
  }

  double _calculateRecentTotalExpense() {
    final recentTransactions = newTransactions.length > 5
        ? newTransactions.sublist(0, 5)
        : newTransactions;

    return recentTransactions
        .where((tx) => tx['isExpense'] == 1) // Only expenses
        .fold(0.0, (sum, tx) => sum + double.parse(tx['amount'].toString()));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false, // Prevents automatic back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Ignore if already popped

        bool shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) {
          exitApp(); // Exit app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 173, 141, 189),
          elevation: 2,
          centerTitle: true,
          title: Text(
            "Vault",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(1, 153, 159, 198),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Swappable Stack Cards
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.40, // Adjust height as needed
                      child: PageView(
                        controller: _pageController,
                        children: [
                          OverallExpenses(
                            key: overallExpenseKey,
                            onTransactionUpdated: refreshTransactions,
                          ),
                          ExpensesBarChart(
                            key: expensesBarChartKey,
                            onTransactionUpdated: refreshTransactions,
                          ),
                        ],
                      ),
                    ),
                    // Page Indicator (Dots)
                    Positioned(
                      bottom: 20,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2, // Two pages
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Color.fromARGB(255, 221, 153, 211),
                          dotColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                Padding(
                  padding: const EdgeInsets.only(left: 10.5, right: 11.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                      // Total Expenses Amount
                      Text(
                        '₹${_calculateRecentTotalExpense()}',
                        style: TextStyle(
                          color: Colors.red, // You can change this color
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Expanded(
                  child: RecentTransactionList(
                    transactions: newTransactions,
                    deleteTransaction: _deleteTransaction,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
            currentIndex: currentIndex, onItemTapped: onItemTapped),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 173, 141, 189),
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewTransactionPage(
                  onUpdate:
                      refreshTransactions, // Pass the callback to NewTransactionPage
                ),
              ),
            );
            if (result == true) {
              refreshTransactions(); // Refresh the transactions if a new one was added
            }
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }

  /// Show confirmation dialog before exiting
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    bool shouldExit =
        await exitConfirmationDialog(context); // Default to false if dismissed
    return shouldExit;
  }
}
