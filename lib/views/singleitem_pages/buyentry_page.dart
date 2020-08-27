import 'dart:async';
import 'package:Bookkeeper/models/buy_entry.dart';
import 'package:Bookkeeper/models/transaction.dart' as t;
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/views/forms/buylist_forms.dart';
import 'package:Bookkeeper/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BuyEntryPage extends StatefulWidget {
  final BuyEntry item;
  BuyEntryPage(this.item);
  @override
  State<StatefulWidget> createState() => _BuyEntryPageState(item);
}

class _BuyEntryPageState extends State<BuyEntryPage> {
  BuyEntry item;
  DatabaseHelper databaseHelper = DatabaseHelper();
  String currency = "\€";
  List<Choice> choices = [
    Choice(title: 'Edit'),
    Choice(title: 'Delete'),
  ];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _BuyEntryPageState(this.item);
  Choice _selectedChoices;
  void _select(Choice choice) {
    if(choice.title == "Edit") _edit();
    else if(choice.title == "Delete") _delete();
  }

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_selectedChoices == null) _selectedChoices = choices[0];
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
                        Text(item.title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                      ],
                    ),
                    Stack(
                      children:[ 
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
                              Text("Cost", style: TextStyle(color: Colors.white70, fontSize: 18.0),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(format(item.cost), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w500),),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 32,
                          right: 8,
                          child: PopupMenuButton<Choice>(
                            onSelected: _select,
                            icon: Icon(LineAwesomeIcons.ellipsis_v, color: Colors.white,),
                            itemBuilder: (BuildContext context) {
                              return choices.map((Choice choice) {
                                return PopupMenuItem<Choice>(
                                  value: choice,
                                  child: Text(choice.title),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ]
                    ),

                  ],
                ),
              ),
              Container(
                color: Colors.white38,
                padding: EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87.withOpacity(.25),
                            blurRadius: 24.0,
                            offset: Offset(0, 8)
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: ThemeColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.0)
                            ),
                            child: Icon(LineAwesomeIcons.link, color: ThemeColors.primaryColor, size: 24.0,),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Link", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.0),),
                                  Text(item.link, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0), overflow: TextOverflow.ellipsis,),
                                ],
                              )
                            ),
                          )
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
      floatingActionButton: FloatingActionButton.extended(
        elevation: 10.0,
        backgroundColor: ThemeColors.primaryColor,
        onPressed: () => _buy(),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(LineAwesomeIcons.cart_plus, size: 24.0,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0),
              child: Text("Buy", style: TextStyle(fontSize: 16.0),),
            )
          ],
        )
      ),    
    );
  }
  Future<String> getCurrency() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("currencySymbol") ?? "\€";
  }
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "en_US", symbol: currency, decimalDigits: 2);
    return formatter.format(value);
  }
  void _edit(){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return MainPage();
    }));
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BuyListFormsPage(item, "Edit", currency);
    }));
  }
  void _delete() async{
    int result = await databaseHelper.deleteBEntry(item.id);
    if(result != 0) Navigator.of(context).pop();
  }
  void _buy() async{
    t.Transaction trans = t.Transaction(item.cost*-1, DateFormat.yMMMMd().format(DateTime.now()), "Shopping", 0);
    int result = await databaseHelper.insertTransaction(trans);
    _delete();
  }
}

class Choice {
  Choice({this.title});
  String title;
}