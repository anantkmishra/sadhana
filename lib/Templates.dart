import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habbittracker/commander_users.dart';
import 'package:habbittracker/ActivitiesInTemplates.dart';
import 'package:habbittracker/team_reports.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';
import 'Colors.dart';

class Templates extends StatefulWidget {
  @override
  _TemplatesState createState() => _TemplatesState();
}

class _TemplatesState extends State<Templates> {
  List templates = [];
  var templateName = TextEditingController();
  var editTemplateName = TextEditingController();
  _getTemplate() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    if (snapShot.documents[0].data['templates'] != null) {
      setState(() {
        templates = snapShot.documents[0].data['templates'].toList();
      });
    } else {
      setState(() {
        templates.add('There are no templates saved yet');
      });
    }
  }

  void initState() {
    _getTemplate();
  }

  Widget _template_cards(templates) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: templates.length,
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
                      title: Text(templates[index]),
                      onLongPress: () {
                        setState(() {
                          editTemplateName.text = templates[index];
                        });
                        _editTemplateNameDialog(templates[index]);
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ActivitiesInTemplates.fromSetting(
                                        templates[index])));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> _templateName() {
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
                            controller: templateName,
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
                              hintText: 'Template Name',
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
                            _addTemplate();
                          }),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  _editTemplateNameDialog(template_name) {
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
                            controller: editTemplateName,
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
                              hintText: 'Template Name',
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
                            _editTemplateName(template_name);
                          }),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  _editTemplateName(template_name) async {
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
        .where('template', isEqualTo: template_name)
        .getDocuments();
    List templates = snapShot.documents[0].data['templates'].toList();
    templates.remove(template_name);
    templates.add(editTemplateName.text);
    for (int i = 0; i < snapShot1.documents.length; i++) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[i].documentID)
          .collection('templates')
          .document(snapShot1.documents[i].documentID)
          .updateData({
        'template': editTemplateName.text,
      }).then((value) {
        Firestore.instance
            .collection('Users')
            .document(snapShot.documents[0].documentID)
            .updateData({'templates': templates}).then((value) {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UsersUnderCommander()));
        });
      });
    }
  }

  _addTemplate() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    if (snapShot.documents[0].data['templates'] != null) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .updateData({
        'templates': FieldValue.arrayUnion([templateName.text])
      });
    } else {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .updateData({
        'templates': [templateName.text],
      });
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ActivitiesInTemplates(templateName.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor1,
        child: Column(
          children: <Widget>[Flexible(child: _template_cards(templates))],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _templateName();
        },
      ),
    );
  }
}
