// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:quiver/async.dart';
// import 'flutter_screen_recording_platform_interface.dart';
//
// // void main() => runApp(MyApp());
// //
// class ScreenRecording extends StatefulWidget {
//   @override
//   _ScreenRecordingState createState() => _ScreenRecordingState();
// }
// class _ScreenRecordingState extends State<ScreenRecording> {
//   bool recording = false;
//   int _time = 0;
//   requestPermissions() async {
//     if (await Permission.storage.request().isDenied) {
//       await Permission.storage.request();
//     }
//     if (await Permission.photos.request().isDenied) {
//       await Permission.photos.request();
//     }
//     if (await Permission.microphone.request().isDenied) {
//       await Permission.microphone.request();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     requestPermissions();
//     startTimer();
//   }
//
//   void startTimer() {
//     CountdownTimer countDownTimer = new CountdownTimer(
//       new Duration(seconds: 1000),
//       new Duration(seconds: 1),
//     );
//
//     var sub = countDownTimer.listen(null);
//     sub.onData((duration) {
//       setState(() => _time++);
//     });
//
//     sub.onDone(() {
//       print("Done");
//       sub.cancel();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Screen Recording'),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Time: $_time\n'),
//             !recording
//                 ? Center(
//               child: ElevatedButton(
//                 child: Text("Record Screen"),
//                 onPressed: () => startScreenRecord(false),
//               ),
//             ): Center(
//               child: ElevatedButton(
//                 child: Text("Stop Record"),
//                 onPressed: () => stopScreenRecord(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   startScreenRecord(bool audio) async {
//     bool start = false;
//     if (audio) {
//       start = await FlutterScreenRecordingPlatform.instance.startRecordScreenAndAudio("Title");
//     } else {
//       start = await FlutterScreenRecordingPlatform.instance.startRecordScreen("Title");
//     }
//
//     if (start) {
//       setState(() => recording = !recording);
//     }
//
//     return start;
//   }
//
//   stopScreenRecord() async {
//     String path = await FlutterScreenRecordingPlatform.instance.stopRecordScreen;
//     setState(() {
//       recording = !recording;
//     });
//     SaveScreenRecord(path, context);
//     print("#############save video");
//     // print(path);
//     // OpenFile.open(path);
//   }
//
//   // function for screen recoding save
//   Future<void> SaveScreenRecord(String screenVideoPath, BuildContext context) async{
//     try{
//       // final appDir=await getExternalStorageDirectory();
//       final screenVideoDir= Directory('/storage/emulated/0/DCIM/ScreenRecording/');
//       if(!(await screenVideoDir.exists())){
//         await screenVideoDir.create(recursive: true);
//       }
//       print("##########directory is created$screenVideoDir");
//       final currentTime=DateTime.now();
//       final fileName='ScreenRecording_${currentTime.microsecondsSinceEpoch}.mp4';
//       final filePath="${screenVideoDir.path}$fileName";
//       final copyFile=await File(screenVideoPath).copy(filePath);
//       print("################# video is save");
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("save ")));
//     }catch(e){
//       print("#############$e");
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("error to save recording")));
//     }
//
//   }
//
// }
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:circular_countdown/circular_countdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:offscreen_recorder/Button/main_screen_button.dart';
import 'package:offscreen_recorder/Screen_recording/screen_recording_video.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'flutter_screen_recording_platform_interface.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
class ScreenRecording extends StatefulWidget {
  @override
  _ScreenRecordingState createState() => _ScreenRecordingState();
}
class _ScreenRecordingState extends State<ScreenRecording> {
  bool recording = false;
  int _seconds = 0;
  Timer? _timer;

  // Start Timer
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // Stop Timer
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      setState(() {
        _seconds = 0;
      });
    }
  }

  String get formattedTime {
    int hours = _seconds ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    int seconds = _seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  requestPermissions() async {
    if (await Permission.storage.request().isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.request().isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.microphone.request().isDenied) {
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  bool record=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black45,
      appBar: AppBar(
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
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Screen Recording", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SavedVideosScreen()));
              },
                child: const Icon(Icons.folder_open_outlined,size: 35,color: Colors.white,)),
          )
        ],
      ),
      body:
      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Wrap(
      //       crossAxisAlignment: WrapCrossAlignment.center,
      //       alignment: WrapAlignment.center,
      //       spacing: 50,
      //       runSpacing: 50,
      //       children: [
      //         Visibility(
      //           visible: record,
      //           child: TimeCircularCountdown(
      //             textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
      //             diameter: 188,
      //             gapFactor: 5,
      //             strokeWidth: 100,
      //             unit: record ? CountdownUnit.second : CountdownUnit.hour,
      //             countdownTotal:5,
      //             countdownTotalColor: Colors.white,
      //             countdownCurrentColor: Colors.green,
      //             countdownRemainingColor: Colors.grey,
      //             onUpdated: (unit, remainingTime)=>print(''),
      //             onFinished: () =>startScreenRecord(true),
      //           ),
      //         )
      //       ],
      //     ),
      //         const SizedBox(height: 30,),
      //         Text(formattedTime, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      //         const SizedBox(height: 130),
      //         !recording
      //             ? Center(
      //           child: ScreenRecordingButton(
      //               ontap:(){
      //             setState(() {
      //               record=true;
      //             });
      //             // startScreenRecord(true);
      //           }, icons:Icons.play_arrow)
      //         )
      //             : Column(
      //           children: [
      //             Center(
      //               child:
      //              ScreenRecordingButton(ontap:()=> stopScreenRecord(), icons:Icons.stop)
      //             ),
      //           ],
      //         ),
      //   ],
      // ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 50,
                runSpacing: 50,
                children: [
                  TimeCircularCountdown(
                    textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
                    diameter: 188,
                    gapFactor: 5,
                    strokeWidth: 100,
                    unit: recording ? CountdownUnit.second : CountdownUnit.hour,
                    countdownTotal: 5,
                    countdownTotalColor: Colors.white,
                    countdownCurrentColor: Colors.green,
                    countdownRemainingColor: Colors.grey,
                    onUpdated: (unit, remainingTime) => print(""),
                    onFinished: () => print(''),
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              Text(formattedTime, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 100),
              !recording
                  ? Center(
                child: ScreenRecordingButton( ontap:()=>startScreenRecord(true), icons:Icons.play_arrow)
              )
                  : Column(
                children: [
                  Center(
                    child:
                   ScreenRecordingButton( ontap:()=> stopScreenRecord(), icons:Icons.stop)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  startScreenRecord(bool audio) async {
    bool start = false;
    if (audio) {
      start = await FlutterScreenRecordingPlatform.instance.startRecordScreenAndAudio("Title");
    } else {
      start = await FlutterScreenRecordingPlatform.instance.startRecordScreen("Title");
    }
    if (start) {
      setState(() => recording = true);
      startTimer();
      // Start foreground service
      FlutterForegroundTask.startService(
        notificationTitle: 'Screen Recording',
        notificationText: 'Recording in progress...',
        callback: startForegroundTask,
      );
    }
    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecordingPlatform.instance.stopRecordScreen;
    setState(() => recording = false);
    stopTimer();
    _saveVideoInBackground(path, context);
    // SaveScreenRecord(path, context);
    print("#############save video");
    FlutterForegroundTask.stopService();
  }

  // Function to save screen recording
  Future<void> _saveVideoInBackground(String videoFilePath, BuildContext context) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final videoDir = Directory('${appDir?.path}/Movies/MyScreenVideos');
      await videoDir.create(recursive: true);
      final currentTime = DateTime.now();
      final fileName = 'video_${currentTime.millisecondsSinceEpoch}.mp4';
      final filePath = '${videoDir.path}/$fileName';
      final copiedFile = await File(videoFilePath).copy(filePath);
      Toast1.show(context, "Screen saved successfully");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Video is saved at $filePath'),
      //   ),
      // );
    } catch (e) {
      print('Error saving video: $e');
    }
  }
  // Future<void> SaveScreenRecord(String screenVideoPath, BuildContext context) async {
  //   try {
  //     final screenVideoDir = Directory('/storage/emulated/0/DCIM/ScreenRecording/');
  //     if (!(await screenVideoDir.exists())) {
  //       await screenVideoDir.create(recursive: true);
  //     }
  //     print("##########directory is created$screenVideoDir");
  //     final currentTime = DateTime.now();
  //     final fileName = 'ScreenRecording_${currentTime.microsecondsSinceEpoch}.mp4';
  //     final filePath = "${screenVideoDir.path}$fileName";
  //     final copyFile = await File(screenVideoPath).copy(filePath);
  //     print("################# video is save");
  //     Toast1.show(context, "Screen recording is save");
  //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Successfully")));
  //   } catch (e) {
  //     print("#############$e");
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving recording")));
  //   }
  // }
}

// Callback for foreground service
void startForegroundTask() {
  FlutterForegroundTask.setTaskHandler(ScreenRecordingTaskHandler());
}

class ScreenRecordingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {}

  @override
  void onButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}
}


// button here..................
class ScreenRecordingButton extends StatefulWidget {
  final VoidCallback ontap;
  final icons;
  ScreenRecordingButton({super.key,
    required this.ontap,
    required this.icons
  });

  @override
  State<ScreenRecordingButton> createState() => _ScreenRecordingButtonState();
}

class _ScreenRecordingButtonState extends State<ScreenRecordingButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:40),
      child: GestureDetector(
        onTap: widget.ontap,
        child: Container(
          height: 65,
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
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icons,size: 40,color: Colors.white,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}