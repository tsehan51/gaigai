class PromptData {
  PromptData({
    required this.textInput,
    List<String>? placeTouristTextInput,
    this.dateInput,
  }) : placeTouristTextInput = placeTouristTextInput ?? [];

  PromptData.empty()
      : textInput = '',
        placeTouristTextInput = [],
        dateInput = null;

  String textInput;
  List<String> placeTouristTextInput;
  DateTime? dateInput;

//aaaaaaaaaaa
 @override
  String toString() {
    return 'PromptData(textInput: $textInput, placeTouristTextInput: $placeTouristTextInput)';
  }

  PromptData copyWith({
    String? textInput,
    List<String>? placeTouristTextInput,
    DateTime? dateInput,
  }) {
    return PromptData(
      textInput: textInput ?? this.textInput,
      placeTouristTextInput: placeTouristTextInput ?? this.placeTouristTextInput,
      dateInput: dateInput ?? this.dateInput,
    );
  }
}
