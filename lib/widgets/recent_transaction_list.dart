// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants.dart';

class RecentTransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Future<void> Function(int id) deleteTransaction;

  const RecentTransactionList({
    super.key,
    required this.transactions,
    required this.deleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return transactions.isNotEmpty
        ? ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final category = transaction['category'];
              final color = categoryColors[category] ?? Colors.cyan;

              return Dismissible(
                key: ValueKey(transaction['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Delete Transaction"),
                    content: Text(
                        "Are you sure you want to delete this transaction?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  deleteTransaction(transaction['id']);
                },
                child: Card(
                  color: color.withOpacity(0.8),
                  child: ListTile(
                    iconColor: Colors.white,
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text(
                      transaction['category'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(transaction['date'])],
                    ),
                    trailing: Text(
                      transaction['amount'].toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text('No transactions yet!'),
          );
  }
}
