// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_import, avoid_print

import 'package:flutter/material.dart';
import './widgets/expense_tracker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseTracker(), 
      debugShowCheckedModeBanner: false,
    );
  }
}
