enum PayMethod { upi, card, wallet }

class SubscriptionPlan {
  const SubscriptionPlan(this.name, this.validity, this.price, this.unit);

  final String name;
  final String validity;
  final int price;
  final String unit;
}

const subscriptionPlans = [
  SubscriptionPlan('CAB EV - Daily', 'Valid for 1 day', 89, 'day'),
  SubscriptionPlan('CAB EV - Weekly', 'Valid for 7 days', 249, 'Week'),
  SubscriptionPlan('CAB EV - Monthly', 'Valid for 30 days', 749, 'Month'),
];

const subscriptionBenefits = [
  '0% Commission',
  'Fair & transparent earnings',
  'Parcel Access',
  'Flexible earning',
  'Verified platform',
  'Safety support (SOS & ride tracking)',
  'AI-based matching/dispatch',
  'Faster support',
  'Refer & earn',
];

String payMethodLabel(PayMethod method) {
  return switch (method) {
    PayMethod.upi => 'UPI',
    PayMethod.card => 'Debit/Credit Card',
    PayMethod.wallet => 'Wallet',
  };
}
