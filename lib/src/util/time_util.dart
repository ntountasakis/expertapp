import 'package:intl/intl.dart';

String messageTimeAnnotation(int msSinceEpochUtc) {
  final messageTime =
      DateTime.fromMillisecondsSinceEpoch(msSinceEpochUtc).toLocal();
  final DateFormat formatter = DateFormat().add_yMd().add_jm();
  return formatter.format(messageTime);
}
