import 'dart:async';
import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Screens/transactions_forms.dart';
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grouped_list/grouped_list.dart';


class TransactionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<t.Transaction> list;
  String currency = "\€";
  Future<double> balance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String> _categories = ["Salary", "Gift", "Interest Money", "Selling", "Award", "Other", "Food", "Entertainment", "Travel", "Education", "Transport", "Shopping", "Loan", "Medical", "Goal", "Untitled"];
  List<Color> colors = [Colors.blue, Colors.yellow, Colors.orange, Colors.purple, Colors.pink, Colors.amber, Colors.indigo, Colors.teal, Colors.brown, Colors.blueGrey, Colors.deepOrange, Colors.deepPurple, Colors.grey];
  List<IconData> categories = [LineAwesomeIcons.dollar, LineAwesomeIcons.gift, LineAwesomeIcons.line_chart, LineAwesomeIcons.money, LineAwesomeIcons.certificate, LineAwesomeIcons.cubes, LineAwesomeIcons.cutlery, LineAwesomeIcons.music, LineAwesomeIcons.plane, LineAwesomeIcons.graduation_cap, LineAwesomeIcons.bus, LineAwesomeIcons.shopping_cart, LineAwesomeIcons.bank, LineAwesomeIcons.ambulance, LineAwesomeIcons.trophy, LineAwesomeIcons.trophy];
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
                    FutureBuilder<double>(
                      future: balance,
                      builder: (context, snapshot){
                        if(!snapshot.hasError){
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                            child: Row(
                              children: [
                                Text(snapshot.data != null ? format(snapshot.data) : format(0), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w400)),
                              ],
                            )
                          );
                        } else if (snapshot.hasError) {
                          return Text("\${snapshot.error}");
                        }
                        return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),);
                      },
                    ),
                    list.length == 0 ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                      child: Row(
                        children: [
                          Icon(LineAwesomeIcons.minus, size: 16.0, color: Colors.white54,),
                          Text(format(0.00), style: TextStyle(color: Colors.white54, fontSize: 16.0, fontWeight: FontWeight.w400)),
                        ],
                      )
                    ) : Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                      child: Row(
                        children: [
                          list[list.length-1].money > 0 ? Icon(LineAwesomeIcons.arrow_up, size: 16.0, color: greenColor,) : Icon(LineAwesomeIcons.arrow_down, size: 16.0, color: redColor,),
                          Text(format(list[list.length-1].money), style: TextStyle(color: list[list.length-1].money > 0 ? greenColor : redColor, fontSize: 16.0, fontWeight: FontWeight.w400)),
                        ],
                      )
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
                        Padding(
                          padding: EdgeInsets.only(bottom: 36.0),
                          child: Text("Transactions".toUpperCase(), style: TextStyle(fontSize: 16.0),),
                        ),
                        Flexible(
                          child: FutureBuilder<List<t.Transaction>>(
                            future: databaseHelper.getTransactionsList(),
                            builder: (context, snapshot){
                              if(snapshot.hasData){
                                return GroupedListView(
                                  elements: snapshot.data,
                                  groupBy: (element) => element.date,
                                  groupSeparatorBuilder: _buildGroupSeparator,
                                  order: GroupedListOrder.DESC,
                                  itemBuilder: (context, element){
                                    return Column(
                                      children: [
                                        Dismissible(
                                          key: UniqueKey(),
                                          background: Container(
                                            color: redColor,
                                          ),
                                          child: InkWell(
                                            onTap: () => navigateToDetail(element, "Edit"),
                                            child: ListTile(
                                              leading: element.type == 1 ? CircleAvatar(
                                                backgroundColor: greenColor.withOpacity(0.1),
                                                child: Icon(LineAwesomeIcons.plus, color: greenColor,),
                                              ) : CircleAvatar(
                                                backgroundColor: redColor.withOpacity(0.1),
                                                child: Icon(LineAwesomeIcons.minus, color: redColor,),
                                              ),
                                              title: Text(format(element.money), style: TextStyle(fontWeight: FontWeight.w700),),
                                              subtitle: Text(element.category),
                                              trailing: CircleAvatar(
                                                backgroundColor: colors[_categories.indexOf(element.category)%14].withOpacity(0.1),
                                                child: Icon(categories[_categories.indexOf(element.category)], color: colors[_categories.indexOf(element.category)%14],)
                                              ),
                                            ),
                                          ),
                                          onDismissed: (direction) {
                                            setState(() {
                                              _delete(context, element);
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
                                return Text("\${snapshot.error}");
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
            navigateToDetail(t.Transaction(0.0, '', '', 1), 'New');
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
  void navigateToDetail(t.Transaction trans, String title) async {
    Navigator.of(context).pop();
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TransactionsFormsPage(trans, title, currency, trans.type);
    }));
    if (result == true) {
      updateList();
    }
  }
  void _delete(BuildContext context, t.Transaction trans) async {
    int result = await databaseHelper.deleteTransaction(trans.id);
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
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text('$groupByValue'.toUpperCase()),
    );
  }
}