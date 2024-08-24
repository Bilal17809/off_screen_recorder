import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:offscreen_recorder/Audio_recording/save_audio.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'package:file/local.dart';
import 'package:permission_handler/permission_handler.dart';
import '../notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class RecorderService extends ChangeNotifier {
  static final RecorderService _instance = RecorderService._internal();
  factory RecorderService() => _instance;
  RecorderService._internal();

  AnotherAudioRecorder? _recorder;
  Recording? _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  final LocalFileSystem localFileSystem = LocalFileSystem();

  RecordingStatus get currentStatus => _currentStatus;
  Recording? get current => _current;

  Future<void> init() async {
    if (await AnotherAudioRecorder.hasPermissions) {
      String customPath = '/another_audio_recorder_';
      io.Directory appDocDirectory;
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = (await getExternalStorageDirectory())!;
      }

      customPath = appDocDirectory.path + customPath + DateTime.now().millisecondsSinceEpoch.toString();
      _recorder = AnotherAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

      await _recorder?.initialized;
      _current = await _recorder?.current(channel: 0);
      _currentStatus = _current!.status!;
      notifyListeners();
    } else {
      throw Exception("You must accept permissions");
    }
  }

  Future<void> start() async {
    await _recorder?.start();
    _current = await _recorder?.current(channel: 0);
    _currentStatus = RecordingStatus.Recording;

    const tick = Duration(milliseconds: 50);
    Timer.periodic(tick, (Timer t) async {
      if (_currentStatus == RecordingStatus.Stopped) {
        t.cancel();
      }

      _current = await _recorder?.current(channel: 0);
      _currentStatus = _current!.status!;
      notifyListeners();
    });

    if (io.Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        return;
      }
    }
    await NotificationService.showAudioNotification();
  }

  Future<void> stop(BuildContext context) async {
    var result = await _recorder?.stop();
    await NotificationService.cancelNotification();
    io.File file = localFileSystem.file(result?.path);

    io.Directory? appDir = await getExternalStorageDirectory();
    if (appDir != null) {
      String videoDirPath = '${appDir.path}/Movies/MyAudio';
      io.Directory videoDir = io.Directory(videoDirPath);
      await videoDir.create(recursive: true);

      final currentTime = DateTime.now();
      final fileName = 'audio_${currentTime.millisecondsSinceEpoch}.wav';
      final filePath = '$videoDirPath/$fileName';
      Toast1.show(context, "Audio saved successfully");

      try {
        await file.rename(filePath);
        // Display success message
      } catch (e) {
        print('Error moving file: $e');
      }
    } else {
      print('Error getting external storage directory');
    }

    _current = result;
    _currentStatus = _current!.status!;
    await init();
  }
}

class RecorderExample extends StatefulWidget {
  @override
  _RecorderExampleState createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recorderService = Provider.of<RecorderService>(context, listen: false);
      if (recorderService.currentStatus == RecordingStatus.Unset) {
        recorderService.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recorderService = Provider.of<RecorderService>(context);

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
        title: const Text(
          'Audio Recording',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              icon: const Icon(Icons.folder_open_outlined,size: 35,color: Colors.white,),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FolderScreen()));
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 88),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  switch (recorderService.currentStatus) {
                    case RecordingStatus.Initialized:
                    case RecordingStatus.Stopped:
                      recorderService.start();
                      break;
                    case RecordingStatus.Recording:
                      recorderService.stop(context);
                      break;
                    default:
                      break;
                  }
                },
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 36, color: Colors.grey.shade200),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(1, 1),
                        spreadRadius: 1.0,
                        color: Colors.grey.shade400,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${_formated(recorderService.current?.duration)}",
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: TextButton(
                  onPressed: () {
                    switch (recorderService.currentStatus) {
                      case RecordingStatus.Initialized:
                      case RecordingStatus.Stopped:
                        recorderService.start();
                        break;
                      case RecordingStatus.Recording:
                        recorderService.stop(context);
                        break;
                      default:
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          recorderService.currentStatus == RecordingStatus.Recording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recorderService.currentStatus == RecordingStatus.Recording ? "Stop" : "Start",
                            style: const TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      recorderService.currentStatus == RecordingStatus.Recording ? Colors.red : Colors.lightGreen,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(10)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formated(Duration? duration) {
    if (duration == null) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
