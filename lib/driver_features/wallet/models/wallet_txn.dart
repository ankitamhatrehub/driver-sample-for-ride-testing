
class WalletTxn {
  const WalletTxn({
    required this.kind,
    required this.time,
    required this.amount,
    required this.parcel,
  });

  final String kind;
  final String time;
  final String amount;
  final bool parcel;
}
