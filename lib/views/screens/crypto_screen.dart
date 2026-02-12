import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/rates_controller.dart';
import '../../../core/theme/app_colors.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatesController>().loadRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RatesController>(
          builder: (context, rates, _) {
            if (rates.loading && rates.cryptoPrices.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final list = ['BTC', 'ETH', 'USDT'];
            return CustomScrollView(
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
                            const Text(
                              'Crypto',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined),
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...list.map(
                          (symbol) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CryptoCard(
                              symbol: symbol,
                              name: symbol == 'BTC'
                                  ? 'Bitcoin'
                                  : symbol == 'ETH'
                                      ? 'Ethereum'
                                      : 'Tether',
                              price: rates.formatCryptoPrice(symbol),
                              change: rates.formatChange24h(symbol),
                              isUp: rates.isCryptoUp(symbol),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CryptoCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isUp;

  const _CryptoCard({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              symbol.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  symbol,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isUp ? AppColors.up : AppColors.down,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
