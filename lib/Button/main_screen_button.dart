import 'package:flutter/material.dart';

class ScreenButton extends StatefulWidget {
  String? text;
  final icons;
  final VoidCallback ontap;
  ScreenButton({super.key,
    required this.text,
    required this.icons,
    required this.ontap
  });

  @override
  State<ScreenButton> createState() => _ScreenButtonState();
}

class _ScreenButtonState extends State<ScreenButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:40),
        child: Center(
          child: Container(
            // height: 80,
            // width: MediaQuery.of(context).size.width*.7,
            // width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lightGreen.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icons,size: 52,color: Colors.white,),
                  const SizedBox(width: 18,),
                  Expanded(child: Text("${widget.text}",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
   This is button inside the
   main App setting for all button
*/

class MainAppButton extends StatefulWidget {
  String? text;
  final VoidCallback ontap;
  final icons;
   MainAppButton({super.key,
    required this.text,
    required this.ontap,
     required this.icons
  });

  @override
  State<MainAppButton> createState() => _MainAppButtonState();
}

class _MainAppButtonState extends State<MainAppButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: GestureDetector(
        onTap: widget.ontap,
        child: Center(
          child: Container(
            // height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lightGreen.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(widget.icons,size: 35,color: Colors.white,),
                  SizedBox(width: 25,),
                  Expanded(child: Text("${widget.text}",style: const TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
