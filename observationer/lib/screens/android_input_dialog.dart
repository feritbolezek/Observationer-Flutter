
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observationer/model/input_dialog.dart';
import 'package:observationer/model/observation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'message_dialog.dart';

/// A material design style dialog for Android.
class AndroidInputDialog implements InputDialog {
  AndroidInputDialog(
      {@required this.onPressPositive(Observation ob),
        @required this.onPressNegative,
        @required this.pos});

  var firstCamera = null;

  @override
  Function onPressPositive;

  @override
  Function onPressNegative;

  String title;
  String desc;
  Position pos;

  Future<void> loadCamera() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    firstCamera = cameras.first;



  }

  Widget buildDialog(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lägg till ny observation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    loadCamera();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (context) => TakePictureScreen(camera: firstCamera)),
                    );
                  },
                  child: Image(
                      width: 150,
                      image: AssetImage('assets/images/Placeholder.png')

                  )),
              Text('Bifoga ny bild'),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Titel...'),
            onChanged: (val) {
              title = val;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            maxLength: 250,
            decoration: InputDecoration(labelText: 'Anteckningar...'),
            onChanged: (val) {
              desc = val;
            },
          ),
          Center(
            child: SizedBox(
              height: 8.0,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  textStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                child: new Text('Avbryt'),
                onPressed: () {
                  onPressNegative();
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                width: 32.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  textStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                child: new Text('Lägg till'),
                onPressed: () {
                  if (title == null || title == "") {
                    var errorMessage = new MessageDialog();
                    errorMessage.buildAndroidDialog(context, "Titel saknas",
                        "Var god fyll i observationstitel.", true);
                  } else {
                    onPressPositive(Observation(
                        subject: title,
                        body: desc,
                        latitude: pos.latitude,
                        longitude: pos.longitude));
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {

          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            final path = join(

              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            await _controller.takePicture(path);



            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
