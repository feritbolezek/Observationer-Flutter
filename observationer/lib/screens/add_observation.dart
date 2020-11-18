import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observationer/model/input_dialog.dart';
import 'package:observationer/model/observation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'message_dialog.dart';

class AddObservation extends StatefulWidget {
  @override
  _AddObservationState createState() => _AddObservationState();
}

class _AddObservationState extends State<AddObservation> {
  String title;
  String desc;
  Position pos;

  List<String> imagesTakenPath;

  @override
  void initState() {
    imagesTakenPath = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'icon',
              child: Image(
                color: Colors.white,
                image: AssetImage('assets/images/obs_icon.png'),
                width: 20.0,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text('Karta'),
          ],
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
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
                          _goToCameraView(context);
                        },
                        child: Image(
                            width: 200,
                            image: imagesTakenPath.isNotEmpty
                                ? FileImage(File(imagesTakenPath.first))
                                : AssetImage('assets/images/Placeholder.png'))),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        textStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      child: new Text('Avbryt'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 32.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        textStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      child: new Text('Lägg till'),
                      onPressed: () {
                        if (title == null || title == "") {
                          var errorMessage = new MessageDialog();
                          errorMessage.buildAndroidDialog(
                              context,
                              "Titel saknas",
                              "Var god fyll i observationstitel.",
                              true);
                        } else {
                          imagesTakenPath.forEach((element) {
                            print("FERIT: $element");
                          });
                          // onPressPositive(Observation(
                          //     subject: title,
                          //     body: desc,
                          //     latitude: pos.latitude,
                          //     longitude: pos.longitude));
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goToCameraView(BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: cameras.first)),
    );
    setState(() {
      imagesTakenPath.add(result);
    });
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
  String imagePath;

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
      appBar: AppBar(
        title: Text('Take a picture'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context, imagePath),
        ),
      ),
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

            imagePath = path;

            await _controller.takePicture(path);

            Navigator.pop(context, imagePath);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
