import 'dart:core';
import 'package:Bookkeeper/Screens/buylist_page.dart';
import 'package:Bookkeeper/Screens/home_page.dart';
import 'package:Bookkeeper/Screens/transactions_page.dart';
import 'package:flutter/material.dart';


void main(){
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookkeeper',
      theme: ThemeData(
        fontFamily: "Rubik",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/transactions': (context) => TransactionsPage(),
        '/buylist': (context) => BuyListPage(),
      },
    )
  );
}