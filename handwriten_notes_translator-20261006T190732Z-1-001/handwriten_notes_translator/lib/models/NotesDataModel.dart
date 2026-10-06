class NotesDataModel {
  final String timeStamp;
  final String imagePath;
  final String text;

  NotesDataModel({
    required this.timeStamp,
    required this.imagePath,
    required this.text,
  });

  factory NotesDataModel.fromJson(Map<String, dynamic> json) {
    return NotesDataModel(
      timeStamp: json['timeStamp'] as String,
      imagePath: json['imagePath'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp,
      'imagePath': imagePath,
      'text': text,
    };
  }
}
