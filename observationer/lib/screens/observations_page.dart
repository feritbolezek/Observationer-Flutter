import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:observationer/util/location_manager.dart';
import 'package:observationer/util/observations_api.dart';
import '../model/observation.dart';
import 'message_dialog.dart';
import 'one_observation_page.dart';
import 'bottom_nav_bar.dart';
import 'dart:async';

/// Shows list of observations.
class ObservationsPage extends StatefulWidget {
  @override
  _ObservationsPageState createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  Future<List<Observation>> futureObservation;
  int filterChoice = 2;
  LocationManager _locationManager;
  bool _permission = false;
  LatLng cords;
  String search;
  bool showErrorDialog = true;

  /* //Refresh button doesn't work if you only fetch observations in initState()
  @override
  void initState() {
    super.initState();
    futureObservation = fetchObservations();
  }
*/
  //Refresh when swiping
  Future<Null> refreshList() async {
    setState(() {
      showErrorDialog = true;
      search = null;
    });
  }

  Future<void> _getCurrentLocation() async {
    Position pos;
    _locationManager = LocationManager();

    _permission = await _locationManager.checkPermission();

    if (_permission) {
      //getCurrentLocation() is pretty slow, lastKnown is much faster
      //Get last known position if there is one.
      pos = await Geolocator.getLastKnownPosition() ??
          await _locationManager.getCurrentLocation();
      cords = LatLng(pos.latitude, pos.longitude);
    } else {
      bool request = await _locationManager.requestPermission();
      if (request) {
        pos = await _locationManager.getCurrentLocation();
        cords = LatLng(pos.latitude, pos.longitude);
      } else {
        _permission = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _key,
        appBar: AppBar(
          centerTitle: true,
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
              Text('Observationer'),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh page',
              onPressed: () {
                refreshList();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refreshList,
          child: Column(
            children: [
              Container(
                child: _filter(),
              ),
              Expanded(
                child: FutureBuilder(
                  future: futureObservation = ObservationsAPI()
                      .fetchObservations(filterChoice, cords, search,
                          (statusCode) {
                    if (showErrorDialog) {
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          MessageDialog().buildDialog(
                              context,
                              "Kunde ej hämta observationer",
                              "Fel i anslutningen till databasen, felkod: $statusCode",
                              true));
                      showErrorDialog = false;
                    }
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildListView(snapshot);
                    } else if (snapshot.hasError) {
                      print("ERROR: ${snapshot.error.toString()}");
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          MessageDialog().buildDialog(
                              context,
                              "Kunde ej hämta observationer",
                              "Fel i anslutningen till databasen",
                              true));
                      return Center(child: Text("Försök igen..."));
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: navbar(2));
  }

  Widget _buildListView(snapshot) {
    return ListView.separated(
      //padding: EdgeInsets.all(8.0),
      separatorBuilder: (context, index) => Divider(),
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildRow(snapshot.data[index]);
      },
    );
  }

  Widget _buildRow(Observation obs) {
    String body = obs.body ?? "";
    String long = obs.longitude.toString() ?? "";
    String lat = obs.latitude.toString() ?? "";

    FutureOr onGoBack(dynamic value) {
      print('refresh');
      refreshList();
    }

    void navigateSecondPage() {
      Route route =
          MaterialPageRoute(builder: (context) => OneObservationPage(obs, _key));
      Navigator.push(context, route).then(onGoBack);
    }

    return ListTile(
      title: Text(obs.subject, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text('Plats: ' + long + ', ' + lat + '\n' + 'Anteckningar: ' + body),
      trailing: obs.local
          ? Text(
              "LOKAL",
              style: TextStyle(color: Colors.deepPurple[700]),
            )
          : Text(""),
      isThreeLine: true,
      //Gives each item more space
      onTap: () {
        navigateSecondPage();
      },
    );
  }

  Widget _filter() {
    var msgController = TextEditingController();
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          TextField(
            controller: msgController,
            onSubmitted: (text) {
              setState(() {
                search = text;
                filterChoice = 4;
              });
              msgController.clear();
            },
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              suffixIcon: new Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromRGBO(180, 180, 180, 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromRGBO(180, 180, 180, 0.1)),
              ),
              border: new OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
              fillColor: Color.fromRGBO(180, 180, 180, 0.1),
              filled: true,
              hintText: 'Type Something...',
              isDense: true,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Sortera',
                style: TextStyle(fontSize: 15),
              ),
              ButtonTheme(
                minWidth: 100.0,
                height: 25.0,
                child: RaisedButton(
                  color: filterChoice == 1 ? Colors.blue : Colors.grey[300],
                  textColor: filterChoice == 1 ? Colors.white : Colors.black,
                  onPressed: () {
                    setState(() {
                      filterChoice = 1;
                    });
                  },
                  child: Text("Alfabetiskt", style: TextStyle(fontSize: 15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              ButtonTheme(
                minWidth: 100.0,
                height: 25.0,
                child: RaisedButton(
                  color: filterChoice == 2 ? Colors.blue : Colors.grey[300],
                  textColor: filterChoice == 2 ? Colors.white : Colors.black,
                  onPressed: () {
                    setState(() {
                      filterChoice = 2;
                    });
                  },
                  child: Text("Datum", style: TextStyle(fontSize: 15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              ButtonTheme(
                minWidth: 100.0,
                height: 25.0,
                child: RaisedButton(
                  color: filterChoice == 3 ? Colors.blue : Colors.grey[300],
                  textColor: filterChoice == 3 ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  onPressed: () async {
                    await _getCurrentLocation();
                    if(_permission){
                      setState(() {
                        filterChoice = 3;
                      });
                    }
                  },
                  child: Text("Närmaste", style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
