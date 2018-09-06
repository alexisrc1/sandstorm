import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:sandstorm_app/Recording.dart';
import 'package:sandstorm_app/RecordingWidget.dart';
import 'package:sandstorm_app/Server.dart';

class RecordingsList extends StatefulWidget {
  RecordingsList({Key key}) : super(key: key);

  @override
  _RecordingsListState createState() => new _RecordingsListState();
}

class _RecordingsListState extends State<RecordingsList> {
  List<Recording> _recordings = [];
  bool _refreshing = false;
  String _errorMessage;

  StreamSubscription<Recording> _recordingsSubscribtion;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      this._refreshing = true;
      this._errorMessage = null;
    });
    await Future.delayed(Duration(seconds: 1));
    await this._recordingsSubscribtion?.cancel();
    _recordings.clear();
    this._recordingsSubscribtion = Server.getRecordings().listen((recording) {
      print(recording);
      setState(() {
        _recordings.add(recording);
      });
    });
    this._recordingsSubscribtion.onError((err) {
      setState(() {
        this._errorMessage = "$err";
        this._refreshing = false;
      });
    });
    this._recordingsSubscribtion.onDone(() {
      setState(() {
        this._refreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this._refreshing) {
      return buildLoading();
    } else if (this._errorMessage != null) {
      return buildError(this._errorMessage);
    } else if (this._recordings.isEmpty) {
      return buildEmpty();
    }
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

  Widget buildLoading() {
    return Column(
      children: <Widget>[
        IconButton(icon: Icon(Icons.cloud_download), onPressed: _refresh),
        Text("Loading...")
      ],
    );
  }

  Widget buildError(String errorMessage) {
    return Column(
      children: <Widget>[
        IconButton(
            iconSize: 70.0,
            tooltip: errorMessage,
            icon: Icon(Icons.error),
            color: Colors.red,
            onPressed: _refresh),
        Text("An error occured while fetching the latest recordings"),
        Text(errorMessage)
      ],
    );
  }

  Widget buildEmpty() {
    return Column(
      children: <Widget>[
        IconButton(
            iconSize: 70.0, icon: Icon(Icons.close), onPressed: _refresh),
        Text("No recordings yet... Make your own !")
      ],
    );
  }
}
