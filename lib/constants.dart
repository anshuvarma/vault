// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<String> expenseCategories = [
  'Food',
  'Shopping',
  'Transport',
  'Entertainment',
  'Health',
  'Others',
];

final List<String> typeCategory = ['Income', 'Expense'];

final List<String> incomeSources = [
  'Salary',
  'Business',
  'Investment',
  'Rental',
  'Freelance',
  'Others',
];

final List<String> accounts = ['Cash', 'Card', 'UPI'];

final Map<String, Color> categoryColors = {
  'Food': Colors.redAccent,
  'Shopping': Colors.greenAccent,
  'Transport': Color.fromARGB(255, 208, 62, 234),
  'Entertainment': const Color.fromARGB(255, 227, 161, 74),
  'Health': Colors.blueAccent,
  'Others': Colors.grey,
};

final Map<String, Color> typeColor = {
  'Income': Colors.green.shade100,
  'Expense': Colors.red.shade200,
};

final Map<String, Color> sourceColors = {
  'Salary': Colors.redAccent,
  'Business': Colors.greenAccent,
  'Investment': Colors.orangeAccent,
  'Rental': Colors.purpleAccent,
  'Freelance': Colors.blueAccent,
  'Others': Colors.grey.shade700,
};

final Map<String, Color> accountColors = {
  'Cash': Colors.pinkAccent,
  'Card': Colors.indigoAccent,
  'UPI': Colors.cyanAccent.shade700,
};

void deleteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.all(16),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        content: SizedBox(
          width: 300, // Adjust width
          height: 130, // Adjust height
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 25,
              ),
              Text(
                "Your transaction has been deleted succesfully",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Exit confirmation popup message
Future<bool> exitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit App"),
            content: Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit
                child: Text("Exit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Function to exit the app properly
  void exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop(); // Properly exits the app on Android
    } else if (Platform.isIOS) {
      exit(0); // Force exit on iOS (not recommended by Apple)
    }
  }
