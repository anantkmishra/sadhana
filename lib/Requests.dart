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

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<dynamic> names = [];
  List<dynamic> emails = [];
  List<dynamic> images = [];

  _getRequests() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('requests')
        .getDocuments();
    if (snapShot1.documents.isNotEmpty) {
      for (int i = 0; i < snapShot1.documents.length; i++) {
        if (snapShot1.documents[i].data['approval_status'] ==
            'Not yet approved') {
          emails.add(snapShot1.documents[i].data['email']);
          setState(() {
            images.add(snapShot1.documents[i].data['profile_pic']);
            names.add(snapShot1.documents[i].data['name']);
          });
        }
      }
    }
  }

  void initState() {
    _getRequests();
  }

  _accept(name, email, image) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    if (snapShot.documents[0].data['groups'] == null) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .updateData({
        'groups': ['default']
      });
    }
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('requests')
        .where('email', isEqualTo: email)
        .getDocuments();
    final snapShot2 = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('requests')
        .document(snapShot1.documents[0].documentID)
        .updateData({
      'approval_status': 'Approved',
      'approval_time': DateTime.now().millisecondsSinceEpoch ~/ 1000
    }).then((value) {
      Firestore.instance
          .collection('Users')
          .document(snapShot2.documents[0].documentID)
          .updateData({
        'Monitors': FieldValue.arrayUnion([user.email])
      });
    }).then((value) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .collection('groups')
          .document()
          .setData({
        'group_name': 'default',
        'user_email': email,
        'user_name': name,
        'profile_pic': image
      });
    }).then((value) {
      setState(() {
        names.remove(name);
        emails.remove(email);
        images.remove(image);
      });
    });
  }

  _reject(name, email, image) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('requests')
        .where('name', isEqualTo: name)
        .getDocuments();
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('requests')
        .document(snapShot1.documents[0].documentID)
        .updateData({
      'approval_status': 'Rejected',
      'rejected_time': DateTime.now().millisecondsSinceEpoch ~/ 1000
    }).then((value) {
      setState(() {
        names.remove(name);
        emails.remove(email);
        images.remove(image);
      });
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => Requests()));
    });
  }

  Widget _card(name, email, image) {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
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
                color: listItemColor,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(image),
                                  fit: BoxFit.fill)),
                        ),
                      ),
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

  Widget _requests(names, emails, images) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: names.length,
        itemBuilder: (context, index) {
          return Slidable(
            key: ValueKey(index),
            actionPane: SlidableDrawerActionPane(),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: IconSlideAction(
                  caption: 'Accept',
                  color: Colors.green,
                  icon: Icons.check,
                  closeOnTap: true,
                  onTap: () {
                    _accept(names[index], emails[index], images[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: IconSlideAction(
                  caption: 'Reject',
                  color: Colors.red,
                  icon: Icons.clear,
                  onTap: () {
                    _reject(names[index], emails[index], images[index]);
                  },
                ),
              )
            ],
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _card(names[index], emails[index], images[index])
                ],
              ),
            ),
          );
        });
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
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: _requests(names, emails, images),
              ),
            ],
          ),
        ));
  }
}
