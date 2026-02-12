/// Taux de change ou cours crypto (temps réel + variation).
class Rate {
  final String from;
  final String to;
  final double rate;
  final double? changePercent;
  final DateTime? updatedAt;

  const Rate({
    required this.from,
    required this.to,
    required this.rate,
    this.changePercent,
    this.updatedAt,
  });

  bool get isUp => (changePercent ?? 0) >= 0;
}
