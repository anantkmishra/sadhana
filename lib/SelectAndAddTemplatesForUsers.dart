import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/home.dart';
import 'package:toast/toast.dart';

class SelectTemplateForUser extends StatefulWidget {
  var email;
  SelectTemplateForUser(this.email);

  @override
  _SelectTemplateForUserState createState() =>
      _SelectTemplateForUserState(email);
}

class _SelectTemplateForUserState extends State<SelectTemplateForUser> {
  var email;
  _SelectTemplateForUserState(this.email);

  List templates = [];
  _getTemplates() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('templates')
        .getDocuments();

    if (snapShot1.documents.isNotEmpty) {
      for (int i = 0; i < snapShot1.documents.length; i++) {
        if (!templates.contains(snapShot1.documents[i].data['template'])) {
          setState(() {
            templates.add(snapShot1.documents[i].data['template']);
          });
        }
      }
    } else {
      setState(() {
        templates.add('There are no templates to add');
      });
    }
  }

  Widget _template_cards(templates) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: listItemColor,
              child: ListTile(
                title: Text(templates[index]),
                onTap: () {
                  _addSettings(templates[index]);
                },
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _getTemplates();
    super.initState();
  }

  _addSettings(template) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .collection('templates')
        .where('type', isEqualTo: 'habit')
        .where('template', isEqualTo: template)
        .getDocuments();

    final snapShot2 = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .getDocuments();

    Firestore.instance
        .collection('Users')
        .document(snapShot2.documents[0].documentID)
        .collection('settings')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    }).then((value) {
      for (int i = 0; i < snapShot1.documents.length; i++) {
        Firestore.instance
            .collection('Users')
            .document(snapShot2.documents[0].documentID)
            .collection('settings')
            .document()
            .setData(snapShot1.documents[i].data)
            .then((value) {
          Toast.show('Successfully added Habits to the user', context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home(3)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text('Select Template'),
      ),
      backgroundColor: backgroundColor1,
      body: Column(
        children: <Widget>[_template_cards(templates)],
      ),
    );
  }
}
