import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sandstorm_app/Recording.dart';

class Server {
  static const String _BASE = "http://192.168.42.43:5000/";
  static final Uri _baseUri = Uri.parse(_BASE);
  static final Uri _uploadUri = _baseUri.resolve("upload");
  static final Uri _recordingsUri = _baseUri.resolve("recordings");
  static final Uri _staticRecordingsUri =
      _baseUri.resolve("static/recordings/");

  static Future<Object> uploadFile(File file) async {
    var bytesStream = file.openRead();
    var fileSize = file.statSync().size;

    var request = new http.MultipartRequest("POST", _uploadUri);
    var mediaType = new MediaType("audio", "mp4");
    var multipartFile = http.MultipartFile("recording", bytesStream, fileSize,
        filename: "recording.m4a", contentType: mediaType);
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode != 200)
      throw "Server error: ${response.reasonPhrase}";

    var responseObject = await response.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .first;
    // TODO parse the response
    return responseObject;
  }

  static Stream<Recording> getRecordings() {
    print("Making a request to $_recordingsUri");
    return http.Request("GET", _recordingsUri)
        .send()
        .asStream()
        .asyncExpand((response) {
          if (response.statusCode != 200) {
            throw new Exception(response.reasonPhrase);
          } else
            return response.stream;
        })
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map(json.decode)
        .map((obj) => Recording.fromJson(obj));
  }

  static Uri getRecordingUri(Recording recording) =>
      _staticRecordingsUri.resolve(recording.name);
}
