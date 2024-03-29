import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WarningMessages {
  static void success(BuildContext context, String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
        timeInSecForIosWeb: 1);
  }

  static void error(BuildContext context, String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
        timeInSecForIosWeb: 1);
  }
}
