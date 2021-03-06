import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/screens/photo_gallery_dialog.dart';
import 'package:observationer/util/LengthLimitingTextFieldFormatterFixed.dart';
import 'package:observationer/util/local_file_manager.dart';
import 'package:observationer/util/observations_api.dart';
import 'add_observation.dart';
import 'package:observationer/util/position_input_formatter.dart';
import 'bottom_nav_bar.dart';
import 'message_dialog.dart';

/// The view that displays specific/detailed data for a singular Observation.
class EditObservationPage extends StatefulWidget {
  EditObservationPage(this.obs, this._keyDelete);

  final GlobalKey<ScaffoldState> _keyDelete;
  final Observation obs;

  @override
  _EditObservationPage createState() => _EditObservationPage(obs, _keyDelete);
}

class _EditObservationPage extends State<EditObservationPage> {
  _EditObservationPage(this.obs, this._keyDelete);

  var _key = new GlobalKey<ScaffoldState>();
  Observation obs;
  GlobalKey<ScaffoldState> _keyDelete;

  String initialTextTitle,
      initialTextBody,
      initialTextLatitude,
      initialTextLongitude;
  Future<List<String>> futureObservationImages;
  TextEditingController _editingControllerTitle;
  TextEditingController _editingControllerBody;
  TextEditingController _editingControllerLatitude;
  TextEditingController _editingControllerLongitude;
  int _currentImg = 0;
  List<String> imagesTakenPath;
  static const int MAX_IMAGE_SIZE = 5000000; // 5 MB

  @override
  void initState() {
    super.initState();

    if (obs.subject != null) {
      initialTextTitle = obs.subject;
    } else {
      initialTextTitle = "Namnlös";
    }

    if (obs.body != null) {
      initialTextBody = obs.body;
    } else {
      initialTextBody = "";
    }

    if (obs.latitude != null) {
      initialTextLatitude = obs.latitude.toString();
    } else {
      initialTextLatitude = "0.0";
    }

    if (obs.longitude != null) {
      initialTextLongitude = obs.longitude.toString();
    } else {
      initialTextLongitude = "0.0";
    }

    imagesTakenPath = [];
    _editingControllerTitle = TextEditingController(text: initialTextTitle);
    _editingControllerBody = TextEditingController(text: initialTextBody);
    _editingControllerLatitude =
        TextEditingController(text: initialTextLatitude);
    _editingControllerLongitude =
        TextEditingController(text: initialTextLongitude);
  }

  @override
  void dispose() {
    _editingControllerTitle.dispose();
    _editingControllerBody.dispose();
    _editingControllerLatitude.dispose();
    _editingControllerLongitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(),
        body: buildInfoAboutObservation(),
        bottomNavigationBar: navbar(2));
  }

  Widget buildInfoAboutObservation() {
    return FutureBuilder(
      future: futureObservationImages =
          ObservationsAPI().fetchObservationImages(obs),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          obs.imageUrl = snapshot.data;

          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    headers(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          width: MediaQuery.of(context).size.width * 0.4,
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        "Anteckningar",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: _editBody()),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 30.0),
                        child: Row(children: [
                          Text(
                            "Latitud:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ])),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: _editLatitude()),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(children: [
                          Text(
                            "Longitud:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ])),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: _editLongitude()),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        margin: const EdgeInsets.only(top: 10.0),
                        child: mapView())
                  ])));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget headers() {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: observationWithImage()),
        Expanded(
          child: Column(children: [
            Container(
                height: 100.0,
                child: Center(
                  child: _editTitleTextField(),
                )),
            Container(
                height: 30.0,
                child: Center(
                    child: Text(
                      formatDate(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ))),
            Container(height: 50.0, child: controllerButtons()),
          ]),
        ),
      ]),
    );
  }

  Widget observationWithImage() {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                print("Rebuild");
                return SimpleDialog(
                  backgroundColor: Colors.white,
                  children: [
                    Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.width,
                          //This one doesn't affecting anything but is needed, otherwise doesnt work.
                          width: MediaQuery.of(context).size.width,
                          child: CarouselSlider(
                            options: CarouselOptions(
                                enableInfiniteScroll: false,
                                height: MediaQuery.of(context).size.width,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImg = index;
                                  });
                                }),
                            items: obs.local
                                ? obs.imageUrl
                                .map(
                                  (pic) => Center(
                                  widthFactor: 2.0,
                                  child: Image.memory(
                                    base64Decode(pic),
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width,
                                  )),
                            )
                                .toList()
                                : obs.imageUrl
                                .map(
                                  (pics) => Center(
                                  widthFactor: 2.0,
                                  child: Image.network(
                                    pics,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width,
                                  )),
                            )
                                .toList(),
                          ),
                        ),
                        Material(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Ink(
                                height: 50,
                                width: 50,
                                decoration: ShapeDecoration(
                                  color: Colors.blue,
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  color: Colors.white,
                                  onPressed: () {
                                    if (obs.imageUrl.length < 7) {
                                      //bör vara parameter till photoGalleryDialog?
                                      PhotoGalleryDialog(
                                          _goToCameraView, _picGallery)
                                          .buildDialog(context);
                                    } else {
                                      MessageDialog().buildDialog(
                                          context,
                                          "Fel",
                                          "Max antal bilder är 7.",
                                          true);
                                    }

                                  },
                                ),
                              ),
                              Ink(
                                  height: 50,
                                  width: 50,
                                  decoration: ShapeDecoration(
                                    color: Colors.red,
                                    shape: CircleBorder(),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_forever_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Ta bort bild?'),
                                              actions: [
                                                FlatButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text('Avbryt'),
                                                ),
                                                FlatButton(
                                                    onPressed: () async {
                                                      obs.imageUrl.removeAt(
                                                          _currentImg);
                                                      await removeObservationImage(
                                                          _key);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Ta bort'))
                                              ],
                                            );
                                          }).then((value) {
                                        setState(() {
                                          if (_currentImg > 0) {
                                            _currentImg = _currentImg - 1;
                                          }
                                        });
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              });
            });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.25,
        margin: const EdgeInsets.only(right: 20.0),
        child: obs.local
            ? getLocalImage()
            : Image.network(
          //Displays first image
          obs.imageUrl[0],
          errorBuilder: (BuildContext context, Object exception,
              StackTrace stackTrace) {
            return observationWithoutImage();
          },
        ),
      ),
    );
  }

  Widget getLocalImage() {
    if (obs.imageUrl.isNotEmpty)
      return Image.memory(base64Decode(obs.imageUrl[0]));
    else
      return observationWithoutImage();
  }

  Widget observationWithoutImage() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Placeholder.png'),
            fit: BoxFit.fill,
          )),
    );
  }

  Widget imageStack() {
    if (obs.imageUrl.length > 1) {
      return Stack(
        children: <Widget>[
          Positioned(
              height: 190,
              width: 140,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Placeholder.png'),
                      fit: BoxFit.none,
                      alignment: Alignment.bottomRight,
                    )),
              )),
          Image.network(
            //Displays first image
            obs.imageUrl[0],
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {
              return observationWithoutImage();
            },
          ),
          Positioned(
              top: 15,
              right: 37,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              )),
          Positioned(
              right: 42.0,
              top: 20.0,
              child: Text(
                '+' + (obs.imageUrl.length - 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
        ],
      );
    } else if (obs.imageUrl.length == 1) {
      return Image.network(
        //Displays first image
        obs.imageUrl[0],
        errorBuilder:
            (BuildContext context, Object exception, StackTrace stackTrace) {
          return observationWithoutImage();
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Placeholder.png'),
              fit: BoxFit.fill,
            )),
      );
    }
  }

  //Spara och ta bort knappar
  Widget controllerButtons() {
    return RaisedButton(
        onPressed: () {
          updateObservation(_key);
        },
        color: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Theme.of(context).accentColor)),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                Text(
                  'Spara',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget mapView() {
    GoogleMapController mapController;
    CameraPosition observationLocation;
    List<Marker> markers = <Marker>[];

    if (obs.latitude != null && obs.longitude != null) {
      markers.add(Marker(
        markerId: MarkerId(obs.id.toString()),
        position: LatLng(obs.latitude, obs.longitude),
        infoWindow: InfoWindow(title: obs.subject),
      ));
      observationLocation = CameraPosition(
        target: LatLng(obs.latitude, obs.longitude),
        zoom: 14.4746,
      );
    } else {
      observationLocation = CameraPosition(
        target: LatLng(45.521563, -122.677433),
        zoom: 14.4746,
      );
    }

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: observationLocation,
          markers: Set<Marker>.of(markers),
        ),
      ),
    );
  }

  Widget _editBody() {
    return TextField(
      inputFormatters: [
        LengthLimitingTextInputFormatterFixed (250),
      ],
      maxLength: 250,
      maxLengthEnforced: false,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onChanged: (text) {
        initialTextBody = text;
      },
      autofocus: true,
      controller: _editingControllerBody,
    );
  }

  Widget _editTitleTextField() {
    return Center(
      child: TextField(
        inputFormatters: [
          LengthLimitingTextInputFormatterFixed (64),
        ],
        maxLength: 64,
        maxLengthEnforced: false,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (text) {
          initialTextTitle = text;
        },
        autofocus: true,
        controller: _editingControllerTitle,
      ),
    );
  }

  Widget _editLatitude() {
    return TextField(
      maxLines: 1,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]')),
        PositionInputFormatter(90.0, -90.0),
      ],
      textInputAction: TextInputAction.done,
      onChanged: (text) {
        initialTextLatitude = text;
      },
      autofocus: true,
      controller: _editingControllerLatitude,
    );
  }

  Widget _editLongitude() {
    return TextField(
      maxLines: 1,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]')),
        PositionInputFormatter(180.0, -180.0),
      ],
      textInputAction: TextInputAction.done,
      onChanged: (text) {
        initialTextLongitude = text;
      },
      autofocus: true,
      controller: _editingControllerLongitude,
    );
  }

  String formatDate() {
    String string = obs.created;
    String date = string.substring(0, 10);
    String time = string.substring(11, 19);
    return date.replaceAll("-", "/") + " - " + time;
  }

  void updateObservation(key, [bool addImage]) {
    print(addImage);
    if (obs.local) {
      LocalFileManager().updateObservation(Observation(
          id: obs.id,
          subject: initialTextTitle,
          body: initialTextBody,
          created: obs.created,
          latitude: double.parse(initialTextLatitude),
          longitude: double.parse(initialTextLongitude),
          local: true,
          localId: obs.localId,
          imageUrl: obs.imageUrl));
      if (addImage) {
        print("Lägg till lokal bild!");
        key.currentState.showSnackBar(
            SnackBar(content: Text("Lokal bild har lagts till.")));
        Future.delayed(Duration(seconds: 2), () {
          _key.currentState.hideCurrentSnackBar();
        });
      }
      //Shouldnt be possible to fail with a local observation
    } else {
      ObservationsAPI.updateObservation(
          id: obs.id,
          title: initialTextTitle,
          description: initialTextBody,
          latitude: double.parse(initialTextLatitude),
          longitude: double.parse(initialTextLongitude))
          .then((var result) {
        String response = result.toString();
        if (response == "204") {
          Navigator.pop(context);
        } else
          key.currentState.showSnackBar(
              SnackBar(content: Text("Uppdateringen misslyckades.")));
      });
    }
  }

  Future<void> removeObservationImage(key) async {
    if (obs.local) {
      LocalFileManager().updateObservation(Observation(
          id: obs.id,
          subject: initialTextTitle,
          body: initialTextBody,
          created: obs.created,
          latitude: double.parse(initialTextLatitude),
          longitude: double.parse(initialTextLongitude),
          local: true,
          localId: obs.localId,
          imageUrl: obs.imageUrl));
      //Shouldnt be possible to fail with a local observation
      key.currentState
          .showSnackBar(SnackBar(content: Text("Lokal bild har tagits bort.")));
      Future.delayed(Duration(seconds: 2), () {
        _key.currentState.hideCurrentSnackBar();
      });
      return;
    }

    await ObservationsAPI.deleteObservationImage(obs, _currentImg)
        .then((var result) {
      String response = result.toString();
      if (response == "204")
        response = "Bilden har tagits bort.";
      else
        response = "Borttagning misslyckades.";
      key.currentState.showSnackBar(SnackBar(content: Text(response)));
      Future.delayed(Duration(seconds: 2), () {
        _key.currentState.hideCurrentSnackBar();
      });
    });
  }

  Future<void> addObservationImage(key) async {
    if (!obs.local) {
      await ObservationsAPI.addObservationImage(obs, imagesTakenPath)
          .then((var result) {
        String response = result.toString();
        print("AddObservationImage: " + response);
        if (response == "201") {
          response = "Bilden har lagts till.";
          setState(() {
            _currentImg = _currentImg + 1;
          });
        } else
          response = "Kunde inte lägga till bild.";
        key.currentState.showSnackBar(SnackBar(content: Text(response)));
        Future.delayed(Duration(seconds: 2), () {
          _key.currentState.hideCurrentSnackBar();
        });
      });
    } else {
      print("Update local");
      updateObservation(_key, true);
    }
  }

  Future<void> _picGallery() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile == null) {
      print('img is null');
      return;
    }
    setState(() {
      String _image = imageFile.path;
      _checkImageSize(_image).then((value) {
        value
            ? imagesTakenPath.add(_image)
            : _key.currentState.showSnackBar(
            SnackBar(content: Text("Fel: Bildstorleken överstiger 5 MB")));
        if (value) {
          addObservationImage(_key);
        }
      });
      Navigator.of(context).pop(context);
    });
  }

  Future<void> _goToCameraView() async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

    var result = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: cameras.first)),
    );

    if (result != null) {
      _checkImageSize(result).then((value) {
        setState(()  {
          value
              ? addToImages(result)
              : _key.currentState.showSnackBar(SnackBar(
              content: Text(
                  "Fel: Bildstorleken överstiger ${MAX_IMAGE_SIZE / 1000000} MB")));
          //Maybe not the best place to call addObservationImage, just testing for now though.
          if (value) {
            addObservationImage(_key);
          }
          imagesTakenPath = [];
          Navigator.of(context).pop(context);
        });
      });
    }
  }

  void addToImages(String result) {
    if (!obs.local) {
      imagesTakenPath.add(result);
    } else {
      File f = new File(result);
      obs.imageUrl.add(base64Encode(f.readAsBytesSync()));
      imagesTakenPath.add(base64Encode(f.readAsBytesSync()));
    }
  }

  Future<bool> _checkImageSize(String path) async {
    var image = File(path);
    int size = await image.length();

    return size < MAX_IMAGE_SIZE;
  }
}
