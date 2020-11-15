import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/util/observations_api.dart';
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

  Future<List<String>> futureObservationImages;
  Observation obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildInfoAboutObservation(),
      bottomNavigationBar: navbar(1)
    );
  }

  Widget buildInfoAboutObservation() {
    return FutureBuilder(
      future: futureObservationImages = ObservationsAPI().fetchObservationImages(obs),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          obs.imageUrl = snapshot.data;

          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    headers(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        "Anteckningar",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 10.0),
                      child: Text(obs.body, textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 30.0),
                        child: locationWidget()),
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
                    child: Text(
                  obs.subject,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ))),
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.25,
      margin: const EdgeInsets.only(right: 20.0),
      child: Image.network(
        //Displays first image
        obs.imageUrl[0],
        errorBuilder:
            (BuildContext context, Object exception, StackTrace stackTrace) {
          return observationWithoutImage();
        },
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

  //Spara och ta bort knappar
  Widget controllerButtons() {
    return ButtonBar(mainAxisSize: MainAxisSize.min,
        // this will take space as minimum as posible(to center)
        children: <Widget>[
          new RaisedButton(
              onPressed: () {},
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
              onPressed: () {},
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

  //Widget som visar positionen
  Widget locationWidget() {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
            margin: const EdgeInsets.only(left: 5.0, right: 10),
            child: Icon(
              Icons.map_outlined,
              color: Colors.black,
              size: 24.0,
            )),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: "Platsnamn" + "\n",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: obs.latitude.toString() +
                      ", " +
                      obs.longitude.toString()),
            ],
          ),
        ),
      ]),
    );
  }

  Widget mapView() {
    GoogleMapController mapController;
    CameraPosition observationLocation;

    if (obs.latitude != null && obs.longitude != null) {
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

}
