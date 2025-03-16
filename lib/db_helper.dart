// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version to trigger the onUpgrade method
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,                 -- Transaction type: 'Expense' or 'Income'
            category TEXT,              -- Category or source of transaction
            amount REAL,                -- Amount of transaction
            date TEXT,                  -- Date of transaction
            account TEXT,               -- Account used, only for expenses
            isExpense INTEGER           -- 1 if expense, 0 if income
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Ensure the 'name' column is added if upgrading from version 1
          await db.execute("ALTER TABLE transactions ADD COLUMN name TEXT");
          // Update existing NULL values with 'Unknown'
          await db.execute(
              "UPDATE transactions SET name = 'Unknown' WHERE name IS NULL");
        }
      },
    );
  }

  // Insert a transaction into the database
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;

    // Debugging: Check if `account` is null before inserting
    print("Before insert - Account: ${transaction['account']}");

    // Ensure the name field is never null
    transaction['name'] = transaction['name'] ?? 'Unknown';

    // Ensure the 'account' field is properly stored
    transaction['account'] = transaction['account']?.toString().trim();

    if (transaction['account'] == null || transaction['account'].toString().trim().isEmpty) {
    print("⚠️ Warning: 'account' is null or empty!");
  }

    print("Inserting transaction: $transaction");
    final result = await db.insert('transactions', transaction);
    print("Transaction inserted with ID: $result");

    return result;
  }

  // Fetch all transactions from the database
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT id, 
           COALESCE(name, 'Unknown') AS name,  -- Ensure 'name' is never null
           category, 
           CAST(amount AS REAL) AS amount, 
           date,
           account, 
           isExpense 
    FROM transactions
    ''');
    print("Fetched transactions: $result"); // Debugging log
    return result;
  }

  // Delete a transaction from the database
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
