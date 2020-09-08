import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:habbittracker/Colors.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Analytics extends StatefulWidget {
  String email;
  List<String> reportList = [
    "Not relevant",
    "Illegal",
    "Spam",
    "Offensive",
    "Uncivil"
  ];
  Analytics(this.email);

  @override
  _AnalyticsState createState() => _AnalyticsState(email);
}

class _AnalyticsState extends State<Analytics> {
  String email;
  _AnalyticsState(this.email);

  var textDate = 0;
  List<charts.Series<Scoresgraph, double>> _seriesLineData = [];

  String date1 = '';
  List<Scoresgraph> linesalesdata = [];
  List<String> names = ['Overall'];
  final now = DateTime.now();
  DateTime dateTime;
  DateTime dateTime1;

  ProgressDialog progressDialog;

  void _show(String name) async {
    progressDialog.show();
    final user = await FirebaseAuth.instance.currentUser();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();

    Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch',
            isGreaterThanOrEqualTo: dateTime1.millisecondsSinceEpoch ~/ 1000)
        .where('day_epoch',
            isLessThanOrEqualTo: dateTime.millisecondsSinceEpoch ~/ 1000)
        .orderBy('day_epoch')
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
        double temp = 0;
        if (name == 'Average' || name == 'Overall') {
          if (value.documents[i].data['Average'] != null) {
            temp = value.documents[i].data['Average'].toDouble();
          } else {
            temp = 0;
          }
        } else {
          if (value.documents[i].data['$name' '_score'] != null) {
            temp = value.documents[i].data['$name' '_score'].toDouble();
          } else {
            temp = 0;
          }
        }
        Timestamp date2 = value.documents[i].data['date'];
        double day = double.parse(date2.toDate().day.toString());
        linesalesdata.add(new Scoresgraph(day, temp));
      }
//      Future.delayed(const Duration(milliseconds: 500), () {
      progressDialog.hide();
      setState(() {
        _seriesLineData.add(
          charts.Series(
            colorFn: (__, _) =>
                charts.ColorUtil.fromDartColor(Color(0xff990099)),
            id: 'Scores of wakeup',
            data: linesalesdata,
            domainFn: (Scoresgraph sales, _) => sales.dateval,
            measureFn: (Scoresgraph sales, _) => sales.scoresval,
          ),
        );
//        });
      });
    });
  }

  _get() async {
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();

    QuerySnapshot snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();

    for (int i = 0; i < snapShot1.documents.length; i++) {
      setState(() {
        names.add(snapShot1.documents[i].data['name']);
      });
    }
  }

  void initState() {
    dateTime =
        DateTime(now.year, now.month, 0, 23, 59, 59).add(Duration(days: 30));
    dateTime1 = DateTime(now.year, now.month, 1, 0, 0, 0);
    setState(() {
      _get().then((value) {
        _show('Average');
      });
    });
  }

  String selectedChoice = '';

  int _defaultChoiceIndex = 0;
  Widget choiceChips(names) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: List<Widget>.generate(
        names.length,
        (int index) {
          return ChoiceChip(
            label: Text(names[index]),
            selected: _defaultChoiceIndex == index,
            selectedColor: secondaryColor,
            onSelected: (bool selected) {
              setState(() {
                _defaultChoiceIndex = selected ? index : index;
                linesalesdata.clear();
                _seriesLineData.clear();
                selectedChoice = names[index];
                _show(selectedChoice);
              });
            },
            backgroundColor: primaryColor,
            labelStyle: TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      isDismissible: false,
      type: ProgressDialogType.Normal,
    );
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: ListView(
        children: <Widget>[
          choiceChips(names),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                color: primaryColor,
                child: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  setState(() {
                    linesalesdata.clear();
                    _seriesLineData.clear();
                    dateTime = Jiffy(dateTime).subtract(months: 1);
                    dateTime1 = Jiffy(dateTime1).subtract(months: 1);
                  });
                  _show(selectedChoice);
                },
              ),
              Text(
                DateFormat.yMMMM().format(dateTime),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
              RaisedButton(
                color: primaryColor,
                child: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  setState(() {
                    linesalesdata.clear();
                    _seriesLineData.clear();
                    dateTime = Jiffy(dateTime).add(months: 1);
                    dateTime1 = Jiffy(dateTime1).add(months: 1);
                  });
                  _show(selectedChoice);
                },
              ),
            ],
          ),
          Container(
            height: 500,
            width: 500,
            child: Card(
                child: charts.LineChart(_seriesLineData,
                    defaultRenderer: new charts.LineRendererConfig(
                        includeArea: true, stacked: true),
                    animate: true,
                    animationDuration: Duration(seconds: 5),
                    behaviors: [
                  new charts.ChartTitle('Dates',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                ])),
          ),
        ],
      ),
    );
  }
}

class Scoresgraph {
  double dateval;
  double scoresval;

  Scoresgraph(this.dateval, this.scoresval);
}
