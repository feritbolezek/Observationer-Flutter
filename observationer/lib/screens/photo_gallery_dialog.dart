import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoGalleryDialog {
  //Optional parameters
  PhotoGalleryDialog([this.camera, this.gallery]);
  VoidCallback camera;
  VoidCallback gallery;

  void buildDialog(BuildContext context) {
    //IOS MESSAGE DIALOG
    if (Platform.isIOS) {
      buildIOSDialog(context);
    }
    //ANDROID MESSAGE DIALOG
    else {
      buildAndroidDialog(context);
    }
  }

  void buildAndroidDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text("Hur vill du gå vidare?")),
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
                                    if(camera != null){
                                      camera()
                                    }
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
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                          Text('Ta foto'),
                                        ],
                                      ),
                                    ),
                                  )),
                              new ElevatedButton(
                                  onPressed: () => {
                                    if(gallery != null){
                                      gallery()
                                    }
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
                                          Icon(
                                            Icons.insert_photo,
                                            color: Colors.white,
                                          ),
                                          Text('Galleri'),
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

  void buildIOSDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Center(child: Text("Hur vill du gå vidare?")),
            content: IntrinsicHeight(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new CupertinoButton(
                        onPressed: () => {
                          if(camera != null){
                            camera()
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.camera_alt,
                                ),
                                Text('Ta foto'),
                              ],
                            ),
                          ),
                        )),
                    new CupertinoButton(
                        onPressed: () => {
                          if(gallery != null){
                            gallery()
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.insert_photo,
                                ),
                                Text('Galleri'),
                              ],
                            ),
                          ),
                        )),
                  ]),
            ),
          );
        });
  }
}
