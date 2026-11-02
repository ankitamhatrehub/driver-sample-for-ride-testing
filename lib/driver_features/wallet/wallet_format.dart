/// Number helpers shared by the wallet and earnings screens.
double toAmount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}'.replaceAll(',', '')) ?? 0;
}

/// First non-null numeric value among [keys], or null when none is present.
double? pickAmount(Map<dynamic, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value == null) continue;
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse('$value'.replaceAll(',', ''));
    if (parsed != null) return parsed;
  }
  return null;
}

/// ₹1,23,456.00 with Indian digit grouping.
String rupees(num amount, {int decimals = 2}) {
  final fixed = amount.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  var head = parts[0];
  if (head.length > 3) {
    final tail = head.substring(head.length - 3);
    var rest = head.substring(0, head.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    head = '${groups.join(',')},$tail';
  }
  final body = parts.length > 1 ? '$head.${parts[1]}' : head;
  return '${amount < 0 ? '-' : ''}₹$body';
}
