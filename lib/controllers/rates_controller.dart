import 'package:flutter/foundation.dart';

import '../services/rates_service.dart';

class RatesController extends ChangeNotifier {
  final RatesService _ratesService = RatesService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Map<String, double> _cryptoPrices = {};
  Map<String, double> _cryptoChange24h = {};
  double? _usdToCdf;

  Map<String, double> get cryptoPrices => Map.unmodifiable(_cryptoPrices);
  Map<String, double> get cryptoChange24h => Map.unmodifiable(_cryptoChange24h);
  double? get usdToCdf => _usdToCdf;

  /// Charge les taux pour l'accueil et la liste crypto.
  Future<void> loadRates() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCrypto(),
        _loadUsdCdf(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCrypto() async {
    _cryptoPrices = await _ratesService.getCryptoPricesInUsd();
    _cryptoChange24h = await _ratesService.getCryptoChangePercent24h();
  }

  Future<void> _loadUsdCdf() async {
    _usdToCdf = await _ratesService.getFiatRate('USD', 'CDF');
  }

  /// Conversion : montant, devise source, devise cible.
  double _lastResult = 0;
  double get lastResult => _lastResult;

  Future<double> convert(String from, String to, double amount) async {
    if (amount <= 0) {
      _lastResult = 0;
      notifyListeners();
      return 0;
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _lastResult = await _ratesService.convert(from, to, amount);
      return _lastResult;
    } catch (e) {
      _error = e.toString();
      _lastResult = 0;
      return 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<double> getRate(String from, String to) async {
    return _ratesService.getRate(from, to);
  }

  String formatCryptoPrice(String code) {
    final p = _cryptoPrices[code];
    if (p == null) return '—';
    if (p >= 1000) return '${(p).toStringAsFixed(2)} \$';
    if (p >= 1) return '${p.toStringAsFixed(2)} \$';
    return '${p.toStringAsFixed(4)} \$';
  }

  String formatChange24h(String code) {
    final c = _cryptoChange24h[code];
    if (c == null) return '0.00%';
    final prefix = c >= 0 ? '▲' : '▼';
    return '$prefix ${c.toStringAsFixed(2)}%';
  }

  bool isCryptoUp(String code) {
    final c = _cryptoChange24h[code];
    return (c ?? 0) >= 0;
  }
}
