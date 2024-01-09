import 'package:intl/intl.dart';

String messageTimeAnnotation(int msSinceEpochUtc) {
  final messageTime =
      DateTime.fromMillisecondsSinceEpoch(msSinceEpochUtc).toLocal();
  final DateFormat formatter = DateFormat().add_yMd().add_jm();
  return formatter.format(messageTime);
}

Map<String, int> convertMillisecondsToMinutesAndSeconds(int milliseconds) {
  int totalSeconds = (milliseconds ~/ 1000).floor();
  int minutes = (totalSeconds ~/ 60).floor();
  int seconds = totalSeconds % 60;

  return {'minutes': minutes, 'seconds': seconds};
}
