import 'package:flutter/material.dart';
class ShortNotes extends StatefulWidget {
  const ShortNotes({super.key});

  @override
  State<ShortNotes> createState() => _ShortNotesState();
}

class _ShortNotesState extends State<ShortNotes> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
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
          ),
        ),
        toolbarHeight: 88,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Padding(
          padding:  EdgeInsets.all(8.0),
          child:  Text(
            'Recording Note',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(14.0),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical:30),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shake Video Recorder", style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 8,),
                  Text(
                    "The shake feature in the offscreen recorder allows users to trigger "
                        "actions by shaking their device. This can be used for functionalities "
                        "like starting or stopping the recording without interacting with the screen.",
                    style: TextStyle(
                      fontSize: 16,
                      wordSpacing: 1.3,
                    ),
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
              SizedBox(height: 30,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Background Video Recorder", style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 8,),
                  Text(
                    "Background services perform predefined tasks, such as recording audio,"
                        " managing timers, or sending notifications, independently of the app’s foreground state "
                        "these services continue running even if the app is closed or "
                        "in the background, maintaining their functionality without user interaction.",
                    style: TextStyle(
                      fontSize: 16,
                      wordSpacing: 1.3,
                    ),
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
              SizedBox(height: 30,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Where is Recorder Videos Saved?", style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 8,),
                  Text(
                    "Videos are Saved in save video folder in App and path for Video in Internal "
                        "Storage is 'DCIM/ExceedVideos' Folder.",
                    style: TextStyle(
                      fontSize: 16,
                      wordSpacing: 1.3,
                    ),
                    textAlign: TextAlign.justify,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
