import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/alerts_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/alert.dart';
import '../../../models/currency.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthController>().user?.uid;
      context.read<AlertsController>().listenAlerts(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Alertes de prix'),
      ),
      body: Consumer2<AlertsController, AuthController>(
        builder: (context, alerts, auth, _) {
          if (auth.user == null) {
            return Center(
              child: Text(
                'Connectez-vous pour gérer vos alertes',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          if (alerts.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(alerts.error!, style: TextStyle(color: AppColors.down)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => alerts.listenAlerts(auth.user?.uid),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (alerts.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune alerte',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour en créer une',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: alerts.alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts.alerts[index];
              return _AlertTile(
                alert: alert,
                onEdit: () => _showAlertDialog(context, alerts, auth, alert: alert),
                onDelete: () => _deleteAlert(context, alerts, auth, alert),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<AuthController>(
        builder: (context, auth, _) {
          if (auth.user == null) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showAlertDialog(context, context.read<AlertsController>(), auth),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Future<void> _deleteAlert(
    BuildContext context,
    AlertsController alerts,
    AuthController auth,
    PriceAlert alert,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Supprimer l\'alerte ?'),
        content: Text(
          alert.shortDescription,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Supprimer', style: TextStyle(color: AppColors.down)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await alerts.deleteAlert(auth.user!.uid, alert.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Alerte supprimée' : alerts.error ?? 'Erreur'),
          backgroundColor: ok ? AppColors.up : AppColors.down,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAlertDialog(
    BuildContext context,
    AlertsController alertsController,
    AuthController auth, {
    PriceAlert? alert,
  }) async {
    final isEdit = alert != null;
    String asset = alert?.asset ?? 'BTC';
    String targetCurrency = alert?.targetCurrency ?? 'USD';
    bool isAbove = alert?.isAbove ?? true;
    final controller = TextEditingController(
      text: alert?.targetValue.toString() ?? '',
    );

    final codes = Currency.popular.map((c) => c.code).toList();

    final result = await showDialog<PriceAlert>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(isEdit ? 'Modifier l\'alerte' : 'Nouvelle alerte'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Actif', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: asset,
                    dropdownColor: AppColors.card,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: codes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setDialogState(() => asset = v ?? asset),
                  ),
                  const SizedBox(height: 16),
                  const Text('Devise cible', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: targetCurrency,
                    dropdownColor: AppColors.card,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: codes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setDialogState(() => targetCurrency = v ?? targetCurrency),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Au-dessus de')),
                      ButtonSegment(value: false, label: Text('En-dessous de')),
                    ],
                    selected: {isAbove},
                    onSelectionChanged: (s) => setDialogState(() => isAbove = s.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return AppColors.primary;
                        return AppColors.surface;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valeur cible',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text.replaceFirst(',', '.'));
                  if (value == null || value <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Saisissez une valeur valide'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final a = PriceAlert(
                    id: alert?.id ?? '',
                    asset: asset,
                    targetCurrency: targetCurrency,
                    isAbove: isAbove,
                    targetValue: value,
                    createdAt: alert?.createdAt ?? DateTime.now(),
                  );
                  Navigator.pop(ctx, a);
                },
                child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
              ),
            ],
          );
        },
      ),
    );

    controller.dispose();
    if (result == null || !context.mounted) return;

    bool ok;
    if (isEdit) {
      ok = await alertsController.updateAlert(auth.user!.uid, alert.id, result);
    } else {
      ok = await alertsController.addAlert(auth.user!.uid, result) != false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? (isEdit ? 'Alerte modifiée' : 'Alerte créée') : alertsController.error ?? 'Erreur',
          ),
          backgroundColor: ok ? AppColors.up : AppColors.down,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AlertTile extends StatelessWidget {
  final PriceAlert alert;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlertTile({
    required this.alert,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
        ),
        title: Text(
          alert.shortDescription,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          color: AppColors.card,
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }
}
