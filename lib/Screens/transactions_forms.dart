import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';


class TransactionsFormsPage extends StatefulWidget {
  final String title;
	final t.Transaction transaction;
  final String currency;
  final int type;
	TransactionsFormsPage(this.transaction, this.title, this.currency, this.type);
  @override
  State<StatefulWidget> createState() => TransactionFormsState(transaction, title, currency, type);
}

class TransactionFormsState extends State<TransactionsFormsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  t.Transaction transaction;
  String title;
  String currency;
  int type;
  String _typeText = "Income";
  String _selectedText = "Salary";
  bool _validate = false;
  List<String> _categories = ["Salary", "Gift", "Interest Money", "Selling", "Award", "Other", "Food", "Entertainment", "Travel", "Education", "Transport", "Shopping", "Loan", "Medical"];
  TransactionFormsState(this.transaction, this.title, this.currency, this.type);
  MoneyMaskedTextController transactionsController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    transactionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(transaction.id != null){
      _typeText = transaction.type == 0 ? "Expense" : "Income";
    }
    var size = MediaQuery.of(context).size;
    transactionsController.text = (transaction.money*10).toString();
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/transactions");
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
                          Navigator.of(context).pushNamed("/transactions");
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
                            child: Text("Value".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: primaryColor,
                                primaryColorDark: primaryColor,
                              ),
                              child: TextField(
                                controller: transactionsController,
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
                                  prefixText: _typeText == "Income" ? '+ ' : '- ',
                                  suffixText: currency,
                                  suffixStyle: const TextStyle(color: Colors.black54),
                                  errorText: _validate ? "The amount can't be 0.00" : null
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text("Category".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Container(
                              width: double.infinity,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedText,
                                  items: _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String val) {
                                    _selectedText = val;
                                    setState(() {
                                      _selectedText = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text("Transaction type".toUpperCase(), style: TextStyle(fontSize: 14.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Container(
                              width: double.infinity,
                              child:ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _typeText,
                                  items: ['Income', 'Expense'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String val) {
                                    _typeText = val;
                                    setState(() {
                                      _typeText = val;
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
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            transaction.money == 0 ? _validate = true : _save();
          },
          child: Icon(title == "New" ? Icons.add : Icons.edit),
          backgroundColor: primaryColor,
        ),
      ),
    );
  }
  void updateEarning(){
    List<String> parsableList = transactionsController.text.split(",");
    String parsable = parsableList.join('');
    transaction.money = double.tryParse(parsable);
  }
  void _save() async {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/transactions");
    int x = _typeText == "Income" ? 1 : 0;
    if(transaction.type == null || transaction.type != x){
      transaction.type = x;
      transaction.money = _typeText == 'Income' ? transaction.money : transaction.money*(-1);
    }
    transaction.category = _selectedText;
    int result;
    if (transaction.id != null) {
      result = await databaseHelper.updateTransaction(transaction);
    } else {
      transaction.date = DateFormat.yMMMMd().format(DateTime.now());
      result = await databaseHelper.insertTransaction(transaction);
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