import 'package:Bookkeeper/models/subscription.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flushbar/flushbar.dart';
import 'package:Bookkeeper/utils/capitalize.dart';


class SubscriptionsFormsPage extends StatefulWidget {
  final String title;
	final Subscription subscription;
  final String currency;
  final String type;
	SubscriptionsFormsPage(this.subscription, this.title, this.currency, this.type);
  @override
  State<StatefulWidget> createState() => SubscriptionsFormsState(subscription, title, currency, type);
}

class SubscriptionsFormsState extends State<SubscriptionsFormsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Subscription subscription;
  String title;
  String currency;
  String period = "monthly";
  bool _validate = false;
  DateTime selectedDate = DateTime.now();
  SubscriptionsFormsState(this.subscription, this.title, this.currency, this.period);
  // Form
  MoneyMaskedTextController _moneyController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  TextEditingController _linkController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subscription.period = 'monthly';
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
    _moneyController.text = (subscription.cost*10).toString();
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
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0)
                                ),
                                child: Icon(LineAwesomeIcons.history, color: Colors.orange, size: 24.0,),
                              ),
                              title: Text(subscription.title, style: TextStyle(fontWeight: FontWeight.w500),),
                              subtitle: Text(capitalize(subscription.period)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(format(subscription.cost), style: TextStyle(fontWeight: FontWeight.w500),),
                                  Text(subscription.date.split(",")[0])
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
                            Text("Title", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
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
                                    },
                                    child: TextField(
                                      controller: _titleController,
                                      style: TextStyle(decoration: TextDecoration.none),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12),
                                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')), 
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          subscription.title = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black12),
                                        ),
                                        hintText: 'Untitled',
                                        suffixText: currency,
                                        suffixStyle: const TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text("${subscription.period.capitalize()} cost", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
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
                                        if(subscription.cost > 0) _validate = false;
                                        subscription.cost = getDouble();
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
                            Text("Start date", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: InkWell(
                                onTap: () {pickDate();},
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
                                  child: Text("${DateFormat.yMMMMd().format(selectedDate)}", style: TextStyle(fontSize: 16),),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black54,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              )
                            ),
                            title == "New" ?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Type", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Container(
                                    width: double.infinity,
                                    child:ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: period,
                                        items: ['monthly', 'yearly'].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value.capitalize()),
                                          );
                                        }).toList(),
                                        onChanged: (String val) {
                                          setState(() {
                                            subscription.period = val;
                                            period = val;
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
                                subscription.cost <= 0.00 ? _validate = true : _save();
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
  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year-1),
      lastDate: DateTime(DateTime.now().year+1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  double getDouble(){
    List<String> parsableList = _moneyController.text.split(",");
    String parsable = parsableList.join('');
    return double.tryParse(parsable);
  }
  void updateMoney(){
    List<String> parsableList = _moneyController.text.split(",");
    String parsable = parsableList.join('');
    subscription.cost = double.tryParse(parsable);
  }
	void _save() async {
    Navigator.of(context).pop();
    int result;
    if (subscription.id != null) {
      result = await databaseHelper.updateSubscription(subscription);
    } else {
      subscription.date = DateFormat.yMMMMd().format(selectedDate);
      result = await databaseHelper.insertSubscription(subscription);
    }
    if (result != 0) {
      _showFlushBar('Hurray!', 'Subscription created!', true);
    } else {
      _showFlushBar('Oops!', 'An error occured!', false);
    }
	}
  String format(double value){
    NumberFormat formatter = new NumberFormat.compactCurrency(locale: "en_US", symbol: currency, decimalDigits: 2);
    return formatter.format(value);
  }
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
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