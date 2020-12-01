import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'emergency_camera.dart';
import 'map_view.dart';
import 'observations_page.dart';

/// The starting page of the application.
class StartingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Background_observations.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: StartingPageBody(),
        ),
      ),
    );
  }
}

class StartingPageBody extends StatelessWidget {
  String s = "";
  Position pos = null;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: <Widget>[
          Spacer(
            flex: 5,
          ),
          Image(
            image: AssetImage('assets/images/obs_icon.png'),
            width: 120.0,
          ),
          Text(
            'Observationer',
            style: TextStyle(
                color: Color(0xFF6ACEF0),
                fontSize: 26.0,
                fontWeight: FontWeight.bold),
          ),
          Spacer(flex: 6),
          Material(
              type: MaterialType
                  .transparency, //Makes it usable on any background color, thanks @IanSmith
              child: Ink(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigoAccent, width: 4.0),
                  color: Colors.indigo[700],
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  //This keeps the splash effect within the circle
                  borderRadius: BorderRadius.circular(
                      1000.0), //Something large to ensure a circle
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmergencyCamera()))
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add_a_photo,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
          Spacer(flex: 6),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Välkommen till Observationer!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
          new ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 63, vertical: 15),
              textStyle: TextStyle(
                fontSize: 20.0,
              ),
            ),
            child: new Text('Till kartvyn'),
            onPressed: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MapView()))
            },
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(height: 1, color: Colors.white60),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Text(
                      'ELLER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(height: 1, color: Colors.white60),
                ),
              ],
            ),
          ),
          Spacer(),
          new ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              textStyle: TextStyle(
                fontSize: 20.0,
              ),
            ),
            child: new Text('Utforska observationer'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (context) => ObservationsPage()),
              );
            },
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  getVal() async {
    await getImage();
  }

  getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      s = pickedFile.path;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    pos = position;
  }
}
