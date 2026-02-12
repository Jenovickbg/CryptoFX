import 'package:flutter/foundation.dart';

import '../services/rates_service.dart';

enum ChartPeriod { h1, h24, d7, m1 }

extension ChartPeriodExt on ChartPeriod {
  int get days => switch (this) {
        ChartPeriod.h1 => 1,
        ChartPeriod.h24 => 1,
        ChartPeriod.d7 => 7,
        ChartPeriod.m1 => 30,
      };
  bool get lastHourOnly => this == ChartPeriod.h1;
  String get label => switch (this) {
        ChartPeriod.h1 => '1h',
        ChartPeriod.h24 => '24h',
        ChartPeriod.d7 => '7j',
        ChartPeriod.m1 => '1 mois',
      };
}

/// Données pour un point du graphique (index, prix).
class ChartPoint {
  final int index;
  final double price;
  final DateTime time;

  const ChartPoint({required this.index, required this.price, required this.time});
}

class ChartController extends ChangeNotifier {
  final RatesService _rates = RatesService();

  ChartPeriod _period = ChartPeriod.h24;
  ChartPeriod get period => _period;

  List<ChartPoint> _points = [];
  List<ChartPoint> get points => List.unmodifiable(_points);

  bool _loading = false;
  bool get loading => _loading;

  String _coinId = 'bitcoin';
  String get coinId => _coinId;

  Future<void> loadChart({String? coinId}) async {
    if (coinId != null) _coinId = coinId;
    _loading = true;
    notifyListeners();
    try {
      final list = await _rates.getMarketChart(
        _coinId,
        days: _period.days,
        lastHourOnly: _period.lastHourOnly,
      );
      _points = list
          .asMap()
          .entries
          .map((e) => ChartPoint(
                index: e.key,
                price: e.value.value,
                time: e.value.key,
              ))
          .toList();
    } catch (_) {
      _points = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setCoin(String coinId) {
    if (_coinId == coinId) return;
    _coinId = coinId;
    loadChart();
  }

  void setPeriod(ChartPeriod p) {
    if (_period == p) return;
    _period = p;
    loadChart();
  }

  double get minPrice =>
      _points.isEmpty ? 0 : _points.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  double get maxPrice =>
      _points.isEmpty ? 0 : _points.map((e) => e.price).reduce((a, b) => a > b ? a : b);
}
