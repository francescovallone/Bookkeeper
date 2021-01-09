import 'dart:async';
import 'package:Bookkeeper/models/buy_entry.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/views/forms/buylist_forms.dart';
import 'package:Bookkeeper/views/singleitem_pages/buyentry_page.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BuyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BuyListPageState();
}

class _BuyListPageState extends State<BuyListPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Future<List<BuyEntry>> list;
  String currency = "\€";
  Future<double> total;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    total = getMoney();
    list = getEntries();
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
                          Text("My Buy List", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                          InkWell(
                            onTap: (){
                              navigateToForm(BuyEntry(0.0, "Untitled", "https://example.com"), "New");
                            },
                            child: Icon(LineAwesomeIcons.plus),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
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
                                Text("Total Cost", style: TextStyle(color: Colors.white70, fontSize: 18.0),),
                                FutureBuilder<double>(
                                  future: total,
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
                          ),
                          Positioned(
                            right: 16,
                            top: 32,
                            child: IconButton(
                              color: Colors.white,
                              icon: Icon(
                                LineAwesomeIcons.refresh,
                                size: 16,
                              ),
                              onPressed: (){
                                setState(() {
                                  total = getMoney();
                                  list = getEntries();
                                });
                              },
                            )
                          ),
                        ],
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
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: [
                            FutureBuilder<List<BuyEntry>>(
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
                                                  return BuyEntryPage(snapshot.data[position]);
                                                })).then((_) => {
                                                  setState((){
                                                    total = getMoney();
                                                    list = getEntries();
                                                  })
                                                });
                                              },
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Container(
                                                  padding: EdgeInsets.all(16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(16.0)
                                                  ),
                                                  child: Icon(LineAwesomeIcons.cart_plus, color: Colors.deepPurple, size: 24.0,),
                                                ),
                                                title: Text(snapshot.data[position].title, style: TextStyle(fontWeight: FontWeight.w500),),
                                                trailing: Text(format(snapshot.data[position].cost), style: TextStyle(fontWeight: FontWeight.w500),),
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
                                          Text("No items yet.".toUpperCase()),
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
          ),
        ),
      ),
    );
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSumList();
    return x;
  }
  Future<List<BuyEntry>> getEntries() async{
    final List<BuyEntry> x = await databaseHelper.getBuyList();
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
  void navigateToForm(BuyEntry entry, String title) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BuyListFormsPage(entry, title, currency);
    })).then((value) {
      setState((){
        total = getMoney();
        list = getEntries();
      });
    });
  }
  Future<void> _refresh() async{
    setState(() {
      total = getMoney();
      list = getEntries();
    });
  }
}