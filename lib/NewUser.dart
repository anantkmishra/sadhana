import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/authentication.dart';
import 'package:habbittracker/home.dart';
import 'package:habbittracker/main.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  dynamic container = Container(
    color: containerColor,
  );

  void initState() {
    FirebaseAuth.instance.currentUser().then((value) {
      if (value != null) {
        //progressDialog.show();
        //progressDialog.hide();
        setState(() {
          container = Home(0);
        });
      } else {
        setState(() {
          container = Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  primaryColor.withOpacity(0.07),
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.2),
                  primaryColorShade.withOpacity(0.4),
                  primaryColorShade.withOpacity(0.5),
                  primaryColorShade.withOpacity(0.6),
                  primaryColorShade1.withOpacity(0.6),
                  primaryColorShade1.withOpacity(0.7),
                  primaryColorShade1.withOpacity(0.9),
                  primaryColorShade1.withOpacity(1.0),
                  primaryColorShade1.withOpacity(1.0),
                  primaryColorShade1.withOpacity(1.0),
                ]),
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        primaryColor.withOpacity(1.0), BlendMode.softLight),
                    image: AssetImage('images/bg1.png'),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 200.0, 0.0, 0.0),
                      child: Text(
                        'Hey\nthere !',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 100,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                      child: Text(
                        'Welcome to Habit Tracker. Be the new change.',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                        child: Container(
                          width: 150,
                          height: 40,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: primaryColor1,
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 20, color: primaryColor),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        child: Container(
                          width: 150,
                          height: 40,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: primaryColor1,
                            child: Text(
                              'SignUp',
                              style:
                                  TextStyle(fontSize: 20, color: primaryColor),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: container);
  }
}
