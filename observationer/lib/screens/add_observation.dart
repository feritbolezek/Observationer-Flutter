import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/screens/display_image.dart';
import 'package:observationer/screens/photo_gallery_dialog.dart';
import 'package:observationer/util/local_file_manager.dart';
import 'package:observationer/util/observations_api.dart';
import 'package:observationer/util/LengthLimitingTextFieldFormatterFixed.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'message_dialog.dart';
import 'dart:async';

class AddObservation extends StatefulWidget {
  AddObservation(this._position);

  String path;

  AddObservation.xd(this._position, path) {
    this.path = path;
  }

  final _position;

  @override
  _AddObservationState createState() => _AddObservationState(_position, path);
}

class _AddObservationState extends State<AddObservation> {
  _AddObservationState(this.pos, this.path);

  String path;

  static const int MAX_IMAGE_SIZE = 5000000; // 5 MB

  String title;
  String desc;
  Position pos;

  bool _share = false;

  List<String> imagesTakenPath;
  bool _leave = false;

  bool _uploadBtnIsEnabled = true;

  String _image;
  final picker = ImagePicker();

  var _key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    imagesTakenPath = [];
    super.initState();
    if (path != null) imagesTakenPath.add(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Text('Lägg till observation'),
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
                SizedBox(
                  height: 16,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [_previewDisplay()],
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatterFixed (64),
                  ],
                  maxLength: 64,
                  maxLengthEnforced: false,
                  decoration: InputDecoration(labelText: 'Titel...'),
                  onChanged: (val) {
                    title = val;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatterFixed (250),
                  ],
                  // for mobile
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  maxLength: 250,
                  maxLengthEnforced: false,
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
                      onPressed: () async {
                        await _showAlertDialog();
                        if (_leave) Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 32.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:
                            _uploadBtnIsEnabled ? Colors.blue : Colors.white70,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        textStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      child: _uploadBtnIsEnabled
                          ? Text('Lägg till')
                          : Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator())),
                      onPressed: () {
                        if (title == null || title == "") {
                          var errorMessage = new MessageDialog();
                          errorMessage.buildAndroidDialog(
                              context,
                              "Titel saknas",
                              "Var god fyll i observationstitel.",
                              true);
                        } else {
                          if (_uploadBtnIsEnabled) {
                            _disableAddButton();
                            if (_share)
                              insertObservation(_key);
                            else
                              createLocalObservation();
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dela med andra",
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                        value: _share,
                        onChanged: (val) {
                          setState(() {
                            _share = val;
                          });
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enableAddButton() {
    setState(() {
      _uploadBtnIsEnabled = true;
    });
  }

  void _disableAddButton() {
    setState(() {
      _uploadBtnIsEnabled = false;
    });
  }

  void createLocalObservation() async {
    LocalFileManager localFileManager = LocalFileManager();

    Observation obs = Observation(
        subject: title,
        body: desc,
        created: DateTime.now().toString(),
        latitude: pos == null ? 0.0 : pos.latitude,
        longitude: pos == null ? 0.0 : pos.longitude,
        imageUrl: imagesTakenPath);

    await localFileManager.saveObservationLocally(obs).then((value) {
      _key.currentState.showSnackBar(
          SnackBar(content: Text("Observationen har sparats lokalt!")));
      _enableAddButton();
    });
  }

  /// Will attempt to upload the data included within [observation].
  void insertObservation(key) async {
    ObservationsAPI.uploadObservation(
            title: title,
            description: desc,
            latitude: pos == null ? 0.0 : pos.latitude,
            longitude: pos == null ? 0.0 : pos.longitude,
            images: imagesTakenPath)
        .then((var result) {
      String response = result.toString();
      if (response == "201")
        response = "Observationen har skapats!";
      else
        response = "Observationen kunde inte skapas. Felkod:${response}";
      key.currentState.showSnackBar(SnackBar(content: Text(response)));
      _enableAddButton();
    });
  }

  Future<bool> _checkImageSize(String path) async {
    var image = File(path);
    int size = await image.length();

    return size < MAX_IMAGE_SIZE;
  }

  /// Shows an alert dialog when the user attempts to leave this view.
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: this.context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Är du säker?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Dina ändringar kommer INTE att sparas.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Avbryt'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Ja'),
              onPressed: () {
                setState(() {
                  _leave = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _previewDisplay() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      crossAxisSpacing: 2,
      mainAxisSpacing: 10,
      crossAxisCount: 4,
      children: _getImageChildren(this.context),
    );
  }

  List<Widget> _getImageChildren(BuildContext context) {
    List<Widget> images = [];

    if (imagesTakenPath.isNotEmpty) {
      //print(imagesTakenPath.length);
      for (var path in imagesTakenPath) {
        if (path != null) {
          images.add(GestureDetector(
            onTap: () {
              _goToImageDisplay(path);
            },
            child: Image(
              width: 200,
              image: FileImage(File(path)),
            ),
          ));
        }
      }
    }

    images.add(GestureDetector(
      onTap: () {
        if (imagesTakenPath.length < 7) {
          PhotoGalleryDialog(_goToCameraView, _picGallery).buildDialog(context);
        } else
          MessageDialog()
              .buildDialog(context, "Fel", "Max antal bilder är 7.", true);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Icon(Icons.add),
              Text('Bifoga bild'),
            ],
          ),
        ],
      ),
    ));

    //print("returning images: ${images.length}");

    return images;
  }

  _goToImageDisplay(String path) async {
    var res = await Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => DisplayImage(path)),
    );

    setState(() {
      imagesTakenPath.remove(res);
    });
  }

  Future<void> _goToCameraView() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (imagesTakenPath.length == 6) {
      Navigator.pop(this.context);
    }

    final cameras = await availableCameras();

    var result = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: cameras.first)),
    );
    print(result);
    if (result != null) {
      _checkImageSize(result).then((value) {
        setState(() {
          value
              ? imagesTakenPath.add(result)
              : _key.currentState.showSnackBar(SnackBar(
                  content: Text("Fel: Bildstorleken överstiger 5 MB")));
        });
      });
    }
  }

  Future<void> _picGallery() async {
    if (imagesTakenPath.length == 6) {
      Navigator.pop(this.context);
    }

    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _image = imageFile.path;
      _checkImageSize(_image).then((value) {
        value
            ? imagesTakenPath.add(_image)
            : _key.currentState.showSnackBar(
                SnackBar(content: Text("Fel: Bildstorleken överstiger 5 MB")));
      });
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
      ResolutionPreset.high,
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
          onPressed: () => Navigator.pop(context),
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
