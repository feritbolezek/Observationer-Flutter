import 'package:flutter/material.dart';

import 'map_view.dart';
import 'observations_page.dart';

/// The starting page of the application.
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
        children: <Widget>[

          Spacer(),

          Image(
              image: AssetImage('assets/images/obs_icon.png'),
              width: 120.0,
            ),

          Text('Observationer',
            style: TextStyle(
                color: Color(0xFF6ACEF0),
                fontSize: 26.0,
                fontWeight: FontWeight.bold),
          ),

          Spacer(flex: 2),

          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
              child: Text('Välkommen till Observationer!',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold),
            ),
          ),

          new ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 63, vertical: 15),
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

          Container(
            padding: EdgeInsets.symmetric(vertical: 3),
              child: Text('eller',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
            ),
          ),

          new ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              textStyle: TextStyle(
              fontSize: 20.0,
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

          Spacer(),

        ],
      ),
    );
  }
}
