import 'package:Bookkeeper/Models/transaction.dart' as t;
import 'package:Bookkeeper/Utils/colors_cost.dart';
import 'package:Bookkeeper/Utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';


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
  String data;
	NumberFormat formatter;
  List<String> _categories = ["Salary", "Gift", "Interest Money", "Selling", "Award", "Other", "Food", "Entertainment", "Travel", "Education", "Transport", "Shopping", "Loan", "Medical"];
  TransactionFormsState(this.transaction, this.title, this.currency, this.type);

  @override
  void initState() {
    super.initState();
		data = transaction.money.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(transaction.id != null){
      _typeText = transaction.type == 0 ? "Expense" : "Income";
    }
		formatter = NumberFormat.simpleCurrency(locale: "it_IT", name: currency, decimalDigits: 2);
    var size = MediaQuery.of(context).size;
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
                      child: IconButton(
                        icon: Icon(LineAwesomeIcons.arrow_left),
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
                  height: size.height*.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
											Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(format(data), style: TextStyle(color: Colors.white, fontSize: data.length >= 5 ? 28.0 : 48.0, fontWeight: FontWeight.w400)),
                      ),	
											Padding(
											  padding: const EdgeInsets.all(16.0),
											  child: Icon(_typeText == "Income" ? LineAwesomeIcons.plus : LineAwesomeIcons.minus, color: Colors.white),
											),									
                    ]
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
											Row(
												children: [
													Expanded(
														child: Container(
															width: double.infinity,
															decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                  right: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                ),
                              ),
															child: Padding(
															  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
															  child: DropdownButtonHideUnderline(			
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
													),
													Expanded(
														child: Container(
															width: double.infinity,
															decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                  right: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                ),
                              ),
															child: Padding(
															  padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
															  child: Row(
																	mainAxisAlignment: MainAxisAlignment.spaceEvenly,
															  	children: [
															  		IconButton(
															  			onPressed: (){
																				setState(() {
																				  _typeText = "Income";
																				});
																			},
															  			icon: Icon(LineAwesomeIcons.plus, color: _typeText == "Income" ? greenColor : Colors.grey,),
															  		),
															  		IconButton(
															  			onPressed: (){
																				setState(() {
																				  _typeText = "Expense";
																				});
																			},
															  			icon: Icon(LineAwesomeIcons.minus, color: _typeText != "Income" ? redColor : Colors.grey),
															  		)
															  	],
															  ),
															),
														),
													),
												],
											),
                      Row(
                        children: [
                          buildButton("7"),
                          buildButton("8"),
                          buildButton("9"),
                        ],
                      ),
                      Row(
                        children: [
                          buildButton("4"),
                          buildButton("5"),
                          buildButton("6"),
                        ],
                      ),
                      Row(
                        children: [
                          buildButton("1"),
                          buildButton("2"),
                          buildButton("3"),
                        ],
                      ),
                      Row(
                        children: [
                          buildButton("0"),
                          buildButton("."),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  if(data.length > 0 && data != null){
                                    data = data.substring(0, data.length - 1);
																		updateEarning();
                                  }
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                    right: BorderSide(color: Colors.black87.withOpacity(0.1)),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                                  child: Icon(LineAwesomeIcons.arrow_left, size: 21.0,),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
													if(!_validate) _save();
													else _showAlertDialog("Upsie!", "The amount can't be 0.00");
												},
                        child: Container(
                          alignment: Alignment.center,
                          width: size.width,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text("Save".toUpperCase(), style: TextStyle(fontSize: 18.0),),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void updateEarning(){
		if(data == "0.00" || data == null || data == "") _validate = true;
    else{
			transaction.money = formatter.parse(data);
			_validate = false;
		}
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
  Widget buildButton(String value){
    return Expanded(
      child: InkWell(
        onTap: (){
          setState(() {
            if(data.length < 12){
							if(value != "."){
              	data += value;
							}else if(data.length > 0 && data != null && data.indexOf(".") == -1){
								data += value;
							}
							updateEarning();
						}
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.black87.withOpacity(0.1)), right: BorderSide(color: Colors.black87.withOpacity(0.1)))
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(value, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: primaryColor)),
          ),
        ),
      ),
    );
  }
  String format(String value){
    if(value == null || value.length == 0) value = "0.00";
    double d = formatter.parse(value);
    return formatter.format(d);
  }
}