import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/NewUser.dart';
import 'package:habbittracker/TextStyle.dart';
import 'package:habbittracker/authentication.dart';
import 'package:habbittracker/home.dart';
import 'package:habbittracker/scores.dart';
import 'package:habbittracker/ActivitiesInTemplates.dart';
import 'package:habbittracker/team_reports.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'offlineData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'my_flutter_app_icons.dart' as customIcons;

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('settings')
        .getDocuments();
    List<String> names = [];
    if (snapShot1.documents.isNotEmpty) {
      snapShot1.documents.forEach((element) {
        names.add(element.data['name']);
      });
    }

    final now = DateTime.now();
    final finaldate = DateTime(now.year, now.month, now.day);
    final dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;

    final snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();
    if (snapShot2.documents.isNotEmpty) {
      for (int i = 0; i < names.length; i++) {
        if (snapShot2.documents[0].data[names[i]] == null) {
          _showNotificationWithDefaultSound();
          break;
        }
      }
    } else {
      _showNotificationWithDefaultSound();
    }
    return Future.value(true);
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

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

Future onSelectNotification(String payload) async {
  return Home(0);
}

void main() {
  runApp(MaterialApp(title: 'Habbit Tracker', home: NewUser()));
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  DateTime finaldate = DateTime.now();
  String updateStatus = 'Not Updated';
  String average_score = '0';
  var dayepoch = 0;
  dynamic listview1 = Container();

  String textDate = 'Select Date';
  String breakfast = 'Not Updated';
  String lunch = 'Not Updated';

  Color buttoncolor = Colors.green;
  Color todaycolor = primaryColor1;
  Color dbyesterdayColor = primaryColor;
  Color yesterdayColor = primaryColor;
  Color calendarColor = primaryColor;
  Color todayTextcolor = primaryColor;
  Color dbyesterdayTextColor = primaryColor1;
  Color yesterdayTextColor = primaryColor1;
  Color calendarTextColor = primaryColor1;

  List<String> names = [];
  List<String> types = [];
  ProgressDialog progressDialog;

  bool _isyesnoVisible = true;
  bool _isyesnoVisible1 = true;

  var uid;

  List<String> data = [];

  Future _showAllCards() async {
    progressDialog.show();
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

    if (snapShot1.documents.isNotEmpty) {
      for (int i = 0; i < snapShot1.documents.length; i++) {
        String name = snapShot1.documents[i].data['name'];
        String type = snapShot1.documents[i].data['habit_type'];
        setState(() {
          names.add(name);
          types.add(type);
          data.add('Select');
        });
      }
      progressDialog.hide();
    } else {
      progressDialog.hide();
    }
  }

  String _userName = '';
  String _userEmail = '';

  Future _showUpdatedCards() async {
    progressDialog.show();
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    _userName = snapShot.documents[0].data['name'];
    _userEmail = snapShot.documents[0].data['email'];

    QuerySnapshot snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();

    QuerySnapshot snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();
    if (snapShot1.documents.isNotEmpty) {
      for (int i = 0; i < snapShot2.documents.length; i++) {
        String tempName = snapShot2.documents[i].data['name'];
        String tempType = snapShot2.documents[i].data['habit_type'];
        if (snapShot1.documents[0].data['$tempName'] != null) {
          setState(() {
            names.add(tempName);
            types.add(tempType);
            data.add(snapShot1.documents[0].data['$tempName'].toString());
          });
        } else {}
      }
      progressDialog.hide();
    } else {
      progressDialog.hide();
    }
  }

  String saved_comments = '';
  List<String> allNames = [];
  List<String> allTypes = [];
  var snapShot2;

  Future _showNotUpdatedCards() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    QuerySnapshot snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();

    if (snapShot1.documents.isNotEmpty) {
      if (snapShot1.documents[0].data['Comments'] != null) {
        saved_comments = snapShot1.documents[0].data['Comments'].toString();
        comments.text = saved_comments;
      } else {
        comments.text = '';
      }
    }

    snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();

//    for (int i = 0; i < snapShot2.documents.length; i++) {
//      allNames.add(snapShot2.documents[i].data['name']);
//      allTypes.add(snapShot2.documents[i].data['habit_type']);
//    }

    if (snapShot1.documents.isNotEmpty) {
      for (int i = 0; i < snapShot2.documents.length; i++) {
        String tempName = snapShot2.documents[i].data['name'];
        String tempType = snapShot2.documents[i].data['habit_type'];
        if (snapShot1.documents[0].data['$tempName'] == null) {
          setState(() {
            names.add(tempName);
            types.add(tempType);
            data.add('Select');
          });
        } else {}
      }
    } else {
      if (snapShot2.documents.isNotEmpty) {
        for (int i = 0; i < snapShot2.documents.length; i++) {
          String name = snapShot2.documents[i].data['name'];
          String type = snapShot2.documents[i].data['habit_type'];
          setState(() {
            names.add(name);
            types.add(type);
            data.add('Select');
          });
        }
      }
    }
  }

  _remove() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void initState() {
    final now = DateTime.now();
    finaldate = DateTime(now.year, now.month, now.day);
    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
    textDate = new DateFormat.yMMMd().format(finaldate);
    _checkConnection().then((value) {
      if (value == true) {
        Scaffold.of(context).hideCurrentSnackBar();
        _showNotUpdatedCards().then((value) {
          _checkOfflineData();
          saveString('count', snapShot2.documents.length);
          for (int i = 0; i < snapShot2.documents.length; i++) {
            saveString(i, snapShot2.documents[i].data);
          }
          _averageScoredisplay();
          setState(() {
            _set(names, types, data);
          });
        });
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Text('You are Offline'),
          duration: Duration(days: 1),
        ));
        getString('count').then((value) {
          for (int i = 0; i < value; i++) {
            getString(i).then((value) {
              setState(() {
                names.add(value['name']);
                types.add(value['habit_type']);
                data.add('Select');
              });
            }).then((value) {
              _set(names, types, data);
            });
          }
        });
      }
    });
  }

  _checkOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys().toList();
    keys.removeWhere((element) => element.length < 10);

    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    var snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    for (int i = 0; i < keys.length; i++) {
      var data = await getString(keys[i]);

      var key = keys[i].split('_')[0];
      var name = keys[i].split('_')[1];

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .collection('data')
          .where('day_epoch', isEqualTo: int.parse(key))
          .getDocuments();

      var score = data['$name' + '_score'];
      var avg_score = await _avgScore(score);

      if (snapShot1.documents.isNotEmpty) {
        Firestore.instance
            .collection('Users')
            .document(snapShot.documents[0].documentID)
            .collection('data')
            .document(snapShot1.documents[0].documentID)
            .updateData(data)
            .then((value) {
          prefs.remove(keys[i]);
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID)
              .collection('data')
              .document(snapShot1.documents[0].documentID)
              .updateData({'Average': avg_score});
        });
      } else {
        Map<String, Object> data1 = <String, Object>{
          'date': DateTime.fromMillisecondsSinceEpoch(int.parse(key)),
          'week_in_year':
              Jiffy(DateTime.fromMillisecondsSinceEpoch(int.parse(key))).week,
          'day_in_year':
              Jiffy(DateTime.fromMillisecondsSinceEpoch(int.parse(key)))
                  .dayOfYear,
          'month_in_year':
              Jiffy(DateTime.fromMillisecondsSinceEpoch(int.parse(key))).month,
          'year':
              Jiffy(DateTime.fromMillisecondsSinceEpoch(int.parse(key))).year,
          'day_epoch': int.parse(key),
        };

        Firestore.instance
            .collection('Users')
            .document(snapShot.documents[0].documentID)
            .collection('data')
            .document()
            .setData(data1)
            .then((value) async {
          QuerySnapshot snapShot1 = await Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID)
              .collection('data')
              .where('day_epoch', isEqualTo: int.parse(key))
              .getDocuments();
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID)
              .collection('data')
              .document(snapShot1.documents[0].documentID)
              .updateData(data)
              .then((value) {
            prefs.remove(keys[i]);
            Firestore.instance
                .collection('Users')
                .document(snapShot.documents[0].documentID)
                .collection('data')
                .document(snapShot1.documents[0].documentID)
                .updateData({'Average': avg_score});
          });
        });
      }
    }
  }

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

  void saveString(i, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$i', json.encode(value));
  }

  Future getString(key) async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
    return json.decode(prefs.getString('$key'));
  }

  _card(name, type, dataCard) {
    if (type == "Yes/No") {
      bool temp = true;
      bool _isyesnoVisible = true;
      return StatefulBuilder(builder: (context, setState) {
        return Visibility(
          visible: temp,
          child: AnimatedOpacity(
            onEnd: () {
              setState(() {
                temp = false;
              });
            },
            opacity: _isyesnoVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              color: secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(name, style: Heading()),
                      ],
                    ),
                    Text(dataCard.toString(), style: Style2()),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            color: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            child: Text('Yes', style: ButtonText()),
                            onPressed: () {
                              setState(() {
                                _yesno('Yes', name).then((value) {
                                  setState(() {
                                    _isyesnoVisible = false;
                                  });
                                });
                              });
                            },
                          ),
                          RaisedButton(
                            color: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            child: Text('Partial', style: ButtonText()),
                            onPressed: () {
                              setState(() {
                                _yesno('Partial', name).then((value) {
                                  setState(() {
                                    _isyesnoVisible = false;
                                  });
                                });
                              });
                            },
                          ),
                          RaisedButton(
                            color: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            child: Text('No', style: ButtonText()),
                            onPressed: () {
                              setState(() {
                                _yesno('No', name).then((value) {
                                  setState(() {
                                    _isyesnoVisible = false;
                                  });
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
    if (type == "Actual_time") {
      bool temp = true;
      bool _isActualTimeVisible = true;
      return StatefulBuilder(builder: (context, setState) {
        return Visibility(
          visible: temp,
          child: AnimatedOpacity(
            onEnd: () {
              setState(() {
                temp = false;
              });
            },
            opacity: _isActualTimeVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                color: secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: Heading(),
                          ),
                        ],
                      ),
                      Text(
                        dataCard.toString(),
                        style: Style2(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TimePickerSpinner(
                          is24HourMode: false,
                          normalTextStyle: TextStyle(
                              fontSize: 24,
                              color: Colors.purple[200].withOpacity(0.5)),
                          highlightedTextStyle:
                              TextStyle(fontSize: 24, color: primaryColor1),
                          spacing: 40,
                          itemHeight: 50,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            setState(() {
                              time1 = time;
                              time2 = DateFormat('Hm').format(time);
                            });
                          },
                        ),
                      ),
                      RaisedButton(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        child: Text('Update', style: ButtonText()),
                        onPressed: () {
                          setState(() {
                            _addActualTime(name).whenComplete(() {
                              setState(() {
                                _isActualTimeVisible = false;
                              });
                            });
                          });
                        },
                      ),
                    ],
                  ),
                )),
          ),
        );
      });
    }
    var minutes = 0;
    if (type == "Time_Duration") {
      bool temp = true;
      bool _isTimeDurationVisible = true;
      if (dataCard != 'Select') {
        minutes = (double.parse(dataCard)).round();
      }
      return StatefulBuilder(builder: (context, setState) {
        return Visibility(
          visible: temp,
          child: AnimatedOpacity(
            onEnd: () {
              setState(() {
                temp = false;
              });
            },
            opacity: _isTimeDurationVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              color: secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Heading(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text_time + ' ' + 'minutes',
                        style: Style1(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          dataCard.toString(),
                          style: Style2(),
                        ),
                        Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Builder(
                              builder: (BuildContext context) =>
                                  new FloatingActionButton(
                                    backgroundColor: primaryColor,
                                    onPressed: () async {
                                      time_duration = await showDurationPicker(
                                        context: context,
                                        initialTime:
                                            new Duration(minutes: minutes),
                                      );
                                      setState(() {
                                        text_time =
                                            time_duration.inMinutes.toString();
                                      });
                                    },
                                    child: new Icon(Icons.timelapse),
                                  )),
                        ),
                      ],
                    ),
                    RaisedButton(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        child: Text('Update', style: ButtonText()),
                        onPressed: () {
                          setState(() {
                            _addTimeDuration(name).then((value) {
                              setState(() {
                                _isTimeDurationVisible = false;
                              });
                            });
                          });
                        })
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }

    if (type == "Punch") {
      bool temp = true;
      bool _isPunchVisible = true;
      return StatefulBuilder(builder: (context, setState) {
        return Visibility(
          visible: temp,
          child: AnimatedOpacity(
            opacity: _isPunchVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            onEnd: () {
              setState(() {
                temp = false;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                color: secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Heading(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            dataCard.toString(),
                            style: Style2(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RaisedButton(
                              color: primaryColor,
                              shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20.0)),
                              child: Text('Punch', style: ButtonText()),
                              onPressed: () {
                                setState(() {
                                  _addPunchTime(name).then((value) {
                                    setState(() {
                                      _isPunchVisible = false;
                                    });
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    }
    if (type == "Number") {
      bool _isNumberVisible = true;
      bool temp = true;
      if (dataCard != 'Select') {
        number.text = dataCard;
      }
      return StatefulBuilder(builder: (context, setState) {
        return Visibility(
          visible: temp,
          child: AnimatedOpacity(
            opacity: _isNumberVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            onEnd: () {
              setState(() {
                temp = false;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              color: secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(name, style: Heading()),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                height: 50,
                                width: 100,
                                child: TextField(
                                  cursorColor: Colors.grey,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  controller: number,
                                  decoration: InputDecoration(
                                    focusColor: Colors.white,
                                    hintStyle: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                    hintText: 'Select',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                )),
                            RaisedButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                color: primaryColor,
                                child: Text(
                                  'Update',
                                  style: ButtonText(),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _addNumber(name).then((value) {
                                      setState(() {
                                        _isNumberVisible = false;
                                      });
                                    });
                                  });
                                })
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
  }

  Widget _habbit_cards(names, types, data) {
    return ListView.builder(
        //scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: names.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _card(names[index], types[index], data[index])
              ],
            ),
          );
        });
  }

  String sendData() {
    return textDate;
  }

  Future<double> _avgScore(score) async {
    double tot_score = 0;
    double avg_score = 0;
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    QuerySnapshot snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();

    QuerySnapshot snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('settings')
        .where('type', isEqualTo: 'habit')
        .getDocuments();
    List names = [];
    int count = 0;
    if (snapShot1.documents.isEmpty) {
      setState(() {
        average_score = ((tot_score + score) / (count + 1)).round().toString();
      });
      return score.toDouble();
    } else {
      for (int i = 0; i < snapShot2.documents.length; i++) {
        names.add(snapShot2.documents[i].data['name']);
      }
      for (int i = 0; i < snapShot2.documents.length; i++) {
        String temp = names[i];
        if (snapShot1.documents[0].data['$temp' '_score'] != null) {
          count++;
          tot_score = tot_score +
              double.parse(
                  snapShot1.documents[0].data['$temp' '_score'].toString());
        }
      }
      setState(() {
        average_score = ((tot_score + score) / (count + 1)).round().toString();
      });
      return ((tot_score + score) / (count + 1));
      //print(avg_score);
    }
    //return avg_score;
  }

  String text_time = '';
  Duration time_duration;
  Future _addTimeDuration(name) async {
    if (!await _checkConnection()) {
      var count = await getString('count');
      for (int i = 0; i < count; i++) {
        getString(i).then((value) {
          if (value['name'] == name) {
            double time100 = value['time_100'].toDouble();
            double time75 = value['time_75'].toDouble();
            double time50 = value['time_50'].toDouble();
            double time25 = value['time_25'].toDouble();

            double score = time_duration.inMinutes.toDouble();
            if (score >= time100) {
              score = 100;
            } else if (score < time100 && score >= time75) {
              score = 75;
            } else if (score < time75 && score >= time50) {
              score = 50;
            } else if (score < time50 && score >= time25) {
              score = 25;
            } else if (score < time25) {
              score = 0;
            }

            Map<String, Object> data = <String, Object>{
              '$name': time_duration.inMinutes.toDouble(),
              '$name' '_score': score,
              '$name' '_updated':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            };
            saveString(dayepoch.toString() + '_' + '$name', data);
          }
        });
      }
    } else {
      final user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;
      final snapShot = await Firestore.instance
          .collection('Users')
          .where('UUID', isEqualTo: uid)
          .getDocuments();

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .where('day_epoch', isEqualTo: dayepoch)
          .getDocuments();

      QuerySnapshot snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('settings')
          .where('name', isEqualTo: name)
          .getDocuments();

      double time100 = snapShot2.documents[0].data['time_100'].toDouble();
      double time75 = snapShot2.documents[0].data['time_75'].toDouble();
      double time50 = snapShot2.documents[0].data['time_50'].toDouble();
      double time25 = snapShot2.documents[0].data['time_25'].toDouble();

      double score = time_duration.inMinutes.toDouble();
      if (score >= time100) {
        score = 100;
      } else if (score < time100 && score >= time75) {
        score = 75;
      } else if (score < time75 && score >= time50) {
        score = 50;
      } else if (score < time50 && score >= time25) {
        score = 25;
      } else if (score < time25) {
        score = 0;
      }

      double avg_score;
      _avgScore(score).then((value) {
        avg_score = value;
        final now = DateTime.now();
        if (snapShot1.documents.isEmpty) {
          Map<String, Object> data = <String, Object>{
            '$name': time_duration.inMinutes.toDouble(),
            '$name' '_score': score,
            'date': finaldate,
            'Average': avg_score,
            'week_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .week,
            'day_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .dayOfYear,
            'month_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .month,
            'year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .year,
            'day_epoch':
                (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                        .millisecondsSinceEpoch ~/
                    1000),
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document()
              .setData(data);
        } else {
          Map<String, Object> data = <String, Object>{
            '$name': time_duration.inMinutes.toDouble(),
            '$name' '_score': score,
            'Average': avg_score,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document(snapShot1.documents[0].documentID.toString())
              .updateData(data);
        }
      });
    }
  }

  final number = TextEditingController();
  Future _addNumber(name) async {
    if (!await _checkConnection()) {
      var count = await getString('count');
      for (int i = 0; i < count; i++) {
        getString(i).then((value) {
          if (value['name'] == name) {
            double score100 = value['number_100'].toDouble();
            double score75 = value['number_75'].toDouble();
            double score50 = value['number_50'].toDouble();
            double score25 = value['number_25'].toDouble();

            double score = double.parse(number.text);
            if (score >= score100) {
              score = 100;
            } else if (score < score100 && score >= score75) {
              score = 75;
            } else if (score < score75 && score >= score50) {
              score = 50;
            } else if (score > score25 && score < score50) {
              score = 25;
            } else if (score < score25) {
              score = 0;
            }

            Map<String, Object> data = <String, Object>{
              '$name': double.parse(number.text),
              '$name' '_score': score,
              '$name' '_updated':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            };
            saveString(dayepoch.toString() + '_' + '$name', data);
          }
        });
      }
    } else {
      progressDialog.show();
      final user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;
      final snapShot = await Firestore.instance
          .collection('Users')
          .where('UUID', isEqualTo: uid)
          .getDocuments();

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .where('day_epoch', isEqualTo: dayepoch)
          .getDocuments();

      QuerySnapshot snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('settings')
          .where('name', isEqualTo: name)
          .getDocuments();
      double score100 = snapShot2.documents[0].data['number_100'].toDouble();
      double score75 = snapShot2.documents[0].data['number_75'].toDouble();
      double score50 = snapShot2.documents[0].data['number_50'].toDouble();
      double score25 = snapShot2.documents[0].data['number_25'].toDouble();

      double score = double.parse(number.text);
      if (score >= score100) {
        score = 100;
      } else if (score < score100 && score >= score75) {
        score = 75;
      } else if (score < score75 && score >= score50) {
        score = 50;
      } else if (score > score25 && score < score50) {
        score = 25;
      } else if (score < score25) {
        score = 0;
      }

      double avg_score;
      _avgScore(score).then((value) {
        avg_score = value;

        final now = DateTime.now();
        if (snapShot1.documents.isEmpty) {
          Map<String, Object> data = <String, Object>{
            '$name': double.parse(number.text),
            '$name' '_score': score,
            'date': finaldate,
            'Average': avg_score,
            'week_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .week,
            'day_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .dayOfYear,
            'month_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .month,
            'year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .year,
            'day_epoch':
                (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                        .millisecondsSinceEpoch ~/
                    1000),
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document()
              .setData(data);
        } else {
          Map<String, Object> data = <String, Object>{
            '$name': double.parse(number.text),
            '$name' '_score': score,
            'Average': avg_score,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document(snapShot1.documents[0].documentID.toString())
              .updateData(data);
        }
      }).whenComplete(() {
        progressDialog.hide();
      });
    }
  }

  _addActualTime(name) async {
    if (!await _checkConnection()) {
      var count = await getString('count');
      for (int i = 0; i < count; i++) {
        getString(i).then((value) {
          if (value['name'] == name) {
            int start_time = value['start_time'];
            int end_time = value['end_time'];
            int time100 = value['time_100'];
            int time75 = value['time_75'];
            int time50 = value['time_50'];
            int time25 = value['time_25'];

            int score = time1.hour * 60 + time1.minute;

            if (score >= start_time && score <= end_time) {
              if (score >= time100) {
                score = 100;
              } else if (score >= time75 && score < time100) {
                score = 75;
              } else if (score >= time50 && score <= time75) {
                score = 50;
              } else if (score >= time25 && score <= time50) {
                score = 25;
              } else {
                score = 0;
              }
            } else {
              score = 0;
            }

            Map<String, Object> data = <String, Object>{
              '$name': time2,
              '$name' '_score': score,
              '$name' '_updated':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            };
            saveString(dayepoch.toString() + '_' + '$name', data);
          }
        });
      }
    } else {
      final user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;
      final snapShot = await Firestore.instance
          .collection('Users')
          .where('UUID', isEqualTo: uid)
          .getDocuments();

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .where('day_epoch', isEqualTo: dayepoch)
          .getDocuments();

      QuerySnapshot snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('settings')
          .where('name', isEqualTo: name)
          .getDocuments();

      int start_time = snapShot2.documents[0].data['start_time'];
      int end_time = snapShot2.documents[0].data['end_time'];
      int time100 = snapShot2.documents[0].data['time_100'];
      int time75 = snapShot2.documents[0].data['time_75'];
      int time50 = snapShot2.documents[0].data['time_50'];
      int time25 = snapShot2.documents[0].data['time_25'];

      int score = time1.hour * 60 + time1.minute;

      if (score >= start_time && score <= end_time) {
        if (score >= time100) {
          score = 100;
        } else if (score >= time75 && score < time100) {
          score = 75;
        } else if (score >= time50 && score <= time75) {
          score = 50;
        } else if (score >= time25 && score <= time50) {
          score = 25;
        } else {
          score = 0;
        }
      } else {
        score = 0;
      }

      double avg_score;
      _avgScore(score).then((value) {
        avg_score = value;
        final now = DateTime.now();
        if (snapShot1.documents.isEmpty) {
          Map<String, Object> data = <String, Object>{
            '$name': time2,
            '$name' '_score': score,
            'Average': avg_score,
            'date': finaldate,
            'week_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .week,
            'day_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .dayOfYear,
            'month_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .month,
            'year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .year,
            'day_epoch':
                (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                        .millisecondsSinceEpoch ~/
                    1000),
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document()
              .setData(data)
              .whenComplete(() {
            //progressDialog.hide();
          });
        } else {
          Map<String, Object> data = <String, Object>{
            '$name': time2,
            '$name' '_score': score,
            'Average': avg_score,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document(snapShot1.documents[0].documentID.toString())
              .updateData(data)
              .whenComplete(() {
            //progressDialog.hide();
          });
        }
      }).whenComplete(() {
        //progressDialog.hide();
      });
    }
  }

  final comments = TextEditingController();
  _addComments() async {
    progressDialog.show();
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    QuerySnapshot snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .where('day_epoch', isEqualTo: dayepoch)
        .getDocuments();

    final now = DateTime.now();
    if (snapShot1.documents.isEmpty) {
      Map<String, Object> data = <String, Object>{
        'day_epoch':
            (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                    .millisecondsSinceEpoch ~/
                1000),
        'week_in_year': Jiffy(
                DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0))
            .week,
        'day_in_year': Jiffy(
                DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0))
            .dayOfYear,
        'month_in_year': Jiffy(
                DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0))
            .month,
        'year': Jiffy(
                DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0))
            .year,
        'Comments': comments.text,
        'Comments_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      };
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .document()
          .setData(data)
          .whenComplete(() {
        progressDialog.hide();
      });
    } else {
      Map<String, Object> data = <String, Object>{
        "Comments": comments.text,
        "Comments_updated": (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      };
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .document(snapShot1.documents[0].documentID.toString())
          .updateData(data)
          .whenComplete(() {
        progressDialog.hide();
      });
    }
  }

  Future _addPunchTime(name) async {
    if (!await _checkConnection()) {
      var count = await getString('count');
      for (int i = 0; i < count; i++) {
        getString(i).then((value) {
          if (value['name'] == name) {
            int start_time = value['start_time'];
            int end_time = value['end_time'];
            int time100 = value['time_100'];
            int time75 = value['time_75'];
            int time50 = value['time_50'];
            int time25 = value['time_25'];

            TimeOfDay time = TimeOfDay.now();
            int score = time.hour * 60 + time.minute;

            if (score >= start_time && score <= end_time) {
              if (score >= time100) {
                score = 100;
              } else if (score >= time75 && score < time100) {
                score = 75;
              } else if (score >= time50 && score <= time75) {
                score = 50;
              } else if (score >= time25 && score <= time50) {
                score = 25;
              } else {
                score = 0;
              }
            } else {
              score = 0;
            }

            Map<String, Object> data = <String, Object>{
              '$name': time.format(context),
              '$name' '_score': score,
              '$name' '_updated':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            };
            saveString(dayepoch.toString() + '_' + '$name', data);
          }
        });
      }
    } else {
      final user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;
      final snapShot = await Firestore.instance
          .collection('Users')
          .where('UUID', isEqualTo: uid)
          .getDocuments();

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .where('day_epoch', isEqualTo: dayepoch)
          .getDocuments();

      QuerySnapshot snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('settings')
          .where('name', isEqualTo: name)
          .getDocuments();

      int start_time = snapShot2.documents[0].data['start_time'];
      int end_time = snapShot2.documents[0].data['end_time'];
      int time100 = snapShot2.documents[0].data['time_100'];
      int time75 = snapShot2.documents[0].data['time_75'];
      int time50 = snapShot2.documents[0].data['time_50'];
      int time25 = snapShot2.documents[0].data['time_25'];

      TimeOfDay time = TimeOfDay.now();
      int score = time.hour * 60 + time.minute;

      if (score >= start_time && score <= end_time) {
        if (score >= time100) {
          score = 100;
        } else if (score >= time75 && score < time100) {
          score = 75;
        } else if (score >= time50 && score <= time75) {
          score = 50;
        } else if (score >= time25 && score <= time50) {
          score = 25;
        } else {
          score = 0;
        }
      } else {
        score = 0;
      }

      double avg_score;
      _avgScore(score).then((value) {
        avg_score = value;
        final now = DateTime.now();
        if (snapShot1.documents.isEmpty) {
          Map<String, Object> data = <String, Object>{
            '$name': time.format(context),
            '$name' '_score': score,
            'Average': avg_score,
            'date': finaldate,
            'week_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .week,
            'day_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .dayOfYear,
            'month_in_year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .month,
            'year': Jiffy(DateTime(
                    finaldate.year, finaldate.month, finaldate.day, 0, 0))
                .year,
            'day_epoch':
                (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                        .millisecondsSinceEpoch ~/
                    1000),
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document()
              .setData(data);
        } else {
          Map<String, Object> data = <String, Object>{
            '$name': time.format(context),
            '$name' '_score': score,
            'Average': avg_score,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document(snapShot1.documents[0].documentID.toString())
              .updateData(data);
        }
      });
    }
  }

  Future _yesno(String value1, String name) async {
    breakfast = value1;
    if (!await _checkConnection()) {
      var count = await getString('count');
      for (int i = 0; i < count; i++) {
        getString(i).then((value) {
          if (value['name'] == name) {
            value1 = value1.toLowerCase();
            double score = value['$value1' '_score'].toDouble();

            Map<String, Object> data = <String, Object>{
              '$name': breakfast,
              '$name' '_score': score,
              '$name' '_updated':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            };
            saveString(dayepoch.toString() + '_' + '$name', data);
          }
        });
      }
    } else {
      final now = DateTime.now();
      final user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;
      final snapShot = await Firestore.instance
          .collection('Users')
          .where('UUID', isEqualTo: uid)
          .getDocuments();

      QuerySnapshot snapShot1 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('settings')
          .where('name', isEqualTo: name)
          .getDocuments();
      QuerySnapshot snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('data')
          .where('day_epoch', isEqualTo: dayepoch)
          .getDocuments();

      value1 = value1.toLowerCase();
      double score = snapShot1.documents[0].data['$value1' '_score'].toDouble();

      double avg_score;
      _avgScore(score).then((value) {
        setState(() {
          avg_score = value;
        });
        if (snapShot2.documents.isEmpty) {
          Map<String, Object> data = <String, Object>{
            '$name': breakfast,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            '$name' '_score': score,
            'Average': avg_score,
            'date': finaldate,
            'day_epoch':
                (DateTime(finaldate.year, finaldate.month, finaldate.day, 0, 0)
                        .millisecondsSinceEpoch ~/
                    1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document()
              .setData(data)
              .then((value) {
            setState(() {
              _isyesnoVisible = false;
            });
          });
        } else {
          Map<String, Object> data = <String, Object>{
            '$name': breakfast,
            '$name' '_score': score,
            'Average': avg_score,
            '$name' '_updated': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          };
          Firestore.instance
              .collection('Users')
              .document(snapShot.documents[0].documentID.toString())
              .collection('data')
              .document(snapShot2.documents[0].documentID.toString())
              .updateData(data)
              .then((value) {
            setState(() {
              _isyesnoVisible = false;
            });
          });
        }
      });
    }
  }

  dynamic time1;
  String time2 = 'Select time';

  final now = DateTime.now();

  Widget _calendar() {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(
            color: calendarColor,
            shape: BoxShape.circle,
            boxShadow: [
              new BoxShadow(
                color: Colors.purple[200],
                spreadRadius: 3,
                blurRadius: 3,
              )
            ],
          ),
          height: 50,
          width: 50,
          //padding: EdgeInsets.all(8.0),
          child: Icon(
            customIcons.MyFlutterApp.calendar,
            color: calendarTextColor,
          )),
      onTap: () {
        setState(() {
          showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(now.year, now.month, now.day)
                      .subtract(Duration(days: 30)),
                  lastDate: DateTime(now.year, now.month, now.day))
              .then((date) {
            names.clear();
            types.clear();
            data.clear();
            setState(() {
              yesterdayTextColor = primaryColor1;
              dbyesterdayTextColor = primaryColor1;
              todayTextcolor = primaryColor1;
              calendarTextColor = primaryColor;
              calendarColor = primaryColor1;
              dbyesterdayColor = primaryColor;
              yesterdayColor = primaryColor;
              todaycolor = primaryColor;
              String date1 = new DateFormat.yMMMd().format(date);
              finaldate = date;
              dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
              textDate = date1;
              _showNotUpdatedCards().then((value) {
                _averageScoredisplay();
                _set(names, types, data);
              });
            });
          });
        });
      },
    );
  }

  Widget _dbyesterday() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: dbyesterdayColor,
          shape: BoxShape.circle,
          boxShadow: [
            new BoxShadow(
              color: Colors.purple[200],
              spreadRadius: 3,
              blurRadius: 3,
            )
          ],
        ),
        height: 50,
        width: 50,
        //padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((Jiffy(DateTime.now()).subtract(days: 2)).day.toString(),
                style: TextStyle(color: dbyesterdayTextColor, fontSize: 20)),
            Text(
                DateFormat('E').format(Jiffy(DateTime.now()).subtract(days: 2)),
                style: TextStyle(color: dbyesterdayTextColor, fontSize: 10)),
          ],
        ),
      ),
      onTap: () {
        names.clear();
        types.clear();
        data.clear();
        setState(() {
          yesterdayTextColor = primaryColor1;
          dbyesterdayTextColor = primaryColor;
          calendarTextColor = primaryColor1;
          todayTextcolor = primaryColor1;
          todaycolor = primaryColor;
          yesterdayColor = primaryColor;
          calendarColor = primaryColor;
          dbyesterdayColor = primaryColor1;
          final now = DateTime.now();
          final date = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 2));
          finaldate = date;
          dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
          textDate = new DateFormat.yMMMd().format(date);
          _showNotUpdatedCards().then((value) {
            _averageScoredisplay();
            _set(names, types, data);
          });
        });
      },
    );
  }

  Widget _yesterday() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: yesterdayColor,
          shape: BoxShape.circle,
          boxShadow: [
            new BoxShadow(
              color: Colors.purple[200],
              spreadRadius: 3,
              blurRadius: 3,
            )
          ],
        ),
        height: 50,
        width: 50,
        //padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((Jiffy(DateTime.now()).subtract(days: 1)).day.toString(),
                style: TextStyle(color: yesterdayTextColor, fontSize: 20)),
            Text(
                DateFormat('E').format(Jiffy(DateTime.now()).subtract(days: 1)),
                style: TextStyle(color: yesterdayTextColor, fontSize: 10)),
          ],
        ),
      ),
      onTap: () {
        names.clear();
        types.clear();
        data.clear();
        setState(() {
          dbyesterdayTextColor = primaryColor1;
          calendarTextColor = primaryColor1;
          todayTextcolor = primaryColor1;
          yesterdayTextColor = primaryColor;
          todaycolor = primaryColor;
          calendarColor = primaryColor;
          yesterdayColor = primaryColor1;
          dbyesterdayColor = primaryColor;
          final now2 = DateTime.now();
          final yesterdaydate = DateTime(now2.year, now2.month, now2.day)
              .subtract(Duration(days: 1));
          textDate = new DateFormat.yMMMd().format(yesterdaydate);
          finaldate = yesterdaydate;
          dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
          _showNotUpdatedCards().then((value) {
            _averageScoredisplay();
            _set(names, types, data);
          });
        });
      },
    );
  }

  Widget _today() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: todaycolor,
          shape: BoxShape.circle,
          boxShadow: [
            new BoxShadow(
              color: Colors.purple[200],
              spreadRadius: 3,
              blurRadius: 3,
            )
          ],
        ),
        height: 50,
        width: 50,
        //padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((DateTime.now().day).toString(),
                style: TextStyle(color: todayTextcolor, fontSize: 20)),
            Text(DateFormat('E').format(DateTime.now()),
                style: TextStyle(color: todayTextcolor, fontSize: 10)),
          ],
        ),
      ),
      onTap: () {
        names.clear();
        types.clear();
        data.clear();
        setState(() {
          yesterdayTextColor = primaryColor1;
          dbyesterdayTextColor = primaryColor1;
          calendarTextColor = primaryColor1;
          todayTextcolor = primaryColor;
          todaycolor = primaryColor1;
          calendarColor = primaryColor;
          yesterdayColor = primaryColor;
          dbyesterdayColor = primaryColor;
          final now3 = DateTime.now();
          final todaydate = DateTime(now3.year, now3.month, now3.day);
          textDate = new DateFormat.yMMMd().format(todaydate);
          finaldate = todaydate;
          dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
          _showNotUpdatedCards().then((value) {
            _averageScoredisplay();
            _set(names, types, data);
          });
        });
      },
    );
  }

  List updatedName = [];
  List updatedType = [];

  _set(names, types, data) {
    setState(() {
      text_time = '';
      number.text = '';
      listview1 = _habbit_cards(names, types, data);
    });
  }

  Future _reset() async {
    progressDialog.show();
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
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('data')
        .document(ds.documents[0].documentID.toString())
        .delete()
        .whenComplete(() {
      progressDialog.hide();
    });
  }

  _averageScoredisplay() async {
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
        setState(() {
          average_score = ds.documents[0].data['Average'].round().toString();
        });
      } else {
        setState(() {
          average_score = '0';
        });
      }
    } else {
      setState(() {
        average_score = '0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      isDismissible: false,
      type: ProgressDialogType.Normal,
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  color: secondaryColor,
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey.shade500,
                      spreadRadius: 3,
                      blurRadius: 3,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    DateFormat('EEEE').format(finaldate) + ', ' + textDate,
                    style: Style2(),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _calendar(),
                        _dbyesterday(),
                        _yesterday(),
                        _today(),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  margin: EdgeInsets.fromLTRB(10, 15.0, 10, 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: primaryColor1,
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.purple[400],
                        spreadRadius: 3,
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      child: LinearPercentIndicator(
                        animation: true,
                        animationDuration: 1000,
                        lineHeight: 14.0,
                        leading: new Text(
                          "Your Progress",
                          style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        trailing: new Text(
                          average_score.toString() + '%',
                          style: TextStyle(color: primaryColor),
                        ),
                        percent: double.parse(average_score) / 100,
                        backgroundColor: Colors.purple[200],
                        progressColor: primaryColor,
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Scores()));
                      },
                    ),
                  ),
                ),
              ),
              listview1,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  color: secondaryColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: TextField(
                          cursorColor: primaryColor1,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          controller: comments,
                          maxLines: 5,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            hintStyle:
                            TextStyle(fontSize: 20, color: primaryColor1),
                            hintText: 'Comments',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          color: primaryColor,
                          child: Text(
                            'Update',
                            style: ButtonText(),
                          ),
                          onPressed: () {
                            _addComments();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: primaryColor,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              child: Icon(Icons.delete, color: Colors.white),
              backgroundColor: Colors.red[700],
              onTap: () {
                _reset().then((value) {
                  names.clear();
                  types.clear();
                  data.clear();
                  setState(() {
                    average_score = '0';
                  });
                  _showAllCards().then((value) {
                    _set(names, types, data);
                  });
                });
              },
              label: 'Reset',
              labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.red[700],
            ),
            SpeedDialChild(
              child: Icon(Icons.grid_off, color: Colors.white),
              backgroundColor: Colors.purple,
              onTap: () {
                names.clear();
                types.clear();
                data.clear();
                _showNotUpdatedCards().then((value) {
                  _set(names, types, data);
                });
              },
              label: 'Show Not-Updated Cards',
              labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.purple,
            ),
            SpeedDialChild(
              child: Icon(Icons.check_box, color: Colors.white),
              backgroundColor: Colors.purple,
              onTap: () {
                names.clear();
                types.clear();
                data.clear();
                _showUpdatedCards().then((value) {
                  _set(names, types, data);
                });
              },
              label: 'Show Updated cards',
              labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.purple,
            ),
            SpeedDialChild(
              child: Icon(Icons.grid_on, color: Colors.white),
              backgroundColor: Colors.purple,
              onTap: () {
                names.clear();
                types.clear();
                data.clear();
                _showAllCards().then((value) {
                  _set(names, types, data);
                });
              },
              label: 'Show All Cards',
              labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}