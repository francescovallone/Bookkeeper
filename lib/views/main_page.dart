import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/views/buylist_page.dart';
import 'package:Bookkeeper/views/settings_page.dart';
import 'package:Bookkeeper/views/transactions_page.dart';
import 'package:Bookkeeper/views/subscriptions_page.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';


class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  PageController _pageController;
  int _page = 0;

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12.0,
        showUnselectedLabels: false,
        onTap: navigationTapped,
        currentIndex: _page,
        elevation: 10.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ThemeColors.primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.bank),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.list),
            title: Text('Buy List'),
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.history),
            title: Text('Subscriptions'),
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.cog),
            title: Text('Settings'),
          ),
        ],
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          TransactionsPage(),
          BuyListPage(),
          SubscriptionsPage(),
          SettingsPage()
        ],
      ),
    ); 
  }
}