import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/util/local_file_manager.dart';
import 'package:observationer/util/observations_api.dart';
import 'bottom_nav_bar.dart';
import 'edit_observation_page.dart';

/// The view that displays specific/detailed data for a singular Observation.
class OneObservationPage extends StatefulWidget {
  OneObservationPage(this.obs, this._keyDelete);

  final GlobalKey<ScaffoldState> _keyDelete;
  final Observation obs;

  @override
  _OneObservationPageState createState() =>
      _OneObservationPageState(obs, _keyDelete);
}

class _OneObservationPageState extends State<OneObservationPage> {
  _OneObservationPageState(this.obs, this._keyDelete);

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

    _editingControllerTitle = TextEditingController(text: initialTextTitle);
    _editingControllerBody = TextEditingController(text: initialTextBody);
    _editingControllerLatitude =
        TextEditingController(text: initialTextLatitude);
    _editingControllerLongitude =
        TextEditingController(text: initialTextLongitude);
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
                      child: Text(
                        initialTextBody,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
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
                      child: Text(
                        initialTextLatitude,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
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
                      child: Text(
                        initialTextLongitude,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
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
                  child: Expanded(
                      child: Center(
                          child: Text(
                    initialTextTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ))),
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
              return SimpleDialog(
                backgroundColor: Colors.white,
                children: [
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
                      items: obs.imageUrl
                          .map(
                            (pics) => Center(
                                widthFactor: 2.0,
                                child: Image.network(
                                  pics,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                )),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
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

  //Redigera och ta bort knappar
  Widget controllerButtons() {
    return ButtonBar(mainAxisSize: MainAxisSize.min,
        // this will take space as minimum as posible(to center)
        children: <Widget>[
          new RaisedButton(
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(32.5, -120), zoom: 20.0),
                  ),
                );
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
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.white,
                  ),
                ),
              )),
          new RaisedButton(
            onPressed: () {
              showEditScreen();
            },
            color: Theme.of(context).accentColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).accentColor)),
            child: Padding(
              padding: EdgeInsets.all(0),
              child: Container(
                alignment: Alignment.center,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ]);
  }
  
    void showEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditObservationPage(obs, _key)),
    );

    if (result != null) {
      _key.currentState.showSnackBar(
          SnackBar(content: Text("Observationen har uppdaterats.")));
      setState(() {
        initialTextTitle = result.subject;
        initialTextBody = result.body;
        initialTextLatitude = result.latitude.toString();
        initialTextLongitude = result.longitude.toString();
        obs.imageUrl = result.imageUrl;

        mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(double.parse(initialTextLatitude),
              double.parse(initialTextLongitude))),
        );
      });
    }
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
                                  onPressed: () async => {
                                        await removeObservation(_keyDelete),
                                        Navigator.pop(context),
                                        Navigator.pop(context),
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

  
  GoogleMapController mapController;
  Widget mapView() {
    CameraPosition observationLocation;
    List<Marker> markers = <Marker>[];

    if (double.parse(initialTextLatitude) != null &&
        double.parse(initialTextLongitude) != null) {
      markers.add(Marker(
        markerId: MarkerId(obs.id.toString()),
        position: LatLng(double.parse(initialTextLatitude),
            double.parse(initialTextLongitude)),
        infoWindow: InfoWindow(title: obs.subject),
      ));
      observationLocation = CameraPosition(
        target: LatLng(double.parse(initialTextLatitude),
            double.parse(initialTextLongitude)),
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


  String formatDate() {
    String string = obs.created;
    String date = string.substring(0, 10);
    String time = string.substring(11, 19);
    return date.replaceAll("-", "/") + " - " + time;
  }

  Future<void> removeObservation(key) async {
    if (obs.local) {
      LocalFileManager().removeObservation(obs.localId);
      //Shouldnt be possible to fail with a local observation
      key.currentState.showSnackBar(
          SnackBar(content: Text("Lokal observation har tagits bort.")));
      return;
    }

    await ObservationsAPI.deleteObservation(obs.id.toString())
        .then((var result) {
      String response = result.toString();
      if (response == "204")
        response = "Observationen har tagits bort.";
      else
        response = "Borttagning misslyckades.";
      key.currentState.showSnackBar(SnackBar(content: Text(response)));
    });
  }
}
