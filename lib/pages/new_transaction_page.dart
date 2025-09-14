// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, library_private_types_in_public_api, avoid_print, unused_element, deprecated_member_use, equal_keys_in_map, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vault/widgets/expenses_bar_chart.dart';
import 'package:vault/widgets/overall_expense.dart';
import 'package:vault/widgets/recent_transaction.dart';
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
  bool isImageTabSelected = false;
  String selectedCategory = '';
  String selectedSource = '';
  DateTime selectedDate = DateTime.now();
  String selectedAccount = '';
  bool imageDetailsFilled = false;
  List<Map<String, dynamic>> newTransactions = [];
  final dbHelper = DBHelper();
  final GlobalKey<RecentTransactionsState> recentTransactionsKey =
      GlobalKey<RecentTransactionsState>();
  final GlobalKey<OverallExpensesState> overallExpenseKey =
      GlobalKey<OverallExpensesState>();
  final GlobalKey<ExpensesBarChartState> expensesBarChartKey =
      GlobalKey<ExpensesBarChartState>();

  bool get isFormValid {
    return _amountController.text.isNotEmpty &&
        (isExpense ? selectedCategory.isNotEmpty : selectedSource.isNotEmpty) &&
        selectedDate != null &&
        (isExpense ? selectedAccount.isNotEmpty : true);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadAndParseReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;
      print("Extracted Text: $extractedText");

      // Split lines for easier parsing
      final lines = extractedText.split('\n').map((l) => l.trim()).toList();

      // ---------------- AMOUNT PARSING ----------------
      double? _extractAmount(String text) {
        // Normalize OCR errors
        text = text
            .replaceAll(RegExp(r'[zZ]'), '₹')
            .replaceAll(RegExp(r'[?=PE]'), '₹')
            .replaceAll('7', '₹')
            .replaceAll('₹₹', '₹')
            .replaceAll('INR', '₹')
            .replaceAll(RegExp(r'Rs\.?', caseSensitive: false), '₹');

        final lines = text.split('\n').map((l) => l.trim()).toList();

        debugPrint("----- OCR DEBUG START -----");
        for (var line in lines) {
          debugPrint("LINE: [$line]");
        }
        debugPrint("----- OCR DEBUG END -----");

        // Case 1: ₹, Rs, INR
        final regexInline = RegExp(
          r'(?:₹|Rs|INR|[?=PE])\s*([\d]+(?:[.,]\d{1,2})?)',
          caseSensitive: false,
        );

        List<double> candidates = [];
        for (final line in lines) {
          for (final match in regexInline.allMatches(line)) {
            String raw = match.group(1)!;
            raw = raw.replaceAll(RegExp(r'[^\d.]'), '');
            final val = double.tryParse(raw);
            if (val != null) {
              if (!(line.toLowerCase().contains('cashback') && val < 5)) {
                candidates.add(val);
              }
            }
          }
        }
        if (candidates.isNotEmpty) return candidates.last;

        // Case 2: standalone numbers
        final regexLoose = RegExp(r'^\d+(?:[.,]\d{1,2})?$');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (regexLoose.hasMatch(line)) {
            final numVal = double.tryParse(line);
            if (numVal == null) continue;

            final prev = i > 0 ? lines[i - 1].toLowerCase() : '';
            final next = i < lines.length - 1 ? lines[i + 1].toLowerCase() : '';
            final context = prev + " " + next;

            if (context.contains('paid') ||
                context.contains('₹aid') || // corrupted Paid
                context.contains('debited') ||
                context.contains('credited') ||
                context.contains('payment') ||
                context.contains('transaction') ||
                context.contains('success')) {
              return numVal;
            }
          }
        }

        // Case 3: ultimate fallback → take the first valid standalone number
        for (final line in lines) {
          if (regexLoose.hasMatch(line)) {
            return double.tryParse(line);
          }
        }

        return null;
      }

      double? amount = _extractAmount(extractedText);

      // ---------------- DATE PARSING ----------------
      String date = '';
      final patterns = [
        RegExp(r"(\d{1,2})(?:st|nd|rd|th)?\s+([a-zA-Z]+)\'?(\d{2,4})"),
        RegExp(r'(\d{1,2})\s+([a-zA-Z]+)\s+(\d{2,4})'),
        RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
        RegExp(r'(\d{2})[/-](\d{2})[/-](\d{2,4})'),
        RegExp(r'([a-zA-Z]+)\s+(\d{1,2}),\s*(\d{2,4})'),
        RegExp(r'(\d{4})[.](\d{2})[.](\d{2})'),
      ];

      final months = {
        'jan': '01',
        'feb': '02',
        'mar': '03',
        'apr': '04',
        'may': '05',
        'jun': '06',
        'jul': '07',
        'aug': '08',
        'sep': '09',
        'oct': '10',
        'nov': '11',
        'dec': '12',
        'january': '01',
        'february': '02',
        'march': '03',
        'april': '04',
        'may': '05',
        'june': '06',
        'july': '07',
        'august': '08',
        'september': '09',
        'october': '10',
        'november': '11',
        'december': '12',
      };

      for (final line in lines) {
        for (final regex in patterns) {
          final match = regex.firstMatch(line);
          if (match != null) {
            if (regex.pattern.contains('st|nd|rd|th') ||
                regex.pattern.contains("'")) {
              final day = match.group(1);
              final month =
                  months[match.group(2)!.toLowerCase().substring(0, 3)] ?? '01';
              final year = match.group(3)!.length == 2
                  ? '20${match.group(3)}'
                  : match.group(3);
              date = '$day/$month/$year';
            } else if (regex.pattern.contains(r'(\d{1,2})\s+([a-zA-Z]+)\s+')) {
              final day = match.group(1);
              final month =
                  months[match.group(2)!.toLowerCase().substring(0, 3)] ?? '01';
              final year = match.group(3)!.length == 2
                  ? '20${match.group(3)}'
                  : match.group(3);
              date = '$day/$month/$year';
            } else if (regex.pattern.contains('-') &&
                match.groupCount == 3 &&
                match.group(1)!.length == 4) {
              date = '${match.group(3)}/${match.group(2)}/${match.group(1)}';
            } else if (regex.pattern.contains(r'[/-]')) {
              final day = match.group(1);
              final month = match.group(2);
              var year = match.group(3);
              if (year!.length == 2) year = '20$year';
              date = '$day/$month/$year';
            } else if (regex.pattern.contains(',')) {
              final month =
                  months[match.group(1)!.toLowerCase().substring(0, 3)] ?? '01';
              final day = match.group(2);
              var year = match.group(3);
              if (year!.length == 2) year = '20$year';
              date = '$day/$month/$year';
            } else if (regex.pattern.contains('.')) {
              date = '${match.group(3)}/${match.group(2)}/${match.group(1)}';
            }
            break;
          }
        }
        if (date.isNotEmpty) break;
      }
      // ---------------------------------------------------

      String paidThrough = 'UPI'; // Always UPI for image upload

      print('Parsed Amount: $amount');
      print('Parsed Date: $date');

      // Show confirmation dialog with parsed details
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ₹${amount ?? "Not Found"}'),
              Text('Date: $date'),
              Text('Paid Through: $paidThrough'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      if (confirm == true && amount != null) {
        setState(() {
          _amountController.text = amount.toString();
          selectedAccount = paidThrough;
          // Parse date string to DateTime if possible
          try {
            final parts = date.split('/');
            selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } catch (e) {
            selectedDate = DateTime.now();
          }
          imageDetailsFilled = true;
        });
      }
    } else {
      // No image selected
    }
  }

  Future<void> _loadTransactions() async {
    final data = await dbHelper.fetchTransactions();
    if (!mounted) {
      return;
    }
    setState(() {
      newTransactions = data.reversed.toList();
    });
  }

  void refreshTransactions() {
    if (!mounted) return;

    recentTransactionsKey.currentState?.refreshTransactionList();
    overallExpenseKey.currentState?.fetchTransactions();
    _loadTransactions();
    expensesBarChartKey.currentState?.fetchTransactions();
    _loadTransactions();
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
                  // Add this widget below your AppBar and above "Add Expense"
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
                  SizedBox(height: 15),
                  // Tab Switch: Add vs Image Upload
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EFFE), // background
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isImageTabSelected = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: !isImageTabSelected
                                      ? const Color(0xFF885DFF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Add Expense",
                                    style: TextStyle(
                                      color: !isImageTabSelected
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isImageTabSelected = true;
                                  _uploadAndParseReceipt(); // 👈 automatically open image picker
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isImageTabSelected
                                      ? const Color(0xFF885DFF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Image Upload",
                                    style: TextStyle(
                                      color: isImageTabSelected
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),

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
