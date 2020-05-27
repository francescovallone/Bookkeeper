import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:Bookkeeper/Models/buy_entry.dart';
import 'package:Bookkeeper/Screens/buylist_forms.dart';
import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';


class BuyEntryPage extends StatefulWidget {
  BuyEntry entry;
  BuyEntryPage(this.entry);
  @override
  State<StatefulWidget> createState() => BuyEntryState(entry);
}

class BuyEntryState extends State<BuyEntryPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  String currency = "\€";
  BuyEntry entry;
  BuyEntryState(this.entry);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  ScrollController scrollController;
  bool dialVisible = true;
  Future<String> getCurrency() async {
	  final SharedPreferences prefs = await _prefs;
  	return prefs.getString("currencySymbol") ?? "\€";
  }
  TapGestureRecognizer _tapRecognizer;
  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    scrollController = ScrollController()
    ..addListener(() {
      setDialVisible(scrollController.position.userScrollDirection ==
          ScrollDirection.forward);
    });
    _tapRecognizer = TapGestureRecognizer() ..onTap = () { launch(entry.link); };
  }
  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }
  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                        Navigator.of(context).pushNamed('/buylist');
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
                      child: Text("Cost".toUpperCase(), style: TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.w400)),
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                      child: Row(
                        children: [
                          Text(format(entry.cost), style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w400)),
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
                          padding: EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: Text("Product name".toUpperCase(), style: TextStyle(fontSize: 16.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: Text(entry.title, style: TextStyle(fontSize: 24.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: Text("Link".toUpperCase(), style: TextStyle(fontSize: 16.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: RichText(
                            text: TextSpan(
                              text: entry.link,
                              style: TextStyle(fontSize: 24.0, color: Colors.blue),
                              recognizer: _tapRecognizer
                            )
                          ),
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
      floatingActionButton: SpeedDial(
        backgroundColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.05),
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0,),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        visible: dialVisible,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(LineAwesomeIcons.edit, color: Colors.white),
            backgroundColor: Colors.blue,
            onTap: () => navigateToDetail(entry, "Edit")
          ),
          SpeedDialChild(
            child: Icon(LineAwesomeIcons.trash_o, color: Colors.white),
            backgroundColor: redColor,
            onTap: () => _delete(context, entry),
          ),
          SpeedDialChild(
            child: Icon(LineAwesomeIcons.check, color: Colors.white),
            backgroundColor: greenColor,
            onTap: () => complete(context, entry),
          ),
        ],
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
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/buylist');
  }
  void navigateToDetail(BuyEntry trans, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BuyListFormsPage(trans, title, currency);
    }));
  }
  void _delete(BuildContext context, BuyEntry trans) async {
    int result = await databaseHelper.deleteBEntry(trans.id);
    if (result != 0) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed("/buylist");
    }
  }
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}