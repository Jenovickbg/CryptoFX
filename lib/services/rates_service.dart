import 'dart:convert';

import 'package:http/http.dart' as http;

/// Consommation API REST : taux fiat (Frankfurter) + crypto (CoinGecko).
class RatesService {
  static const _frankfurterBase = 'https://api.frankfurter.app';
  static const _coingeckoBase = 'https://api.coingecko.com/api/v3';

  final http.Client _client = http.Client();

  /// Taux de change entre devises classiques (USD, EUR, etc.).
  /// CDF non supporté par Frankfurter : fallback fixe 1 USD ≈ 2800 CDF.
  Future<double> getFiatRate(String from, String to) async {
    if (from == to) return 1.0;

    // CDF : taux indicatif (API gratuite sans CDF)
    const double usdToCdf = 2800.0;
    if (from == 'CDF' && to == 'USD') return 1 / usdToCdf;
    if (from == 'USD' && to == 'CDF') return usdToCdf;
    if (from == 'CDF' && to == 'EUR') return (1 / usdToCdf) * await _eurPerUsd();
    if (from == 'EUR' && to == 'CDF') return await _eurPerUsd() * usdToCdf;
    if (to == 'CDF') return (await getFiatRate(from, 'USD')) * usdToCdf;
    if (from == 'CDF') return await getFiatRate('USD', to) / usdToCdf;

    try {
      final uri = Uri.parse(
        '$_frankfurterBase/latest?from=$from&to=$to',
      );
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) return _fallbackFiat(from, to);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      if (rates == null || !rates.containsKey(to)) return _fallbackFiat(from, to);
      return (rates[to] as num).toDouble();
    } catch (_) {
      return _fallbackFiat(from, to);
    }
  }

  Future<double> _eurPerUsd() async {
    try {
      final response = await _client.get(
        Uri.parse('$_frankfurterBase/latest?from=USD&to=EUR'),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return 0.92;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      return rates != null && rates.containsKey('EUR')
          ? (rates['EUR'] as num).toDouble()
          : 0.92;
    } catch (_) {
      return 0.92;
    }
  }

  double _fallbackFiat(String from, String to) {
    if (from == 'USD' && to == 'EUR') return 0.92;
    if (from == 'EUR' && to == 'USD') return 1.09;
    return 1.0;
  }

  /// Cours crypto en USD (CoinGecko).
  Future<Map<String, double>> getCryptoPricesInUsd() async {
    try {
      const ids = 'bitcoin,ethereum,tether';
      final uri = Uri.parse(
        '$_coingeckoBase/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true',
      );
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) return _fallbackCrypto();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final btc = (data['bitcoin'] as Map<String, dynamic>?)?['usd'];
      final eth = (data['ethereum'] as Map<String, dynamic>?)?['usd'];
      final usdt = (data['tether'] as Map<String, dynamic>?)?['usd'];
      return {
        'BTC': (btc is num) ? btc.toDouble() : 60000.0,
        'ETH': (eth is num) ? eth.toDouble() : 3000.0,
        'USDT': (usdt is num) ? usdt.toDouble() : 1.0,
      };
    } catch (_) {
      return _fallbackCrypto();
    }
  }

  Map<String, double> _fallbackCrypto() =>
      {'BTC': 60000.0, 'ETH': 3000.0, 'USDT': 1.0};

  /// Variation 24h en % (CoinGecko).
  Future<Map<String, double>> getCryptoChangePercent24h() async {
    try {
      const ids = 'bitcoin,ethereum,tether';
      final uri = Uri.parse(
        '$_coingeckoBase/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true',
      );
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) return {};
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final out = <String, double>{};
      for (final e in ['bitcoin', 'ethereum', 'tether']) {
        final map = data[e] as Map<String, dynamic>?;
        final change = map?['usd_24h_change'];
        if (change is num) {
          final code = e == 'bitcoin' ? 'BTC' : e == 'ethereum' ? 'ETH' : 'USDT';
          out[code] = change.toDouble();
        }
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  /// Historique des prix pour le graphique (CoinGecko market_chart).
  /// [coinId] ex. bitcoin, ethereum. [days] 1, 7 ou 30.
  /// Pour "1h" on utilise days=1 et on garde les derniers points (≈1h).
  Future<List<MapEntry<DateTime, double>>> getMarketChart(
    String coinId, {
    int days = 1,
    bool lastHourOnly = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$_coingeckoBase/coins/$coinId/market_chart?vs_currency=usd&days=$days',
      );
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final prices = data['prices'] as List<dynamic>?;
      if (prices == null || prices.isEmpty) return [];
      final list = <MapEntry<DateTime, double>>[];
      for (final p in prices) {
        if (p is! List || p.length < 2) continue;
        final ts = (p[0] as num).toDouble().toInt();
        final price = (p[1] as num).toDouble();
        list.add(MapEntry(DateTime.fromMillisecondsSinceEpoch(ts), price));
      }
      list.sort((a, b) => a.key.compareTo(b.key));
      if (lastHourOnly && list.length > 12) {
        return list.sublist(list.length - 12);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Convertit un montant entre deux devises (fiat ou crypto).
  Future<double> convert(String from, String to, double amount) async {
    final rate = await getRate(from, to);
    return amount * rate;
  }

  /// Un seul taux (fiat ou crypto).
  Future<double> getRate(String from, String to) async {
    if (from == to) return 1.0;
    final cryptoCodes = ['BTC', 'ETH', 'USDT'];
    final fromCrypto = cryptoCodes.contains(from);
    final toCrypto = cryptoCodes.contains(to);
    if (fromCrypto && toCrypto) {
      final prices = await getCryptoPricesInUsd();
      final fromPrice = prices[from] ?? 0;
      final toPrice = prices[to] ?? 0;
      if (toPrice == 0) return 0;
      return fromPrice / toPrice;
    }
    if (fromCrypto && to == 'USD') {
      final prices = await getCryptoPricesInUsd();
      return prices[from] ?? 0;
    }
    if (from == 'USD' && toCrypto) {
      final prices = await getCryptoPricesInUsd();
      final p = prices[to] ?? 0;
      return p == 0 ? 0 : 1 / p;
    }
    if (fromCrypto) {
      final usdPerFrom = await getRate(from, 'USD');
      final toPerUsd = await getFiatRate('USD', to);
      return usdPerFrom * toPerUsd;
    }
    if (toCrypto) {
      final usdPerFrom = await getFiatRate(from, 'USD');
      final toPerUsd = await getRate('USD', to);
      return usdPerFrom * toPerUsd;
    }
    return getFiatRate(from, to);
  }
}
