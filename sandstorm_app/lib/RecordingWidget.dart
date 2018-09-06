import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sandstorm_app/Recording.dart';

class RecordingWidget extends StatelessWidget {
  final Recording _recording;

  RecordingWidget(this._recording);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.play_circle_outline,
          color: Colors.blue,
          semanticLabel: "play the recording",
          size: 70.0,
        ),
        new Expanded(
          child: Text(this._recording.name, style: TextStyle(fontSize: 30.0),),
        )
      ],
    );
  }
}
