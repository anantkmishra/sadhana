import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}

SharedPreferences prefs;

saveDetailsOffline(_userName, _userEmail) async {
  prefs = await SharedPreferences.getInstance();
  prefs.setString('name', _userName);
  prefs.setString('email', _userEmail);
}
