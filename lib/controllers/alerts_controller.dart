import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/alert.dart';
import '../services/alerts_firestore_service.dart';

/// Gestion des alertes de prix (CRUD) + écoute Firestore.
class AlertsController extends ChangeNotifier {
  final AlertsFirestoreService _firestore = AlertsFirestoreService();

  List<PriceAlert> _alerts = [];
  List<PriceAlert> get alerts => List.unmodifiable(_alerts);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  StreamSubscription? _subscription;

  void listenAlerts(String? uid) {
    _subscription?.cancel();
    if (uid == null || uid.isEmpty) {
      _alerts = [];
      notifyListeners();
      return;
    }
    _subscription = _firestore.streamAlerts(uid).listen(
      (list) {
        _alerts = list;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<bool> addAlert(String uid, PriceAlert alert) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _firestore.addAlert(uid, alert);
      return id != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAlert(String uid, String alertId, PriceAlert alert) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.updateAlert(uid, alertId, alert);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAlert(String uid, String alertId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.deleteAlert(uid, alertId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
