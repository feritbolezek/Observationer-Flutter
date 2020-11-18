import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../model/observation.dart';
import 'package:http/http.dart' as http;

/// This class is responsible for communication with the observations API.
class ObservationsAPI {
  final List<Observation> observations = [];
  final List<String> imageUrl = [];

  /// Fetches all observations from the database.
  ///
  /// Returns a list of Observations sometime in the future.
  Future<List<Observation>> fetchObservations() async {
    //Get all observations
    var data = await http
        .get('https://saabstudent2020.azurewebsites.net/observation/');

    if (data.statusCode == 200) {
      var jsonData = json.decode(data.body);

      for (int i = jsonData.length - 1; i >= 0; i--) {
        //If the observation has image(s)
        Observation obs = Observation(
            id: jsonData[i]['id'],
            subject: jsonData[i]['subject'],
            body: jsonData[i]['body'],
            created: jsonData[i]['created'],
            longitude: jsonData[i]['position']['longitude'],
            latitude: jsonData[i]['position']['latitude'],
            imageUrl: ['']);

        observations.add(obs);
      }
      return observations;
    } else {
      throw Exception('Failed to load observations');
    }
  }

  Future<List<String>> fetchObservationImages(Observation observation) async {
    Observation obs = observation;

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

    var response = await http.post(
        'https://saabstudent2020.azurewebsites.net/observation/',
        headers: headers,
        body: payload);

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
  }

  Future<Response> delete(String id) async {
    final http.Response response = await http.delete(
      'https://saabstudent2020.azurewebsites.net/observation/$id',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return response;
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
