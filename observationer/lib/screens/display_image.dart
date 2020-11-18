import 'dart:io';

import 'package:flutter/material.dart';

class DisplayImage extends StatefulWidget {
  final imgPath;

  DisplayImage(this.imgPath);

  @override
  _DisplayImageState createState() => _DisplayImageState(imgPath);
}

class _DisplayImageState extends State<DisplayImage> {
  String imgPath;

  _DisplayImageState(this.imgPath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
            Text('Tagen bild'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Image(
              fit: BoxFit.cover,
              image: FileImage(File(imgPath)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  textStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                child: new Text('Ta bort'),
                onPressed: () {
                  Navigator.pop(context, imgPath);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
