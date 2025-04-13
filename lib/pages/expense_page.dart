// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, unused_element, override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:vault/widgets/all_transaction_list.dart';

import '../constants.dart';
import '../db_helper.dart';
import '../main.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/recent_transaction.dart';
import 'new_transaction_page.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool transactionsUpdated = false;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RecentTransactionsState> recentTransactionsKey =
      GlobalKey<RecentTransactionsState>();

  String? selectedCategory;
  String searchQuery = '';
  int currentIndex = 1;
  List<Map<String, dynamic>> newTransactions = [];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

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
    _loadTransactions();
  }

  Future<void> _deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    setState(() {
      transactionsUpdated = true; // Mark transactions as updated
    });
    refreshTransactions();
    deleteDialog(context);
  }

  List<Map<String, dynamic>> getFilteredTransactions() {
    return newTransactions.where((transaction) {
      bool isExpense = transaction['name'] == 'Expense';
      bool matchesCategory = selectedCategory == null ||
          transaction['category'] == selectedCategory;
      bool matchesSearch = transaction['name']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          transaction['category']
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      return isExpense && matchesCategory && matchesSearch;
    }).toList();
  }

  // Override the back navigation behavior
  @override
  void dispose() {
    // Navigator.pop(context, transactionsUpdated); // Ensure update is passed
    super.dispose();
  }

  double _calculateTotalExpense() {
    return newTransactions
        .where((tx) => tx['isExpense'] == 1) // Only expenses
        .fold(0.0, (sum, tx) => sum + double.parse(tx['amount'].toString()));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = getFilteredTransactions();
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          bool shoulExit = await _showExitConfirmationDialog(context);
          if (shoulExit) {
            exitApp();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 173, 141, 189),
            elevation: 1,
            title: Text(
              'Vault',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 241, 229, 245),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for any expense',
                      hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                      icon: Image.asset(
                        'lib/assets/icons/search.png',
                        width: 24,
                        height: 24,
                        // color: Colors.blueGrey.shade200,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Category Filter
                Text('Category',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: expenseCategories.map((category) {
                        bool isSelected = selectedCategory == category;
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedCategory = selected ? category : null;
                              });
                            },
                            selectedColor: Colors.purple,
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 10.5, right: 11.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Expenses',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      // Total Expenses Amount
                      Text(
                        '₹${_calculateTotalExpense()}',
                        style: TextStyle(
                          color: Colors.red, // You can change this color
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Transaction List
                SizedBox(height: 15),
                Expanded(
                  child: newTransactions.isNotEmpty
                      ? AllTransactionList(
                          filteredTransactions: filteredTransactions,
                          onDeleteTransaction: _deleteTransaction,
                          categoryColors: categoryColors)
                      : Center(
                          child: Text('No transactions yet!'),
                        ),
                ),
              ],
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
                    onUpdate: refreshTransactions,
                  ),
                ),
              );
              if (result == true) {
                setState(() {
                  transactionsUpdated = true;
                });
              }
            },
            child: Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
        ));
  }

  /// Show confirmation dialog before exiting
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    bool shouldExit =
        await exitConfirmationDialog(context); // Default to false if dismissed
    return shouldExit;
  }
}
