import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/authentication.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:habbittracker/NewUser.dart';
import 'package:habbittracker/main.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChooseZones extends StatefulWidget {
  @override
  _ChooseZonesState createState() => _ChooseZonesState();
}

class _ChooseZonesState extends State<ChooseZones> {
  List<String> zone_names = [];
  List<String> zone_commander = [];

  _getZones() async {
    final snapShot =
        await Firestore.instance.collection('zones').getDocuments();
    for (int i = 0; i < snapShot.documents.length; i++) {
      setState(() {
        zone_names.add(snapShot.documents[i].data['name']);
        zone_commander.add(snapShot.documents[i].data['commander']);
      });
    }
  }

  void initState() {
    _getZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: RadioButtonListView(zone_names, zone_commander));
  }
}

class RadioButtonListView extends StatefulWidget {
  var zone_name;
  var zone_commander;
  RadioButtonListView(this.zone_name, this.zone_commander);
  @override
  _RadioButtonListViewState createState() =>
      _RadioButtonListViewState(zone_name, zone_commander);
}

class _RadioButtonListViewState extends State<RadioButtonListView> {
  String _currentIndex;

  List<String> zone_name = [];
  var zone_commander;
  _RadioButtonListViewState(this.zone_name, this.zone_commander);

  _addZone(zone_name, commander_name) async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();

    final snapShot1 =
        await Firestore.instance.collection('defaults').getDocuments();
    for (int i = 0; i < snapShot1.documents.length; i++) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .collection('settings')
          .document()
          .setData(snapShot1.documents[i].data);
    }

    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .updateData({'zone': zone_name, 'commander': commander_name}).then(
            (value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text("Zones"),
      ),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: zone_name.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Card(
                color: listItemColor,
                child: ListTile(
                  title: Text(zone_name[index]),
                  onTap: () {
                    _addZone(zone_name[index], zone_commander[index]);
                  },
                ),
              ),
            );
          }),
    );
  }
}
