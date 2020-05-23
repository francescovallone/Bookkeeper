import 'dart:async';
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class PreferencesPage extends StatefulWidget{
  final String currentCurr;
  final String name;
  PreferencesPage(this.currentCurr, this.name);

  @override
  PreferencesState createState() => PreferencesState(currentCurr, name);
}

class PreferencesState extends State<PreferencesPage> {
  String currentCurr;
  PreferencesState(this.currentCurr, this.name);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static List<String> symbols = ["F", "\u00a5", "\€", "\£", "\u20B9", "\u00a5", "W", "kr", "R", "\$"];
  static List<String> names = ["Franc", "Yuan", "Euro", "Pound", "Rupee", "Yen", "Won", "Krone", "Ruble", "Dollar"];
  String currencyValue;
  String currencySymbol;
  String name;
  TextEditingController nameController = TextEditingController();
  void addStringToSF(String symbol) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString("currencySymbol", symbol);
  }
  void addName(String name) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString("name", name);
  }
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      child: Text("Settings", style: TextStyle(color: Colors.white, fontSize: 48.0, fontWeight: FontWeight.w400)),
                      padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
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
                    padding: EdgeInsets.only(top: 36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text("What's your name?".toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 16.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Theme(
                            data: ThemeData(
                              primaryColor: Colors.black54,
                              primaryColorDark: primaryColor,
                            ),
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(decoration: TextDecoration.none),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(12),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text("Set the currency".toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 16.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Container(
                            width: double.infinity,
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                value: currencyValue,
                                items: currName.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String val) {
                                  currencyValue = val;
                                  currencySymbol = currSymbol[currName.indexOf(val)];
                                  setState(() {
                                    currencyValue = val;
                                    currencySymbol = currSymbol[currName.indexOf(val)];
                                  });
                                },
                              ),
                            ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            addStringToSF(currencySymbol);
            addName(nameController.text);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/");
          },
          label: Text("Save"),
          icon: Icon(Icons.save),
          backgroundColor: primaryColor,
        ),
      );
  }
}
class ScreenArguments {
  final String route;
  ScreenArguments(this.route);
}