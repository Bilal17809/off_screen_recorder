import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../Button/main_screen_button.dart';
import '../Short Note/short_note.dart';

class MainScreenSetting extends StatefulWidget {
  const MainScreenSetting({super.key});

  @override
  State<MainScreenSetting> createState() => _MainScreenSettingState();
}

class _MainScreenSettingState extends State<MainScreenSetting> {
  /*
  share App link function
  */
  void _shareApp() {
    final appLink = 'https://banckgroundcamera.com';
    final shareMessage = 'offscreen recording: $appLink';
    Share.share(shareMessage);
  }

  void _showDialog(){
    showDialog(context: context, builder:(context){
      return const AlertDialog(
        title: Text("Internal Storage"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Path: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
            Text("/DCIM/ExceedVideo/",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17)),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title:const Padding(
          padding: EdgeInsets.all(8.0),
          child:  Text(
            'App Setting',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MainAppButton(text: 'Share Link', ontap:_shareApp, icons:Icons.share),
          SizedBox(height: 20,),
          MainAppButton(text: 'Rate Us', ontap: () {  }, icons:Icons.star_rate),
          SizedBox(height: 20,),
          MainAppButton(text: 'Short Notes', ontap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShortNotes()));
          }, icons:Icons.note_add),
          SizedBox(height: 20,),
          MainAppButton(text: 'Video Path', ontap:_showDialog, icons:Icons.video_call_outlined),
        ],
      ),
    );
  }
}
