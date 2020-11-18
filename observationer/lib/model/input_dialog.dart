import 'package:flutter/cupertino.dart';

/// Interface for input dialogs.
abstract class InputDialog {
  Function onPressPositive;
  Function onPressNegative;
  Function onImageReceived;

  Widget buildDialog(BuildContext context);
}
