import 'dart:async';
import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Screens/settings.dart';
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';


class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<t.Transaction> list;
  Future<double> balance;
  String name = "Anonymous User";
  String currency;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> getName() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("name") ?? "Anonymous User";
  }
  Future<String> getCurrency() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("currencySymbol") ?? "\€";
  }
  @override
  void initState() {
    super.initState();
    balance = getMoney();
    getName().then((value) => name = value);
    getCurrency().then((value) => currency = value);
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (list == null) {
      list = List<t.Transaction>();
      updateList();
    }
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Container(
          width: size.width,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text("Bookkeeper".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Container(
                width: size.width,
                height: size.height*.20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Welcome back, ", style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w300)),
                          Text(name, style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                        child: Ink(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.0),
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100.0),
                            onTap: (){
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return PreferencesPage(currency, name);
                              }));
                            },
                            child: Padding(
                              padding:EdgeInsets.all(16.0),
                              child: Icon(
                                LineAwesomeIcons.cog,
                                size: 24.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                  ]
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: .85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  children: [
                    CategoryClass(
                      title: "Transactions",
                      path: "assets/images/transactions.svg",
                      func: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/transactions');
                      },
                    ),
                    CategoryClass(
                      title: "Buy List",
                      path: "assets/images/buylist.svg",
                      func: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/buylist');
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "en_US", symbol: "€", decimalDigits: 2);
    return formatter.format(value);
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSumTransactions();
    return x;
  }
  void updateList() {
    balance = getMoney();
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<t.Transaction>> eListFuture = databaseHelper.getTransactionsList();
      eListFuture.then((list) {
        setState(() {
          this.list = list;
        });
      });
    });
  }
}

class CategoryClass extends StatelessWidget{
  final String title;
  final String path;
  final Function func;
  const CategoryClass({
    Key key,
    this.title,
    this.path,
    this.func,
  }) : super(key:key);
  @override
  Widget build(BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: Offset(0, 17),
              spreadRadius: -23,
            )
          ]
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: func,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Spacer(),
                  SvgPicture.asset(
                    path,
                    height: 80.0,
                    width: 80.0,
                  ),
                  Spacer(),
                  Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}