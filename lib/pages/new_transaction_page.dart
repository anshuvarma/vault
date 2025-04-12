// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../constants.dart';

class NewTransactionPage extends StatefulWidget {
  final VoidCallback onUpdate;
  const NewTransactionPage({super.key, required this.onUpdate});

  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isExpense = true;
  String selectedCategory = '';
  String selectedSource = '';
  DateTime selectedDate = DateTime.now();
  String selectedAccount = '';

  bool get isFormValid {
    return _amountController.text.isNotEmpty &&
        (isExpense ? selectedCategory.isNotEmpty : selectedSource.isNotEmpty) &&
        selectedDate != null &&
        (isExpense ? selectedAccount.isNotEmpty : true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Save transaction into the database
  Future<void> _saveTransaction() async {
    if (!isFormValid) {
      return;
    }
    final type = isExpense ? 'Expense' : 'Income';
    final amount = _amountController.text;
    final date =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    final account = isExpense ? selectedAccount : 'N/A';
    final categoryOrSource = isExpense ? selectedCategory : selectedSource;

    final dbHelper = DBHelper();
    print(
        "Saving transaction: {name: $type, category: $categoryOrSource, amount: $amount, date: $date, isExpense: ${isExpense ? 1 : 0}}");
    await dbHelper.insertTransaction({
      'name': type,
      'category': categoryOrSource,
      'amount': amount,
      'date': date,
      'account': account,
      'isExpense': isExpense ? 1 : 0,
    });

    // Clear fields after saving
    _amountController.clear();
    setState(() {
      selectedCategory = '';
      selectedSource = '';
      selectedAccount = '';
    });

    // Pass a result back to the previous page
    print("Transaction saved, calling onUpdate callback...");
    // Close the current page and return to the previous one
    widget.onUpdate();
    Navigator.pop(context, true);
  }

  // Custom Dropdown Menu with Colorful Options
  Widget buildCustomDropdown(
      {required List<String> items,
      required String value,
      required ValueChanged<String?> onChanged,
      required Map<String, Color> colorMap,
      required String label,
      required String iconPath
      // required IconData icon,
      }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(label),
            content: Container(
              height: MediaQuery.of(context).size.height / 5.0,
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      onChanged(item);
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorMap[item],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black54),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Image.asset(
                iconPath, // 👈 use asset image
                width: 24,
                height: 24,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: value == ''
                  ? Text('Select', style: TextStyle(color: Colors.black))
                  : Text(value, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is open
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 173, 141, 189),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          'Vault',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add Expense",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 20.0),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Amount Input Field
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 36),
                    ),
                    onChanged: (_) => setState(() {}), // Trigger validations
                  ),
                  SizedBox(height: 24),

                  // Category or Source Dropdown
                  buildCustomDropdown(
                    items: isExpense ? expenseCategories : incomeSources,
                    value: isExpense ? selectedCategory : selectedSource,
                    onChanged: (newValue) {
                      setState(() {
                        if (isExpense) {
                          selectedCategory = newValue!;
                        } else {
                          selectedSource = newValue!;
                        }
                      });
                    },
                    colorMap: categoryColors,
                    label: 'Category',
                    iconPath: 'lib/assets/icons/category.png',
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
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'lib/assets/icons/calendar.png',
                            width: 14,
                            height: 14,
                          ),
                        ),
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
                    buildCustomDropdown(
                      items: accounts,
                      value: selectedAccount,
                      onChanged: (newValue) {
                        setState(() {
                          selectedAccount = newValue!;
                        });
                      },
                      colorMap: accountColors,
                      label: 'Account',
                      iconPath: 'lib/assets/icons/coin.png',
                    ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Conditional visibility of Save button based on keyboard state
          if (!keyboardOpen)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFormValid ? _saveTransaction : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color.fromARGB(255, 173, 141, 189),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Save',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
