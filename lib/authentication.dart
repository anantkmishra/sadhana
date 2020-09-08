import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:habbittracker/Colors.dart';
import 'package:habbittracker/chooseZones.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:habbittracker/NewUser.dart';
import 'package:habbittracker/main.dart';
import 'package:image_picker/image_picker.dart';
import 'Colors.dart';
import 'home.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Account.dart';
import 'TextStyle.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final email = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  final confpassword = TextEditingController();
  bool _passwordvalidate = false;
  bool _emailvalidate = false;
  bool _namevalidate = false;
  bool _confypassvalidate = false;
  ProgressDialog progressDialog;
  String errorMessage = '';

  var imageFile;

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('images/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void initState() {
    getImageFileFromAssets('account.png').then((value) {
      imageFile = value;
    });
  }

  _signUp() async {
    progressDialog.show();
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) async {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        var uid = user.uid;
        StorageTaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child("images/$uid")
            .putFile(imageFile)
            .onComplete;

        final String downloadUrl = await snapshot.ref.getDownloadURL();

        Map<String, Object> data = <String, Object>{
          'UUID': user.uid,
          'email': email.text,
          'name': name.text,
          'profile_pic': downloadUrl,
          'Monitors': [],
        };

        await Firestore.instance
            .collection('Users')
            .document()
            .setData(data)
            .then((value) {
          progressDialog.hide();
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChooseZones()));
        });
      });
    } catch (e) {
      setState(() {
        progressDialog.hide();
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
    );
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 60, 0.0, 40),
                    color: primaryColor,
                    height: 250,
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Register Now !',
                      style: BigText(),
                    ),
                  ),
                ],
              ),
              Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  margin: const EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50,),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 60.0, 15.0, 0.0),
                        child: Container(
                            height: 50,
                            width: 300,
                            child: TextField(
                                cursorColor: primaryColor,
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                                controller: email,
                                decoration: InputDecoration(
                                    focusColor: Colors.white,
                                    hintStyle: TextStyle(
                                        fontSize: 20, color: primaryColor),
                                    hintText: 'Email',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    errorText: _emailvalidate
                                        ? 'Email cannot be empty'
                                        : null),
                                onChanged: (value) {
                                  setState(() {
                                    _emailvalidate = false;
                                  });
                                })),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                        child: Container(
                            height: 50,
                            width: 300,
                            child: TextField(
                                cursorColor: primaryColor,
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                                controller: name,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: 20, color: primaryColor),
                                    hintText: 'Name',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    errorText: _namevalidate
                                        ? 'Name cannot be empty'
                                        : null),
                                onChanged: (value) {
                                  setState(() {
                                    _namevalidate = false;
                                  });
                                })),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                        child: Container(
                            height: 50,
                            width: 300,
                            child: TextField(
                              cursorColor: primaryColor,
                              style:
                                  TextStyle(fontSize: 20, color: primaryColor),
                              controller: password,
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                hintStyle: TextStyle(
                                    fontSize: 20, color: primaryColor),
                                hintText: 'Password',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                errorText: _passwordvalidate
                                    ? 'Password cannot be empty'
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _passwordvalidate = false;
                                });
                              },
                              obscureText: true,
                            )),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                        child: Container(
                            height: 50,
                            width: 300,
                            child: TextField(
                                cursorColor: primaryColor,
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                                controller: confpassword,
                                decoration: InputDecoration(
                                    focusColor: Colors.white,
                                    hintStyle: TextStyle(
                                        fontSize: 20, color: primaryColor),
                                    hintText: 'Confirm Password',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    errorText: _confypassvalidate
                                        ? 'Passwords not matching'
                                        : null),
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    _confypassvalidate = false;
                                  });
                                })),
                      ),
                      SizedBox(height: 30,),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 150,
                                height: 40,
                                child: RaisedButton(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20,
                                        letterSpacing: 1.0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  color: Hexcolor('#7C3DCA'),
                                  onPressed: () {
                                    if (email.text.isEmpty) {
                                      setState(() {
                                        _emailvalidate = true;
                                      });
                                    } else if (name.text.isEmpty) {
                                      setState(() {
                                        _namevalidate = true;
                                      });
                                    } else if (password.text.isEmpty) {
                                      setState(() {
                                        _passwordvalidate = true;
                                      });
                                    } else if (password.text ==
                                        confpassword.text) {
                                      _signUp();
                                    } else {
                                      setState(() {
                                        _confypassvalidate = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 20.0, 15.0, 0.0),
                                child: FlatButton(
                                    child: Text(
                                      'Already Registered? Login',
                                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    }),
                              ),
                              Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.fill),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool _emailvalidate = false;
  bool _passwordvalidate = false;
  String errorMessage = '';
  ProgressDialog progressDialog;

  _signIn() async {
    await progressDialog.show();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) {
        progressDialog.hide();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home(0)));
      });
    } catch (e) {
      setState(() {
        progressDialog.hide();
        errorMessage = e.message;
      });
    }
  }

  _resetPassword() async {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: forgotEmail.text)
        .then((value) {
      Toast.show('Reset Link sent to your Email', context, duration: 3);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    });
  }

  var forgotEmail = TextEditingController();

  Future<dynamic> _resetPasswordDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              child: SimpleDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            //autofocus: true,
                            cursorColor: Colors.grey,
                            style: TextStyle(fontSize: 20, color: primaryColor),
                            controller: forgotEmail,
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              fillColor: Colors.white,
                              hintStyle:
                                  TextStyle(fontSize: 20, color: primaryColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Email',
                              suffixIcon: Icon(Icons.edit, color: primaryColor,)
                            ),
                          ),
                        ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      OutlineButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        borderSide: BorderSide(style: BorderStyle.solid, color: primaryColor, width: 3.0),
                        child: Text("Cancel", style: TextStyle(color: primaryColor)),
                        onPressed:() => Navigator.pop(context),
                      ),
                      FlatButton(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Text("Submit", style: TextStyle(color: primaryColor1)),
                        onPressed: () { _resetPassword(); },
                      ),
                      ],
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      isDismissible: false,
      type: ProgressDialogType.Normal,
    );
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 60, 0.0, 40),
                  color: primaryColor,
                  alignment: Alignment.bottomCenter,
                  height: 250,
                  child: Text(
                    'Welcome Back !',
                    style: BigText(),
                  ),
                ),
              ],
            ),
            Stack(children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 200,
                    margin: const EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(
                        color: containerColor,
                        boxShadow: [
                          new BoxShadow(
                            color: primaryColor,
                            spreadRadius: 3,
                            blurRadius: 3,
                          )
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 40.0, 15.0, 0.0),
                              child: Container(
                                  height: 50,
                                  width: 300,
                                  child: TextField(
                                      autofocus: false,
                                      cursorColor: primaryColor,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20, color: primaryColor),
                                      controller: email,
                                      decoration: InputDecoration(
                                          focusColor: Colors.white,
                                          hintStyle: TextStyle(
                                              fontSize: 20,
                                              color: primaryColor),
                                          hintText: 'Email',
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: primaryColor),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: primaryColor),
                                          ),
                                          errorText: _emailvalidate
                                              ? 'Email cannot be empty'
                                              : null),
                                      onChanged: (value) {
                                        setState(() {
                                          _emailvalidate = false;
                                        });
                                      })),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                15.0, 20.0, 15.0, 0.0),
                            child: Container(
                                height: 50,
                                width: 300,
                                child: TextField(
                                  autofocus: false,
                                  cursorColor: primaryColor,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: primaryColor),
                                  controller: password,
                                  decoration: InputDecoration(
                                    focusColor: primaryColor,
                                    fillColor: primaryColor,
                                    hintStyle: TextStyle(
                                        fontSize: 20, color: primaryColor),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    hintText: 'Password',
                                    errorText: _passwordvalidate
                                        ? 'Password cannot be empty'
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _passwordvalidate = false;
                                    });
                                  },
                                  obscureText: true,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                15.0, 80.0, 15.0, 0.0),
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: 150,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                            letterSpacing: 1.0,
                                            color: Colors.white,
                                            fontSize: 20),
                                      ),
                                      color: Hexcolor('#7C3DCA'),
                                      onPressed: () {
                                        if (email.text.isEmpty) {
                                          setState(() {
                                            _emailvalidate = true;
                                          });
                                        } else if (password.text.isEmpty) {
                                          setState(() {
                                            _passwordvalidate = true;
                                          });
                                        } else {
                                          setState(() {
                                            _signIn();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Text(
                                    errorMessage,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: primaryColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12
                                      ),
                                    ),
                                    onPressed: () {
                                      _resetPasswordDialog();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Create New Account',
                                      style: TextStyle(color: primaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Register()));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0.0,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: AssetImage('images/logo.png'),
                          fit: BoxFit.fill),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
