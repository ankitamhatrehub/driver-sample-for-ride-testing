/// Placeholder payout data until the payout APIs are ready. Replace these with
/// API calls; the screens only read from these classes.
class PayoutMock {
  static const double availableBalance = 1000;
  static const double thisWeek = 3420;
  static const double pendingPayouts = 3420;

  /// Set to true to see the "Payment Failed" screen after tapping Withdraw.
  static const bool withdrawFails = false;

  static const List<PayoutEntry> today = [
    PayoutEntry('Personal Expense', '10:24 pm', 520),
    PayoutEntry('Transfer', '10:24 pm', 200),
    PayoutEntry('Billing', '10:24 pm', 430),
  ];
}

class PayoutEntry {
  const PayoutEntry(this.title, this.time, this.amount);

  final String title;
  final String time;
  final double amount;
}

/// What the withdraw flow shows on the result screens.
class WithdrawReceipt {
  const WithdrawReceipt({
    required this.amount,
    required this.transactionId,
    required this.dateTime,
    this.fee = 0,
    this.method = 'UPI',
    this.paidTo = 'upi@id65//',
  });

  final double amount;
  final String transactionId;
  final String dateTime;
  final double fee;
  final String method;
  final String paidTo;

  static const _months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];

  factory WithdrawReceipt.now(double amount) {
    final t = DateTime.now();
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'am' : 'pm';
    return WithdrawReceipt(
      amount: amount,
      transactionId: '${t.millisecondsSinceEpoch}'.substring(2, 13),
      dateTime:
          '${t.day} ${_months[t.month - 1]} , '
          '${h.toString().padLeft(2, '0')}:$m $ampm',
    );
  }
}
