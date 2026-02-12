import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/rates_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/currency.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final _amountController = TextEditingController(text: '');
  String _from = 'USD';
  String _to = 'CDF';
  double _result = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert(RatesController ctrl) async {
    final amount = double.tryParse(
      _amountController.text.replaceFirst(',', '.'),
    ) ?? 0;
    if (amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saisissez un montant valide'),
            backgroundColor: AppColors.down,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final res = await ctrl.convert(_from, _to, amount);
    if (mounted) {
      setState(() => _result = res);
      if (ctrl.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ctrl.error!),
            backgroundColor: AppColors.down,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = Currency.popular.map((c) => c.code).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Convertir'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<RatesController>(
          builder: (context, ctrl, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _AmountCard(
                    label: 'De',
                    code: _from,
                    codes: codes,
                    controller: _amountController,
                    onCodeChanged: (v) => setState(() => _from = v),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => setState(() {
                      final t = _to;
                      _to = _from;
                      _from = t;
                    }),
                    icon: const Icon(Icons.swap_vert, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 16),
                  _ResultCard(
                    to: _to,
                    result: _result,
                    loading: ctrl.loading,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctrl.loading
                          ? null
                          : () => _convert(ctrl),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: ctrl.loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Convertir'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final String code;
  final List<String> codes;
  final TextEditingController controller;
  final ValueChanged<String> onCodeChanged;

  const _AmountCard({
    required this.label,
    required this.code,
    required this.codes,
    required this.controller,
    required this.onCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_exchange, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: code,
                dropdownColor: AppColors.card,
                underline: const SizedBox(),
                items: codes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) onCodeChanged(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: '0,00',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Text(
            'Saisir le montant',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String to;
  final double result;
  final bool loading;

  const _ResultCard({required this.to, required this.result, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vers', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          if (loading)
            const SizedBox(
              height: 32,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else
            Text(
              '${result.toStringAsFixed(2)} $to',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
