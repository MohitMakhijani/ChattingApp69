
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class toast{

  void toastmsg(String msg){
    Fluttertoast.showToast(
        msg: msg,
    backgroundColor: Colors.orange,fontSize: 15,
    toastLength: Toast.LENGTH_SHORT,
    textColor: Colors.black,
        gravity: ToastGravity.BOTTOM
    );

  }
}