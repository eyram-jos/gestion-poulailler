import 'package:intl/intl.dart';

String formatDate(DateTime d) => DateFormat.yMMMd().format(d);
num round2(num v) => double.parse(v.toStringAsFixed(2));
