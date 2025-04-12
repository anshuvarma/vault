// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      // selectedItemColor: Colors.lightBlueAccent,
      // unselectedItemColor: Colors.grey,
      onTap: widget.onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'lib/assets/icons/home.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'lib/assets/icons/expenses.png',
            width: 24,
            height: 24,
          ),
          label: 'Expense',
        ),
      ],
    );
  }
}
