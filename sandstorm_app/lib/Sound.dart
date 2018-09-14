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

class CurrentlyPlaying {
  static CurrentlyPlaying _current;

  CurrentlyPlaying() {
    this.statusStream = flutterSound.onPlayerStateChanged;
  }

  Stream<PlayStatus> statusStream;

  Future<void> stop() async {
    print(await flutterSound.stopPlayer());
    _current = null;
  }

  static Future<CurrentlyPlaying> play(Uri soundUri) async {
    if (_current != null) _current.stop();
    print(await flutterSound.startPlayer(soundUri.toString()));
    return new CurrentlyPlaying();
  }
}
