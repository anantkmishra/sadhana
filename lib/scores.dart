import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/Overall.dart';
import 'package:habbittracker/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habbittracker/groups.dart';
import 'package:habbittracker/team_reports.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:jiffy/jiffy.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'Colors.dart';
import 'main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

class Scores extends StatefulWidget {
  @override
  _ScoresState createState() => _ScoresState();
}

class _ScoresState extends State<Scores> {
  //String textDate = 'Select Date';
  final now = DateTime.now();

  List names = [];
  List score = [];
  String email;
  String comments = '';

  void scores() async {
    setState(() {
      names.clear();
      score.clear();
    });
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    email = user.email;
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    QuerySnapshot snapShot = await Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();
    QuerySnapshot snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();
    for (int i = 0; i < snapShot2.documents.length; i++) {
      names.add(snapShot2.documents[i].data['name']);
    }
    setState(() {
      if (snapShot.documents.isNotEmpty) {
        if (snapShot.documents[0].data['Comments'] != null) {
          setState(() {
            comments = snapShot.documents[0].data['Comments'];
          });
        } else {
          setState(() {
            comments = 'No comments';
          });
        }
        for (int i = 0; i < snapShot2.documents.length; i++) {
          if (snapShot.documents[0].data[names[i]] != null) {
            String temp = names[i];
            score.add(snapShot.documents[0].data['$temp' '_score']);
          } else {
            score.add('Not yet entered');
          }
        }
      } else {
        for (int i = 0; i < snapShot2.documents.length; i++) {
          setState(() {
            score.add('Not yet entered');
            comments = 'No comments';
          });
        }
      }
    });
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Habits remaining today',
      'Fill the habits out for today',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  _exportData() async {
    var dateTime = Jiffy(DateTime.now()).subtract(days: 30);
    var dateTime1 = DateTime.now();
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();

    List<List<String>> rows = List<List<String>>();

    List<String> names = [];
    snapShot1.documents.forEach((element) {
      names.add(element.data['name']);
      names.add(element.data['name'].toString() + '_score');
    });
    rows.add(names);

    final snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch',
            isGreaterThanOrEqualTo: dateTime1.millisecondsSinceEpoch ~/ 1000)
        .where('day_epoch',
            isLessThanOrEqualTo: dateTime.millisecondsSinceEpoch ~/ 1000)
        .orderBy('day_epoch')
        .getDocuments();

    for (int i = 0; i < snapShot2.documents.length; i++) {
      List<String> row = List<String>();
      row.add(snapShot2.documents[i].data['day_epoch']);
      for (int j = 0; j < names.length; j++) {
        if (snapShot2.documents[i].data[names[j]] != null) {
          row.add(snapShot2.documents[i].data[names[j]].toString());
        } else {
          row.add('');
        }
      }
      rows.add(row);
    }
    File f = await _localFile;

    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv).then((value) {
      _showNotificationWithDefaultSound();
    });
    print(csv);
  }

  Future onSelectNotification(String payload) async {
    return OpenFile.open(filePath);
  }

  String filePath;

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    print(directory);
    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    filePath = '$path/data.csv';
    return File('$path/data.csv').create();
  }

  String textDate = 'Select Date';
  var finaldate;
  var dayepoch;

  @override
  void initState() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    finaldate = DateTime(now.year, now.month, now.day);
    textDate = DateFormat('yMMMd').format(finaldate);
    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
    scores();
  }

  Widget _habbit_cards(names, score) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: names.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  height: 50,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    color: backgroundColor1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(names[index]),
                        Text(score[index].toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: backgroundColor1,
          appBar: AppBar(
            backgroundColor: appBarColor,
            automaticallyImplyLeading: false,
            title: Text('Reports'),
            bottom: TabBar(
              indicatorColor: primaryColor1,
              tabs: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Overall',
                    style: TextStyle(fontSize: 18, color: primaryColor1,  ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Analysis',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'scores',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
          ),
          body: StatefulBuilder(builder: (context, setState) {
            return TabBarView(children: [
              Overall(),
              Analytics(email),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        color: primaryColor,
                        child: Icon(Icons.keyboard_arrow_left,
                            color: primaryColor1),
                        onPressed: () {
                          setState(() {
                            finaldate = Jiffy(finaldate).subtract(days: 1);
                            dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
                            textDate = DateFormat('yMMMd').format(finaldate);
                            scores();
                          });
                        },
                      ),
                      Text(
                        textDate,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      RaisedButton(
                        color: primaryColor,
                        child: Icon(Icons.keyboard_arrow_right,
                            color: primaryColor1),
                        onPressed: () {
                          setState(() {
                            finaldate = Jiffy(finaldate).add(days: 1);
                            dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
                            textDate = DateFormat('yMMMd').format(finaldate);
                            scores();
                          });
                        },
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text('Export'),
                    onPressed: () {
                      _exportData();
                    },
                  ),
                  Flexible(child: _habbit_cards(names, score)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Comments'),
                      Text(comments),
                    ],
                  ),
                ],
              ),
            ]);
          })),
    );
  }
}
