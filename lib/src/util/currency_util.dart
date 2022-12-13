import 'package:intl/intl.dart';

String formattedRate(num centsFee) {
  final dollarFormat = new NumberFormat("#,##0.00", "en_US");
  int dollars = (centsFee / 100).truncate();
  num cents = centsFee % 100;
  num decimalAmount = dollars + (cents / 100);
  return '\$${dollarFormat.format(decimalAmount)}';
}