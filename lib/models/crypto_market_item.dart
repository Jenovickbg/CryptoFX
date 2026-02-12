/// Une crypto avec prix et variation 24h (liste CoinGecko /coins/markets).
class CryptoMarketItem {
  final String id;
  final String symbol;
  final String name;
  final double priceUsd;
  final double? changePercent24h;
  final String? imageUrl;

  const CryptoMarketItem({
    required this.id,
    required this.symbol,
    required this.name,
    required this.priceUsd,
    this.changePercent24h,
    this.imageUrl,
  });

  bool get isUp => (changePercent24h ?? 0) >= 0;

  String get priceFormatted {
    if (priceUsd >= 1000) return '${priceUsd.toStringAsFixed(2)} \$';
    if (priceUsd >= 1) return '${priceUsd.toStringAsFixed(2)} \$';
    if (priceUsd >= 0.0001) return '${priceUsd.toStringAsFixed(4)} \$';
    return '${priceUsd.toStringAsFixed(6)} \$';
  }

  String get changeFormatted {
    final c = changePercent24h ?? 0;
    final prefix = c >= 0 ? '▲' : '▼';
    return '$prefix ${c.toStringAsFixed(2)}%';
  }
}
