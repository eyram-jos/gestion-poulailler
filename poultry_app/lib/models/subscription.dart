class SubscriptionModel {
  final String plan;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? renewAt;

  const SubscriptionModel({
    required this.plan,
    required this.status,
    this.trialEndsAt,
    this.renewAt,
  });

  bool get isPro => plan == 'pro' && status == 'active';
  bool get isTrial => status == 'trial';

  Map<String, dynamic> toMap() => {
        'plan': plan,
        'status': status,
        'trialEndsAt': trialEndsAt,
        'renewAt': renewAt,
      };

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      final maybeTimestamp = v as dynamic;
      return maybeTimestamp.toDate?.call();
    }

    return SubscriptionModel(
      plan: (map['plan'] ?? 'free').toString(),
      status: (map['status'] ?? 'trial').toString(),
      trialEndsAt: toDate(map['trialEndsAt']),
      renewAt: toDate(map['renewAt']),
    );
  }
}
