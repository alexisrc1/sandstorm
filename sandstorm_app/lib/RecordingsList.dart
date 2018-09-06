import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:sandstorm_app/Recording.dart';
import 'package:sandstorm_app/RecordingWidget.dart';

class RecordingsList extends StatefulWidget {
  RecordingsList({Key key}) : super(key: key);

  @override
  _RecordingsListState createState() => new _RecordingsListState();
}

class _RecordingsListState extends State<RecordingsList> {
  List<Recording> _recordings;

  @override
  void initState() {
    super.initState();
    _recordings = [new Recording("test", 0), new Recording("recording 2", 3)];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      padding: new EdgeInsets.all(8.0),
      itemExtent: RecordingWidget.HEIGHT,
      itemCount: _recordings.length,
      itemBuilder: (BuildContext context, int index) {
        return new RecordingWidget(_recordings[index]);
      },
    ));
  }
}
