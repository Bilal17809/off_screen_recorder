import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:offscreen_recorder/setting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:vibration/vibration.dart';
import '../../notification_service.dart';
import 'package:flutter/services.dart';
class RecordingState extends ChangeNotifier {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _recordingTimer;
  bool _handshakeEnabled = false;
  ShakeDetector? _shakeDetector;
  bool _canShakeStartRecording = true;

  RecordingState(BuildContext context) {
    _initializeCamera();
    _initShakeDetector(context);
  }

  void _initShakeDetector(BuildContext context) {
    _shakeDetector = ShakeDetector.autoStart(
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
      onPhoneShake: () {
        if (_handshakeEnabled && _canShakeStartRecording) {
          toggleRecording(context);
          _setShakeCooldown();
        }
      },
    );
  }

  void _toggleHandshake() {
    double accelerationMagnitude = _calculateAccelerationMagnitude();
    final double shakeThreshold = 12.0;
    _handshakeEnabled = !_handshakeEnabled;
    notifyListeners();
    if (_handshakeEnabled && accelerationMagnitude > shakeThreshold) {
      Vibration.vibrate(duration: 3000);
    }
  }

  void _setShakeCooldown() {
    _canShakeStartRecording = false;
    notifyListeners();
    Future.delayed(Duration(seconds: 2), () {
      _canShakeStartRecording = true;
      notifyListeners();
    });
  }

  final double shakeThreshold = 22.0;
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  double mySqrt(double x) {
    if (x == 0) return 0.0;
    double guess = x / 2.0;
    double threshold = 0.00001;
    while ((guess * guess - x).abs() > threshold) {
      guess = (guess + x / guess) / 2.0;
    }
    return guess;
  }

  double _calculateAccelerationMagnitude() {
    double squaredSum = _accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ;
    return mySqrt(squaredSum);
  }

  String get elapsedFormattedTime {
    final int milliseconds = _stopwatch.elapsedMilliseconds;
    final int seconds = (milliseconds / 1000).truncate();
    final int minutes = (seconds / 60).truncate();
    final int hours = (minutes / 60).truncate();

    final String hoursStr = (hours % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  Future<void> _initializeCamera() async {
    final selectedCamera = await _getSelectedCamera();
    final selectedQuality = await _getSelectedQuality();
    await CameraControllerManager.initialize(selectedCamera, selectedQuality);
    notifyListeners();
  }

  Future<void> _disposeCamera() async {
    await CameraControllerManager.dispose();
  }

  Future<void> toggleRecording(BuildContext context) async {
    if (CameraControllerManager.cameraController == null || !CameraControllerManager.cameraController!.value.isInitialized) {
      await _initializeCamera();
    }

    if (_handshakeEnabled && _canShakeStartRecording) {
      if (_isRecording) {
        await _stopAndSaveVideo(context);
      } else {
        _startRecordingTimer(context);
        await _startRecording(context);
      }
      _setShakeCooldown();
    } else {
      if (_isRecording) {
        await _stopAndSaveVideo(context);
      } else {
        _startRecordingTimer(context);
        await _startRecording(context);
      }
    }
    notifyListeners();
  }

  void _startRecordingTimer(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int duration = prefs.getInt('recording_duration') ?? -1;

    _stopwatch.reset();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      notifyListeners();
    });
    _stopwatch.start();

    if (duration > 0) {
      _recordingTimer = Timer(Duration(minutes: duration), () {
        if (_isRecording) {
          _stopAndSaveVideo(context);
        }
      });
    }
  }

  Future<void> _startRecording(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? selectedCameraDirection = prefs.getString('cameraDirection');
    final int? selectedQuality = prefs.getInt('selectedQuality');

    CameraDescription selectedCamera;
    if (selectedCameraDirection == 'Front Camera') {
      selectedCamera = (await availableCameras()).firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      selectedCamera = (await availableCameras()).firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    await CameraControllerManager.initialize(selectedCamera, ResolutionPreset.values[selectedQuality ?? 2]);

    if (CameraControllerManager.cameraController != null && CameraControllerManager.cameraController!.value.isInitialized) {
      await CameraControllerManager.cameraController!.prepareForVideoRecording();
      await CameraControllerManager.cameraController!.startVideoRecording();
      if (_handshakeEnabled) {
        Vibration.vibrate(duration: 500);
      }
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        if (status.isDenied) {
          return;
        }
      }
      await NotificationService.showNotification();
      _isRecording = true;
    }
  }

  Future<void> _stopAndSaveVideo(BuildContext context) async {
    if (_isRecording && CameraControllerManager.cameraController != null && CameraControllerManager.cameraController!.value.isInitialized) {
      try {
        final XFile videoFile = await CameraControllerManager.cameraController!.stopVideoRecording();
        _isRecording = false;
        _stopwatch.stop();
        _timer?.cancel();
        _recordingTimer?.cancel();
        _stopwatch.reset();
        await NotificationService.cancelNotification();
        await _saveVideoInBackground(videoFile.path, context);
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveVideoInBackground(String videoFilePath, BuildContext context) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final videoDir = Directory('${appDir?.path}/Movies/MyVideos');
      await videoDir.create(recursive: true);
      final currentTime = DateTime.now();
      final fileName = 'video_${currentTime.millisecondsSinceEpoch}.mp4';
      final filePath = '${videoDir.path}/$fileName';
      final copiedFile = await File(videoFilePath).copy(filePath);
      Toast1.show(context, "Video saved successfully");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Video is saved at $filePath'),
      //   ),
      // );
    } catch (e) {
      print('Error saving video: $e');
    }
  }

  Future<CameraDescription> _getSelectedCamera() async {
    final cameras = await availableCameras();
    final prefs = await SharedPreferences.getInstance();
    final selectedCameraDirection = prefs.getString('cameraDirection') ?? 'CameraLensDirection.back';

    return cameras.firstWhere(
          (camera) => camera.lensDirection.toString() == selectedCameraDirection,
      orElse: () => cameras.first,
    );
  }

  Future<ResolutionPreset> _getSelectedQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedQuality = prefs.getInt('selectedQuality') ?? 2;
    return ResolutionPreset.values[selectedQuality];
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _disposeCamera();
    super.dispose();
  }
}
class CameraControllerManager {
  static CameraController? cameraController;

  static Future<void> initialize(CameraDescription cameraDescription, ResolutionPreset resolutionPreset) async {
    cameraController = CameraController(cameraDescription, resolutionPreset);
    await cameraController!.initialize();
  }

  static Future<void> dispose() async {
    await cameraController?.dispose();
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecordingState>(
        builder: (context, recordingState, _) => _buildRecordingView(context, recordingState),
      ),
    );
  }

  Widget _buildRecordingView(BuildContext context, RecordingState recordingState) {
    return Scaffold(
      key: GlobalKey(),
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
          'Video Recording',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: (){
                  recordingState.isRecording?
                 Toast1.show(context,"No setting change during recording")
                      :
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            }, icon: const Icon(Icons.settings,color: Colors.white,size: 35,)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10.0),
            Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Shake",style: TextStyle(fontWeight: FontWeight.bold),),
                              const SizedBox(width: 7,),
                              Switch(
                                activeColor: Colors.green,
                                thumbColor:  MaterialStateProperty.all(Colors.black45),
                                value: recordingState._handshakeEnabled,
                                onChanged: (value) {
                                  recordingState._toggleHandshake();
                                  // Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                      ),
                      // SizedBox(height: 135),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 65),
                        child: GestureDetector(
                          onTap: () {
                            recordingState.toggleRecording(context);
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
                                  offset: const Offset(1, 1),
                                  spreadRadius: 1.0,
                                  color: Colors.grey.shade400,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                recordingState.elapsedFormattedTime,
                                style: const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 88.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: TextButton(
                onPressed: () {
                  recordingState.toggleRecording(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        recordingState.isRecording ? Icons.stop : Icons.video_camera_back,
                        color: Colors.white,
                        size: 30,
                      ),
                       const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recordingState.isRecording ? 'Stop' : 'Start',
                          style:  TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    recordingState.isRecording ? Colors.red : Colors.lightGreen.shade400,
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
    );
  }
}

