/// Représente une devise (fiat ou crypto).
class Currency {
  final String code;
  final String name;
  final bool isCrypto;

  const Currency({
    required this.code,
    required this.name,
    this.isCrypto = false,
  });

  static const List<Currency> popular = [
    Currency(code: 'USD', name: 'Dollar américain'),
    Currency(code: 'EUR', name: 'Euro'),
    Currency(code: 'CDF', name: 'Franc congolais'),
    Currency(code: 'BTC', name: 'Bitcoin', isCrypto: true),
    Currency(code: 'ETH', name: 'Ethereum', isCrypto: true),
    Currency(code: 'USDT', name: 'Tether', isCrypto: true),
  ];
}
