import 'dart:async';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_permissions/simple_permissions.dart';

class RecordButton extends StatefulWidget {
  RecordButton({Key key}) : super(key: key);

  @override
  _RecordButtonState createState() => new _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
  }

  void _startRecording() async {
    var permitted =
        await SimplePermissions.checkPermission(Permission.RecordAudio) &&
            await SimplePermissions.checkPermission(
                Permission.WriteExternalStorage);

    if (!permitted) {
      _showError("The app is not authorized to record...");
      await Future.delayed(Duration(seconds: 2));
      SimplePermissions.openSettings();
      return;
    }

    var now = DateTime.now().toIso8601String();
    try {
      var res = await flutterSound.startRecorder(null);
      _showError(res);
      setState(() {
        _isRecording = true;
      });
    } on Exception catch (e) {
      _showError("Unable to start recording: $e");
    }
  }

  void _stopRecording() async {
    var res = await flutterSound.stopRecorder();
    _showError("$res");
    setState(() {
      _isRecording = false;
    });
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
