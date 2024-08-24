import 'package:flutter/material.dart';
import 'package:offscreen_recorder/Toast/toast_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingDurationScreen extends StatefulWidget {
  @override
  _RecordingDurationScreenState createState() => _RecordingDurationScreenState();
}

class _RecordingDurationScreenState extends State<RecordingDurationScreen> {
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Switch(
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
                      Text("Auto"),
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
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
                      Text("Time limit"),
                    ],
                  ),
                  if (tempTimeLimit)
                    Column(
                      children: [
                        Text("Duration: ${tempSliderValue.toInt()} minutes"),
                        Slider(
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
      appBar: AppBar(title: Text("Recording Duration")),
      body: Center(
        child: ElevatedButton(
          onPressed: timeLine,
          child: Text("Set Recording Duration"),
        ),
      ),
    );
  }
}
