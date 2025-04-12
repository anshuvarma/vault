// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants.dart';

class AllTransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredTransactions;
  final Function(int id) onDeleteTransaction;
  final Map<String, Color> categoryColors;

  const AllTransactionList({
    super.key,
    required this.filteredTransactions,
    required this.onDeleteTransaction,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        final category = transaction['category'];
        final color = categoryColors[category] ?? Colors.cyan;
        final iconPath = categoryIcons[category.toString().toLowerCase()];

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
              content:
                  Text("Are you sure you want to delete this transaction?"),
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
            onDeleteTransaction(transaction['id']);
          },
          child: Card(
            color: color,
            child: ListTile(
              iconColor: Colors.white,
              leading: iconPath != null
                  ? Image.asset(
                      iconPath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    )
                  : Icon(Icons.category, color: Colors.white),
              title: Text(transaction['category'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    transaction['date'],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Paid through ${transaction['account']}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                transaction['amount'].toString(),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
