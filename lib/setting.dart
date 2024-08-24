import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:offscreen_recorder/Button/main_screen_button.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:offscreen_recorder/save_video.dart';
import 'package:offscreen_recorder/switch_camera_screen.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera_quality_screen.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  late CameraController _cameraController;
  @override
  void dispose() {
    _cameraController.dispose(); // Dispose the camera controller
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // _initializeCameraController();
  }
  void _initializeCameraController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
  }
  Future<void> _switchCamera(BuildContext context) async {
    final cameras = await availableCameras();

    print('Available cameras: ${cameras.length}');

    if (cameras.length < 2) {
      print('Only one camera available. Cannot switch.');
      return;
    }

    CameraLensDirection? selectedCameraDirection = await _getSelectedCameraDirection(); // Retrieve selected camera direction

    // Show dialog with camera options
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Switch Camera'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text('Front Camera'),
                    leading: Radio(
                      value: CameraLensDirection.front,
                      groupValue: selectedCameraDirection,
                      onChanged: (CameraLensDirection? value) {
                        setState(() {
                          selectedCameraDirection = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCameraDirection = CameraLensDirection.front;
                      });
                    },
                  ),
                  ListTile(
                    title: Text('Back Camera'),
                    leading: Radio(
                      value: CameraLensDirection.back,
                      groupValue: selectedCameraDirection,
                      onChanged: (CameraLensDirection? value) {
                        setState(() {
                          selectedCameraDirection = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCameraDirection = CameraLensDirection.back;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if(selectedCameraDirection != null) {
                      _toggleCamera(cameras, selectedCameraDirection!, context);
                      _saveSelectedCameraDirection(selectedCameraDirection!); // Save selected camera direction
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Switch'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<CameraLensDirection?> _getSelectedCameraDirection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cameraDirection = prefs.getString('cameraDirection');
    if (cameraDirection == 'Front Camera') {
      return CameraLensDirection.front;
    } else if (cameraDirection == 'Back Camera') {
      return CameraLensDirection.back;
    }
    return null;
  }
  Future<void> _saveSelectedCameraDirection(CameraLensDirection direction) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cameraDirection', _getCameraDirectionText(direction));
  }
  void _toggleCamera(List<CameraDescription> cameras, CameraLensDirection desiredDirection, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentCameraIndex = cameras.indexWhere((camera) => camera.lensDirection == desiredDirection);
    if (currentCameraIndex == -1) {
      print('Selected camera not found.');
      return;
    }

    final newCameraDescription = cameras[currentCameraIndex];

    print('Switching to camera: ${newCameraDescription.name}');

    _cameraController.dispose();
    _cameraController = CameraController(
      newCameraDescription,
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
    final newCameraDirection = newCameraDescription.lensDirection;
    print('Switched to ${_getCameraDirectionText(newCameraDirection)}');
    setState(() async{
      await prefs.setString('cameraDirection', _getCameraDirectionText(newCameraDirection));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Camera switch: ${_getCameraDirectionText(newCameraDirection)}")));
    });
  }
  String _getCameraDirectionText(CameraLensDirection direction) {
    return direction == CameraLensDirection.front ? 'Front Camera' : 'Back Camera';
  }
// *****************************%%%%%%%%%%%%%%%%%%******************************

  /*
  set the Time for recording
  on maximum minutes the
  recording will be atop
  */

  bool auto = true;
  bool timeLimit = false;
  double _sliderValue = 1;

  void timeLine() {
    showDialog(
      context: context,
      builder: (context) {
        bool tempAuto = auto;
        bool tempTimeLimit = timeLimit;
        double tempSliderValue = _sliderValue;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Recording duration",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
              content: Container(
                width: MediaQuery.of(context).size.width*9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Switch(
                          activeColor: Colors.green,
                          thumbColor: MaterialStateColor.transparent,
                          value: tempAuto,
                          onChanged: (value) {
                            setState(() {
                              tempAuto = value;
                              if (tempAuto) {
                                tempTimeLimit = false;
                              }
                            });
                          },
                        ),
                        SizedBox(width: 12,),
                        Text("Auto",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Switch(
                          activeColor: Colors.green,
                          thumbColor: MaterialStateColor.transparent,
                          value: tempTimeLimit,
                          onChanged: (value) {
                            setState(() {
                              tempTimeLimit = value;
                              if (tempTimeLimit) {
                                tempAuto = false;
                              }
                            });
                          },
                        ),
                        SizedBox(width: 12,),
                        Text("Time limit",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17)),
                      ],
                    ),
                    // if (tempTimeLimit)
                      Column(
                        children: [
                          Text("Duration: ${tempSliderValue.toInt()} minutes"),
                          Slider(
                            activeColor: Colors.green,
                            thumbColor: Colors.green,
                            value: tempSliderValue,
                            min: 1,
                            max: 60,
                            divisions: 59,
                            label: tempSliderValue.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                tempSliderValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              auto = tempAuto;
                              timeLimit = tempTimeLimit;
                              _sliderValue = tempSliderValue;
                            });
                            saveDuration(tempAuto ? -1 : tempSliderValue.toInt());
                            Navigator.of(context).pop();
                            Toast1.show(context, "Duration set to ${tempAuto ? 'Auto' : tempSliderValue.toInt()} minutes");
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> saveDuration(int minutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recording_duration', minutes);
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
        title: const Text(
          'Video Setting',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MainAppButton(text: "Video Quality", ontap:(){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CameraQualityScreen()));
          }, icons:Icons.account_balance_wallet,),
          const SizedBox(height: 25,),
          MainAppButton(text: "Camera Switch", ontap:(){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SwitchCameraScreen()));
          }, icons:Icons.switch_camera),
          const SizedBox(height: 25,),
          MainAppButton(text: "Video Folder", ontap:(){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>SavedMediaPage(),
              ),
            );
          }, icons:Icons.folder),
          const SizedBox(height: 25,),
          MainAppButton(text: "Set Recording", ontap:timeLine, icons:Icons.timer)
        ],
      ),
    );
  }
}
