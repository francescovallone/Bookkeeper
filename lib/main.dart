import 'dart:core';
import 'package:Bookkeeper/utils/consts.dart';
import 'package:Bookkeeper/views/splash.dart';
import 'package:flutter/material.dart';


void main(){
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConts.appName,
      theme: ThemeData(
        fontFamily: "Rubik",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    )
  );
}