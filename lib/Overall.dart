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
import 'package:table_calendar/table_calendar.dart';
import 'Account.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Overall extends StatefulWidget {
  @override
  _OverallState createState() => _OverallState();
}

class _OverallState extends State<Overall> {
  var cal = CalendarController();

  int average_score = 0;
  var dayepoch = 0;
  var finaldate;
  var text = 'score';
  var text1 = '';
  var text2 = '';

  void initState() {
    final now = DateTime.now();
    finaldate = DateTime(now.year, now.month, now.day);
    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;

    //_averageScoredisplay(dayepoch);
    _barChartData().then((value) {
      _buildChart(context, day_data);
      setState(() {
        container = SimpleBarChart(_seriesBarData, animate: true);
      });
    });
  }

  dynamic container = Container();

  Future<int> _averageScoredisplay(dayepoch) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    QuerySnapshot ds = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();

    if (ds.documents.isNotEmpty) {
      if (ds.documents[0].data['Average'] != null) {
        //setState(() {
        return ds.documents[0].data['Average'].round();
        //});
      } else {
        //setState(() {
        return 0;
        //});
      }
    } else {
      //setState(() {
      return 0;
      //});
    }
  }

  int present_week = Jiffy(DateTime.now()).week;
  int last1_week = Jiffy(Jiffy(DateTime.now()).subtract(weeks: 1)).week;
  int last2_week = Jiffy(Jiffy(DateTime.now()).subtract(weeks: 2)).week;

  int present_month = Jiffy(DateTime.now()).month;
  int last1_month = Jiffy(Jiffy(DateTime.now()).subtract(months: 1)).month;
  int last2_month = Jiffy(Jiffy(DateTime.now()).subtract(months: 2)).month;

  int present_day = Jiffy(DateTime.now()).dayOfYear;
  int last1_day = Jiffy(Jiffy(DateTime.now()).subtract(days: 1)).dayOfYear;
  int last2_day = Jiffy(Jiffy(DateTime.now()).subtract(days: 2)).dayOfYear;

  List<OverallScore> week_data = [];

  List<OverallScore> month_data = [];

  List<OverallScore> day_data = [];

  Future _barChartData() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    QuerySnapshot week = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('week_in_year', isEqualTo: present_week)
        .getDocuments();

    QuerySnapshot week1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('week_in_year', isEqualTo: last1_week)
        .getDocuments();

    QuerySnapshot week2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('week_in_year', isEqualTo: last2_week)
        .getDocuments();

    QuerySnapshot month = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('month_in_year', isEqualTo: present_month)
        .getDocuments();

    QuerySnapshot month1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('month_in_year', isEqualTo: last1_month)
        .getDocuments();

    QuerySnapshot month2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('month_in_year', isEqualTo: last2_month)
        .getDocuments();

    QuerySnapshot day = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_in_year', isEqualTo: present_day)
        .getDocuments();

    QuerySnapshot day1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_in_year', isEqualTo: last1_day)
        .getDocuments();

    QuerySnapshot day2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_in_year', isEqualTo: last2_day)
        .getDocuments();

    if (week.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < week.documents.length; i++) {
        sum += (week.documents[i].data['Average']);
      }
      week_data.add(new OverallScore(sum / week.documents.length, 'This week'));
    } else {
      week_data.add(new OverallScore(0.0, 'This week'));
    }
    if (week1.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < week1.documents.length; i++) {
        sum += (week1.documents[i].data['Average']);
      }
      week_data
          .add(new OverallScore(sum / week1.documents.length, 'last week'));
    } else {
      week_data.add(new OverallScore(0.0, 'last week'));
    }
    if (week2.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < week2.documents.length; i++) {
        sum += (week2.documents[i].data['Average']);
      }
      week_data.add(new OverallScore(sum / week2.documents.length, '2nd week'));
    } else {
      week_data.add(new OverallScore(0.0, '2nd week'));
    }
    if (month.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < month.documents.length; i++) {
        sum += (month.documents[i].data['Average']);
      }
      month_data.add(new OverallScore(sum / month.documents.length,
          DateFormat.MMM().format(DateTime.now())));
    } else {
      month_data
          .add(new OverallScore(0.0, DateFormat.MMM().format(DateTime.now())));
    }
    if (month1.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < month1.documents.length; i++) {
        sum += (month1.documents[i].data['Average']);
      }
      month_data.add(new OverallScore(sum / month1.documents.length,
          DateFormat.MMM().format(Jiffy(DateTime.now()).subtract(months: 1))));
    } else {
      month_data.add(new OverallScore(0.0,
          DateFormat.MMM().format(Jiffy(DateTime.now()).subtract(months: 1))));
    }
    if (month2.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < month2.documents.length; i++) {
        sum += (month2.documents[i].data['Average']);
      }
      month_data.add(new OverallScore(sum / month2.documents.length,
          DateFormat.MMM().format(Jiffy(DateTime.now()).subtract(months: 2))));
    } else {
      month_data.add(new OverallScore(0.0,
          DateFormat.MMM().format(Jiffy(DateTime.now()).subtract(months: 2))));
    }
    if (day.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < day.documents.length; i++) {
        sum += (day.documents[i].data['Average']);
      }
      day_data.add(new OverallScore(
          sum / day.documents.length, DateTime.now().day.toString()));
    } else {
      day_data.add(new OverallScore(0.0, DateTime.now().day.toString()));
    }
    if (day1.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < day1.documents.length; i++) {
        sum += (day1.documents[i].data['Average']);
      }
      day_data.add(new OverallScore(sum / day1.documents.length,
          Jiffy(DateTime.now()).subtract(days: 1).day.toString()));
    } else {
      day_data.add(new OverallScore(
          0.0, Jiffy(DateTime.now()).subtract(days: 1).day.toString()));
    }
    if (day2.documents.isNotEmpty) {
      double sum = 0;
      for (int i = 0; i < day2.documents.length; i++) {
        sum += (day2.documents[i].data['Average']);
      }
      day_data.add(new OverallScore(sum / day2.documents.length,
          Jiffy(DateTime.now()).subtract(days: 2).day.toString()));
    } else {
      day_data.add(new OverallScore(
          0.0, Jiffy(DateTime.now()).subtract(days: 2).day.toString()));
    }
  }

  List<charts.Series<OverallScore, String>> _seriesBarData = [];
  List<OverallScore> scores = [];

  _buildChart(BuildContext context, List<OverallScore> saledata) {
    scores = saledata;
    _seriesBarData = List<charts.Series<OverallScore, String>>();
    setState(() {
      text = saledata[0].scoresval.round().toString();
      text1 = saledata[1].scoresval.round().toString();
      text2 = saledata[2].scoresval.round().toString();
      _seriesBarData.add(
        charts.Series(
          domainFn: (OverallScore sales, _) => sales.measure,
          measureFn: (OverallScore sales, _) => sales.scoresval,
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: 'Overall_score',
          data: saledata,
        ),
      );
    });
  }

  _set(data) {
    text = data;
  }

  Widget _dayDecorator(date, average_score) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            StatefulBuilder(builder: (context, setState) {
              return TableCalendar(
                  calendarStyle: CalendarStyle(),
                  calendarController: cal,
                  //dayHitTestBehavior: HitTestBehavior(),
                  builders: CalendarBuilders(dayBuilder: (context, date, _) {
                    var score = 20;
                    finaldate = DateTime(date.year, date.month, date.day);
                    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
                    return FutureBuilder<int>(
                      future: _averageScoredisplay(dayepoch),
                      initialData: 0,
                      builder: (context, snapShot) {
                        return CircularPercentIndicator(
                          //animation: true,
                          //animateFromLastPercent: true,
                          //animationDuration: 1200,
                          circularStrokeCap: CircularStrokeCap.round,
                          restartAnimation: true,
                          radius: 30.0,
                          lineWidth: 4.0,
                          percent: double.parse(snapShot.data.toString()) / 100,
                          backgroundColor: Colors.white,
                          progressColor: primaryColor,
                          center: new Text(date.day.toString()),
                        );
                      },
                    );
                  }),
                  onDaySelected: (date, _) {
                    finaldate = DateTime(date.year, date.month, date.day);
                    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
                  });
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  child: Text('Monthly'),
                  onPressed: () {
                    setState(() {
                      _buildChart(context, month_data);
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Weekly'),
                  onPressed: () {
                    setState(() {
                      _buildChart(context, week_data);
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Daily'),
                  onPressed: () {
                    setState(() {
                      _buildChart(context, day_data);
                    });
                  },
                ),
              ],
            ),
            StatefulBuilder(builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                          color: primaryColor, shape: BoxShape.rectangle),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          text,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                          color: primaryColor, shape: BoxShape.rectangle),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          text1,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                          color: primaryColor, shape: BoxShape.rectangle),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          text2,
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              );
            }),
            Container(
                height: 300,
                child: StatefulBuilder(builder: (context, setState) {
                  return SimpleBarChart(_seriesBarData);
                }))
          ],
        ),
      ),
    );
  }
}

class OverallScore {
  double scoresval;
  String measure;

  OverallScore(this.scoresval, this.measure);
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.

  var text = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: new charts.BarChart(
        seriesList,
        selectionModels: [
          charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
            _OverallState obj = new _OverallState();
            if (model.hasDatumSelection) {
              obj._set(model.selectedSeries[0]
                  .measureFn(model.selectedDatum[0].index)
                  .toString());
            }
          })
        ],
        animate: animate,
      ),
    );
  }
}
