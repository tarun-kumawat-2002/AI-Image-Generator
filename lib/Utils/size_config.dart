import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

late MediaQueryData _mediaQueryData;
late double screenWidth;
late double screenHeight;
late double fontSize;

class SizeConfig {
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    fontSize = screenWidth * 0.8;
  }
}

void showToast(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      timeInSecForIosWeb: 1,
      textColor: Colors.black,
      fontSize: 13
  );
}

