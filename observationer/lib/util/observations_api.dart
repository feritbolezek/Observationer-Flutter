import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observationer/util/local_file_manager.dart';
import '../model/observation.dart';
import 'package:http/http.dart' as http;

/// This class is responsible for communication with the observations API.
class ObservationsAPI {
  final List<Observation> observations = [];
  final List<String> imageUrl = [];

  /// Fetches all observations from the database.
  ///
  /// Returns a list of Observations sometime in the future.
  Future<List<Observation>> fetchObservations(
      [int filter, LatLng pos, String search, void onFailure(int)]) async {
    //Get all observations

    final obs = await loadLocalObservations();

    observations.addAll(obs);

    var data = await http
        .get('https://saabstudent2020.azurewebsites.net/observation/')
        .catchError((e) {});

    if (data?.statusCode == 200) {
      var jsonData = json.decode(data.body);
      for (int i = jsonData.length - 1; i >= 0; i--) {
        //If the observation has image(s)
        Observation obs = Observation(
            id: jsonData[i]['id'],
            subject: jsonData[i]['subject'],
            body: jsonData[i]['body'],
            created: jsonData[i]['created'],
            longitude: jsonData[i]['position'] == null
                ? 0.0
                : jsonData[i]['position']['longitude'],
            latitude: jsonData[i]['position'] == null
                ? 0.0
                : jsonData[i]['position']['latitude'],
            imageUrl: [''],
            local: false);

        observations.add(obs);
      }
    } else {
      onFailure(data?.statusCode ?? 403);
      //throw Exception('Failed to load observations');
    }
    if (observations.isNotEmpty) {
      switch (filter) {
        //Sort alphabetically
        case 1:
          {
            observations.sort((a, b) =>
                a.subject.toLowerCase().compareTo(b.subject.toLowerCase()));
          }
          break;
        //Sort by date, newest first. This is the default.
        case 2:
          {
            observations.sort((a, b) =>
                DateTime.parse(formatDateForSorting(b.created)).compareTo(
                    DateTime.parse(formatDateForSorting(a.created))));
          }
          break;
        //Sort by closest distance to current GPS-position
        case 3:
          {
            if (pos != null) {
              observations.sort((a, b) => GeolocatorPlatform.instance
                  .distanceBetween(
                      pos.latitude, pos.longitude, a.latitude, a.longitude)
                  .compareTo(GeolocatorPlatform.instance.distanceBetween(
                      pos.latitude, pos.longitude, b.latitude, b.longitude)));
            }
          }
          break;
        //When you search for the name of an observation.
        case 4:
          {
            if (search != null) {
              return observations
                  .where((i) =>
                      i.subject.toLowerCase().contains(search.toLowerCase()))
                  .toList();
            }
          }
          break;
      }
    }
    return observations;
  }

  String formatDateForSorting(String created) {
    String string = created;
    String date = string.substring(0, 10);
    String time = string.substring(11, 19);
    return date + ' ' + time + 'Z';
  }

  Future<List<String>> fetchObservationImages(Observation observation) async {
    Observation obs = observation;

    if (observation.local) {
      for (String image in observation.imageUrl) imageUrl.add(image);
      return imageUrl;
    }

    var imageData = await http.get(
        'https://saabstudent2020.azurewebsites.net/observation/' +
            obs.id.toString() +
            '/attachment');
    if (imageData.statusCode == 200) {
      var jsonImageData = json.decode(imageData.body);

      if (!jsonImageData.isEmpty) {
        for (int y = 0; y < jsonImageData.length; y++) {
          imageUrl.add(
              'https://saabstudent2020.azurewebsites.net/observation/' +
                  obs.id.toString() +
                  '/attachment/' +
                  jsonImageData[y]['id'].toString() +
                  '/data');
        }
      } else {
        //Temporary fix(probably). Right now, in one_observation_page we take the imageUrl[0], so cant be empty
        imageUrl.add('');
      }
    } else {
      throw Exception('Failed to load observation image page');
    }

    return imageUrl;
  }

  Future<List<Observation>> loadLocalObservations() async {
    LocalFileManager lfm = LocalFileManager();

    List<Observation> obs = await lfm.readAllLocalObservations();
    return obs;
  }

  /// Given the required parameter [title] and [position], uploads the given observation
  /// to the database.
  ///
  /// This function will return the status code for the resulting HTTP request.
  static Future<int> uploadObservation(
      {@required String title,
      @required double latitude,
      @required double longitude,
      String description,
      List<String> images}) async {
    var payload = json.encode({
      'subject': title,
      'body': description,
      'position': {'longitude': longitude, 'latitude': latitude}
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    bool success = true;
    var response = await http
        .post('https://saabstudent2020.azurewebsites.net/observation/',
            headers: headers, body: payload)
        .catchError((error) {
      success = false;
    });

    if (!success) return 503; // Could indicate no internet connection.

    if (response.statusCode >= 300) return response.statusCode;

    int obsId = json.decode(response.body)['id'];

    if (images != null && images.isNotEmpty) {
      List<String> payloads = await getInBase64(images);
      for (String payload in payloads) {
        Map<String, String> headers = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        };

        var response = await http.post(
            'https://saabstudent2020.azurewebsites.net/observation/$obsId/attachment',
            headers: headers,
            body: payload);
      }
    }
    return response.statusCode;
  }

  static Future<int> updateObservation(
      {@required int id,
      @required String title,
      @required double latitude,
      @required double longitude,
      @required String description}) async {
    var payload = json.encode({
      'subject': title,
      'body': description,
      'position': {'longitude': longitude, 'latitude': latitude}
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var response = await http.put(
        'https://saabstudent2020.azurewebsites.net/observation/$id',
        headers: headers,
        body: payload);

    return response.statusCode;
  }

  static Future<int> deleteObservation(String id) async {
    var response = await http.delete(
      'https://saabstudent2020.azurewebsites.net/observation/$id',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return response.statusCode;
  }

  static Future<int> deleteObservationImage(Observation obs, int index) async {
    List<String> images = await ObservationsAPI().fetchObservationImages(obs);
    String imageToDelete = images[index].substring(0, images[index].length - 5);

    var response = await http.delete(
      imageToDelete,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    return response.statusCode;
  }

  static Future<int> addObservationImage(Observation obs, images) async {
    var response;
    int obsId = obs.id;

    if (images != null && images.isNotEmpty) {
      List<String> payloads = await getInBase64(images);
      for (String payload in payloads) {
        Map<String, String> headers = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        };

        response = await http.post(
            'https://saabstudent2020.azurewebsites.net/observation/$obsId/attachment',
            headers: headers,
            body: payload);
      }
    }

    return response.statusCode;
  }

  static Future<List<String>> getInBase64(List<String> images) async {
    List<String> payloads = [];
    for (String path in images) {
      List<int> imageBytes = await File(path).readAsBytes();
      String b64 = base64Encode(imageBytes);

      var imagePayload = jsonEncode({
        'description': 'empty',
        'type': 'image/jpeg',
        'data': {'type': 'image/jpeg', 'dataBase64': b64},
      });
      payloads.add(imagePayload);
    }
    return payloads;
  }
}
