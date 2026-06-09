import 'package:flutter/services.dart';

class TitleCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter of each word
    final words = newValue.text.split(' ');
    final titleCasedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final titleCasedText = titleCasedWords.join(' ');

    return TextEditingValue(
      text: titleCasedText,
      selection: newValue.selection,
    );
  }
}
