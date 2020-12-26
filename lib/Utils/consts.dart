import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class ThemeColors{
  static Color greenColor = Color(0xFF7FB685);
  static Color primaryColor = Color(0xFF172A3A);
  static Color secondaryColor = Color.fromRGBO(36, 35, 37, 1);
  static Color shadowColor = Colors.black;
  static Color redColor = Color(0xFFD66853);
}
class StringConts{
  static String appName = "Bookkeeper";
  static Map<String, dynamic> categories = {
    "Salary": {"color": Colors.blue,"icon": LineAwesomeIcons.dollar},
    "Gift": {"color": Colors.yellow,"icon": LineAwesomeIcons.gift},
    "Interest Money":{"color": Colors.orange,"icon": LineAwesomeIcons.line_chart},
    "Selling":{"color": Colors.purple,"icon": LineAwesomeIcons.money},
    "Award": {"color": Colors.pink,"icon": LineAwesomeIcons.certificate},
    "Other":{"color": Colors.amber,"icon": LineAwesomeIcons.cubes},
    "Food":{"color": Colors.indigo,"icon": LineAwesomeIcons.cutlery},
    "Entertainment":{"color": Colors.teal,"icon": LineAwesomeIcons.music},
    "Travel":{"color": Colors.brown,"icon": LineAwesomeIcons.plane},
    "Education":{"color": Colors.blueGrey,"icon": LineAwesomeIcons.graduation_cap},
    "Transport":{"color": Colors.deepOrange,"icon": LineAwesomeIcons.bus},
    "Shopping":{"color": Colors.deepPurple,"icon": LineAwesomeIcons.shopping_cart},
    "Loan":{"color": Colors.grey,"icon": LineAwesomeIcons.bank},
    "Medical":{"color": Color.fromARGB(255, 58, 48, 66),"icon": LineAwesomeIcons.ambulance},
    "Goal":{"color": Color.fromARGB(255, 69, 9, 32),"icon": LineAwesomeIcons.trophy}
  };
}