// ignore_for_file: annotate_overrides, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../constants.dart';

class RecentTransactions extends StatefulWidget {
  final VoidCallback onTransactionDeleted;

  const RecentTransactions({super.key, required this.onTransactionDeleted});

  @override
  RecentTransactionsState createState() => RecentTransactionsState();
}

class RecentTransactionsState extends State<RecentTransactions>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> transactionsFuture;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    transactionsFuture = dbHelper.fetchTransactions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh transactions when app resumes
      _loadTransactions();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  _loadTransactions() {
    setState(() {
      transactionsFuture = dbHelper.fetchTransactions().then(
            (transactions) => transactions.reversed.toList(),
          );
    });
  }

  Future<void> _deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    await _loadTransactions();
    widget.onTransactionDeleted();
  }

  void refreshTransactionList() {
    _loadTransactions();
  }

  Future<bool?> _confirmDeletion() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content:
              const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final transactions = snapshot.data!.take(5).toList();
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final category = transaction['category'];
                final cardColor = categoryColors[category] ?? Colors.cyan;
                return Dismissible(
                  key: ValueKey(transaction['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) => _confirmDeletion(),
                  onDismissed: (direction) {
                    _deleteTransaction(transaction['id']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor.withValues(),
                        // color: cardColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.account_balance_wallet,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  transaction['category'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  transaction['date'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            transaction['amount'].toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet!'));
          } else {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
