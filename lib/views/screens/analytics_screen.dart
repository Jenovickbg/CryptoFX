import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/chart_controller.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedSymbol = 'BTC';

  static const Map<String, String> _symbolToCoinId = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChartController>().loadChart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Analytiques',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_outlined),
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Sélecteur de période
                    Consumer<ChartController>(
                      builder: (context, chart, _) {
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: ChartPeriod.values
                                .map((p) => Expanded(
                                      child: GestureDetector(
                                        onTap: () => chart.setPeriod(p),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: chart.period == p
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            p.label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: chart.period == p
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                              fontWeight: chart.period == p
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Sélecteur de paire (BTC, ETH, USDT vs USD)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paire à analyser',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedSymbol,
                          dropdownColor: AppColors.card,
                          underline: const SizedBox.shrink(),
                          items: _symbolToCoinId.keys
                              .map(
                                (sym) => DropdownMenuItem<String>(
                                  value: sym,
                                  child: Text(sym),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedSymbol = value);
                            final coinId = _symbolToCoinId[value]!;
                            context.read<ChartController>().setCoin(coinId);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Historique des variations',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($_selectedSymbol / USD)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: Consumer<ChartController>(
                              builder: (context, chart, _) {
                                if (chart.loading) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  );
                                }
                                if (chart.points.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Aucune donnée',
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  );
                                }
                                final spots = chart.points
                                    .map((p) => FlSpot(
                                          p.index.toDouble(),
                                          p.price,
                                        ))
                                    .toList();
                                final minY = chart.minPrice;
                                final maxY = chart.maxPrice;
                                final pad = (maxY - minY) * 0.1;
                                return LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                        color: AppColors.divider,
                                        strokeWidth: 0.5,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 42,
                                          getTitlesWidget: (value, meta) {
                                            if (value == meta.min ||
                                                value == meta.max) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: Text(
                                                value.toStringAsFixed(0),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      AppColors.textTertiary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      bottomTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: (chart.points.length - 1)
                                        .toDouble(),
                                    minY: minY - pad,
                                    maxY: maxY + pad,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: AppColors.primary,
                                        barWidth: 2,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(
                                          show: false,
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppColors.primary
                                              .withOpacity(0.15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(
                                    milliseconds: 250,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
