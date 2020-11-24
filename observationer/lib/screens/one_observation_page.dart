import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/screens/photo_gallery_dialog.dart';
import 'package:observationer/util/observations_api.dart';
import 'package:observationer/util/position_input_formatter.dart';
import 'bottom_nav_bar.dart';

/// The view that displays specific/detailed data for a singular Observation.
class OneObservationPage extends StatefulWidget {
  OneObservationPage(this.obs);

  final Observation obs;

  @override
  _OneObservationPageState createState() => _OneObservationPageState(obs);
}

class _OneObservationPageState extends State<OneObservationPage> {
  _OneObservationPageState(this.obs);

  var _key = new GlobalKey<ScaffoldState>();
  Observation obs;
  String initialTextTitle,
      initialTextBody,
      initialTextLatitude,
      initialTextLongitude;
  Future<List<String>> futureObservationImages;
  bool _isEditingText = false;
  bool _editBodySwitch = false;
  bool _editLatitudeSwitch = false;
  bool _editLongitudeSwitch = false;
  TextEditingController _editingControllerTitle;
  TextEditingController _editingControllerBody;
  TextEditingController _editingControllerLatitude;
  TextEditingController _editingControllerLongitude;

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
        bottomNavigationBar: navbar(1));
  }

  Widget buildInfoAboutObservation() {
    return FutureBuilder(
      future: futureObservationImages =
          ObservationsAPI().fetchObservationImages(obs),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          obs.imageUrl = snapshot.data;
          print(obs.imageUrl.length);

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
                          child: RaisedButton(
                              //Ladda upp bild click-event
                              onPressed: () {
                                PhotoGalleryDialog().buildDialog(context);
                              },
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.blue)),
                              child: Padding(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.file_upload,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Lägg upp bild',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 30.0),
                        child: Row(children: [
                          Text(
                            "Anteckningar",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey[600]),
                              onPressed: () {
                                setState(() {
                                  _editBodySwitch = !_editBodySwitch;
                                });
                              })
                        ])),
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
                  child: Expanded(child: _editTitleTextField()),
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
      //TODO: funktion för att byta ut bild.
      onTap: () {},
      child: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              margin: const EdgeInsets.only(right: 20.0),
              child: imageStack()),
          Align(
            alignment: Alignment(-0.9, -0.9),
            child: Icon(Icons.edit, color: Colors.grey[600]),
          )
        ],
      ),
    );
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
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/Placeholder.png'),
              fit: BoxFit.none,
              alignment: Alignment.bottomRight,
            )),
          ),
          Image.network(
            //Displays first image
            obs.imageUrl[0],
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {
              return observationWithoutImage();
            },
          ),
          Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              )),
          Positioned(
              right: 7.0,
              top: 5.0,
              child: Text(
                '+' + (obs.imageUrl.length - 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
        ],
      );
    } else if(obs.imageUrl.length == 1){
      return Image.network(
        //Displays first image
        obs.imageUrl[0],
        errorBuilder: (BuildContext context, Object exception,
            StackTrace stackTrace) {
          return observationWithoutImage();
        },
      );
    }

    else {
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
    return ButtonBar(mainAxisSize: MainAxisSize.min,
        // this will take space as minimum as posible(to center)
        children: <Widget>[
          new RaisedButton(
              onPressed: () {
                buildDialog(context);
              },
              color: Colors.red[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red[400])),
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.white,
                      ),
                      Text(
                        'Ta bort',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              )),
          new RaisedButton(
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
              ))
        ]);
  }

  void buildDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text("Vill du ta bort observationen?")),
            content: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Center(
                        child: ButtonBar(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              new ElevatedButton(
                                  onPressed: () => {
                                        removeObservation(_key),
                                        Navigator.of(context).pop(),
                                        Navigator.pop(context)
                                      },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    textStyle: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Ja'),
                                        ],
                                      ),
                                    ),
                                  )),
                              new ElevatedButton(
                                  onPressed: () => {
                                        Navigator.of(context).pop(),
                                      },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    textStyle: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Avbryt'),
                                        ],
                                      ),
                                    ),
                                  )),
                            ]),
                      ),
                    ),
                  ]),
            ),
          );
        });
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
    if (_editBodySwitch)
      return TextField(
        textInputAction: TextInputAction.done,
        maxLines: 10,
        onSubmitted: (newValue) {
          setState(() {
            initialTextBody = newValue;
            _editBodySwitch = false;
          });
        },
        autofocus: true,
        controller: _editingControllerBody,
      );
    return Text(
      initialTextBody,
      overflow: TextOverflow.ellipsis,
      maxLines: 10,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
      ),
    );
  }

  Widget _editTitleTextField() {
    if (_isEditingText)
      return Center(
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              initialTextTitle = newValue;
              _isEditingText = false;
            });
          },
          autofocus: true,
          controller: _editingControllerTitle,
        ),
      );
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Center(
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: initialTextTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  WidgetSpan(
                    child: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                  ),
                ]))));
  }

  Widget _editLatitude() {
    if (_editLatitudeSwitch)
      return TextField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]')),
          PositionInputFormatter(90.0, -90.0),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (newValue) {
          setState(() {
            initialTextLatitude = newValue;
            _editLatitudeSwitch = false;
          });
        },
        autofocus: true,
        controller: _editingControllerLatitude,
      );
    return InkWell(
        onTap: () {
          setState(() {
            _editLatitudeSwitch = true;
          });
        },
        child: RichText(
            maxLines: 1,
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: initialTextLatitude,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
              WidgetSpan(
                child: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
              ),
            ])));
  }

  Widget _editLongitude() {
    if (_editLongitudeSwitch)
      return TextField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]')),
          PositionInputFormatter(180.0, -180.0),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (newValue) {
          setState(() {
            initialTextLongitude = newValue;
            _editLongitudeSwitch = false;
          });
        },
        autofocus: true,
        controller: _editingControllerLongitude,
      );
    return InkWell(
        onTap: () {
          setState(() {
            _editLongitudeSwitch = true;
          });
        },
        child: RichText(
            maxLines: 1,
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: initialTextLongitude,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
              WidgetSpan(
                child: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
              ),
            ])));
  }

  String formatDate() {
    String string = obs.created;
    String date = string.substring(0, 10);
    String time = string.substring(11, 19);
    return date.replaceAll("-", "/") + " - " + time;
  }

  void updateObservation(key) {
    ObservationsAPI.updateObservation(
            id: obs.id,
            title: initialTextTitle,
            description: initialTextBody,
            latitude: double.parse(initialTextLatitude),
            longitude: double.parse(initialTextLongitude))
        .then((var result) {
      String response = result.toString();
      if (response == "204")
        response = "Observationen har uppdaterats.";
      else
        response = "Uppdateringen misslyckades.";
      key.currentState.showSnackBar(SnackBar(content: Text(response)));
    });
  }

  void removeObservation(key) {
    ObservationsAPI.deleteObservation(obs.id.toString()).then((var result) {
      String response = result.toString();
      if (response == "204")
        response = "Observationen har tagits bort.";
      else
        response = "Borttagning misslyckades.";
      key.currentState.showSnackBar(SnackBar(content: Text(response)));
    });
  }
}
