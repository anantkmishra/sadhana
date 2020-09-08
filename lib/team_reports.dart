import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'groups.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:hexcolor/hexcolor.dart';
import 'Account.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UsersInGroups extends StatefulWidget {
  var group;
  UsersInGroups(this.group);

  @override
  _UsersInGroupsState createState() => _UsersInGroupsState(group);
}

class _UsersInGroupsState extends State<UsersInGroups> {
  var group;
  _UsersInGroupsState(this.group);

  var _email = '';
  List<String> _teamNames = [];
  List<String> _teamEmails = [];
  List<String> _teamImages = [];

  List<bool> inputs = [];
  List<bool> nonGroupinputs = [];
  List<String> _nonGroupEmails = [];
  List<String> _nonGroupNames = [];
  List<String> _nonGroupImages = [];

  ProgressDialog progressDialog;

  Future _getUsers() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('groups')
        .where('group_name', isEqualTo: group)
        .getDocuments();

    for (int i = 0; i < snapShot1.documents.length; i++) {
      setState(() {
        _teamNames.add(snapShot1.documents[i].data['user_name']);
        _teamEmails.add(snapShot1.documents[i].data['user_email']);
        _teamImages.add(snapShot1.documents[i].data['profile_pic']);
      });
    }
  }

  Future _addUser() async {
    final user = await FirebaseAuth.instance.currentUser();
    final email = user.email;
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('Monitors', arrayContains: email)
        .getDocuments();

    for (int i = 0; i < snapShot1.documents.length; i++) {
      final snapShot = await Firestore.instance
          .collection('Users')
          .document(snapShot1.documents[i].documentID.toString())
          .get();
      setState(() {
        _nonGroupNames.add(snapShot.data['name']);
        _nonGroupEmails.add(snapShot.data['email']);
        _nonGroupImages.add(snapShot.data['profile_pic']);

        nonGroupinputs.add(false);
      });
    }

    final snapShot2 = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();
    final snapShot3 = await Firestore.instance
        .collection('Users')
        .document(snapShot2.documents[0].documentID)
        .collection('groups')
        .where('group_name', isEqualTo: group)
        .getDocuments();

    for (int i = 0; i < snapShot3.documents.length; i++) {
      _nonGroupNames.remove(snapShot3.documents[i].data['user_name']);
      _nonGroupEmails.remove(snapShot3.documents[i].data['user_email']);
      _nonGroupImages.remove(snapShot3.documents[i].data['profile_pic']);
      nonGroupinputs.remove(false);
    }
  }

  _deleteGroupUsers(email, name, image) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('groups')
        .where('user_email', isEqualTo: email)
        .where('group_name', isEqualTo: group)
        .getDocuments();
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('groups')
        .document(snapShot1.documents[0].documentID)
        .updateData({'group_name': 'default'}).then((value) {
      setState(() {
        _teamNames.remove(name);
        _teamEmails.remove(email);
        _teamImages.remove(image);
      });
    });
  }

  Widget _usersNames(emails, names, images) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _teamNames.length,
        itemBuilder: (context, index) {
          return Slidable(
            key: ValueKey(index),
            actionPane: SlidableDrawerActionPane(),
            secondaryActions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.clear,
                  closeOnTap: true,
                  onTap: () {
                    _deleteGroupUsers(
                        emails[index], names[index], images[index]);
                  },
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
              child: Card(
                color: Colors.grey.shade300,
                child: ListTile(
                  onTap: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Team_Scores(
                                  _teamEmails[index], _teamNames[index])));
                    });
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.fill)),
                  ),
                  title: Text(_teamNames[index]),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _getUsers().then((value) {
      progressDialog.show();
      _addUser().then((value) {
        progressDialog.hide();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      isDismissible: false,
      type: ProgressDialogType.Normal,
    );
    return Scaffold(
      backgroundColor: Hexcolor('#7C3DCA'),
      appBar: PreferredSize(
          child: ClipPath(
            clipper: CustomAppBar(),
            child: Container(
              color: Hexcolor('#7C3DCA'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                    child: Text(group,
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight + 40)),
      body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
          child: Column(
            children: <Widget>[
              _usersNames(_teamEmails, _teamNames, _teamImages),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddUsersToGroups(group, _nonGroupNames,
                      _nonGroupEmails, nonGroupinputs, _nonGroupImages)));
        },
      ),
    );
  }
}

class Team_Scores extends StatefulWidget {
  var email = '';
  var name = '';
  Team_Scores(this.email, this.name);
  Team_Scores.fromSetting();

  @override
  _Team_ScoresState createState() => _Team_ScoresState(email, name);
}

class _Team_ScoresState extends State<Team_Scores> {
  var email = '';
  var name = '';
  _Team_ScoresState(this.email, this.name);

  var dayepoch = 0;
  String textDate = 'Select Date';
  List names = [];
  List score = [];

  var finaldate;
  void initState() {
    final now = DateTime.now();
    finaldate = DateTime(now.year, now.month, now.day);
    dayepoch = finaldate.millisecondsSinceEpoch ~/ 1000;
    setState(() {
      textDate = new DateFormat.yMMMd().format(finaldate);
    });
    scores();
  }

  void scores() async {
    setState(() {
      score.clear();
      names.clear();
    });
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
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
    for (int i = 0; i < snapShot2.documents.length; i++) {
      names.add(snapShot2.documents[i].data['name']);
    }
    setState(() {
      if (snapShot1.documents.isNotEmpty) {
        for (int i = 0; i < snapShot2.documents.length; i++) {
          if (snapShot1.documents[0].data[names[i]] != null) {
            String temp = names[i];
            score.add(snapShot1.documents[0].data['$temp' '_score']);
          } else {
            score.add('null');
          }
        }
      } else {
        for (int i = 0; i < snapShot2.documents.length; i++) {
          score.add(null);
        }
      }
    });
  }

  Widget _habbit_cards(names, score) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: names.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(names[index]),
                    Text(':'),
                    Text(score[index].toString()),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(name),
          bottom: TabBar(
            tabs: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Report',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Analysis',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        body: StatefulBuilder(builder: (context, setState) {
          return TabBarView(children: [
            Container(
              child: ListView(
                children: <Widget>[
                  RaisedButton(
                    child: Text(textDate),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2021))
                          .then((value) {
                        setState(() {
                          dayepoch = value.millisecondsSinceEpoch ~/ 1000;
                          textDate = new DateFormat.yMMMd().format(value);
                          scores();
                        });
                      });
                    },
                  ),
                  _habbit_cards(names, score)
                ],
              ),
            ),
            Analytics(email)
          ]);
        }),
      ),
    );
  }
}
