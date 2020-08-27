import 'dart:async';
import 'package:Bookkeeper/models/subscription.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SubscriptionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Subscription> list;
  String currency = "\€";
  Future<double> total;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    total = getMoney();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        Text("My Subscriptions", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                        InkWell(
                          onTap: null,
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
                          Text("Monthly Cost", style: TextStyle(color: Colors.white70, fontSize: 18.0),),
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
                          FutureBuilder<List<Subscription>>(
                            future: databaseHelper.getSubscriptionsList(),
                            builder: (context, snapshot){
                              if(snapshot.hasData){
                                if(snapshot.data.length != 0){
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (BuildContext context, int position){
                                      DateTime parsed = DateTime.parse(snapshot.data[position].date);
                                      Duration difference = parsed.difference(DateTime.now());
                                      return Column(
                                        children: [
                                          position != 0 ? Divider() : SizedBox(height: 0,),
                                          InkWell(
                                            onTap: null,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Container(
                                                padding: EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16.0)
                                                ),
                                                child: Icon(LineAwesomeIcons.trophy, color: Colors.orange, size: 24.0,),
                                              ),
                                              title: Text(snapshot.data[position].title, style: TextStyle(fontWeight: FontWeight.w500),),
                                              subtitle: Text((difference.inDays*-1).toString()),
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
                                        Text("No subscriptions yet.".toUpperCase()),
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
    );
  }
  Future<double> getMoney() async{
    final double x = await databaseHelper.getSubscriptionsSumMonthly();
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
  // void navigateToForm(Goal entry, String title) async {
  //   bool result =
  //       await Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return BuyListFormsPage(entry, title, currency);
  //   }));
  //   if (result == true) {
  //     total = getMoney();
  //   }
  // }
}