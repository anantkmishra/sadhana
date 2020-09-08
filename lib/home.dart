import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/Templates.dart';
import 'package:habbittracker/groups.dart';
import 'package:habbittracker/scores.dart';
import 'ActivitiesInTemplates.dart';
import 'main.dart';
import 'Account.dart';
import 'commander_users.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sphere_bottom_navigation_bar/sphere_bottom_navigation_bar.dart';
import 'my_flutter_app_icons.dart' as customIcons;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Home extends StatefulWidget {
  var index;
  Home(this.index);
  @override
  _HomeState createState() => _HomeState(index);
}

class _HomeState extends State<Home> {
  int _currentIndex;
  _HomeState(this._currentIndex);

  Future<bool> _checkConnection() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Widget _setPage(index) {
    switch (index) {
      case 0:
        return MyHomePage();
      case 1:
        return Scores();
      case 2:
        return Groups();
      case 3:
        return Account();
      default:
        return MyHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor1,
      body: _setPage(_currentIndex),
      bottomNavigationBar: SphereBottomNavigationBar(
          defaultSelectedItem: 0,
          sheetBackgroundColor: secondaryColor,
          sheetRadius: BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          navigationItems: [
            BuildNavigationItem(
              tooltip: 'Home',
              itemColor: secondaryColor,
              icon: Icon(
                customIcons.MyFlutterApp.home,
                color: primaryColor1,
              ),
              selectedItemColor: secondaryColor,
            ),
            BuildNavigationItem(
              tooltip: 'Report',
              itemColor: secondaryColor,
              icon: Icon(
                Icons.receipt,
                color: primaryColor1,
              ),
              selectedItemColor: secondaryColor,
            ),
            BuildNavigationItem(
              tooltip: 'Groups',
              itemColor: secondaryColor,
              icon: Icon(
                customIcons.MyFlutterApp.group,
                color: primaryColor1,
              ),
              selectedItemColor: secondaryColor,
            ),
            BuildNavigationItem(
                tooltip: 'Profile',
                itemColor: secondaryColor,
                icon: Icon(
                  customIcons.MyFlutterApp.user,
                  color: primaryColor1,
                ),
                selectedItemColor: secondaryColor)
          ],
          onItemPressed: (index) {
            setState(() {
              _currentIndex = index;
              _setPage(_currentIndex);
            });
          }
          //currentIndex: ,
          ),
    );
  }
}

//test
