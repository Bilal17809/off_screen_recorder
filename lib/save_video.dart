import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class SavedMediaPage extends StatefulWidget {
  @override
  _SavedMediaPageState createState() => _SavedMediaPageState();
}
class _SavedMediaPageState extends State<SavedMediaPage> {
  // store video in this list...
  List<FileSystemEntity> savedMedia = [];
  // store the thumbail path here...
  Map<int, String> thumbnailPaths = {};
  TextEditingController renameController = TextEditingController();
  // store select video for delete...
  List<bool> selectedMedia = [];
  bool isInMultiSelectMode = false;
  Map<int, String> videoInfo = {};
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadSavedMedia();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Padding(
          padding:  EdgeInsets.all(10.0),
          child:  Text('Video recording',style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold),),
        ),
        actions: <Widget>[
          if (isInMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmationDialog,
            ),
        ],
      ),
      body: savedMedia.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 6),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: savedMedia.length,
          itemBuilder: (context, index) {
            final videoFile = savedMedia[index] as File;
            final thumbnailPath = thumbnailPaths[index];
            final isThumbnailLoaded = thumbnailPath != null;
            final videoInformation = videoInfo[index] ?? 'Loading...';

            return GestureDetector(
              onLongPress: () {
                setState(() {
                  isInMultiSelectMode = !isInMultiSelectMode;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isInMultiSelectMode) {
                          _toggleSelection(index);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoPlayerScreen(videoFile.path),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 100,
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:  isInMultiSelectMode && selectedMedia[index]
                                    ? Colors.green
                                    :null,
                              ),
                              child: isThumbnailLoaded
                                  ? Image.file(
                                File(thumbnailPath!),
                                fit: BoxFit.cover,
                              )
                                  : const SizedBox(
                                width: 74,
                                height: 100,
                                child: Center(
                                    child: LinearProgressIndicator()),
                              ),
                            ),
                            SizedBox(width: 12,),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(videoFile.path.split('/').last,style: TextStyle(fontSize: 16),),
                                    const SizedBox(height: 15,),
                                    Text(videoInformation),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (isInMultiSelectMode)
                      Positioned(
                        child: Checkbox(
                          activeColor: Colors.green,
                          value: selectedMedia[index],
                          onChanged: (value) {
                            setState(() {
                              selectedMedia[index] = value!;
                            });
                          },
                        ),
                      ),
                    const Positioned(
                        top: 22,
                        left: 18,
                        child: Icon(Icons.play_arrow,color: Colors.white,size: 55,)),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : Center(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage("assests/file.png",),height: 80,width: 120,),
              SizedBox(height: 12,),
              Text("No videos recording")
            ],
          )),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       flexibleSpace: Container(
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             stops: [0.0, 0.5, 1.0],
  //             colors: [
  //               Colors.green,
  //               Colors.lightGreen,
  //               Colors.lightGreen.shade400,
  //             ],
  //           ),
  //         ),
  //       ),
  //       toolbarHeight: 88,
  //       automaticallyImplyLeading: false,
  //       iconTheme: IconThemeData(color: Colors.white),
  //       title: const Padding(
  //         padding: EdgeInsets.all(8.0),
  //         child:  Text('All Saved Videos',style: TextStyle(color: Colors.white,
  //             fontWeight: FontWeight.bold),),
  //       ),
  //       actions: <Widget>[
  //         if (isInMultiSelectMode)
  //           IconButton(
  //             icon: const Icon(Icons.delete),
  //             onPressed: _showDeleteConfirmationDialog,
  //           ),
  //       ],
  //     ),
  //     body: savedMedia.isNotEmpty
  //         ? ListView.builder(
  //       controller: _scrollController,
  //       itemCount: savedMedia.length,
  //       itemBuilder: (context, index) {
  //         final videoFile = savedMedia[index] as File;
  //         final thumbnailPath = thumbnailPaths[index];
  //         final isThumbnailLoaded = thumbnailPath != null;
  //         final videoInformation = videoInfo[index] ?? 'Loading...';
  //
  //         return GestureDetector(
  //           onLongPress: () {
  //             setState(() {
  //               isInMultiSelectMode = !isInMultiSelectMode;
  //             });
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Card(
  //               child: Stack(
  //                 children: [
  //                   ListTile(
  //                     leading: isThumbnailLoaded
  //                         ? Image.file(
  //                       File(thumbnailPath!),
  //                       width: 88,
  //                       height: 100,
  //                       fit: BoxFit.cover,
  //                     )
  //                         : const SizedBox(
  //                       width: 74,
  //                       height: 100,
  //                       child: Center(
  //                           child: LinearProgressIndicator()),
  //                     ),
  //                     title: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Text(videoFile.path.split('/').last),
  //                     ),
  //                     subtitle: Padding(
  //                       padding: const EdgeInsets.only(left: 8),
  //                       child: Text(videoInformation),
  //                     ),
  //                     onTap: () {
  //                       if (isInMultiSelectMode) {
  //                         _toggleSelection(index);
  //                       } else {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) =>
  //                                 VideoPlayerScreen(videoFile.path),
  //                           ),
  //                         );
  //                       }
  //                     },
  //                     tileColor: isInMultiSelectMode && selectedMedia[index]
  //                         ? Colors.grey.shade200
  //                         : null,
  //                   ),
  //                   if (isInMultiSelectMode)
  //                     Positioned(
  //                       top: 8,
  //                       left: 8,
  //                       child: Checkbox(
  //                         value: selectedMedia[index],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedMedia[index] = value!;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     )
  //         : const Center(child: Text("Empty")),
  //   );
  // }

  /*
   load the videos
  first laod only videos
  */
  Future<void> _loadSavedMedia() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final videoDir = Directory('${directory.path}/Movies/MyVideos');
        final files = videoDir.listSync();
        savedMedia = files
            .where((entity) => entity is File && entity.path.endsWith('.mp4'))
            .toList();
        selectedMedia = List<bool>.filled(savedMedia.length, false);
        setState(() {}); // Update UI to show loaded videos

        // Load thumbnails and video info after videos are loaded
        _loadAllThumbnailsAndVideoInfo();
      }
    } catch (e) {
      print('Error loading saved media: $e');
    }
  }


  /*
   load the thumbail
  second laod only thumbail
  */
  Future<void> _loadAllThumbnailsAndVideoInfo() async {
    List<Future<void>> futures = [];

    for (int i = 0; i < savedMedia.length; i++) {
      if (!thumbnailPaths.containsKey(i)) {
        futures.add(_generateThumbnailAndVideoInfo(i));
      }
    }

    await Future.wait(futures);
    setState(() {}); // Update UI to show loaded thumbnails and video info
  }

  Future<void> _generateThumbnailAndVideoInfo(int index) async {
    try {
      final videoPath = savedMedia[index].path;
      print('Generating thumbnail and fetching video info for $videoPath');
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 40,
        quality: 20,
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .create();
      await file.writeAsBytes(uint8list!);

      setState(() {
        thumbnailPaths[index] = file.path;
      });

      final videoFile = savedMedia[index] as File;
      VideoPlayerController controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      Duration duration = controller.value.duration;
      int fileSize = await videoFile.length();
      double fileSizeInKB = fileSize / 1024;
      double fileSizeInMB = fileSizeInKB / 1024;
      String durationFormatted = _formatDuration(duration);
      String fileSizeInMBFormatted = fileSizeInMB.toStringAsFixed(2);
      await controller.dispose();

      setState(() {
        videoInfo[index] =
        '$durationFormatted    $fileSizeInMBFormatted MB';
      });

      print('##### thumbnail and video info generated for $videoPath');
    } catch (e) {
      print('##### error generating thumbnail or fetching video info: $e');
      setState(() {
        videoInfo[index] = '### unknown Duration    Unknown Size';
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n >= 10 ? "$n" : "0$n";
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _toggleSelection(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      try {
        setState(() {
          selectedMedia[index] = !selectedMedia[index];
        });
      } catch (e) {
        print('Error toggling selection: $e');
      }
    } else {
      print('Invalid index for selection: $index');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Media'),
          content: const Text('Do you want to delete the selected media files?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedMedia();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelectedMedia() async {
    List<FileSystemEntity> selectedFiles = [];
    for (int i = 0; i < savedMedia.length; i++) {
      if (selectedMedia[i]) {
        selectedFiles.add(savedMedia[i]);
      }
    }

    for (var file in selectedFiles) {
      try {
        await file.delete();
      } catch (e) {
        print('Error deleting media file: $e');
      }
    }

    setState(() {
      savedMedia.removeWhere((file) => selectedFiles.contains(file));
      selectedMedia = List<bool>.filled(savedMedia.length, false);
      _loadAllThumbnailsAndVideoInfo();
    });
  }
}





/*
This class for Display video......................
*/

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen(this.videoPath);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isPlaying = false;
  Timer? _rewindTimer;
  Timer? _forwardTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.addListener(() {
      setState(() {});
    });
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _seekBackward() {
    if (_rewindTimer != null && _rewindTimer!.isActive) return;
    _rewindTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _controller.seekTo(_controller.value.position - Duration(seconds: 1));
      if (_controller.value.position <= Duration(seconds: 1)) {
        _rewindTimer?.cancel();
      }
    });
  }

  void _seekForward() {
    if (_forwardTimer != null && _forwardTimer!.isActive) return;
    _forwardTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _controller.seekTo(_controller.value.position + Duration(seconds: 1));
      if (_controller.value.position >= _controller.value.duration - Duration(seconds: 1)) {
        _forwardTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rewindTimer?.cancel();
    _forwardTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: GestureDetector(
          onTap: _togglePlay,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Positioned(
                  bottom: 10.0,
                  left: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.fast_rewind),
                        color: Colors.white,
                        onPressed: () {
                          _rewindTimer?.cancel();
                          _seekBackward();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40.0,
                        ),
                        color: Colors.white,
                        onPressed: _togglePlay,
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        color: Colors.white,
                        onPressed: () {
                          _forwardTimer?.cancel();
                          _seekForward();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: VideoPlayerScreen('path_to_your_video_file'),
  ));
}
