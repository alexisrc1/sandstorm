import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RecordButton extends StatefulWidget {
  RecordButton({Key key}) : super(key: key);

  @override
  _RecordButtonState createState() => new _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;

  void _startRecording() async {
    var permitted = await AudioRecorder.hasPermissions;
    if (!permitted) {
      _showError("No permission to access your microphone");
      return;
    }

    try {
      await AudioRecorder.start(
          path: "mon_enregistrement", audioOutputFormat: AudioOutputFormat.AAC);
    } on Exception catch (e) {
      _showError(e.toString());
    }
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    var recording = await AudioRecorder.isRecording;
    if (recording) {
      await AudioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } else {
      _showError("Not currently recording");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new GestureDetector(
      child: new Container(
        width: 200.0,
        height: 200.0,
        child: new Icon(
          _isRecording ? Icons.stop : Icons.play_arrow,
          size: 50.0,
        ),
        decoration: new BoxDecoration(
            color: _isRecording ? Colors.red : Colors.green,
            borderRadius: new BorderRadius.circular(200.0)),
      ),
      onTapDown: (e) => _startRecording(),
      onTapUp: (e) => _stopRecording(),
    );
  }

  void _showError(String message) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
