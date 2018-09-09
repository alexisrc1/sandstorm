import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sandstorm_app/Recording.dart';
import 'package:sandstorm_app/Server.dart';
import 'package:sandstorm_app/Sound.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecordingWidget extends StatelessWidget {
  final Recording _recording;
  static const num HEIGHT = 60.0;

  RecordingWidget(this._recording);

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key(this._recording.name),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          iconSize: HEIGHT,
          alignment: Alignment.center,
          icon: Icon(
            Icons.play_circle_outline,
            color: Colors.blue,
            semanticLabel: "play the recording",
            size: HEIGHT,
          ),
          onPressed: () => Player.play(Server.getRecordingUri(_recording.name)),
        ),
        new Expanded(
          child: Text(
            timeago.format(_recording.date),
            style: TextStyle(fontSize: HEIGHT / 2),
          ),
        )
      ],
    );
  }
}
