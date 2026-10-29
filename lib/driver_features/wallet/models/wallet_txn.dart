class WalletTxn {
  const WalletTxn({
    required this.kind,
    required this.time,
    required this.amount,
    required this.parcel,
    this.name = 'User',
    this.date,
  });

  final String kind;
  final String time;
  final String amount;
  final bool parcel;
  final String name;
  final DateTime? date;

  /// Builds a transaction from a transaction-history API item.
  factory WalletTxn.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return '';
    }

    final type = pick(['type', 'transaction_type', 'category', 'service_type', 'ride_type', 'kind']).toLowerCase();
    final parcel = type.contains('parcel');

    final rawAmount = double.tryParse(pick(['amount', 'total', 'fare', 'earning', 'earnings'])) ?? 0;
    final isDebit = type.contains('debit') || type.contains('withdraw') || rawAmount < 0;
    final amountText = '${isDebit ? '-' : '+'}₹${rawAmount.abs().toStringAsFixed(2)}';

    final date = DateTime.tryParse(pick(['created_at', 'date', 'timestamp', 'time', 'completed_at']))?.toLocal();

    return WalletTxn(
      kind: parcel ? 'Parcel' : 'Ride',
      time: date == null ? '' : _formatTime(date),
      amount: amountText,
      parcel: parcel,
      name: pick(['customer_name', 'user_name', 'passenger_name', 'name']).isEmpty
          ? 'User'
          : pick(['customer_name', 'user_name', 'passenger_name', 'name']),
      date: date,
    );
  }

  static String _formatTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h12:$m ${d.hour >= 12 ? 'pm' : 'am'}';
  }
}
