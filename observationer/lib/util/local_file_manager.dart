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

  /// Given [observation] saves all the data locally on the device.
  Future<void> saveObservationLocally(Observation observation) async {
    final file = await _localFile;

    String data = await _FormatText(observation, false);

    return file.writeAsString('$data');
  }

  @Deprecated('Will probably be removed.')

  /// Given [id] reads data from the device.
  Future<String> readLocalObservations(String id) async {
    try {
      final file = await _localFile;

      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      return null;
    }
  }

  /// Reads in all the observations saved locally on the device.
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

  /// Removes the observation with [localId]
  Future<void> removeObservation(String localId) async {
    final path = await _localPath;
    await File('$path/observations/$localId.txt').delete();
  }

  /// Updates observation with data passed in with [observation]
  Future<void> updateObservation(Observation observation) async {
    final path = await _localPath;
    final file = await File('$path/observations/${observation.localId}.txt')
        .create(recursive: true);
    print("Opened file: ${file.path} and writing: ${observation.subject}");
    String data = await _FormatText(observation, true);

    print("the data: $data");

    return file.writeAsString('$data');
  }

  Future<String> _FormatText(Observation observation, bool isInBase64) async {
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
      var imgs;

      if (!isInBase64)
        imgs = await getInBase64(observation.imageUrl);
      else
        imgs = observation.imageUrl;

      for (String img in imgs) {
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
