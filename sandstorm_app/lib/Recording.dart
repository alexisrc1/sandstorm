import 'package:sandstorm_app/Server.dart';

Uri BASE_URI = Uri.parse("http://192.168.42.43:5000/static/recordings/");

class Recording {
  String name;
  int timestamp;

  Recording({this.name, this.timestamp});

  Uri get uri => Server.getRecordingUri(this);

  DateTime get date =>
      new DateTime.fromMillisecondsSinceEpoch(timestamp);

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(name: json['name'], timestamp: json['timestamp']);
  }
}
