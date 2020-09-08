import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/Requests.dart';
import 'package:habbittracker/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habbittracker/home.dart';
import 'package:habbittracker/main.dart';
import 'package:habbittracker/scores.dart';
import 'package:habbittracker/team_reports.dart';
import 'Account.dart';
import 'package:hexcolor/hexcolor.dart';

class AddUsersToGroups extends StatefulWidget {
  var group;
  var _teamNames, _teamEmails, inputs, _teamImages;
  AddUsersToGroups(this.group, this._teamNames, this._teamEmails, this.inputs,
      this._teamImages);

  @override
  _AddUsersToGroupsState createState() => _AddUsersToGroupsState(
      group, _teamNames, _teamEmails, inputs, _teamImages);
}

class _AddUsersToGroupsState extends State<AddUsersToGroups> {
  List<String> _teamNames = [];
  List<String> _teamEmails = [];
  var isSelected = false;
  var mycolor = Colors.white;
  List<bool> inputs = [];
  List<String> _selectedEmails = [];
  List<String> _selectedNames = [];
  List<String> _selectedImages = [];

  var group;
  _AddUsersToGroupsState(this.group, this._teamNames, this._teamEmails,
      this.inputs, this._selectedImages);

  Future _addUsersToGroups() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID)
        .updateData({
      'groups': FieldValue.arrayUnion([group])
    });

    for (int i = 0; i < _selectedEmails.length; i++) {
      Firestore.instance
          .collection('Users')
          .document(snapShot1.documents[0].documentID)
          .collection('groups')
          .document()
          .setData({
        'group_name': group,
        'user_email': _selectedEmails[i],
        'user_name': _selectedNames[i],
        'profile_pic': _selectedImages[i]
      });
    }
  }

  Color color1 = Colors.white;
  List selectedList = [];

  Widget _usersNames() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _teamNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 0.0),
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: new Card(
                color: color1,
                child: Container(
                  color: Colors.grey.shade300,
                  child: new ListTile(
                    leading: Checkbox(
                      checkColor: Hexcolor('#7C3DCA'),
                      value: inputs[index],
                      onChanged: (s) {
                        setState(() {
                          inputs[index] = s;
                        });
                        if (s == true) {
                          _selectedNames.add(_teamNames[index]);
                          _selectedEmails.add(_teamEmails[index]);
                        } else if (s == false) {
                          _selectedNames.remove(_teamNames[index]);
                          _selectedEmails.remove(_teamEmails[index]);
                        }
                      },
                    ),
                    title: Text(_teamNames[index]),
                    onTap: () {
                      setState(() {
                        color1 = Colors.blue;
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: ClipPath(
            clipper: CustomAppBar(),
            child: Container(
              color: appBarColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                    child: Text('Users',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight + 100)),
      backgroundColor: backgroundColor,
      body: Container(
          padding: const EdgeInsets.fromLTRB(8.0, 25.0, 0.0, 0.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          child: Column(
            children: <Widget>[_usersNames()],
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_right),
        backgroundColor: primaryColor,
        onPressed: () {
          _addUsersToGroups().then((value) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home(2)));
          });
        },
      ),
    );
  }
}

class Groups extends StatefulWidget {
  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final editGroupName = TextEditingController();
  dynamic groups = [];
  final grpname = TextEditingController();
  var _email;
  List<String> _teamNames = [];
  List<String> _teamEmails = [];
  List<String> _teamImages = [];
  List<bool> inputs = [];

  _getGroups() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot1.documents[0].documentID)
        .get();
    //for(int i=0;i<snapShot2.data['groups'];i++) {
    setState(() {
      groups = snapShot2.data['groups'].toList();
    });
    //}
  }

  void initState() {
    _getGroups();
    _getUsers();
  }

  Widget _groups() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
              child: Column(
                children: <Widget>[
                  Card(
                    color: listItemColor,
                    child: ListTile(
                      title: Text(groups[index]),
                      onLongPress: () {
                        setState(() {
                          editGroupName.text = groups[index];
                        });
                        _editGroupNameDialog(groups[index]);
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UsersInGroups(groups[index])));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _editGroupNameDialog(group_name) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              child: SimpleDialog(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          //border: Border.all(width: 5.0, color: Colors.white),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(20.0)),
                          color: Colors.grey.shade300,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            //autofocus: true,
                            cursorColor: Colors.grey,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: editGroupName,
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              fillColor: Colors.white,
                              hintStyle:
                                  TextStyle(fontSize: 20, color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Group Name',
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: FlatButton(
                          child: Icon(Icons.chevron_right, color: Colors.white),
                          color: Hexcolor('#7C3DCA'),
                          onPressed: () {
                            _editGroupName(group_name);
                          }),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  _editGroupName(group_name) async {
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
        .where('group_name', isEqualTo: group_name)
        .getDocuments();
    final snapShot2 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .get();

    List groups = snapShot2.data['groups'].toList();
    groups.remove(group_name);
    groups.add(editGroupName.text);

    for (int i = 0; i < snapShot1.documents.length; i++) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[i].documentID)
          .collection('groups')
          .document(snapShot1.documents[i].documentID)
          .updateData({
        'group_name': editGroupName.text,
      }).then((value) {
        Firestore.instance
            .collection('Users')
            .document(snapShot.documents[i].documentID)
            .updateData({
          'groups': groups,
        }).then((value) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Groups()));
        });
      });
    }
  }

  void _getUsers() async {
    final user = await FirebaseAuth.instance.currentUser();
    _email = user.email;
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('Monitors', arrayContains: _email)
        .getDocuments();

    for (int i = 0; i < snapShot1.documents.length; i++) {
      final snapShot = await Firestore.instance
          .collection('Users')
          .document(snapShot1.documents[i].documentID.toString())
          .get();
      setState(() {
        _teamNames.add(snapShot.data['name']);
        _teamEmails.add(snapShot.data['email']);
        _teamImages.add(snapShot.data['profile_pic']);

        inputs.add(false);
      });
    }
  }

  Future<dynamic> _groupName() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              child: SimpleDialog(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          //border: Border.all(width: 5.0, color: Colors.white),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(20.0)),
                          color: Colors.grey.shade300,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            //autofocus: true,
                            cursorColor: Colors.grey,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: grpname,
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              fillColor: Colors.white,
                              hintStyle:
                                  TextStyle(fontSize: 20, color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Group Name',
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: FlatButton(
                          child: Icon(Icons.chevron_right, color: Colors.white),
                          color: Hexcolor('#7C3DCA'),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddUsersToGroups(
                                        grpname.text,
                                        _teamNames,
                                        _teamEmails,
                                        inputs,
                                        _teamImages)));
                          }),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor1,
        appBar: AppBar(
            backgroundColor: appBarColor,
            title: Text('Groups'),
            bottom: TabBar(
              tabs: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Groups',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Requests',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            )),
        body: StatefulBuilder(builder: (context, setState) {
          return TabBarView(
            children: [_groups(), Requests()],
          );
        }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _groupName();
          },
        ),
      ),
    );
  }
}
