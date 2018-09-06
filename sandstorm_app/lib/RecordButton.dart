import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:simple_permissions/simple_permissions.dart';

const UPLOAD_ENDPOINT = "http://192.168.42.43:5000/upload";

class RecordButton extends StatefulWidget {
  RecordButton({Key key}) : super(key: key);

  @override
  _RecordButtonState createState() => new _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  String _filePath;
  FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
  }

  void _startRecording() async {
    if (_isRecording) {
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
      var filepath = await flutterSound.startRecorder(null);
      _showError(filepath);
      setState(() {
        _filePath = filepath;
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

  void _stopRecording() async {
    await flutterSound.stopRecorder();
    _setRecordingState(false);

    var recordingFile = new File(_filePath);

    try {
      _showSuccess("Sending the recording...");
      await _uploadFile(recordingFile);
      _showSuccess("The recording was sent.");
    } catch (e) {
      _showError("Unable to send the recording: $e");
    }
  }

  _uploadFile(File file) async {
    var bytesStream = file.openRead();
    var fileSize = file.statSync().size;

    var request = new MultipartRequest("POST", Uri.parse(UPLOAD_ENDPOINT));
    var mediaType = new MediaType("audio", "mp4");
    var multipartFile = MultipartFile("recording", bytesStream, fileSize,
        filename: "recording.m4a", contentType: mediaType);
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode != 200)
      throw "Server error: ${response.reasonPhrase}";

    var responseObject = await response.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .first;

    return responseObject;
  }

  @override
  Widget build(BuildContext context) {
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
