import 'package:Bookkeeper/models/subscription.dart';
import 'package:Bookkeeper/models/transaction.dart' as t;
import 'package:Bookkeeper/models/goal.dart';
import 'package:Bookkeeper/models/buy_entry.dart';
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
  String subsTable = 'subscriptions_table';
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
  String colCost = 'cost';
  String colLink = 'link';
  String colPeriod = 'period';

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
		String path = directory.path + 'bookeeper.db';
		var database = await openDatabase(
      path,
      version: 3, 
      onCreate: _createDb,
      onDowngrade: onDatabaseDowngradeDelete,
    );
		return database;
	}

	void _createDb(Database db, int newVersion) async {
		await db.execute('CREATE TABLE $tTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colMoney REAL, $colDate TEXT, $colCategory TEXT, $colType INTEGER)');
    await db.execute('CREATE TABLE $gTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colMoneyNeeded REAL, $colTitle TEXT, $colDate TEXT, $colStatus INTEGER)');
    await db.execute('CREATE TABLE $bTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCost REAL, $colTitle TEXT, $colLink TEXT)');
    await db.execute('CREATE TABLE $subsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCost REAL, $colTitle TEXT, $colPeriod TEXT, $colDate TEXT)');
	
  }
	Future<List<Map<String, dynamic>>> getTransactionsMapList() async {
		Database db = await this.database;
		var result = await db.query(tTable, orderBy: '$colId DESC', limit: 5);
		return result;
	}
  Future<List<Map<String, dynamic>>> getTransactionsFullMapList() async {
		Database db = await this.database;
		var result = await db.query(tTable, orderBy: '$colId ASC');
		return result;
	}
  Future<List<t.Transaction>> getTransactionsFullList() async {
	  var moneyMapList = await getTransactionsFullMapList();
		int count = moneyMapList.length;
		List<t.Transaction> moneyList = List<t.Transaction>();
		for (int i = 0; i < count; i++) {
			moneyList.add(t.Transaction.fromMapObject(moneyMapList[i]));
		}
		return moneyList;
	}
  Future<double> getSumTransactions() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM($colMoney) as total FROM $tTable');
    return result[0]['total'];
  }
  Future<List<Map<String, dynamic>>> getExpenseIncomeMap() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM($colMoney) as money, $colType FROM $tTable GROUP BY $colType');
    return result;
  }
  Future<List<t.Transaction>> getExpenseIncome() async{
    var mapList = await getExpenseIncomeMap();
    List<t.Transaction> transactionsList = List<t.Transaction>();
    for(int i = 0; i < mapList.length; i++) transactionsList.add(t.Transaction.fromMapObject(mapList[i]));
    return transactionsList;
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

	Future<int> getTransactionsCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}
  Future<List<Map<String, dynamic>>> getTransactionsByCategory() async {
		Database db = await this.database;
		var result = await db.rawQuery('SELECT SUM($colMoney) as money, $colCategory FROM $tTable GROUP BY $colCategory');
		return result;
	}
  Future<List<t.Transaction>> getTransactionsListCategory() async{
    var categoryMapList = await getTransactionsByCategory();
    List<t.Transaction> transactionsList = List<t.Transaction>();
    for(int i = 0; i < categoryMapList.length; i++) transactionsList.add(t.Transaction.fromMapObject(categoryMapList[i]));
    return transactionsList;
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
		var result = await db.query(gTable, orderBy: '$colId DESC', limit: 10);
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
  Future<double> getGoalsSum() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM($colMoneyNeeded) as total FROM $gTable');
    return result[0]['total'];
  }
  Future<int> getGoalsCount() async{
    Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $gTable');
		int result = Sqflite.firstIntValue(x);
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
    var result = await db.rawQuery('SELECT SUM($colCost) as total FROM $bTable');
    return result[0]['total'];
  }
  Future<int> getBuyCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $bTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}
  // Subscriptions
  Future<List<Map<String, dynamic>>> getSubsMapList() async {
		Database db = await this.database;
		var result = await db.query(subsTable, orderBy: '$colId DESC');
		return result;
	}
  Future<List<Subscription>> getSubscriptionsList() async {
    var subsMapList = await getSubsMapList();
		int count = subsMapList.length;
		List<Subscription> subsList = List<Subscription>();
		for (int i = 0; i < count; i++) {
			subsList.add(Subscription.fromMapObject(subsMapList[i]));
		}
		return subsList;
  }
  Future<double> getSubscriptionsSumMonthly() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT SUM($colCost) as total FROM $subsTable where $colPeriod = "monthly"');
    var yearly = await db.rawQuery('SELECT SUM($colCost) as total FROM $subsTable where $colPeriod = "yearly"');
    if(yearly[0]['total'] != null){
      result[0]['total'] += (yearly[0]['total']/12);
    }
    return result[0]['total'];
  }
}