import 'package:flutter/services.dart';

/// This class handles the input formatting for the position(lat,long)
class PositionInputFormatter extends TextInputFormatter {
  PositionInputFormatter(this.max, this.min);

  final double max;
  final double min;
  final int decimalRange = 10;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    TextEditingValue _newValue = newValue;
    String text = _newValue.text;

    if (text == '.') {
      return TextEditingValue(
        text: '0.',
        selection: _newValue.selection.copyWith(baseOffset: 2, extentOffset: 2),
        composing: TextRange.empty,
      );
    } else if (text == '-') {
      return TextEditingValue(
        text: '-',
        selection: _newValue.selection.copyWith(baseOffset: 1, extentOffset: 1),
        composing: TextRange.empty,
      );
    }

    return this.isValid(text) ? _newValue : oldValue;
  }

  bool isValid(String text) {
    int dots = '.'.allMatches(text).length;
    int minus = '-'.allMatches(text).length;

    if (text.isEmpty) {
      return true;
    }
    if (dots > 1 ||
        minus > 1 ||
        text.indexOf('-') > 0 ||
        double.parse(text) > max ||
        double.parse(text) < min) {
      return false;
    }

    return text.substring(text.indexOf('.') + 1).length <= decimalRange;
  }
}
