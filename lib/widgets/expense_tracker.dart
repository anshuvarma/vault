// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, unused_field, unused_element, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:vault/widgets/bottom_nav_bar.dart';
import 'package:vault/widgets/overall_expense.dart';
import 'package:vault/widgets/recent_transaction.dart';
import 'package:vault/widgets/recent_transaction_list.dart';
import '../constants.dart';
import '../db_helper.dart';
import '../pages/expense_page.dart';
import '../pages/new_transaction_page.dart';

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final GlobalKey<RecentTransactionsState> recentTransactionsKey =
      GlobalKey<RecentTransactionsState>();
  final GlobalKey<OverallExpensesState> overallExpenseKey =
      GlobalKey<OverallExpensesState>();
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
    final data = await dbHelper.fetchTransactions();
    setState(() {
      newTransactions = data.reversed.toList();
    });
  }

  void refreshTransactions() {
    recentTransactionsKey.currentState?.refreshTransactionList();
    overallExpenseKey.currentState?.fetchTransactions();
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
          backgroundColor: Color.fromARGB(255, 250, 189, 241),
          elevation: 2,
          centerTitle: true,
          title: Text(
            "Coin Check",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(1, 153, 159, 198),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverallExpenses(
                  key: overallExpenseKey,
                  onTransactionUpdated:
                      refreshTransactions, // Pass the update callback
                ),
                SizedBox(height: screenWidth * 0.04),
                Padding(
                  padding: const EdgeInsets.only(left: 12.5),
                  child: Text(
                    'Recent Expenses',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
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
          backgroundColor: Color.fromARGB(255, 250, 189, 241),
          foregroundColor: Colors.black,
          onPressed: () async {
            final result = await Navigator.pushReplacement(
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
