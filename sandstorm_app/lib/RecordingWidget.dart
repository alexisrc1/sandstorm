import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sandstorm_app/Recording.dart';
import 'package:sandstorm_app/Server.dart';
import 'package:sandstorm_app/Sound.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecordingWidget extends StatefulWidget {
  final Recording _recording;
  static const num HEIGHT = 60.0;

  RecordingWidget(this._recording);

  @override
  RecordingWidgetState createState() {
    return new RecordingWidgetState();
  }
}

class RecordingWidgetState extends State<RecordingWidget> {
  CurrentlyPlaying _player;
  bool playing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key(this.widget._recording.name),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          iconSize: RecordingWidget.HEIGHT,
          alignment: Alignment.center,
          icon: Icon(
            Icons.play_circle_outline,
            color: Colors.blue,
            semanticLabel: "play the recording",
            size: RecordingWidget.HEIGHT,
          ),
          onPressed: _startOrStop,
        ),
        new Expanded(
          child: Text(
            timeago.format(widget._recording.date),
            style: TextStyle(fontSize: RecordingWidget.HEIGHT / 2),
          ),
        )
      ],
    );
  }

  void _startOrStop() async {
    var recordingUri = Server.getRecordingUri(widget._recording.name);
    _player = await CurrentlyPlaying.play(recordingUri);
  }
}
