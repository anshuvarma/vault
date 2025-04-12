// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';

class Temp extends StatefulWidget {
  const Temp({super.key});

  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  final TextEditingController _amountController = TextEditingController();
  bool isExpense = true;
  String selectedCategory = 'Select';
  String selectedSource = 'Select';
  DateTime selectedDate = DateTime.now();
  String selectedAccount = 'Select';
  bool isRecurring = false;

  final List<String> _expenseCategories = [
    'Select',
    'Food',
    'Groceries',
    'Entertainment',
    'Travel',
    'Shopping'
  ];
  final List<String> _incomeSources = [
    'Select',
    'Salary',
    'Freelance',
    'Investment',
    'Gift'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final amount = _amountController.text;
    final date =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    final account = isExpense ? selectedAccount : 'N/A';
    final categoryOrSource = isExpense ? selectedCategory : selectedSource;

    print('Amount: $amount');
    print('Date: $date');
    print('Type: ${isExpense ? 'Expense' : 'Income'}');
    print('Category/Source: $categoryOrSource');
    print('Account: $account');
    if (!isExpense) print('Recurring Income: $isRecurring');

    _amountController.clear();
    setState(() {
      selectedCategory = 'Select';
      selectedSource = 'Select';
      selectedAccount = 'Select';
      isRecurring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 173, 141, 189),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'New Transaction',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle between Expense and Income
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isExpense ? Colors.redAccent : Colors.grey[200],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.remove_circle_outline,
                              color: isExpense ? Colors.white : Colors.black),
                          SizedBox(height: 8),
                          Text('Expense',
                              style: TextStyle(
                                  color:
                                      isExpense ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isExpense ? Colors.grey[200] : Colors.greenAccent,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: isExpense ? Colors.black : Colors.white),
                          SizedBox(height: 8),
                          Text('Income',
                              style: TextStyle(
                                  color:
                                      isExpense ? Colors.black : Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Amount Input Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 36),
              ),
            ),
            SizedBox(height: 24),

            // Category or Source Dropdown
            DropdownButtonFormField<String>(
              value: isExpense ? selectedCategory : selectedSource,
              decoration: InputDecoration(
                labelText: isExpense ? 'Category' : 'Source',
                prefixIcon:
                    Icon(isExpense ? Icons.category : Icons.attach_money),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  if (isExpense) {
                    selectedCategory = newValue!;
                  } else {
                    selectedSource = newValue!;
                  }
                });
              },
              items: (isExpense ? _expenseCategories : _incomeSources)
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Account Dropdown for Expense
            if (isExpense)
              DropdownButtonFormField<String>(
                value: selectedAccount,
                decoration: InputDecoration(
                  labelText: 'Account',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccount = newValue!;
                  });
                },
                items: ['Select', 'Cash', 'Bank', 'UPI']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            if (!isExpense)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Recurring Income'),
                value: isRecurring,
                onChanged: (bool value) {
                  setState(() {
                    isRecurring = value;
                  });
                },
              ),
            Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('SAVE', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
