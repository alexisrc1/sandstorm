class Recording {
  String name;
  int timestamp;

  Recording({this.name, this.timestamp});
  
  DateTime get date => new DateTime.fromMillisecondsSinceEpoch(timestamp);

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(name: json['name'], timestamp: json['timestamp']);
  }
}
