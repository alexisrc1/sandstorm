import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class Server {
  static const String _BASE = "http://192.168.42.43:5000/";
  static final Uri _baseUri = Uri.parse(_BASE);
  static final Uri _uploadUri = _baseUri.resolve("upload");

  static uploadFile(File file) async {
    var bytesStream = file.openRead();
    var fileSize = file.statSync().size;

    var request = new MultipartRequest("POST", _uploadUri);
    var mediaType = new MediaType("audio", "mp4");
    var multipartFile = MultipartFile("recording", bytesStream, fileSize,
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
}
