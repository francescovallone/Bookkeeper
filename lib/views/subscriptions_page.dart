import 'dart:async';
import 'package:Bookkeeper/models/subscription.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/views/forms/subscriptions_forms.dart';
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
  Future<List<Subscription>> list;
  String currency = "\€";
  Future<double> total;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    total = getMoney();
    list = getSubscriptions();
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
                          onTap: (){navigateToForm(Subscription(0, "Untitled", "monthly", DateFormat.yMMMMd().format(DateTime.now())), "New");},
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
                                            onTap: null,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Container(
                                                padding: EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16.0)
                                                ),
                                                child: Icon(LineAwesomeIcons.history, color: Colors.orange, size: 24.0,),
                                              ),
                                              title: Text(snapshot.data[position].title, style: TextStyle(fontWeight: FontWeight.w500),),
                                              subtitle: Text(snapshot.data[position].period),
                                              trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(format(snapshot.data[position].cost), style: TextStyle(fontWeight: FontWeight.w500),),
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
  Future<List<Subscription>> getSubscriptions() async{
    final List<Subscription> x = await databaseHelper.getSubscriptionsList();
    return x;
  }
  void navigateToForm(Subscription entry, String title) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SubscriptionsFormsPage(entry, title, currency, "monthly");
    })).then((value) => {
      setState((){
        total = getMoney();
        list = getSubscriptions();
      })
    });
  }
}