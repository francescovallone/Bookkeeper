import 'package:Bookkeeper/Models/buy_entry.dart';
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class BuyListFormsPage extends StatefulWidget {
  final String title;
	final BuyEntry entry;
  final String currency;
	BuyListFormsPage(this.entry, this.title, this.currency);
  @override
  State<StatefulWidget> createState() => BuyListFormsState(entry, title, currency);
}

class BuyListFormsState extends State<BuyListFormsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  BuyEntry entry;
  String title;
  String currency;
  int type;
  MoneyMaskedTextController costController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  TextEditingController linkController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool _validate = false;
  BuyListFormsState(this.entry, this.title, this.currency);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    costController.dispose();
    linkController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    costController.text = (entry.cost*10).toString();
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/buylist");
      },
      child: Scaffold(
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
                      child: BackButton(
                        color: Colors.white,
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed("/buylist");
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
                  height: size.height*.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title, style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w300)),
                          ],
                        )
                      ),
                    ]
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
                            child: Text("Cost".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: primaryColor,
                                primaryColorDark: primaryColor,
                              ),
                              child: TextField(
                                controller: costController,
                                style: TextStyle(decoration: TextDecoration.none),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(12),
                                  WhitelistingTextInputFormatter.digitsOnly, 
                                ],
                                onChanged: (value) {
                                  updateEarning();
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black12),
                                  ),
                                  hintText: '10.00',
                                  suffixText: currency,
                                  suffixStyle: const TextStyle(color: Colors.black54),
                                  errorText: _validate ? "The amount can't be 0.00" : null
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text("Product Name".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Colors.black54,
                                primaryColorDark: primaryColor,
                              ),
                              child: TextField(
                                controller: titleController,
                                style: TextStyle(decoration: TextDecoration.none),
                                onChanged: (value) {
                                  updateTitle();
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black12),
                                  ),
                                  hintText: 'Untitled',
                                  suffixStyle: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text("Product Link".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Colors.black54,
                                primaryColorDark: primaryColor,
                              ),
                              child: TextField(
                                controller: linkController,
                                style: TextStyle(decoration: TextDecoration.none),
                                onChanged: (value) {
                                  updateLink();
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black12),
                                  ),
                                  hintText: 'https://example.com',
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
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            entry.cost == 0.00 ? _validate = true : _save();
          },
          child: Icon(title == "New" ? Icons.add : Icons.edit),
          backgroundColor: primaryColor,
        ),
      ),
    );
  }
  void updateEarning(){
    List<String> parsableList = costController.text.split(",");
    String parsable = parsableList.join('');
    entry.cost = double.tryParse(parsable);
  }
  void updateLink(){
    entry.link = linkController.text;
  }
  void updateTitle(){
    entry.title = titleController.text;
  }
	void _save() async {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/buylist");
    int result;
    if (entry.id != null) {
      result = await databaseHelper.updateBEntry(entry);
    } else {
      result = await databaseHelper.insertBEntry(entry);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Saved successfully');
    } else {
      _showAlertDialog('Status', 'An error occured!');
    }
	}
	void _showAlertDialog(String title, String message) {
		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}
}