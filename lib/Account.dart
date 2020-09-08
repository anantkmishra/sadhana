import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/Monitors.dart';
import 'package:habbittracker/Overall.dart';
import 'package:habbittracker/Requests.dart';
import 'package:habbittracker/TextStyle.dart';
import 'package:habbittracker/Templates.dart';
import 'package:habbittracker/authentication.dart';
import 'package:habbittracker/commander_users.dart';
import 'package:habbittracker/home.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:toast/toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'offlineData.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/rendering.dart';
import 'package:workmanager/workmanager.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  var name = '';
  var email = '';
  var image = '';
  var imageFile = DecorationImage(image: AssetImage('images/account.png'));
  bool commander_visible = false;

  Future _get() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('commander', isEqualTo: user.email)
        .getDocuments();
    if (snapShot1.documents.isNotEmpty) {
      setState(() {
        commander_visible = true;
      });
    }
    setState(() {
      image = snapShot.documents[0].data['profile_pic'];
      imageFile = DecorationImage(image: NetworkImage(image), fit: BoxFit.fill);
      name = snapShot.documents[0].data['name'].toString();
      email = snapShot.documents[0].data['email'].toString();
    });
  }

  _edit() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(name, email, imageFile)));
  }

  String _userName = '';
  String _userEmail = '';

  _saveDetailsOffline() async {
    prefs.setString('name', _userName);
    prefs.setString('email', _userEmail);
  }

  _getOfflineDetails() async {
    setState(() {
      name = prefs.getString('name');
      email = prefs.getString('email');
    });
  }

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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  Future _showNotificationWithSound(time) async {
    String alarmUri = await platform.invokeMethod('getAlarmUri');
    final x = UriAndroidNotificationSound(alarmUri);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        sound: x, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      Time(time.hour, time.minute, 0),
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

  Future<bool> _checkConnection() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _get().then((value) {
          _saveDetailsOffline();
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      _getOfflineDetails();
    }
  }

  Future onSelectNotification(String payload) async {
    return Home(0);
  }

  var finaldate;
  var dayepoch;

  void initState() {
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Profile"),
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 20,
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.mode_edit, color: primaryColor1, size: 30,),
            onPressed: () {
              _edit();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 25.0, 0.0, 0.0),
        decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: Center(
            child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [BoxShadow(
                      color: primaryColor,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 5.0,
                    ),]
                ),
                margin: EdgeInsets.all(30.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [BoxShadow(
                        color: primaryColor1,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 5.0,
                      ),]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        padding: EdgeInsets.fromLTRB(30.0,30.0,30.0,30.0),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, image: imageFile),
                        ),
                      ),
                      Text(name, style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      )),
                    ],
                  ),
                ),

              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        //border: Border.all(width: 5.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                        color: primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(email,
                            style: TextStyle(
                                color: primaryColor1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    //border: Border.all(width: 5.0, color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Add Monitor',
                            style: TextStyle(
                                color: primaryColor1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                      FlatButton(
                        child: Icon(
                          Icons.add,
                          color: primaryColor1,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddMonitor()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    //border: Border.all(width: 5.0, color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Monitors',
                            style: TextStyle(
                                color: primaryColor1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                      FlatButton(
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: primaryColor1,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Monitors()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    //border: Border.all(width: 5.0, color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Reminder',
                            style: TextStyle(
                                color: primaryColor1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                      FlatButton(
                        child: Icon(
                          Icons.alarm_on,
                          color: primaryColor1,
                          size: 30,
                        ),
                        onPressed: () {
                          _selectTime(context).then((time) async {
                            final user =
                                await FirebaseAuth.instance.currentUser();
                            final uid = user.uid;
                            final snapShot = await Firestore.instance
                                .collection('Users')
                                .where('UUID', isEqualTo: uid)
                                .getDocuments();
                            var cuurentTime = (DateTime.now().hour * 60 +
                                    DateTime.now().minute) *
                                60000;
                            var selectedTime =
                                (time.hour * 60 + time.minute) * 60000;
                            int diff;
                            if (cuurentTime < selectedTime) {
                              diff = selectedTime - cuurentTime;
                            } else {
                              diff = Duration(minutes: 2).inMilliseconds -
                                  selectedTime;
                            }
                            Workmanager.cancelAll();
                            Firestore.instance
                                .collection('Users')
                                .document(snapShot.documents[0].documentID)
                                .updateData({
                              'reminder_time': time.hour * 60 + time.minute,
                            }).then((value) {
                              Workmanager.registerPeriodicTask(
                                "1",
                                "simplePeriodicTask",
                                initialDelay: Duration(milliseconds: diff),
                                // When no frequency is provided the default 15 minutes is set.
                                // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
                                frequency: Duration(hours: 24),
                              );
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Visibility(
                  visible: commander_visible,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Templates & Users',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20)),
                        ),
                        FlatButton(
                          child: Icon(Icons.keyboard_arrow_right,
                              color: Hexcolor('#7C3DCA')),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UsersUnderCommander()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 40,
                  width: 150,
                  child: RaisedButton(
                    child: Text(
                      'Sign out',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Hexcolor('#7C3DCA'),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class EditProfile extends StatefulWidget {
  String name;
  String email;
  var imageFile;

  EditProfile(this.name, this.email, this.imageFile);

  @override
  _EditProfileState createState() => _EditProfileState(name, email, imageFile);
}

class _EditProfileState extends State<EditProfile> {
  var name = TextEditingController();
  var email = TextEditingController();

  String name1 = '';
  String email1 = '';

  _EditProfileState(this.name1, this.email1, this.imageFile);

  _edit() async {
    final user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('UUID', isEqualTo: uid)
        .getDocuments();
    StorageTaskSnapshot snapshot = await FirebaseStorage.instance
        .ref()
        .child("images")
        .child(uid)
        .putFile(imageFile)
        .onComplete;

    final String downloadUrl = await snapshot.ref.getDownloadURL();

    Map<String, dynamic> data = <String, dynamic>{
      'profile_pic': downloadUrl,
      'name': name.text,
      'email': email.text
    };
    Firestore.instance
        .collection('Users')
        .document(snapShot.documents[0].documentID)
        .updateData(data)
        .then((value) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(3)));
    });
  }

  void initState() {
    setState(() {
      profile_pic = imageFile;
      name.text = name1;
      email.text = email1;
    });
  }

  dynamic profile_pic;
  var imageFile;
  var storageReference;

  _uploadImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profile_pic =
          DecorationImage(image: FileImage(imageFile), fit: BoxFit.fill);
    });
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, image: profile_pic),
                        child: GestureDetector(
                          //child: Container(child: profile_pic),
                          onTap: () {
                            _uploadImage();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight + 100)),
      body: Container(
        decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: ListView(
          children: [
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
                      controller: name,
                      decoration: InputDecoration(
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'name',
                      ),
                    ),
                  )),
            ),
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
                      controller: email,
                      decoration: InputDecoration(
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'email',
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 40,
                width: 150,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                          letterSpacing: 1.0,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    color: Hexcolor('#7C3DCA'),
                    onPressed: () {
                      _edit();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMonitor extends StatefulWidget {
  @override
  _AddMonitorState createState() => _AddMonitorState();
}

class _AddMonitorState extends State<AddMonitor> {
  var email = TextEditingController();
  var text = '';

  _addMonitor() async {
    final user = await FirebaseAuth.instance.currentUser();
    final myemail = user.email;
    final snapShot = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: email.text)
        .getDocuments();
    final snapShot1 = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: myemail)
        .getDocuments();
    List monitors = snapShot1.documents[0].data['Monitors'].toList();
    String name = snapShot1.documents[0].data['name'];
    String profile_pic = snapShot1.documents[0].data['profile_pic'];
    if (monitors.contains(email.text)) {
      setState(() {
        text = 'User is already a Monitor to you';
      });
    } else if (snapShot.documents.isNotEmpty) {
      Firestore.instance
          .collection('Users')
          .document(snapShot.documents[0].documentID)
          .collection('requests')
          .document()
          .setData({
        'approval_status': 'Not yet approved',
        'email': myemail,
        'name': name,
        'profile_pic': profile_pic,
        'time_of_request': DateTime.now().millisecondsSinceEpoch ~/ 1000
      }).then((value) {
        Toast.show('Request sent', context);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home(3)));
      });
    } else {
      setState(() {
        text = 'User does not exist';
      });
    }
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                    child: Text('Add Monitor',
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
            color: containerColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 0.0),
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
                      controller: email,
                      decoration: InputDecoration(
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'email',
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 40,
                width: 150,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text(
                      'Request',
                      style: TextStyle(
                          letterSpacing: 1.0,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    color: Hexcolor('#7C3DCA'),
                    onPressed: () {
                      _addMonitor();
                    }),
              ),
            ),
            Text(text)
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height);

    path.quadraticBezierTo(
        size.width - (size.width / 3), size.height, size.width, size.height);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
