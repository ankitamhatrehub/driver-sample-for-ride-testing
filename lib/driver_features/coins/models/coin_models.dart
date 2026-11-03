int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
String _str(Object? v) => v == null ? '' : '$v';

/// GET /coins/account -> `data`.
class CoinAccount {
  const CoinAccount({
    required this.coins,
    required this.earned,
    required this.redeemed,
    required this.tier,
  });

  final int coins;
  final int earned;
  final int redeemed;
  final String tier;

  factory CoinAccount.fromJson(Map<String, dynamic> j) => CoinAccount(
    coins: _int(j['coins']),
    earned: _int(j['earned']),
    redeemed: _int(j['redeemed']),
    tier: _str(j['tier']),
  );
}

/// One row of GET /coins/ledger.
class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.isCredit,
    required this.amount,
    required this.balanceAfter,
    required this.reason,
    required this.createdAt,
  });

  final int id;
  final bool isCredit;
  final int amount;
  final int balanceAfter;
  final String reason;
  final DateTime? createdAt;

  factory CoinTransaction.fromJson(Map<String, dynamic> j) => CoinTransaction(
    id: _int(j['id']),
    isCredit: _str(j['transaction_type']).toLowerCase() == 'credit',
    amount: _int(j['amount']),
    balanceAfter: _int(j['balance_after']),
    reason: _str(j['reason']),
    createdAt: DateTime.tryParse(_str(j['created_at']))?.toLocal(),
  );
}

/// One row of GET /driver/coins/earning-rules.
class CoinEarningRule {
  const CoinEarningRule({
    required this.code,
    required this.name,
    required this.description,
    required this.coinAmount,
  });

  final String code;
  final String name;
  final String description;
  final int coinAmount;

  factory CoinEarningRule.fromJson(Map<String, dynamic> j) => CoinEarningRule(
    code: _str(j['rule_code']),
    name: _str(j['name']),
    description: _str(j['description']),
    coinAmount: _int(j['coin_amount']),
  );
}

/// One row of GET /driver/coins/milestones.
class CoinMilestone {
  const CoinMilestone({
    required this.code,
    required this.name,
    required this.target,
    required this.current,
    required this.reward,
    required this.isCompleted,
  });

  final String code;
  final String name;
  final int target;
  final int current;
  final int reward;
  final bool isCompleted;

  factory CoinMilestone.fromJson(Map<String, dynamic> j) => CoinMilestone(
    code: _str(j['rule_code']),
    name: _str(j['name']),
    target: _int(j['target_count']),
    current: _int(j['current_count']),
    reward: _int(j['coins_reward']),
    isCompleted: j['is_completed'] == true,
  );
}

/// One row of GET /driver/coins/daily-missions.
class CoinMission {
  const CoinMission({
    required this.id,
    required this.title,
    required this.target,
    required this.done,
    required this.reward,
    required this.status,
  });

  final int id;
  final String title;
  final int target;
  final int done;
  final int reward;
  final String status;

  bool get isCompleted => status.toLowerCase() == 'completed' || done >= target;

  factory CoinMission.fromJson(Map<String, dynamic> j) => CoinMission(
    id: _int(j['id']),
    title: _str(j['title']),
    target: _int(j['target_rides']),
    done: _int(j['rides_done']),
    reward: _int(j['coin_reward']),
    status: _str(j['status']),
  );
}

/// GET /coins/scratch-cards/available -> `data.card`.
class ScratchCard {
  const ScratchCard({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.description,
    required this.coinAmount,
    required this.expiresAt,
  });

  final String id;
  final String campaignId;
  final String title;
  final String description;
  final int coinAmount;
  final DateTime? expiresAt;

  factory ScratchCard.fromJson(Map<String, dynamic> j) => ScratchCard(
    id: _str(j['id']),
    campaignId: _str(j['campaign_id']),
    title: _str(j['title']),
    description: _str(j['description']),
    coinAmount: _int(j['coin_amount']),
    expiresAt: DateTime.tryParse(_str(j['expires_at']))?.toLocal(),
  );
}

/// POST /coins/scratch-cards/{id}/claim -> `data`.
class ScratchClaim {
  const ScratchClaim({
    required this.cardId,
    required this.coinsAwarded,
    required this.newBalance,
  });

  final String cardId;
  final int coinsAwarded;
  final int newBalance;

  factory ScratchClaim.fromJson(Map<String, dynamic> j) => ScratchClaim(
    cardId: _str(j['scratch_card_id']),
    coinsAwarded: _int(j['coins_awarded']),
    newBalance: _int(j['new_balance']),
  );
}
