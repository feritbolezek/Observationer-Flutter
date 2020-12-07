import 'package:characters/characters.dart';
import 'package:flutter/services.dart';

/// A fixed LengthLimitingTextInputFormatter, since it doesn't work as expected
/// Enforces that you will only be able to input maxLength number of characters
/// in a TextField
class LengthLimitingTextInputFormatterFixed
    extends LengthLimitingTextInputFormatter {
  LengthLimitingTextInputFormatterFixed(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (maxLength != null &&
        maxLength > 0 &&
        newValue.text.characters.length > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      return LengthLimitingTextInputFormatter.truncate(newValue, maxLength);
    }
    return newValue;
  }
}