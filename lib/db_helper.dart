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
        }
      },
    );
  }

  // Insert a transaction into the database
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    print("Inserting transaction: $transaction");
    final result = await db.insert('transactions', transaction);
    print("Transaction inserted with ID: $result");
    return result;
  }

  // Fetch all transactions from the database
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT id, name, category, CAST(amount AS REAL) AS amount, date, isExpense FROM transactions');
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
