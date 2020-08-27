import 'dart:async';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class SettingsPage extends StatefulWidget{

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  String currentCurr = "\€";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static List<String> symbols = ["F", "\u00a5", "\€", "\£", "\u20B9", "\u00a5", "W", "kr", "R", "\$"];
  static List<String> names = ["Franc", "Yuan", "Euro", "Pound", "Rupee", "Yen", "Won", "Krone", "Ruble", "Dollar"];
  String currencyValue;
  String currencySymbol;
  String name;
  TextEditingController nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    currencyValue = names[symbols.indexOf(currentCurr)];
    currencySymbol = symbols[symbols.indexOf(currentCurr)];
    nameController.text = name;
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    List<String> currName = List<String>();
    List<String> currSymbol = List<String>();
    for(int i = 0; i<symbols.length; i++){
      currName.add(names[i]);
      currSymbol.add(symbols[i]);
    }
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
                        Text("Settings", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                      ],
                    ),
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
  void _editCurrency(String symbol) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString("currencySymbol", symbol);
  }
}

// Padding(
//                             padding: EdgeInsets.only(left: 16.0),
//                             child: Text("Currency", style: TextStyle(color: ThemeColors.primaryColor, fontSize: 16.0),),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                             child: Container(
//                               width: double.infinity,
//                               child: ButtonTheme(
//                                 alignedDropdown: true,
//                                 child: DropdownButton<String>(
//                                   value: currencyValue,
//                                   items: currName.map((String value) {
//                                     return DropdownMenuItem<String>(
//                                       value: value,
//                                       child: Text(value),
//                                     );
//                                   }).toList(),
//                                   onChanged: (String val) {
//                                     currencyValue = val;
//                                     currencySymbol = currSymbol[currName.indexOf(val)];
//                                     setState(() {
//                                       currencyValue = val;
//                                       currencySymbol = currSymbol[currName.indexOf(val)];
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),