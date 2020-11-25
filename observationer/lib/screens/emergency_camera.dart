import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'add_observation.dart';

class EmergencyCamera extends StatefulWidget {
  @override
  _EmergencyCamera createState() => _EmergencyCamera();
}

class _EmergencyCamera extends State<EmergencyCamera> {
  final picker = ImagePicker();

  getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => AddObservation.xd(position, pickedFile.path)));

  }

  @override
  Widget build(BuildContext context) {

   getImage();
    return Scaffold(

      body: Center(
        child: CircularProgressIndicator()

      ),

    );
  }
}
