// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Toast/toast_msg.dart';
//
// class CameraQualityScreen extends StatefulWidget {
//   const CameraQualityScreen({super.key});
//
//   @override
//   State<CameraQualityScreen> createState() => _CameraQualityScreenState();
// }
//
// class _CameraQualityScreenState extends State<CameraQualityScreen> {
//
//   /*
//   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//   below functions use for quality of video
//   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//  */
//   int _selectedQuality = 2;
//   List<String> mylist=['240P','480P','720P','1080P'];
//   _videoquality() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     // showDialog(
//     //   context: context,
//     //   builder: (context) {
//     //     return AlertDialog(
//     //       title: Text('Choose Video Quality '),
//     //       content: Column(
//     //         mainAxisSize: MainAxisSize.min,
//     //         children: <Widget>[
//     //           buildQualityRadioTile(0, mylist[0]),
//     //           buildQualityRadioTile(1, mylist[1]),
//     //           buildQualityRadioTile(2, mylist[2]),
//     //           buildQualityRadioTile(3, mylist[3]),
//     //           // buildQualityRadioTile(0, '240P'),
//     //           // buildQualityRadioTile(1, '480P'),
//     //           // buildQualityRadioTile(2, '720P'),
//     //           // buildQualityRadioTile(3, '1080P'),
//     //         ],
//     //       ),
//     //     );
//     //   },
//     // );
//   }
//   ListTile buildQualityRadioTile(int value, String title) {
//     return ListTile(
//       title: Text(title),
//       leading: Radio(
//         value: value,
//         groupValue: _selectedQuality,
//         onChanged: (newValue) {
//           setState(() {
//             _selectedQuality = newValue as int;
//           });
//           Navigator.of(context).pop();
//           _saveQualityValue(_selectedQuality); // Save selected value
//           toastMsg.myToast("You select: ${mylist[value]}");
//         },
//       ),
//     );
//   }
//   _saveQualityValue(int value) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('selectedQuality', value);
//   }
//   /*
//   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//   below function it for Switch the camera
//   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//   */
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text("Choose Video Quality",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               buildQualityRadioTile(0, mylist[0]),
//               buildQualityRadioTile(1, mylist[1]),
//               buildQualityRadioTile(2, mylist[2]),
//               buildQualityRadioTile(3, mylist[3]),
//               // buildQualityRadioTile(0, '240P'),
//               // buildQualityRadioTile(1, '480P'),
//               // buildQualityRadioTile(2, '720P'),
//               // buildQualityRadioTile(3, '1080P'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

//*********************%%%%%%%%%%%%%%%%%%%%%%%%%%%*************************
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Toast/toast_msg.dart';

class CameraQualityScreen extends StatefulWidget {
  const CameraQualityScreen({super.key});

  @override
  State<CameraQualityScreen> createState() => _CameraQualityScreenState();
}

class _CameraQualityScreenState extends State<CameraQualityScreen> {
  int _selectedQuality = 4;
  List<String> mylist = ['4k','2k','1080P', '720P','480P','240P'];

  @override
  void initState() {
    super.initState();
    _getQualityValue();
    // _videoquality();
  }

  _getQualityValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedQuality = prefs.getInt('selectedQuality') ?? 2;
    });
  }

  // _videoquality() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _selectedQuality = prefs.getInt('selectedQuality') ?? 2; // Default value if not found
  //   });
  //   Toast1.show(context,"You select: ${mylist[_selectedQuality]}");
  // }

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
          'Choose video quality',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 70),
        child: Column(
          children: [
            for (int i = 0; i < mylist.length; i++)
              buildQualityRadioTile(i, mylist[i]),
          ],
        ),
      ),
    );
  }

  Padding buildQualityRadioTile(int value, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: Container(
        height: 63,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _selectedQuality==value? Colors.green.shade100 :Colors.grey.shade300
        ),
        child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("${title}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              ),
              Radio(
                activeColor: Colors.green,
                value: value,
                groupValue: _selectedQuality,
                onChanged: (newValue) async {
                  setState(() {
                    _selectedQuality = newValue as int;
                  });
                  await _saveQualityValue(_selectedQuality);
                  Toast1.show(context,"You select: ${mylist[value]}");
                },
              ),
            ],
          ),
        )
      ),
    );
  }

  Future<void> _saveQualityValue(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedQuality', value);
  }
}
