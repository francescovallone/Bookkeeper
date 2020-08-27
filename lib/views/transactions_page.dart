import 'dart:async';
import 'package:Bookkeeper/models/transaction.dart' as t;
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/views/forms/transaction_forms.dart';
import 'package:Bookkeeper/views/singleitem_pages/transaction_page.dart';
import 'package:Bookkeeper/views/transactions_full.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TransactionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Future<List<t.Transaction>> list;
  List<t.Transaction> dummylist = List<t.Transaction>();
  String currency = "\€";
  List<String> _categories = ["Salary", "Gift", "Interest Money", "Selling", "Award", "Other", "Food", "Entertainment", "Travel", "Education", "Transport", "Shopping", "Loan", "Medical", "Goal"];
  List<Color> colors = [Colors.blue, Colors.yellow, Colors.orange, Colors.purple, Colors.pink, Colors.amber, Colors.indigo, Colors.teal, Colors.brown, Colors.blueGrey, Colors.deepOrange, Colors.deepPurple, Colors.grey];
  List<IconData> categories = [LineAwesomeIcons.dollar, LineAwesomeIcons.gift, LineAwesomeIcons.line_chart, LineAwesomeIcons.money, LineAwesomeIcons.certificate, LineAwesomeIcons.cubes, LineAwesomeIcons.cutlery, LineAwesomeIcons.music, LineAwesomeIcons.plane, LineAwesomeIcons.graduation_cap, LineAwesomeIcons.bus, LineAwesomeIcons.shopping_cart, LineAwesomeIcons.bank, LineAwesomeIcons.ambulance, LineAwesomeIcons.trophy];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<double> balance;

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    balance = getMoney();
    list = getTransactions();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        backgroundColor: ThemeColors.primaryColor,
        strokeWidth: 2.0,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  padding: EdgeInsets.symmetric(vertical:24.0, horizontal: 36.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("My Balance", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                          InkWell(
                            onTap: (){
                              navigateToForm(t.Transaction(0, DateFormat.yMMMMd().format(DateTime.now()), "Salary", 1), 'New');
                            },
                            child: Icon(LineAwesomeIcons.plus),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24.0),
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        width: double.infinity,
                        height: size.height*.35,
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primaryColor.withOpacity(.45),
                              blurRadius: 24.0,
                              offset: Offset(0, 8)
                            )
                          ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 18.0),),
                            FutureBuilder<double>(
                              future: balance,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(format(snapshot.data), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w500),),
                                  );
                                }else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }else if(!snapshot.hasData){
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(format(0.00), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w500),),
                                  );
                                }
                                return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),),);
                              }
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.white38,
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("History", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return TransactionsFullPage();
                              }));
                            },
                            child: Text("Details", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0, color: Colors.black54),),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: [
                            FutureBuilder<List<t.Transaction>>(
                              future: list,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  if(snapshot.data.length != 0){
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (BuildContext context, int position){
                                        return Column(
                                          children: [
                                            position != 0 ? Divider() : SizedBox(height: 0,),
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return TransactionPage(snapshot.data[position]);
                                                }));
                                              },
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Container(
                                                  padding: EdgeInsets.all(16.0),
                                                  decoration: BoxDecoration(
                                                    color: colors[_categories.indexOf(snapshot.data[position].category)%14].withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(16.0)
                                                  ),
                                                  child: Icon(categories[_categories.indexOf(snapshot.data[position].category)], color: colors[_categories.indexOf(snapshot.data[position].category)%14], size: 24.0,),
                                                ),
                                                title: Text(snapshot.data[position].category, style: TextStyle(fontWeight: FontWeight.w500),),
                                                subtitle: Text(snapshot.data[position].type == 1 ? "Income" : "Expense"),
                                                trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(format(snapshot.data[position].money), style: TextStyle(fontWeight: FontWeight.w500),),
                                                    Text(snapshot.data[position].date.split(",")[0])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                  }else{
                                    return Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 24.0),
                                      child: Column(
                                        children: [
                                          Icon(LineAwesomeIcons.frown_o, size: 48,),
                                          SizedBox(height: 24),
                                          Text("No transactions yet.".toUpperCase()),
                                        ],
                                      ),
                                    );
                                  }
                                }else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),),);
                              }
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSumTransactions();
    return x;
  }
  Future<List<t.Transaction>> getTransactions() async{
    final List<t.Transaction> x = await databaseHelper.getTransactionsList();
    return x;
  }
  Future<String> getCurrency() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("currencySymbol") ?? "\€";
  }
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "en_US", symbol: currency, decimalDigits: 2);
    return formatter.format(value);
  }
  void navigateToForm(t.Transaction trans, String title) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TransactionsFormsPage(trans, title, currency, trans.type);
    })).then((value) {
      setState((){
        balance = getMoney();
        list = getTransactions();
      });
    });
  }
  Future<void> _refresh() async{
    setState(() {
      balance = getMoney();
      list = getTransactions();
    });
  }
  void getList(){
    Future<List<t.Transaction>> ts = databaseHelper.getTransactionsList();
    ts.then((value){
      setState(() {
        this.dummylist = value;
      });
    });
  }
}