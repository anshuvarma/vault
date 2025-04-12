// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<String> expenseCategories = [
  'Food',
  'Shopping',
  'Transport',
  'Health',
  'Entertainment',
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
  'Food': Color.fromARGB(255, 141, 174, 205),
  'Shopping': Color.fromARGB(255, 174, 163, 231),
  'Transport': Color.fromARGB(255, 206, 150, 198),
  'Health': Color.fromARGB(255, 172, 204, 140),
  'Entertainment': Color.fromARGB(255, 206, 137, 137),
  'Others': Colors.grey,
};

final Map<String, Color> typeColor = {
  'Income': const Color.fromARGB(255, 164, 223, 166),
  'Expense': const Color.fromARGB(255, 207, 145, 145),
};

final Map<String, Color> sourceColors = {
  'Salary': const Color.fromARGB(255, 246, 136, 136),
  'Business': const Color.fromARGB(255, 100, 193, 148),
  'Investment': const Color.fromARGB(255, 235, 178, 103),
  'Rental': const Color.fromARGB(255, 195, 125, 207),
  'Freelance': const Color.fromARGB(255, 114, 147, 204),
  'Others': Colors.grey,
};

final Map<String, Color> accountColors = {
  'Cash': const Color.fromARGB(255, 229, 123, 158),
  'Card': const Color.fromARGB(255, 142, 152, 208),
  'UPI': const Color.fromARGB(255, 119, 188, 198),
};

final Map<String, String> categoryIcons = {
  'food': 'lib/assets/icons/food.png',
  'shopping': 'lib/assets/icons/shopping.png',
  'transport': 'lib/assets/icons/transport.png',
  'health': 'lib/assets/icons/health.png',
  'entertainment': 'lib/assets/icons/entertainment.png',
  'others': 'lib/assets/icons/others.png',
};

final Map<String, String> accountIcons = {
  'cash': 'lib/assets/icons/account/cash.png',
  'card': 'lib/assets/icons/account/card.png',
  'upi': 'lib/assets/icons/account/upi.png',
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
