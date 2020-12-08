import 'package:flutter/material.dart';
import 'package:observationer/screens/map_view.dart';
import 'emergency_camera.dart';
import 'observations_page.dart';

class navbar extends StatefulWidget {
  navbar(this.index);

  final int index;

  @override
  _navbarState createState() => _navbarState(index);
}

class _navbarState extends State<navbar> {
  _navbarState(this._index);

  int _index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _index, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Karta",
          ),
          new BottomNavigationBarItem(
              icon: Icon(
                Icons.add_a_photo,
                size: 25.0,
              ),
              label: ""),
          new BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: "Observationer",
          ),
        ]);
  }

  void onTabTapped(int index) {
    //Keep track of previous page
    int previousPageIndex = _index;
    if (_index != index) {
      setState(() {
        _index = index;
      });
      if (_index == 0) {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (context) => MapView()))
            .then((value) => setState(() {
                  _index = previousPageIndex;
                }));
      } else if (_index == 1) {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(
                builder: (context) => EmergencyCamera()))
            .then((value) => setState(() {
                  _index = previousPageIndex;
                }));
      } else if (_index == 2) {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(
                builder: (context) => ObservationsPage()))
            .then((value) => setState(() {
                  _index = previousPageIndex;
                }));
      }
    }
  }
}
