import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchCameraScreen extends StatefulWidget {
  const SwitchCameraScreen({super.key});

  @override
  State<SwitchCameraScreen> createState() => _SwitchCameraScreenState();
}

class _SwitchCameraScreenState extends State<SwitchCameraScreen> {
  late CameraController _cameraController;
  CameraLensDirection? selectedCameraDirection;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  void _initializeCameraController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
    setState(() {});
  }

  Future<void> _switchCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();
    if (cameras.length < 2) {
      print('Only one camera available. Cannot switch.');
      return;
    }
    _toggleCamera(cameras, direction);
    _saveSelectedCameraDirection(direction);
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

  void _toggleCamera(List<CameraDescription> cameras, CameraLensDirection desiredDirection) async {
    final currentCameraIndex = cameras.indexWhere((camera) => camera.lensDirection == desiredDirection);
    if (currentCameraIndex == -1) {
      print('Selected camera not found.');
      return;
    }

    final newCameraDescription = cameras[currentCameraIndex];

    print('Switching to camera: ${newCameraDescription.name}');

    await _cameraController.dispose();
    _cameraController = CameraController(
      newCameraDescription,
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
    final newCameraDirection = newCameraDescription.lensDirection;
    print('Switched to ${_getCameraDirectionText(newCameraDirection)}');
    setState(() {
      Toast1.show(context, "Camera switch: ${_getCameraDirectionText(newCameraDirection)}");
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Camera switch: ${_getCameraDirectionText(newCameraDirection)}")));
    });
  }

  String _getCameraDirectionText(CameraLensDirection direction) {
    return direction == CameraLensDirection.front ? 'Front Camera' : 'Back Camera';
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
          'Camera switch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: FutureBuilder<CameraLensDirection?>(
          future: _getSelectedCameraDirection(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            CameraLensDirection? selectedCameraDirection = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 55),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 88,
                        width: 70,
                        decoration: BoxDecoration(
                          color: selectedCameraDirection ==CameraLensDirection.front?Colors.green:Colors.grey,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: IconButton(
                          onPressed: () => _switchCamera(CameraLensDirection.front),
                          icon: Icon(Icons.camera_front, size: 55,
                            color: selectedCameraDirection==CameraLensDirection.front?Colors.white:Colors.black,),
                        ),
                      ),
                      SizedBox(height: 15,),
                      const Text("Front Camera",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    ],
                  ),
                  SizedBox(width: 55),
                  Column(
                    children: [
                      Container(
                          height: 88,
                          width: 70,
                          decoration: BoxDecoration(
                              color:selectedCameraDirection==CameraLensDirection.back?Colors.green:Colors.grey,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        child: IconButton(
                          onPressed: () => _switchCamera(CameraLensDirection.back),
                          icon: Icon(Icons.camera_rear, size: 55,
                            color:selectedCameraDirection==CameraLensDirection.back?Colors.white:Colors.black,),
                        ),
                      ),
                      SizedBox(height: 15,),
                      const Text("Back Camera",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
