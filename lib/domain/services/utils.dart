extension StringCasingExtension on String {
  String toCapitalizedEachWord() => toBeginningOfSentenceCase(this);

  String toBeginningOfSentenceCase(String input) {
    if (input.isEmpty) {
      return input;
    }
    final List<String> words = input.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return '';
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    return capitalizedWords.join(' ');
  }
}
