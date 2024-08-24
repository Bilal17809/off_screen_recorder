import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});
  @override
  State<FolderScreen> createState() => _FolderScreenState();
}
class _FolderScreenState extends State<FolderScreen> {
  List<FileSystemEntity> _files = [];
  List<bool> SelectedAudio = [];
  List<bool> PlayingAudio = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  _loadFiles() async {
    Directory? appDir = await getExternalStorageDirectory();
    if (appDir != null) {
      String videoDirPath = '${appDir.path}/Movies/MyAudio';
      Directory videoDir = Directory(videoDirPath);
      List<FileSystemEntity> files = videoDir.listSync();
      setState(() {
        _files = files;
        SelectedAudio = List<bool>.filled(_files.length, false);
        PlayingAudio = List<bool>.filled(_files.length, false);
      });
    }
  }

  void _toggleSelection(int index) {
    if (index >= 0 && index < SelectedAudio.length) {
      setState(() {
        SelectedAudio[index] = !SelectedAudio[index];
      });
    }
  }

  void _playPauseAudio(int index) async {
    if (PlayingAudio[index]) {
      await _audioPlayer.stop();
      setState(() {
        PlayingAudio[index] = false;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(_files[index].path));
      setState(() {
        PlayingAudio = List<bool>.filled(_files.length, false);
        PlayingAudio[index] = true;
      });
    }
  }

  Timer? _timer;

  void _showDeleteOption() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete the Audios"),
          content: Text("Are you sure to delete this?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteSelectedMedia();
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteSelectedMedia() async {
    List<FileSystemEntity> selectFile = [];
    for (int i = 0; i < _files.length; i++) {
      if (SelectedAudio[i]) {
        selectFile.add(_files[i]);
      }
    }
    for (var file in selectFile) {
      try {
        await file.delete();
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      _files.removeWhere((file) => selectFile.contains(file));
      SelectedAudio = List<bool>.filled(_files.length, false);
      PlayingAudio = List<bool>.filled(_files.length, false);
    });
  }

  bool multiDelete = false;

  void _editFileName(int index) {
    // Implement editing file name logic here
    // You can use a dialog or text field for user input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = _files[index].path.split('/').last;
        return AlertDialog(
          title: Text("Edit File Name"),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter new file name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the rename operation
                String newPath = _files[index].parent.path + '/' + newName;
                _files[index].renameSync(newPath);
                Navigator.of(context).pop();
                setState(() {
                  _loadFiles(); // Reload files after rename
                });
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _shareFile(FileSystemEntity file) {
    // Implement sharing logic here
    // Example using share package
    // Replace with actual sharing implementation
    // You may need to adjust based on how you want to share
    // For simplicity, sharing the file path
    // shareFile(file.path);
    print('Shared: ${file.path}');
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
        title:  const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Audio Files',style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold),),
        ),
        actions: [
          if (multiDelete)
            IconButton(
              onPressed: _showDeleteOption,
              icon: Icon(Icons.delete, color: Colors.white, size: 30),
            )
        ],
      ),
      body: _files.isEmpty
          ? const Center(child: Text('No audio files found'))
          : Padding(
            padding: const EdgeInsets.symmetric(vertical: 35,horizontal: 8),
            child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
            FileSystemEntity file = _files[index];
            return GestureDetector(
              onLongPress: () {
                setState(() {
                  multiDelete = !multiDelete;
                  if (!multiDelete) {
                    SelectedAudio = List<bool>.filled(_files.length, false);
                  }
                });
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height:75,
                            width: 75,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: IconButton(
                              icon: Icon(PlayingAudio[index]?Icons.stop:Icons.play_arrow,size: 55,color: Colors.white,),
                              onPressed: () {
                                _playPauseAudio(index);
                              },
                            ),
                          ),
                          SizedBox(width: 8,),
                          Text(file.path.split('/').last),
                          SizedBox(width: 12,),
                          PopupMenuButton<String>(
                            iconSize: 30,
                            onSelected: (String result) {
                              if (result == 'edit') {
                                _editFileName(index);
                              } else if (result == 'share') {
                                _shareFile(file);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit Name'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (multiDelete)
                    Positioned(
                      left: 3,
                      child: Checkbox(
                        activeColor: Colors.green,
                        value: SelectedAudio[index],
                        onChanged: (value) {
                          setState(() {
                            SelectedAudio[index] = value!;
                          });
                        },
                      ),
                    ),
                ],
              ),
            );
                    },
                  ),
          ),
    );
  }
}









// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';
// class FolderScreen extends StatefulWidget {
//   @override
//   _FolderScreenState createState() => _FolderScreenState();
// }
// class _FolderScreenState extends State<FolderScreen> {
//   List<FileSystemEntity> _files = [];
//   List<bool> SelectedAudio = [];
//   List<bool> PlayingAudio = [];
//   AudioPlayer _audioPlayer = AudioPlayer();
//   Timer? _timer;
//   Duration _audioDuration = Duration.zero;
//   @override
//   void initState() {
//     super.initState();
//     _loadFiles();
//     _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
//       if (state == PlayerState.stopped) {
//         setState(() {
//           _audioDuration = Duration.zero; // Reset the duration when stopped
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   _loadFiles() async {
//     Directory? appDir = await getExternalStorageDirectory();
//     if (appDir != null) {
//       String videoDirPath = '${appDir.path}/Movies/MyVideos';
//       Directory videoDir = Directory(videoDirPath);
//       List<FileSystemEntity> files = videoDir.listSync();
//       setState(() {
//         _files = files;
//         SelectedAudio = List<bool>.filled(_files.length, false);
//         PlayingAudio = List<bool>.filled(_files.length, false);
//       });
//     }
//   }
//
//   void _toggleSelection(int index) {
//     if (index >= 0 && index < SelectedAudio.length) {
//       setState(() {
//         SelectedAudio[index] = !SelectedAudio[index];
//       });
//     }
//   }
//
//   void _playPauseAudio(int index) {
//     if (PlayingAudio[index]) {
//       _audioPlayer.stop();
//       setState(() {
//         PlayingAudio[index] = false;
//       });
//     } else {
//       _showPlaybackDialog(index);
//       setState(() {
//         PlayingAudio = List<bool>.filled(_files.length, false);
//         PlayingAudio[index] = true;
//       });
//     }
//   }
//
//   void _showPlaybackDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             double? _sliderValue = 0.0;
//
//             // Inside your state class
//             void _startUpdatingSlider() {
//               _timer = Timer.periodic(Duration(milliseconds: 500), (Timer timer) async {
//                 if (_audioPlayer.state == PlayerState.playing) {
//                   try {
//                     final position = await _audioPlayer.getCurrentPosition();
//                     setState(() {
//                       _sliderValue = position?.inSeconds as double;
//                     });
//                   } catch (e) {
//                     // Handle any errors here
//                     print("#####################Error getting position: $e");
//                   }
//                 } else {
//                   // Stop the timer if playback is not in progress
//                   timer.cancel();
//                 }
//               });
//             }
//
//             void _playAudio() async {
//               await _audioPlayer.play(DeviceFileSource(_files[index].path));
//               _audioDuration = await _audioPlayer.getDuration() ?? Duration.zero;
//               _startUpdatingSlider();
//             }
//
//             void _stopAudio() async {
//               await _audioPlayer.stop();
//               _timer?.cancel();
//               setState(() {
//                 _sliderValue = 0.0;
//               });
//             }
//
//             return AlertDialog(
//               title: Text("Playback Controls"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.play_arrow),
//                         onPressed: _playAudio,
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.stop),
//                         onPressed: _stopAudio,
//                       ),
//                     ],
//                   ),
//                   Slider(
//                     value: _sliderValue??0,
//                     max: _audioDuration.inSeconds.toDouble(),
//                     onChanged: (value) {
//                       setState(() {
//                         _sliderValue = value;
//                         _audioPlayer.seek(Duration(seconds: value.toInt()));
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text("Close"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> deleteSelectedMedia() async {
//     List<FileSystemEntity> selectFile = [];
//     for (int i = 0; i < _files.length; i++) {
//       if (SelectedAudio[i]) {
//         selectFile.add(_files[i]);
//       }
//     }
//     for (var file in selectFile) {
//       try {
//         await file.delete();
//       } catch (e) {
//         print(e);
//       }
//     }
//     setState(() {
//       _files.removeWhere((file) => selectFile.contains(file));
//       SelectedAudio = List<bool>.filled(_files.length, false);
//       PlayingAudio = List<bool>.filled(_files.length, false);
//     });
//   }
//
//   bool multiDelete = false;
//
//   void _editFileName(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         String newName = _files[index].path.split('/').last;
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             onChanged: (value) {
//               newName = value;
//             },
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 String newPath = _files[index].parent.path + '/' + newName;
//                 _files[index].renameSync(newPath);
//                 Navigator.of(context).pop();
//                 setState(() {
//                   _loadFiles();
//                 });
//               },
//               child: Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _shareFile(FileSystemEntity file) {
//     print('Shared: ${file.path}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               stops: [0.0, 0.5, 1.0],
//               colors: [
//                 Colors.green,
//                 Colors.lightGreen,
//                 Colors.lightGreen.shade400,
//               ],
//             ),
//           ),
//         ),
//         toolbarHeight: 88,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(
//             'Audio Files',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         actions: [
//           if (multiDelete)
//             IconButton(
//               onPressed: _showDeleteOption,
//               icon: const Icon(Icons.delete, color: Colors.white, size: 30),
//             ),
//         ],
//       ),
//       body: _files.isEmpty
//           ? const Center(child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image(image: AssetImage("assests/file.png",),height: 80,width: 120,),
//           SizedBox(height: 12,),
//           Text("No audio recording")
//         ],
//       ))
//           : Padding(
//         padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
//         child: ListView.builder(
//           itemCount: _files.length,
//           itemBuilder: (context, index) {
//             FileSystemEntity file = _files[index];
//             return GestureDetector(
//               onTap:(){
//                 _playPauseAudio(index);
//               },
//               onLongPress: () {
//                 setState(() {
//                   multiDelete = !multiDelete;
//                   if (!multiDelete) {
//                     SelectedAudio = List<bool>.filled(_files.length, false);
//                   }
//                 });
//               },
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             height: 65,
//                             width: 75,
//                             decoration: BoxDecoration(
//                               color: Colors.lightGreen,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                                 Icons.audiotrack,
//                                 // PlayingAudio[index] ? Icons.stop : Icons.play_arrow,
//                                 size: 50,
//                                 color: Colors.white,
//                               ),
//                           ),
//                           SizedBox(width: 8),
//                           Text(file.path.split('/').last),
//                           SizedBox(width: 12),
//                           PopupMenuButton<String>(
//                             iconSize: 30,
//                             onSelected: (String result) {
//                               if (result == 'edit') {
//                                 _editFileName(index);
//                               } else if (result == 'share') {
//                                 _shareFile(file);
//                               }
//                             },
//                             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                               const PopupMenuItem<String>(
//                                 value: 'edit',
//                                 child: ListTile(
//                                   leading: Icon(Icons.edit),
//                                   title: Text('Edit Name'),
//                                 ),
//                               ),
//                               const PopupMenuItem<String>(
//                                 value: 'share',
//                                 child: ListTile(
//                                   leading: Icon(Icons.share),
//                                   title: Text('Share'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   if (multiDelete)
//                     Positioned(
//                       left: 3,
//                       child: Checkbox(
//                         activeColor: Colors.green,
//                         value: SelectedAudio[index],
//                         onChanged: (value) {
//                           setState(() {
//                             SelectedAudio[index] = value!;
//                           });
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteOption() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Delete the Audios"),
//           content: Text("Are you sure to delete this?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteSelectedMedia();
//                 Navigator.of(context).pop();
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

