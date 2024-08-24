import 'dart:async';
import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
  final String message;

  CustomToast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          margin: EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class Toast1 {
  static void show(BuildContext context, String message, {int duration = 2}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: CustomToast(message: message),
      ),
    );

    overlay?.insert(overlayEntry);

    Timer(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }
}

