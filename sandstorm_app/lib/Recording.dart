Uri BASE_URI = Uri.parse("http://192.168.42.43:5000/static/recordings/");

class Recording {
  String name;
  int time;

  Recording(this.name, this.time);

  Uri get uri => BASE_URI.resolve(name);

  DateTime get date => new DateTime.fromMicrosecondsSinceEpoch(time ~/ 1000);
}
