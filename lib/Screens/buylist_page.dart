import 'dart:async';
import 'package:Bookkeeper/Models/buy_entry.dart';
import 'package:Bookkeeper/Screens/buyentry_page.dart';
import 'package:Bookkeeper/Screens/buylist_forms.dart';
import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BuyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BuyListState();
}

class BuyListState extends State<BuyListPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<BuyEntry> list;
  Future<double> balance;
  String currency = "\€";
   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> getCurrency() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("currencySymbol") ?? "\€";
  }
  @override
  void initState() {
    super.initState();
    balance = getMoney();
    getCurrency().then((value) => currency = value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (list == null) {
      list = List<BuyEntry>();
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
                    padding: const EdgeInsets.only(left:8.0),
                    child: IconButton(
                      icon: Icon(LineAwesomeIcons.arrow_left),
                      color: Colors.white,
                      onPressed: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text("Bookkeeper".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Container(
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      child: Text("Total".toUpperCase(), style: TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.w400)),
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    ),
                    FutureBuilder<double>(
                      future: balance,
                      builder: (context, snapshot){
                        if(!snapshot.hasError){
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                            child: Row(
                              children: [
                                Text(snapshot.data != null ? format(snapshot.data) : format(0), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w400)),
                              ],
                            )
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(50.0)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        color: shadowColor,
                      )
                    ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 36.0, left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 36.0, left: 16.0),
                              child: Text("Entries".toUpperCase(), style: TextStyle(fontSize: 16.0),),
                            ),
                            FutureBuilder<int>(
                              future: databaseHelper.getBuyCount(),
                              builder: (context, snapshot){
                                if(!snapshot.hasError){
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0, bottom: 36.0),
                                    child: Row(
                                      children: [
                                        Text(snapshot.data != null ? snapshot.data.toString() : format(0), style: TextStyle(fontSize: 16.0)),
                                      ],
                                    )
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),);
                              },
                            ),
                          ],
                        ),
                        Flexible(
                          child: FutureBuilder<List<BuyEntry>>(
                            future: databaseHelper.getBuyList(),
                            builder: (context, snapshot){
                              if(snapshot.hasData){
                                return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int position){
                                    return Column(
                                      children: [
                                        Dismissible(
                                          direction: DismissDirection.startToEnd,
                                          key: UniqueKey(),
                                          background: Container(
                                            color: greenColor,
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left:32.0),
                                              child: Icon(LineAwesomeIcons.check, color: Colors.white,),
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => BuyEntryPage(snapshot.data[position])),
                                              );
                                            },
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: primaryColor.withOpacity(0.1),
                                                child: Icon(LineAwesomeIcons.cart_plus, color: primaryColor),
                                              ),
                                              title: Text(snapshot.data[position].title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),),
                                              subtitle: Text(snapshot.data[position].cost != null ? format(snapshot.data[position].cost) : "",
                                                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                                            ),
                                          ),
                                          onDismissed: (direction) {
                                            setState(() {
                                              complete(context, snapshot.data[position]);
                                              updateList();
                                            });
                                          },
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  }
                                );
                              }else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),),);
                            }
                          )
                        ),
                      ],
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          setState(() {
            navigateToDetail(BuyEntry(0.0, 'Untitled', 'https://example.com'), 'New');
          });
        },
        label: Text("New"),
        icon: Icon(LineAwesomeIcons.plus),
        backgroundColor: primaryColor,
      ),
    );
  }
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "it_IT", symbol: currency, decimalDigits: 2);
    return formatter.format(value);
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSumList();
    return x;
  }
  void complete(BuildContext context, BuyEntry trans) async{
    int result = await databaseHelper.insertTransaction(t.Transaction(trans.cost*-1, DateFormat.yMMMMd().format(DateTime.now()), "Shopping", 0));
    _delete(context, trans);
  }
  void updateList() {
    balance = getMoney();
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<BuyEntry>> eListFuture = databaseHelper.getBuyList();
      eListFuture.then((list) {
        setState(() {
          this.list = list;
        });
      });
    });
  }
  void navigateToDetail(BuyEntry trans, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BuyListFormsPage(trans, title, currency);
    }));
    if (result == true) {
      updateList();
    }
  }
  void _delete(BuildContext context, BuyEntry trans) async {
    int result = await databaseHelper.deleteBEntry(trans.id);
    if (result != 0) {
      _showSnackBar(context, 'Deleted Successfully');
      updateList();
      balance = getMoney();
    }
  }
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}