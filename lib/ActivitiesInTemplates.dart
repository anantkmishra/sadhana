import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/authentication.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ActivitiesInTemplates extends StatefulWidget {
  var template_name;
  ActivitiesInTemplates(String template_name) {
    this.template_name = template_name;
  }
  ActivitiesInTemplates.fromSetting(String template_name) {
    this.template_name = template_name;
  }

  @override
  _ActivitiesInTemplatesState createState() =>
      _ActivitiesInTemplatesState(template_name);
}

class _ActivitiesInTemplatesState extends State<ActivitiesInTemplates> {
  String template_name = '';
  _ActivitiesInTemplatesState(this.template_name);

  final habbit = TextEditingController();
  String dropdownValue = 'Yes/No';
  Widget data = TextField();
  int no_of_habbits = 0;
  List<String> habbits_names_list = [];
  List<String> habbits_types_list = [];
  int flag = 0;

  var yes = TextEditingController();
  var no = TextEditingController();
  var partial = TextEditingController();

  var timepercent25 = TextEditingController();
  var timepercent50 = TextEditingController();
  var timepercent75 = TextEditingController();
  var timepercent100 = TextEditingController();

  var numberpercent25 = TextEditingController();
  var numberpercent50 = TextEditingController();
  var numberpercent75 = TextEditingController();
  var numberpercent100 = TextEditingController();

  bool _habbitnamevalidator = false;
  bool _yesvalidator = false;
  bool _novalidator = false;
  bool _partialvalidator = false;

  bool _timepercent100validator = false;
  bool _timepercent75validator = false;
  bool _timepercent50validator = false;
  bool _timepercent25validator = false;

  bool _numberpercent100validator = false;
  bool _numberpercent75validator = false;
  bool _numberpercent50validator = false;
  bool _numberpercent25validator = false;

  String text = '';

  _getHabbits() async {
    setState(() {
      habbits_names_list.clear();
      habbits_types_list.clear();
    });
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('templates')
        .getDocuments();
    if (snapShot1.documents.isNotEmpty) {
      final snapShot3 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('templates')
          .where('type', isEqualTo: 'habit')
          .where('template', isEqualTo: template_name)
          .getDocuments();
      if (snapShot3.documents.isNotEmpty) {
        for (int i = 0; i < snapShot3.documents.length; i++) {
          String habbit_name = snapShot3.documents[i].data['name'];
          String habbit_type = snapShot3.documents[i].data['habit_type'];
          setState(() {
            habbits_names_list.add(habbit_name);
            habbits_types_list.add(habbit_type);
          });
        }
      } else {
        setState(() {
          text = 'No Activities added till now';
        });
      }
    }
  }

  void initState() {
    setState(() {
      _getHabbits();
    });
  }

  Widget _habbit_cards(names, types) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: names.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
            child: Card(
              color: listItemColor,
              child: ListTile(
                title: Text(names[index]),
                subtitle: Text(types[index]),
                onTap: () {
                  _edit_Habbits(context, names[index], types[index]);
                },
              ),
            ),
          );
        });
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  _edit_Habbits(BuildContext context, name, type) async {
    var habbit1 = TextEditingController();
    var container = Container();
    String dropdownValue1 = '';
    setState(() {
      habbit1.text = name;
      dropdownValue1 = type;
    });
    Map<String, Object> data2;
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('templates')
        .getDocuments();
    QuerySnapshot snapShot2;
    if (snapShot1.documents.isNotEmpty) {
      snapShot2 = await Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID.toString())
          .collection('templates')
          .where('type', isEqualTo: 'habit')
          .where('name', isEqualTo: name)
          .getDocuments();
      var type = snapShot2.documents[0].data['habit_type'];
      if (type == 'Yes/No') {
        yes.text = snapShot2.documents[0].data['yes_score'].toString();
        no.text = snapShot2.documents[0].data['no_score'].toString();
        partial.text = snapShot2.documents[0].data['partial_score'].toString();
      } else if (type == 'Actual_time') {
        strtime = durationToString(snapShot2.documents[0].data['start_time']);
        strtime0 = durationToString(snapShot2.documents[0].data['end_time']);
        strtime1 = durationToString(snapShot2.documents[0].data['time_100']);
        strtime2 = durationToString(snapShot2.documents[0].data['time_75']);
        strtime3 = durationToString(snapShot2.documents[0].data['time_50']);
        strtime4 = durationToString(snapShot2.documents[0].data['time_25']);
      } else if (type == 'Punch') {
        strtime = durationToString(snapShot2.documents[0].data['start_time']);
        strtime0 = durationToString(snapShot2.documents[0].data['end_time']);
        strtime1 = durationToString(snapShot2.documents[0].data['time_100']);
        strtime2 = durationToString(snapShot2.documents[0].data['time_75']);
        strtime3 = durationToString(snapShot2.documents[0].data['time_50']);
        strtime4 = durationToString(snapShot2.documents[0].data['time_25']);
      } else if (type == 'Time_Duration') {
        timepercent100.text =
            snapShot2.documents[0].data['time_100'].toString();
        timepercent75.text = snapShot2.documents[0].data['time_75'].toString();
        timepercent50.text = snapShot2.documents[0].data['time_50'].toString();
        timepercent25.text = snapShot2.documents[0].data['time_25'].toString();
      } else if (type == 'Number') {
        numberpercent100.text =
            snapShot2.documents[0].data['number_100'].toString();
        numberpercent75.text =
            snapShot2.documents[0].data['number_75'].toString();
        numberpercent50.text =
            snapShot2.documents[0].data['number_50'].toString();
        numberpercent25.text =
            snapShot2.documents[0].data['number_25'].toString();
      }
      container = _containerChange(type);
    }
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 100,
              child: SimpleDialog(
                title: Text(name),
                //child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: 50,
                            width: 200,
                            child: TextField(
                              style: TextStyle(fontSize: 20),
                              controller: habbit1,
                              decoration:
                                  InputDecoration(hintText: 'Habit name'),
                            )),
                        container,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.red,
                              child: Text('Delete'),
                              onPressed: () {
                                setState(() {
                                  Firestore.instance
                                      .collection('Users')
                                      .document(snapShot.documents[0].documentID
                                          .toString())
                                      .collection('templates')
                                      .document(snapShot2
                                          .documents[0].documentID
                                          .toString())
                                      .delete()
                                      .then((value) {
                                    Navigator.pop(context);
                                    _getHabbits();
                                  });
                                });
                              },
                            ),
                            RaisedButton(
                              color: Colors.green,
                              child: Text('Update'),
                              onPressed: () {
                                if (type == 'Yes/No') {
                                  data2 = <String, Object>{
                                    'name': habbit1.text,
                                    'yes_score': double.parse(yes.text),
                                    'no_score': double.parse(no.text),
                                    'partial_score': double.parse(partial.text),
                                  };
                                } else if (type == 'Actual_time') {
                                  data2 = <String, Object>{
                                    'name': habbit1.text,
                                    'start_time': time.hour * 60 + time.minute,
                                    'end_time': time0.hour * 60 + time0.minute,
                                    'time_100': time1.hour * 60 + time1.minute,
                                    'time_75': time2.hour * 60 + time2.minute,
                                    'time_50': time3.hour * 60 + time3.minute,
                                    'time_25': time4.hour * 60 + time4.minute,
                                  };
                                } else if (type == 'Punch') {
                                  data2 = <String, Object>{
                                    'name': habbit1.text,
                                    'start_time': time.hour * 60 + time.minute,
                                    'end_time': time0.hour * 60 + time0.minute,
                                    'time_100': time1.hour * 60 + time1.minute,
                                    'time_50': time2.hour * 60 + time2.minute,
                                    'time_75': time3.hour * 60 + time3.minute,
                                    'time_25': time4.hour * 60 + time4.minute,
                                  };
                                } else if (type == 'Time_Duration') {
                                  data2 = <String, Object>{
                                    'name': habbit1.text,
                                    'time_25': double.parse(timepercent25.text),
                                    'time_50': double.parse(timepercent50.text),
                                    'time_75': double.parse(timepercent75.text),
                                    'time_100':
                                        double.parse(timepercent100.text),
                                  };
                                } else if (type == 'Number') {
                                  data2 = <String, Object>{
                                    'name': habbit1.text,
                                    'number_25':
                                        double.parse(numberpercent25.text),
                                    'number_50':
                                        double.parse(numberpercent50.text),
                                    'number_75':
                                        double.parse(numberpercent75.text),
                                    'number_100':
                                        double.parse(numberpercent100.text),
                                  };
                                }
                                setState(() {
                                  Firestore.instance
                                      .collection('Users')
                                      .document(snapShot.documents[0].documentID
                                          .toString())
                                      .collection('templates')
                                      .document(snapShot2
                                          .documents[0].documentID
                                          .toString())
                                      .updateData(data2)
                                      .then((value) {
                                    Navigator.pop(context);
                                    _getHabbits();
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future _addHabbits(value) async {
    setState(() {
      habbits_names_list.clear();
      habbits_types_list.clear();
    });

    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    Map<String, Object> data = <String, Object>{};
    if (value == 'Yes/No') {
      data = <String, Object>{
        'name': habbit.text,
        'habit_type': dropdownValue,
        'position': 1,
        'type': 'habit',
        'yes_score': double.parse(yes.text),
        'no_score': double.parse(no.text),
        'partial_score': double.parse(partial.text),
        'template': template_name
      };
    } else if (value == 'Actual_time') {
      data = <String, Object>{
        'name': habbit.text,
        'habit_type': dropdownValue,
        'position': 1,
        'type': 'habit',
        'start_time': time.hour * 60 + time.minute,
        'end_time': time0.hour * 60 + time0.minute,
        'time_100': time1.hour * 60 + time1.minute,
        'time_75': time2.hour * 60 + time2.minute,
        'time_50': time3.hour * 60 + time3.minute,
        'time_25': time4.hour * 60 + time4.minute,
        'template': template_name
      };
    } else if (value == 'Time_Duration') {
      data = <String, Object>{
        'name': habbit.text,
        'habit_type': dropdownValue,
        'position': 1,
        'type': 'habit',
        'time_25': double.parse(timepercent25.text),
        'time_50': double.parse(timepercent50.text),
        'time_75': double.parse(timepercent75.text),
        'time_100': double.parse(timepercent100.text),
        'template': template_name
      };
    } else if (value == 'Number') {
      data = <String, Object>{
        'name': habbit.text,
        'habit_type': dropdownValue,
        'position': 1,
        'type': 'habit',
        'number_25': double.parse(numberpercent25.text),
        'number_50': double.parse(numberpercent50.text),
        'number_75': double.parse(numberpercent75.text),
        'number_100': double.parse(numberpercent100.text),
        'template': template_name
      };
    } else if (value == 'Punch') {
      data = <String, Object>{
        'name': habbit.text,
        'habit_type': dropdownValue,
        'position': 1,
        'type': 'habit',
        'start_time': time.hour * 60 + time.minute,
        'end_time': time0.hour * 60 + time0.minute,
        'time_100': time1.hour * 60 + time1.minute,
        'time_50': time2.hour * 60 + time2.minute,
        'time_75': time3.hour * 60 + time3.minute,
        'time_25': time4.hour * 60 + time4.minute,
        'template': template_name
      };
    }

    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID.toString())
        .collection('templates')
        .document()
        .setData(data)
        .then((value) {
      Navigator.pop(context);
      setState(() {
        _getHabbits();
      });
    });
  }

  String strtime = 'Start time';
  String strtime0 = 'End time';
  String strtime1 = 'Start time';
  String strtime2 = 'Start time';
  String strtime3 = 'Start time';
  String strtime4 = 'Start time';

  dynamic time = 'Start time';
  dynamic time0 = 'End time';
  dynamic time1 = 'Start time';
  dynamic time2 = 'Start time';
  dynamic time3 = 'Start time';
  dynamic time4 = 'Start time';

  Future<dynamic> _selectTime(BuildContext context) async {
    String temp = '';
    TimeOfDay time = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) {
      setState(() {
        //temp = picked.format(context);
        //time1 = picked.hour.toString() + ':' + picked.minute.toString();
      });
    }
    return picked;
  }

  yesnoContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('Percentage of score you want to give for YES'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: yes,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText: _yesvalidator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _yesvalidator = false;
                  });
                },
              )),
          Text('Percentage of score you want to give for NO'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: no,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText: _novalidator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _yesvalidator = false;
                  });
                },
              )),
          Text('Percentage of score you want to give for PARTIAL'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: partial,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText: _partialvalidator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _partialvalidator = false;
                  });
                },
              ))
        ],
      ),
    );
  }

  actualTimeContainer() {
    return Container(
        child: Column(
      children: <Widget>[
        Text('Select time range the activity is done'),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              StatefulBuilder(builder: (context, setState) {
                return RaisedButton(
                  color: Colors.green,
                  child: Text(strtime),
                  onPressed: () {
                    _selectTime(context).then((value) {
                      setState(() {
                        time = value;
                        strtime = value.format(context);
                      });
                    });
                  },
                );
              }),
              StatefulBuilder(builder: (context, setState) {
                return RaisedButton(
                  color: Colors.red,
                  child: Text(strtime0),
                  onPressed: () {
                    _selectTime(context).then((value) {
                      setState(() {
                        time0 = value;
                        strtime0 = value.format(context);
                      });
                    });
                  },
                );
              }),
            ]),
        Text('Select time range for which you want to give 100% score'),
        StatefulBuilder(builder: (context, setState) {
          return RaisedButton(
            color: Colors.lightBlue,
            child: Text(strtime1),
            onPressed: () {
              _selectTime(context).then((value) {
                setState(() {
                  time1 = value;
                  strtime1 = value.format(context);
                });
              });
            },
          );
        }),
        Text('Select time range for which you want to give 75% score'),
        StatefulBuilder(builder: (context, setState) {
          return RaisedButton(
            color: Colors.lightBlue,
            child: Text(strtime2),
            onPressed: () {
              _selectTime(context).then((value) {
                setState(() {
                  time2 = value;
                  strtime2 = value.format(context);
                });
              });
            },
          );
        }),
        Text('Select time range for which you want to give 50% score'),
        StatefulBuilder(builder: (context, setState) {
          return RaisedButton(
            color: Colors.lightBlue,
            child: Text(strtime3),
            onPressed: () {
              _selectTime(context).then((value) {
                setState(() {
                  time3 = value;
                  strtime3 = value.format(context);
                });
              });
            },
          );
        }),
        Text('Select time range for which you want to give 25% score'),
        StatefulBuilder(builder: (context, setState) {
          return RaisedButton(
            color: Colors.lightBlue,
            child: Text(strtime4),
            onPressed: () {
              _selectTime(context).then((value) {
                setState(() {
                  time4 = value;
                  strtime4 = value.format(context);
                });
              });
            },
          );
        }),
      ],
    ));
  }

  timeDurationContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('Number of minutes you want to score yourself 100%'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: timepercent100,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _timepercent100validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _timepercent100validator = false;
                  });
                },
              )),
          Text('Number of minutes you want to score yourself 75%'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: timepercent75,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _timepercent75validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _timepercent75validator = false;
                  });
                },
              )),
          Text('Number of minutes you want to score yourself 50%'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: timepercent50,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _timepercent50validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _timepercent50validator = false;
                  });
                },
              )),
          Text('Number of minutes you want to score yourself 25%'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: timepercent25,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _timepercent25validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _timepercent25validator = false;
                  });
                },
              )),
        ],
      ),
    );
  }

  numberContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('What is Number above which you want to give 100% score'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: numberpercent100,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _numberpercent100validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _numberpercent100validator = false;
                  });
                },
              )),
          Text('What is Number above which you want to give 75% score'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: numberpercent75,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _numberpercent75validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _numberpercent75validator = false;
                  });
                },
              )),
          Text('What is Number above which you want to give 50% score'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: numberpercent50,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _numberpercent50validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _numberpercent50validator = false;
                  });
                },
              )),
          Text('What is Number above which you want to give 25% score'),
          Container(
              height: 50,
              width: 50,
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: numberpercent25,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '%',
                    errorText:
                        _numberpercent25validator ? 'This is required' : null),
                onChanged: (value) {
                  setState(() {
                    _numberpercent25validator = false;
                  });
                },
              )),
        ],
      ),
    );
  }

  punchContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('Select time range the activity is done'),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StatefulBuilder(builder: (context, setState) {
                  return RaisedButton(
                    child: Text(strtime),
                    onPressed: () {
                      _selectTime(context).then((value) {
                        setState(() {
                          time = value;
                          strtime = value.format(context);
                        });
                      });
                    },
                  );
                }),
                StatefulBuilder(builder: (context, setState) {
                  return RaisedButton(
                    child: Text(strtime0),
                    onPressed: () {
                      _selectTime(context).then((value) {
                        setState(() {
                          time0 = value;
                          strtime0 = value.format(context);
                        });
                      });
                    },
                  );
                }),
              ]),
          Text('Select time range for which you want to give 100% score'),
          StatefulBuilder(builder: (context, setState) {
            return RaisedButton(
              child: Text(strtime1),
              onPressed: () {
                _selectTime(context).then((value) {
                  setState(() {
                    time1 = value;
                    strtime1 = value.format(context);
                  });
                });
              },
            );
          }),
          Text('Select time range for which you want to give 75% score'),
          StatefulBuilder(builder: (context, setState) {
            return RaisedButton(
              child: Text(strtime3),
              onPressed: () {
                _selectTime(context).then((value) {
                  setState(() {
                    time2 = value;
                    strtime3 = value.format(context);
                  });
                });
              },
            );
          }),
          Text('Select time range for which you want to give 50% score'),
          StatefulBuilder(builder: (context, setState) {
            return RaisedButton(
              child: Text(strtime3),
              onPressed: () {
                _selectTime(context).then((value) {
                  setState(() {
                    time3 = value;
                    strtime3 = value.format(context);
                  });
                });
              },
            );
          }),
          Text('Select time range for which you want to give 25% score'),
          StatefulBuilder(builder: (context, setState) {
            return RaisedButton(
              child: Text(strtime4),
              onPressed: () {
                _selectTime(context).then((value) {
                  setState(() {
                    time4 = value;
                    strtime4 = value.format(context);
                  });
                });
              },
            );
          }),
        ],
      ),
    );
  }

  _containerChange(value) {
    if (value == 'Yes/No') {
      Container container = yesnoContainer();
      return container;
    } else if (value == 'Actual_time') {
      Container container = actualTimeContainer();
      return container;
    } else if (value == 'Time_Duration') {
      Container container = timeDurationContainer();
      return container;
    } else if (value == 'Number') {
      Container container = numberContainer();
      return container;
    } else if (value == 'Punch') {
      Container container = punchContainer();
      return container;
    }
  }

  String error = '';

  _addActivity(BuildContext context) {
    setState(() {
      text = '';
    });
    habbit.clear();
    dropdownValue = 'Yes/No';
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 100,
              child: SimpleDialog(
                title: Text('Add habit'),
                //child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: 50,
                            width: 200,
                            child: TextField(
                              style: TextStyle(fontSize: 20),
                              controller: habbit,
                              decoration: InputDecoration(
                                  hintText: 'Habit name',
                                  errorText: _habbitnamevalidator
                                      ? 'Habit name is required'
                                      : null),
                              onChanged: (value) {
                                setState(() {
                                  _habbitnamevalidator = false;
                                });
                              },
                            )),
                        Container(
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                strtime = 'Start time';
                                strtime0 = 'End time';
                                strtime1 = 'Select time';
                                strtime2 = 'Select time';
                                strtime3 = 'Select time';
                                strtime4 = 'Select time';
                              });
                            },
                            items: <String>[
                              'Yes/No',
                              'Actual_time',
                              'Time_Duration',
                              'Number',
                              'Punch'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        _containerChange(dropdownValue),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.red,
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
//                                dropdownValue = 'Yes/No';
                              },
                            ),
                            RaisedButton(
                              color: Colors.green,
                              child: Text('Add'),
                              onPressed: () {
                                if (habbit.text.isEmpty) {
                                  setState(() {
                                    _habbitnamevalidator = true;
                                  });
                                }
                                if (dropdownValue == 'Yes/No') {
                                  if (yes.text.isEmpty) {
                                    setState(() {
                                      _yesvalidator = true;
                                    });
                                  } else if (no.text.isEmpty) {
                                    setState(() {
                                      _novalidator = true;
                                    });
                                  } else if (partial.text.isEmpty) {
                                    setState(() {
                                      _partialvalidator = true;
                                    });
                                  } else {
                                    _addHabbits(dropdownValue);
                                  }
                                } else if (dropdownValue == 'Number') {
                                  if (numberpercent100.text.isEmpty) {
                                    setState(() {
                                      _numberpercent100validator = true;
                                    });
                                  } else if (numberpercent50.text.isEmpty) {
                                    setState(() {
                                      _numberpercent50validator = true;
                                    });
                                  } else if (numberpercent25.text.isEmpty) {
                                    setState(() {
                                      _numberpercent25validator = true;
                                    });
                                  } else if (numberpercent75.text.isEmpty) {
                                    setState(() {
                                      _numberpercent75validator = true;
                                    });
                                  } else {
                                    _addHabbits(dropdownValue);
                                  }
                                } else if (dropdownValue == 'Time_Duration') {
                                  if (timepercent100.text.isEmpty) {
                                    setState(() {
                                      _timepercent100validator = true;
                                    });
                                  } else if (timepercent50.text.isEmpty) {
                                    setState(() {
                                      _timepercent50validator = true;
                                    });
                                  } else if (timepercent25.text.isEmpty) {
                                    setState(() {
                                      _timepercent25validator = true;
                                    });
                                  } else if (timepercent75.text.isEmpty) {
                                    setState(() {
                                      _timepercent75validator = true;
                                    });
                                  } else {
                                    _addHabbits(dropdownValue);
                                  }
                                } else if (dropdownValue == 'Actual_time' ||
                                    dropdownValue == 'Punch') {
                                  if (strtime == 'Start time' ||
                                      strtime0 == 'End time' ||
                                      strtime1 == 'Start time' ||
                                      strtime2 == 'End time' ||
                                      strtime3 == 'Start time' ||
                                      strtime4 == 'End time') {
                                    setState(() {
                                      error = 'Fill all required';
                                    });
                                  } else {
                                    _addHabbits(dropdownValue);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        title: Text('Add Activities'),
      ),
      backgroundColor: primaryColor1,
      body: ListView(
        children: <Widget>[
          Center(
            child: Text(text, style: TextStyle(fontSize: 20)),
          ),
          _habbit_cards(habbits_names_list, habbits_types_list)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addActivity(context);
        },
      ),
    );
  }
}
