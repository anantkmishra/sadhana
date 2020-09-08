import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/SelectAndAddTemplatesForUsers.dart';
import 'package:habbittracker/Templates.dart';
import 'package:habbittracker/authentication.dart';
import 'package:habbittracker/home.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

class UsersUnderCommander extends StatefulWidget {
  @override
  _UsersUnderCommanderState createState() => _UsersUnderCommanderState();
}

class _UsersUnderCommanderState extends State<UsersUnderCommander> {
  List<String> names = [];
  List<String> emails = [];
  List<String> images = [];

  var email;

  _getUsers() async {
    final user = await FirebaseAuth.instance.currentUser();
    email = user.email;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('commander', isEqualTo: email)
        .getDocuments();
    for (int i = 0; i < snapShot.documents.length; i++) {
      setState(() {
        names.add(snapShot.documents[i].data['name']);
        emails.add(snapShot.documents[i].data['email']);
        images.add(snapShot.documents[i].data['profile_pic']);
      });
    }
  }

  void initState() {
    _getUsers();
  }

  Widget _users(names, images) {
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
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(images[index]),
                          fit: BoxFit.fill)),
                ),
                title: Text(names[index]),
                onLongPress: () {
                  setState(() {
                    newCommanderName.text = email;
                  });
                  _changeCommanderDialog(emails[index]);
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SelectTemplateForUser(emails[index])));
                },
              ),
            ),
          );
        });
  }

  var newCommanderName = TextEditingController();

  _changeCommander(email) async {
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .updateData({
      'commander': newCommanderName.text,
    }).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(3)));
    });
  }

  Future<dynamic> _changeCommanderDialog(email) {
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
                            controller: newCommanderName,
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
                              hintText: 'Commander Name',
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
                            _changeCommander(email);
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
          title: Text('Templates'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Templates',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Users',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [Templates(), _users(names, images)],
        ),
      ),
    );
  }
}
