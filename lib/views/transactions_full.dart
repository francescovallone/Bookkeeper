import 'dart:async';
import 'package:Bookkeeper/components/calendar_timeline.dart';
import 'package:Bookkeeper/models/transaction.dart' as t;
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TransactionsFullPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TransactionsFullPageState();
}

class _TransactionsFullPageState extends State<TransactionsFullPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Future<List<t.Transaction>> list;
  List<t.Transaction> dummyList = List<t.Transaction>();
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
    list = getList();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(list);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
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
                        InkWell(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Icon(LineAwesomeIcons.long_arrow_left),
                        ),
                        Text("Details", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                      ],
                    ),
                    // Container(
                    //   width: size.width,
                    //   margin: EdgeInsets.only(top:24.0),
                    //   child: FutureBuilder<List<t.Transaction>>(
                    //     future: databaseHelper.getExpenseIncome(),
                    //     builder: (context, snapshot){
                    //       if(snapshot.hasData){
                    //         if(snapshot.data.length == 2){
                    //           return Column(
                    //             children:[
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.white,
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: ThemeColors.primaryColor.withOpacity(.25),
                    //                       blurRadius: 24.0,
                    //                       offset: Offset(0, 8)
                    //                     )
                    //                   ],
                    //                 ),
                    //                 child: ListTile(
                    //                   title: Text(snapshot.data[0].type == 0 ? "Expense" : "Income", style: TextStyle(fontWeight: FontWeight.w500),),
                    //                   subtitle: Text(format(snapshot.data[0].money)),
                    //                   leading: Container(
                    //                     padding: EdgeInsets.all(16.0),
                    //                     decoration: BoxDecoration(
                    //                       color: snapshot.data[0].type == 0 ? ThemeColors.redColor.withOpacity(0.1) : ThemeColors.greenColor.withOpacity(0.1),
                    //                       borderRadius: BorderRadius.circular(16.0),
                    //                     ),
                    //                     child: snapshot.data[0].type == 0 ?
                    //                     Icon(LineAwesomeIcons.arrow_down, color: ThemeColors.redColor, size: 24.0,) :
                    //                     Icon(LineAwesomeIcons.arrow_up, color: ThemeColors.greenColor, size: 24.0,),
                    //                   ),
                    //                 ),
                    //               ),
                    //               Container(
                    //                 margin: EdgeInsets.only(top: 16.0),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.white,
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: ThemeColors.primaryColor.withOpacity(.25),
                    //                       blurRadius: 24.0,
                    //                       offset: Offset(0, 8)
                    //                     )
                    //                   ],
                    //                 ),
                    //                 child: ListTile(
                    //                   title: Text(snapshot.data[1].type == 0 ? "Expense" : "Income", style: TextStyle(fontWeight: FontWeight.w500),),
                    //                   subtitle: Text(format(snapshot.data[1].money)),
                    //                   leading: Container(
                    //                     padding: EdgeInsets.all(16.0),
                    //                     decoration: BoxDecoration(
                    //                       color: snapshot.data[1].type == 0 ? ThemeColors.redColor.withOpacity(0.1) : ThemeColors.greenColor.withOpacity(0.1),
                    //                       borderRadius: BorderRadius.circular(16.0),
                    //                     ),
                    //                     child: snapshot.data[1].type == 0 ?
                    //                     Icon(LineAwesomeIcons.arrow_down, color: ThemeColors.redColor, size: 24.0,) :
                    //                     Icon(LineAwesomeIcons.arrow_up, color: ThemeColors.greenColor, size: 24.0,),
                    //                   ),
                    //                 ),
                    //               )
                    //             ]
                    //           );
                    //         }else if(snapshot.data.length == 1){
                    //           return Column(
                    //             children:[
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.white,
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: ThemeColors.primaryColor.withOpacity(.25),
                    //                       blurRadius: 24.0,
                    //                       offset: Offset(0, 8)
                    //                     )
                    //                   ],
                    //                 ),
                    //                 child: ListTile(
                    //                   title: Text(snapshot.data[0].type == 0 ? "Expense" : "Income", style: TextStyle(fontWeight: FontWeight.w500),),
                    //                   subtitle: Text(format(snapshot.data[0].money)),
                    //                   leading: Container(
                    //                     padding: EdgeInsets.all(16.0),
                    //                     decoration: BoxDecoration(
                    //                       color: snapshot.data[0].type == 0 ? ThemeColors.redColor.withOpacity(0.1) : ThemeColors.greenColor.withOpacity(0.1),
                    //                       borderRadius: BorderRadius.circular(16.0),
                    //                     ),
                    //                     child: snapshot.data[0].type == 0 ?
                    //                     Icon(LineAwesomeIcons.arrow_down, color: ThemeColors.redColor, size: 24.0,) :
                    //                     Icon(LineAwesomeIcons.arrow_up, color: ThemeColors.greenColor, size: 24.0,),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ]
                    //           );
                    //         }else{
                    //           return Column(
                    //             children:[
                    //               ListTile(
                    //                 title: Text("Income", style: TextStyle(fontWeight: FontWeight.w500),),
                    //                 subtitle: Text(format(0)),
                    //                 leading: Container(
                    //                   padding: EdgeInsets.all(16.0),
                    //                   decoration: BoxDecoration(
                    //                     color: ThemeColors.primaryColor.withOpacity(0.1),
                    //                     borderRadius: BorderRadius.circular(16.0),
                    //                   ),
                    //                   child: Icon(LineAwesomeIcons.minus, color: ThemeColors.primaryColor, size: 24.0,),
                    //                 ),
                    //               ),
                    //               ListTile(
                    //                 title: Text("Expense", style: TextStyle(fontWeight: FontWeight.w500),),
                    //                 subtitle: Text(format(0)),
                    //                 leading: Container(
                    //                   padding: EdgeInsets.all(16.0),
                    //                   decoration: BoxDecoration(
                    //                     color: ThemeColors.primaryColor.withOpacity(0.1),
                    //                     borderRadius: BorderRadius.circular(16.0),
                    //                   ),
                    //                   child: Icon(LineAwesomeIcons.minus, color: ThemeColors.primaryColor, size: 24.0,),
                    //                 ),
                    //               )
                    //             ]
                    //           );
                    //         }
                    //       }else if (snapshot.hasError) {
                    //         return Text("${snapshot.error}");
                    //       }
                    //       return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),),);
                    //     }
                    //   ),
                    // )
                  ],
                ),
              ),
              Container(
                color: Colors.white38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text("By Categories", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 16.0),
                      height: 200,
                      child: FutureBuilder<List<t.Transaction>>(
                        future: databaseHelper.getTransactionsListCategory(),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            if(snapshot.data.length != 0){
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int position){
                                  if(position == 0){
                                    return Container(
                                      width: 100,
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeColors.primaryColor.withOpacity(.15),
                                            blurRadius: 12.0,
                                            offset: Offset(0, 4)
                                          )
                                        ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: colors[_categories.indexOf(snapshot.data[position].category)%14].withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Icon(categories[_categories.indexOf(snapshot.data[position].category)], color: colors[_categories.indexOf(snapshot.data[position].category)%14],),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(snapshot.data[position].category, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),),
                                              Text(format(snapshot.data[position].money), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),)
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }else{
                                    return Container(
                                      width: 100,
                                      margin: EdgeInsets.only(left: 16.0),
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeColors.primaryColor.withOpacity(.15),
                                            blurRadius: 12.0,
                                            offset: Offset(0, 4)
                                          )
                                        ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: colors[_categories.indexOf(snapshot.data[position].category)%14].withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Icon(categories[_categories.indexOf(snapshot.data[position].category)], color: colors[_categories.indexOf(snapshot.data[position].category)%14],),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(snapshot.data[position].category, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),),
                                              Text(format(snapshot.data[position].money), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),)
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }
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
                                    Text("No items.".toUpperCase()),
                                  ],
                                ),
                              );
                            }
                          }else if (snapshot.hasError) {
                            return Text("\${snapshot.error}");
                          }
                          return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),),);
                        }
                      ),
                    ),
                  ],
                )
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text("By Date", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                        ),
                      ],
                    ),
                    Container(
                      child: FutureBuilder<List<t.Transaction>>(
                        future: list,
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom:24.0, top: 16.0),
                                  child: CalendarTimeline(
                                    initialDate: snapshot.data.length != 0 ? DateFormat.yMMMMd().parse(snapshot.data[0].date) : DateTime.now(),
                                    firstDate: snapshot.data.length != 0 ? DateFormat.yMMMMd().parse(snapshot.data[0].date) : DateTime.now(),
                                    lastDate: DateTime.now(),
                                    onDateSelected: (date) {
                                      setState(() {
                                        dummyList = snapshot.data.where((l) => l.date == DateFormat.yMMMMd().format(date)).toList();
                                      });
                                    },
                                    leftMargin: 16,
                                    monthColor: ThemeColors.primaryColor.withOpacity(0.5),
                                    dayColor: ThemeColors.primaryColor.withOpacity(0.2),
                                    activeDayColor: Colors.black,
                                    activeBackgroundDayColor: Colors.white,
                                    dotsColor: Colors.white,
                                    locale: 'en_ISO',
                                  ),
                                ),
                                Container(
                                  height: (100*dummyList.length).toDouble(),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: dummyList.length,
                                    itemBuilder: (context, position){
                                      print(list);
                                      return Column(
                                        children: [
                                          position != 0 ? Divider() : SizedBox(height: 0,),
                                          InkWell(
                                            onTap: () {
                                              if(dummyList[position].category != "Goal"){
                                                //navigateToDetail(dummyList[i], "Edit");
                                              }
                                            },
                                            child: ListTile(
                                              leading: Container(
                                                padding: EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: colors[_categories.indexOf(dummyList[position].category)%14].withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16.0)
                                                ),
                                                child: Icon(categories[_categories.indexOf(dummyList[position].category)], color: colors[_categories.indexOf(dummyList[position].category)%14], size: 24.0,),
                                              ),
                                              title: Text(dummyList[position].category, style: TextStyle(fontWeight: FontWeight.w500),),
                                              subtitle: Text(dummyList[position].type == 1 ? "Income" : "Expense"),
                                              trailing: Text(format(dummyList[position].money), style: TextStyle(fontWeight: FontWeight.w500),),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                ),
                              ]
                            );
                          }else if (snapshot.hasError) {
                            return Text("\${snapshot.error}");
                          }
                          return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),),);
                        }
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSumTransactions();
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
  Future<List<t.Transaction>> getList(){
    Future<List<t.Transaction>> ts = databaseHelper.getTransactionsFullList();
    return ts;
  }
}