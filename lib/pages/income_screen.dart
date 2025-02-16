// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  bool isExpense = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isExpense = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isExpense ? Colors.white : Colors.green,
        foregroundColor: isExpense ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.green),
        ),
      ),
      child: Text('INCOME'),
    );
  }
}
