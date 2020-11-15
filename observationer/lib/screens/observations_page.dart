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
                  return Text("${snapshot.error}");
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
