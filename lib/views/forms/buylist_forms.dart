import 'package:Bookkeeper/models/buy_entry.dart';
import 'package:Bookkeeper/utils/database_helper.dart';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:characters/characters.dart';

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
  bool _validate = false;
  BuyListFormsState(this.entry, this.title, this.currency);

  // Form
  MoneyMaskedTextController _costController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  TextEditingController _linkController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _costController.dispose();
    _linkController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    _costController.text = (entry.cost*10).toString();
    _linkController.text = entry.link;
    _titleController.text = entry.title;
    _costController.selection = TextSelection.collapsed(offset: _costController.text.length);
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
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0)
                                ),
                                child: Icon(LineAwesomeIcons.cart_plus, color: Colors.deepPurple, size: 24.0,),
                              ),
                              title: Text(entry.title, style: TextStyle(fontWeight: FontWeight.w500),),
                              subtitle: Text(entry.link),
                              trailing: Text(format(entry.cost), style: TextStyle(fontWeight: FontWeight.w500),),
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
                            Text("Cost", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
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
                                        if(entry.cost > 0) _validate = false;
                                        entry.cost = getDouble();
                                      });
                                      else _costController.selection = TextSelection.collapsed(offset: _costController.text.length); 
                                    },
                                    child: TextField(
                                      controller: _costController,
                                      style: TextStyle(decoration: TextDecoration.none),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12),
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),  
                                      ],
                                      onChanged: (value) {
                                        updateCost();
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
                            Text("Product name", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: Colors.black54,
                                  primaryColorDark: ThemeColors.primaryColor,
                                ),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (focus){
                                      if(!focus) setState(() {
                                        if(_titleController.text.length != 0) entry.title = _titleController.text;
                                        else entry.title = "Untitled";
                                      });
                                      else _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length); 
                                    },
                                    child: TextField(
                                      controller: _titleController,
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
                              ),
                            ),
                            Text("Link", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: Colors.black54,
                                  primaryColorDark: ThemeColors.primaryColor,
                                ),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (focus){
                                      if(!focus) setState(() {
                                        if(_linkController.text.length != 0) entry.link = _linkController.text;
                                        else entry.link = "http://example.com";
                                      });
                                      else _linkController.selection = TextSelection.collapsed(offset: _linkController.text.length); 
                                    },
                                    child: TextField(
                                      controller: _linkController,
                                      style: TextStyle(decoration: TextDecoration.none),
                                      onChanged: (value) {
                                        updateLink();
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black12),
                                        ),
                                        hintText: 'http://example.com',
                                        suffixStyle: const TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                entry.cost <= 0.00 ? _validate = true : _save();
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
    List<String> parsableList = _costController.text.split(",");
    String parsable = parsableList.join('');
    return double.tryParse(parsable);
  }
  void updateCost(){
    List<String> parsableList = _costController.text.split(",");
    String parsable = parsableList.join('');
    entry.cost = double.tryParse(parsable);
  }
  void updateLink(){
    String entryLink = _linkController.text;
    if(entryLink.length == 0) entryLink = "http://example.com";
    entry.link = entryLink;
  }
  void updateTitle(){
    String entryTitle = _titleController.text;
    if(entryTitle.length == 0) entryTitle = "Untitled";
    entry.title = entryTitle;
  }
	void _save() async {
    Navigator.of(context).pop();
    int result;
    if (entry.id != null) {
      result = await databaseHelper.updateBEntry(entry);
    } else {
      result = await databaseHelper.insertBEntry(entry);
    }
    if (result != 0) {
      _showFlushBar('Hurray!', 'Item added to the buy list!', true);
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