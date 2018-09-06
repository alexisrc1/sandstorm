import 'package:sandstorm_app/Server.dart';

Uri BASE_URI = Uri.parse("http://192.168.42.43:5000/static/recordings/");

class Recording {
  String name;
  int time;

  Recording(this.name, this.time);

  Uri get uri => Server.getRecordingUri(this);

  DateTime get date => new DateTime.fromMicrosecondsSinceEpoch(time ~/ 1000);

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(json['name'], json['time']);
  }
}
