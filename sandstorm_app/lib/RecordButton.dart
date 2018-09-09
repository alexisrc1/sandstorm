import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sandstorm_app/Server.dart';
import 'package:sandstorm_app/Sound.dart';
import 'package:simple_permissions/simple_permissions.dart';

class RecordButton extends StatefulWidget {
  RecordButton({Key key}) : super(key: key);

  @override
  _RecordButtonState createState() => new _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const SIZE = 150.0;
  bool _isRecording = false;
  bool _isWaiting = false;
  CurrentMicrophoneRecording _currentRecording;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isWaiting) {
      // Avoid starting a new recording when one is started already
      return;
    }

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

    try {
      var recording = await CurrentMicrophoneRecording.start();
      setState(() {
        _currentRecording = recording;
        _isRecording = true;
      });
    } on Exception catch (e) {
      _showError("Unable to start recording: $e");
      _setRecordingState(false);
    }
  }

  void _setRecordingState(bool isRecording) {
    setState(() {
      _isRecording = isRecording;
    });
  }

  T _waitFor<T>(Future<T> f) {
    setState(() {
      _isWaiting = true;
    });
    f.whenComplete(() {
      setState(() {
        _isWaiting = false;
      });
    });
  }

  Future<void> _stopRecording() async {
    if (_currentRecording == null || _isWaiting) {
      print("Cannot stop recording");
      return;
    }
    _currentRecording.stop();
    _setRecordingState(false);

    try {
      _showSuccess("Sending the recording...");
      await Server.uploadFile(_currentRecording.file);
      _showSuccess("The recording was sent.");
    } catch (e) {
      _showError("Unable to send the recording: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Container(
        margin: EdgeInsets.all(SIZE / 10),
        width: SIZE,
        height: SIZE,
        child: new Icon(
          getCurrentIcon(),
          size: SIZE / 4,
        ),
        decoration: new BoxDecoration(
            color: getCurrentColor(),
            borderRadius: new BorderRadius.circular(200.0)),
      ),
      onTapDown: (e) => _waitFor(_startRecording()),
      onTapUp: (e) => _waitFor(_stopRecording()),
    );
  }

  Color getCurrentColor() =>
      _isRecording ? Colors.red : _isWaiting ? Colors.purple : Colors.green;

  IconData getCurrentIcon() => _isRecording
      ? Icons.stop
      : _isWaiting ? Icons.watch_later : Icons.play_arrow;

  void _showError(String message) {
    _showMessage(message, Colors.red);
  }

  void _showSuccess(String message) {
    _showMessage(message, Colors.green);
  }

  void _showMessage(String message, Color color) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(message),
      backgroundColor: color,
    ));
  }
}
