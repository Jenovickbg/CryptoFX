/// Alerte de prix : ex. "Alerte si BTC > 70 000\$", "Alerte si USD dépasse 3000 CDF".
class PriceAlert {
  final String id;
  final String asset;       // ex. BTC, USD, ETH
  final String targetCurrency; // ex. USD, CDF (pour afficher "70 000\$" ou "3000 CDF")
  final bool isAbove;       // true = au-dessus de, false = en-dessous de
  final double targetValue;
  final DateTime createdAt;

  const PriceAlert({
    required this.id,
    required this.asset,
    required this.targetCurrency,
    required this.isAbove,
    required this.targetValue,
    required this.createdAt,
  });

  String get conditionLabel => isAbove ? 'au-dessus de' : 'en-dessous de';
  String get shortDescription {
    final isWhole = targetValue == targetValue.truncate().toDouble();
    return '$asset $conditionLabel ${targetValue.toStringAsFixed(isWhole ? 0 : 2)} $targetCurrency';
  }

  Map<String, dynamic> toMap() => {
        'asset': asset,
        'targetCurrency': targetCurrency,
        'isAbove': isAbove,
        'targetValue': targetValue,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  static PriceAlert fromMap(String id, Map<String, dynamic> map) {
    return PriceAlert(
      id: id,
      asset: map['asset'] as String? ?? '',
      targetCurrency: map['targetCurrency'] as String? ?? 'USD',
      isAbove: map['isAbove'] as bool? ?? true,
      targetValue: (map['targetValue'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as int?) ?? 0,
      ),
    );
  }
}
