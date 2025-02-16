// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  bool isExpense = true;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isExpense = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isExpense ? Colors.redAccent : Colors.white,
        foregroundColor: isExpense ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent),
        ),
      ),
      child: Text('EXPENSE'),
    );
  }
}
