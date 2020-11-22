import 'package:flutter/material.dart';
import 'package:observationer/util/observations_api.dart';
import '../model/observation.dart';
import 'one_observation_page.dart';
import 'bottom_nav_bar.dart';

/// Shows list of observations.
class ObservationsPage extends StatefulWidget {
  @override
  _ObservationsPageState createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  Future<List<Observation>> futureObservation;
    int filterChoice = 2;


  /* //Refresh button doesn't work if you only fetch observations in initState()
  @override
  void initState() {
    super.initState();
    futureObservation = fetchObservations();
  }
*/
  //Refresh when swiping
  Future<Null> refreshList() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshList,
        child: Container(
          child: FutureBuilder(
            future: futureObservation = ObservationsAPI().fetchObservations(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildListView(snapshot);
              } else if (snapshot.hasError) {
                  return AlertDialog(
                    title: Text('Kunde ej hämta observationer'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Fel i anslutningen till databasen'),

                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    bottomNavigationBar: navbar(1));
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
    
    return ListTile(
      title: Text(obs.subject, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Plats: ' +
          long +
          ', ' +
          lat +
          '\n' +
          'Anteckningar: ' +
          body),
      isThreeLine: true, //Gives each item more space
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (context) => OneObservationPage(obs)),
        );
      },
    );
  }
   Widget _filter(){
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          TextField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              suffixIcon: new Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(180,180,180,0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(180,180,180,0.1)),
              ),
              border: new OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
              fillColor: Color.fromRGBO(180,180,180,0.1),
              filled: true,
              hintText: 'Type Something...',
              isDense: true,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Text('Sortera', style: TextStyle(fontSize: 15),),

                ButtonBar(
                  children: <Widget>[
                  ButtonTheme(
                    minWidth: 100.0,
                    height: 25.0,
                    child: RaisedButton(
                      color: filterChoice == 1? Colors.blue: Colors.grey,
                      textColor: filterChoice == 1? Colors.white: Colors.black,
                      onPressed: () {
                        setState(() {
                          filterChoice = 1;
                        });
                      },
                    child: Text("Alfabetiskt",style: TextStyle(fontSize: 15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                    ButtonTheme(
                      minWidth: 100.0,
                      height: 25.0,
                      child: RaisedButton(
                        color: filterChoice == 2? Colors.blue: Colors.grey,
                        textColor: filterChoice == 2? Colors.white: Colors.black,
                        onPressed: () {
                          setState(() {
                            filterChoice = 2;
                          });
                        },
                        child: Text("Datum",style: TextStyle(fontSize: 15)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 100.0,
                      height: 25.0,
                      child: RaisedButton(
                        color: filterChoice == 3? Colors.blue: Colors.grey,
                        textColor: filterChoice == 3? Colors.white: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () {
                          setState(() {
                            filterChoice = 3;
                          });
                        },
                        child: Text("Närmaste",style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ],
                ),

            ],
          )
        ],
      ),
    );
  }
}
