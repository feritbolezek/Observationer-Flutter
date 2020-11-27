import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:observationer/model/observation.dart';
import 'package:path_provider/path_provider.dart';
import 'file_name.dart';

class LocalFileManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/observations/${UniqueKey().toString()}.txt')
        .create(recursive: true);
  }

  Future<void> saveObservationLocally(Observation observation) async {
    final file = await _localFile;

    // Write the file.

    String data = await _FormatText(observation);

    return file.writeAsString('$data');
  }

  Future<String> readLocalObservations(String id) async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return null;
    }
  }

  Future<List<Observation>> readAllLocalObservations() async {
    final path = await _localPath;
    var dir = new Directory('$path/observations/');
    List<Observation> observations = [];

    List obs = dir.listSync();
    for (var file in obs) {
      // could be directory (shouldn't be though)
      if (file is File) {
        List<String> contents = await file.readAsLines();

        observations.add(extractToObservation(contents, file.name));
      }
    }
    return observations;
  }

  /// Takes a string and converts it to an observation.
  Observation extractToObservation(List<String> lines, String localId) {
    String subject = lines[0].substring("subject:".length);
    String desc = lines[1].substring("body:".length);
    String created = lines[2].substring("created:".length);
    double longitude = double.parse(lines[3].substring("longitude:".length));
    double latitude = double.parse(lines[4].substring("latitude:".length));
    List<String> b64Images = [];

    if (lines.length > 5) {
      for (int i = 5; i < lines.length; i++) {
        b64Images.add(lines[i].substring("image:".length));
      }
    }

    return Observation(
        subject: subject,
        body: desc,
        created: created,
        longitude: longitude,
        latitude: latitude,
        imageUrl: b64Images,
        local: true,
        localId: localId);
  }

  Future<String> _FormatText(Observation observation) async {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("subject:");
    stringBuffer.write(observation.subject == null ? "" : observation.subject);
    stringBuffer.write("\n");
    stringBuffer.write("body:");
    stringBuffer.write(observation.body == null ? "" : observation.body);
    stringBuffer.write("\n");
    stringBuffer.write("created:");
    stringBuffer.write(observation.created == null ? "" : observation.created);
    stringBuffer.write("\n");
    stringBuffer.write("longitude:");
    stringBuffer
        .write(observation.longitude == null ? "" : observation.longitude);
    stringBuffer.write("\n");
    stringBuffer.write("latitude:");
    stringBuffer
        .write(observation.latitude == null ? "" : observation.latitude);
    stringBuffer.write("\n");

    if (observation.imageUrl != null && observation.imageUrl.isNotEmpty) {
      final b64EncodedImgs = await getInBase64(observation.imageUrl);

      for (String img in b64EncodedImgs) {
        stringBuffer.write("image:");
        stringBuffer.write(img);
        stringBuffer.write("\n");
      }
    }
    return stringBuffer.toString();
  }

  static Future<List<String>> getInBase64(List<String> images) async {
    List<String> payloads = [];
    for (String path in images) {
      List<int> imageBytes = await File(path).readAsBytes();
      String b64 = base64Encode(imageBytes);
      payloads.add(b64);
    }
    return payloads;
  }
}
