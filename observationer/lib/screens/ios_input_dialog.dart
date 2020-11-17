import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observationer/model/input_dialog.dart';
import 'package:observationer/model/observation.dart';
import 'message_dialog.dart';

/// A Cupertino style dialog for iOS.
class iOSInputDialog implements InputDialog {
  iOSInputDialog(
      {@required this.onPressPositive(Observation ob),
      @required this.onPressNegative,
      @required this.pos});

  @override
  Function onPressPositive;

  @override
  Function onPressNegative;

  String title;
  String desc;
  Position pos;

  Widget buildDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Lägg till ny observation'),
      content: Column(
        children: [
          SizedBox(
            height: 8.0,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Image(
                width: 150,
                image: AssetImage('assets/images/Placeholder.png'),
              ),
              Text('Bifoga ny bild'),
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
          CupertinoTextField(
            placeholder: 'Titel...',
          ),
          SizedBox(
            height: 32.0,
          ),
          CupertinoTextField(
            placeholder: 'Anteckningar...',
            maxLines: 3,
            maxLength: 250,
            keyboardType: TextInputType.multiline,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                  child: Text(
                    'Avbryt',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  onPressed: () {
                    onPressNegative();
                    Navigator.of(context).pop();
                  }),
              CupertinoButton(
                  child: Text('Lägg till'),
                  onPressed: () {
                    if (title == null || title == "") {
                      var errorMessage = new MessageDialog();
                      errorMessage.buildIOSDialog(context, "Titel saknas",
                          "Var god fyll i observationstitel.", true);
                    } else {
                      onPressPositive(Observation(
                          subject: title,
                          body: desc,
                          latitude: pos.latitude,
                          longitude: pos.longitude));
                    }
                  })
            ],
          )
        ],
      ),
    ).build(context);
  }
}
