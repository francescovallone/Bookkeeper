import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Models/goal.dart';
import 'package:Bookkeeper/Models/buy_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database
	String tTable = 'transaction_table';
  String gTable = 'goals_table';
  String bTable = 'bentries_table';
  String listTable = 'buylist_table';
	String colId = 'id';
	String colMoney = 'money';
	String colDate = 'date';
  String colCategory = 'category';
  String colType = 'type';  
  String colTitle = 'title';
	String colMoneyNeeded = 'money_needed';
  String colStatus = 'status';
  String colDesc = 'description';
  String colIdTrans = 'id_transactions';
  String colCost = 'cost';
  String colLink = 'link';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'money_manager.db';
		var transsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return transsDatabase;
	}

	void _createDb(Database db, int newVersion) async {
		await db.execute('CREATE TABLE $tTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colMoney REAL, $colDate TEXT, $colCategory TEXT, $colType INTEGER)');
    await db.execute('CREATE TABLE $gTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colMoneyNeeded REAL, $colTitle TEXT, $colDesc TEXT, $colStatus INTEGER, $colIdTrans INTEGER)');
    await db.execute('CREATE TABLE $bTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCost REAL, $colTitle TEXT, $colLink TEXT)');
	}
	Future<List<Map<String, dynamic>>> getTransactionsMapList() async {
		Database db = await this.database;
		var result = await db.query(tTable, orderBy: '$colId DESC');
		return result;
	}
  
  Future<double> getSumTransactions() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM(money) as total FROM $tTable');
    return result[0]['total'];
  }
  Future<List<double>> getChartData() async{
    Database db = await this.database;
    List<double> data = new List(2);
    var resultinc = await db.rawQuery('SELECT SUM(money) as total FROM $tTable WHERE type = 1');
    var resultexp = await db.rawQuery('SELECT SUM(money) as total FROM $tTable WHERE type = 0');
    data[0] = resultinc[0]['total'] == null ? 0.00 : resultinc[0]['total'];
    data[1] = resultexp[0]['total'] == null ? 0.00 : resultexp[0]['total'];
    return data;
  }

	Future<int> insertTransaction(t.Transaction trans) async {
		Database db = await this.database;
		var result = await db.insert(tTable, trans.toMap());
		return result;
	}

	Future<int> updateTransaction(t.Transaction trans) async {
		var db = await this.database;
		var result = await db.update(tTable, trans.toMap(), where: '$colId = ?', whereArgs: [trans.id]);
		return result;
	}

  Future<int> updateTransactionCompleted(t.Transaction trans) async {
		var db = await this.database;
		var result = await db.update(tTable, trans.toMap(), where: '$colId = ?', whereArgs: [trans.id]);
		return result;
	}

	Future<int> deleteTransaction(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $tTable WHERE $colId = $id');
		return result;
	}

	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	Future<List<t.Transaction>> getTransactionsList() async {
		var moneyMapList = await getTransactionsMapList();
		int count = moneyMapList.length;
		List<t.Transaction> moneyList = List<t.Transaction>();
		for (int i = 0; i < count; i++) {
			moneyList.add(t.Transaction.fromMapObject(moneyMapList[i]));
		}
		return moneyList;
	}
  // Goals
  Future<List<Map<String, dynamic>>> getGoalsMapList() async {
		Database db = await this.database;
		var result = await db.query(gTable, orderBy: '$colId DESC');
		return result;
	}
  Future<List<Goal>> getGoalsList() async {
    var goalsMapList = await getGoalsMapList();
		int count = goalsMapList.length;
		List<Goal> goalsList = List<Goal>();
		for (int i = 0; i < count; i++) {
			goalsList.add(Goal.fromMapObject(goalsMapList[i]));
		}
		return goalsList;
  }
  Future<int> insertGoal(Goal g) async {
		Database db = await this.database;
		var result = await db.insert(gTable, g.toMap());
		return result;
  }
  Future<int> updateGoal(Goal g) async {
		var db = await this.database;
		var result = await db.update(gTable, g.toMap(), where: '$colId = ?', whereArgs: [g.id]);
		return result;
	}
  Future<int> updateGoalCompleted(Goal g) async {
		var db = await this.database;
		var result = await db.update(gTable, g.toMap(), where: '$colId = ?', whereArgs: [g.id]);
		return result;
	}
	Future<int> deleteGoal(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $gTable WHERE $colId = $id');
		return result;
	}
  // Buy Entry
  Future<List<Map<String, dynamic>>> getBuyMapList() async {
		Database db = await this.database;
		var result = await db.query(bTable, orderBy: '$colId DESC');
		return result;
	}
  Future<List<BuyEntry>> getBuyList() async {
    var bEntriesMapList = await getBuyMapList();
		int count = bEntriesMapList.length;
		List<BuyEntry> bEntriesList = List<BuyEntry>();
		for (int i = 0; i < count; i++) {
			bEntriesList.add(BuyEntry.fromMapObject(bEntriesMapList[i]));
		}
		return bEntriesList;
  }
  Future<int> insertBEntry(BuyEntry b) async {
		Database db = await this.database;
		var result = await db.insert(bTable, b.toMap());
		return result;
  }
  Future<int> updateBEntry(BuyEntry b) async {
		var db = await this.database;
		var result = await db.update(bTable, b.toMap(), where: '$colId = ?', whereArgs: [b.id]);
		return result;
	}
  Future<int> updateBEntryCompleted(BuyEntry b) async {
		var db = await this.database;
		var result = await db.update(bTable, b.toMap(), where: '$colId = ?', whereArgs: [b.id]);
		return result;
	}
	Future<int> deleteBEntry(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $bTable WHERE $colId = $id');
		return result;
	}
  Future<double> getSumList() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM(cost) as total FROM $bTable');
    return result[0]['total'];
  }
  Future<int> getBuyCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $bTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}
}