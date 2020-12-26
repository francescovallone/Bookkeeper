import 'package:Bookkeeper/models/transaction.dart' as t;
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flushbar/flushbar.dart';


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
  bool _validate = false;
  TransactionFormsState(this.transaction, this.title, this.currency, this.type);
  List<String> _categories = ["Salary", "Gift", "Interest Money", "Selling", "Award", "Other", "Food", "Entertainment", "Travel", "Education", "Transport", "Shopping", "Loan", "Medical", "Goal"];
  // Form
  MoneyMaskedTextController _moneyController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  TextEditingController _linkController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  String _typeText = "Income";
  String _selectedText = "Salary";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _linkController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(transaction.id != null){
      _typeText = transaction.type == 0 ? "Expense" : "Income";
    }
    var size = MediaQuery.of(context).size;
    _moneyController.text = (transaction.money*10).toString();
    _moneyController.selection = TextSelection.collapsed(offset: _moneyController.text.length);
    _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
    _linkController.selection = TextSelection.collapsed(offset: _linkController.text.length);
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  padding: EdgeInsets.symmetric(vertical:24.0, horizontal: 24.0),
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
                          Text("$title", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24.0),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primaryColor.withOpacity(.25),
                              blurRadius: 24.0,
                              offset: Offset(0, 8)
                            )
                          ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: StringConts.categories[transaction.category]['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0)
                                ),
                                child: Icon(StringConts.categories[transaction.category]['icon'], color: StringConts.categories[transaction.category]['color'], size: 24.0,),
                              ),
                              title: Text(transaction.category, style: TextStyle(fontWeight: FontWeight.w500),),
                              subtitle: Text(transaction.type == 1 ? "Income" : "Expense"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(format(transaction.money), style: TextStyle(fontWeight: FontWeight.w500),),
                                  Text(transaction.date.split(",")[0])
                                ],
                              ),
                            ),
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
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Value", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: ThemeColors.primaryColor,
                                  primaryColorDark: ThemeColors.primaryColor,
                                ),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (focus){
                                      if(!focus) setState(() {
                                        if(transaction.money > 0) _validate = false;
                                        transaction.money = getDouble();
                                      });
                                      else _moneyController.selection = TextSelection.collapsed(offset: _moneyController.text.length); 
                                    },
                                    child: TextField(
                                      controller: _moneyController,
                                      style: TextStyle(decoration: TextDecoration.none),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12),
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), 
                                      ],
                                      onChanged: (value) {
                                        updateMoney();
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
                              ),
                            ),
                            Text("Category", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
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
                                        
                                        transaction.category = val;
                                        print(transaction.category);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            title == "New" ?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Type", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
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
                                            transaction.type = val == "Income" ? 1 : 0;
                                            _typeText = val;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : SizedBox(),
                            InkWell(
                              onTap: (){
                                transaction.money <= 0.00 ? _validate = true : _save();
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 16.0),
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeColors.primaryColor.withOpacity(.25),
                                      blurRadius: 24.0,
                                      offset: Offset(0, 8)
                                    )
                                  ]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text("Save", style: TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                                )
                              ),
                            ),
                            SizedBox(height: 50),
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
  double getDouble(){
    List<String> parsableList = _moneyController.text.split(",");
    String parsable = parsableList.join('');
    return double.tryParse(parsable);
  }
  void updateMoney(){
    List<String> parsableList = _moneyController.text.split(",");
    String parsable = parsableList.join('');
    transaction.money = double.tryParse(parsable);
  }
	void _save() async {
    Navigator.of(context).pop();
    transaction.type = null;
    int x = _typeText == "Income" ? 1 : 0;
    int result;
    if(transaction.type == null || transaction.type != x){
      transaction.type = x;
      transaction.money = _typeText == 'Income' ? transaction.money : transaction.money*(-1);
    }
    transaction.category = _selectedText;
    if (transaction.id != null) {
      result = await databaseHelper.updateTransaction(transaction);
    } else {
      transaction.date = DateFormat.yMMMMd().format(DateTime.now());
      result = await databaseHelper.insertTransaction(transaction);
    }
    if (result != 0) {
      _showFlushBar('Hurray!', 'Transaction created!', true);
    } else {
      _showFlushBar('Oops!', 'An error occured!', false);
    }
	}
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "en_US", symbol: currency, decimalDigits: 2);
    return formatter.format(value);
  }
	void _showFlushBar(String title, String message, bool success) {
		Flushbar(
      padding: EdgeInsets.all(24.0),
      margin: EdgeInsets.all(16.0),
      borderRadius: 16,
      shouldIconPulse: false,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.white,
      boxShadows: [
        BoxShadow(
          color: ThemeColors.primaryColor.withOpacity(.45),
          blurRadius: 24.0,
          offset: Offset(0, 8)
        )
      ],
      isDismissible: true,
      duration: Duration(seconds: 3),
      icon: success ? Icon(
        LineAwesomeIcons.thumbs_up,
        color: ThemeColors.greenColor,
        size: 28.0,
      ) : Icon(
        LineAwesomeIcons.thumbs_down,
        color: ThemeColors.redColor,
        size: 28.0,
      ),
      titleText: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
      ),
      messageText: Text(
        message,
        style: TextStyle(fontSize: 16.0, color: Colors.black45),
      ),
    )..show(context);
	}
  
}