import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:observationer/map_view.dart';

void main() {
  runApp(StartingPage());
}

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
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          
          const SizedBox(height: 150),
          Hero(
            tag: 'icon',
            child: Image(
              image: AssetImage('assets/images/obs_icon.png'),
              width: 80.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Observationer',
            style: TextStyle(
                color: Color(0xFF6ACEF0),
                fontSize: 26.0,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 250), //This is probably a bad way
          new ElevatedButton (
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 55, vertical: 15),
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
          const SizedBox(height: 50),
          new ElevatedButton (
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 17),
              textStyle: TextStyle(
                fontSize: 14.0,
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
        ],
      ),
    );
  }
}

class ObservationsPage extends StatefulWidget {
  @override
  _ObservationsPageState createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  Future<List<Observation>> futureObservation;

  /* //Refresh button doesn't work if you only fetch observations in initState()
  @override
  void initState() {
    super.initState();
    futureObservation = fetchObservations();
  }
*/
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
      body: Container(
        child: FutureBuilder(
          future: futureObservation = CommunicateWithApi().fetchObservations(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildListView(snapshot);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
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
    return ListTile(
      title: Text(obs.subject, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Plats: ' +
          obs.longitude.toString() +
          ', ' +
          obs.latitude.toString() +
          '\n' +
          'Anteckningar: ' +
          obs.body),
      isThreeLine: true, //Gives each item more space
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (context) => OneObservationPage(obs)),
        );
      },
    );
  }
}

class OneObservationPage extends StatefulWidget {
  OneObservationPage(this.obs);

  final Observation obs;

  @override
  _OneObservationPageState createState() => _OneObservationPageState(obs);
}

class _OneObservationPageState extends State<OneObservationPage> {
  _OneObservationPageState(this.obs);

  Observation obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(obs.subject),
      ),
      body: Center(
          child: Text("Anteckningar: " +
              obs.body +
              "\n" +
              "Created: " +
              obs.created +
              "\n" +
              "Position: " +
              obs.longitude.toString() +
              ", " +
              obs.latitude.toString())),
    );
  }
}

class CommunicateWithApi {
  final List<Observation> observations = [];

  Future<List<Observation>> fetchObservations() async {
    var data = await http
        .get('https://saabstudent2020.azurewebsites.net/observation/');

    if (data.statusCode == 200) {
      var jsonData = json.decode(data.body);

      //Not sure if this is the best way
      for (var o in jsonData) {
        Observation obs = Observation(
            o['id'],
            o['subject'],
            o['body'],
            o['created'],
            o['position']['longitude'],
            o['position']['latitude']);
        if (!observations.contains(obs)) {
          observations.add(obs);
        }
      }
      return observations;
    } else {
      throw Exception('Failed to load observations');
    }
  }
}

class Observation {
  Observation(this.id, this.subject, this.body, this.created, this.longitude,
      this.latitude);

  final int id;
  final String subject;
  final String body;
  final String created;
  final double longitude;
  final double latitude;
}
