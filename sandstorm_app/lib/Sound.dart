import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';

FlutterSound flutterSound = new FlutterSound();

class CurrentMicrophoneRecording {
  static CurrentMicrophoneRecording _recording;

  final String _filepath;

  CurrentMicrophoneRecording._internal(this._filepath);

  static Future<CurrentMicrophoneRecording> start() async {
    if (_recording != null)
      throw new Exception("Cannot create two concurrent recordings");
    flutterSound.setSubscriptionDuration(0.01);
    var filepath = await flutterSound.startRecorder(null);
    return CurrentMicrophoneRecording._internal(filepath);
  }

  File get file => new File(this._filepath);

  stop() async {
    var retMsg = await flutterSound.stopRecorder();
    print(retMsg);
    _recording = null;
  }
}
