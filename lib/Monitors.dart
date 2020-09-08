import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:toast/toast.dart';
import 'Account.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Monitors extends StatefulWidget {
  @override
  _MonitorsState createState() => _MonitorsState();
}

class _MonitorsState extends State<Monitors> {
  List names = [];
  dynamic emails = [];

  _getMonitors() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    emails = snapShot.documents[0].data['Monitors'].toList();
    for (int i = 0; i < emails.length; i++) {
      final snapShot1 = await Firestore.instance
          .collection('Users')
          .where('email', isEqualTo: emails[i])
          .getDocuments();
      setState(() {
        names.add(snapShot1.documents[0].data['name']);
      });
    }
  }

  _deleteMonitor(email, name) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .updateData({
      'Monitors': FieldValue.arrayRemove([email])
    }).then((value) {
      setState(() {
        names.remove(name);
        emails.remove(email);
      });
    });
  }

  void initState() {
    _getMonitors();
  }

  Widget _monitors(names, emails) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: names.length,
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
                    _deleteMonitor(emails[index], names[index]);
                  },
                ),
              ),
            ],
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[_card(names[index])],
              ),
            ),
          );
        });
  }

  _card(name) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(name.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                    child: Text('Monitors',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight + 80)),
      body: Container(
        decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: ListView(
          children: [_monitors(names, emails)],
        ),
      ),
    );
  }
}
