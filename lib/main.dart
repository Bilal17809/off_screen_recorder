import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Audio_recording/audio_recording.dart';
import 'Button/main_screen_button.dart';
import 'MainScreen_Setting/main_screen_setting.dart';
import 'Screen_recording/main_screen_recording_screen.dart';
import 'camera_main_screen.dart';
import 'notification_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (context) => RecordingAudioState(context)),
        ChangeNotifierProvider(create: (context) => RecordingState(context)),
        ChangeNotifierProvider(create: (context) =>  RecorderService()),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(
  //     ChangeNotifierProvider(
  //       create: (context) => RecordingState(),
  //       child: const MyApp(),
  //     ));
}
// @pragma("vm:entry-point")
// void overlayMain() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: TrueCallerOverlay(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (conttext)=>MainScreenSetting()));
            }, icon: Icon(Icons.settings,size: 45,color: Colors.lightGreen,)),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScreenButton(text: 'Off screen recording', icons:Icons.video_call, ontap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>  CameraPage())
                    );
            },),
            const SizedBox(height: 25),
            ScreenButton(text: 'Audio recording', icons:Icons.audiotrack_outlined, ontap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>  RecorderExample())
              );
            },),
            // this is audio recording
            const SizedBox(height: 25),
            ScreenButton(text: 'Screen recording', icons:Icons.screen_lock_landscape_rounded, ontap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ScreenRecording())
              );
            },),
            // this is screen recording
          ],
        ),
      ),
    );
  }
}

