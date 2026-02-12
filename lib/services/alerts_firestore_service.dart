import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert.dart';

/// CRUD Firestore pour les alertes de prix.
/// Structure : users / {uid} / alerts / {alertId}
class AlertsFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _alertsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('alerts');

  /// Lecture : stream des alertes de l'utilisateur (temps réel).
  Stream<List<PriceAlert>> streamAlerts(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _alertsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PriceAlert.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Ajout.
  Future<String?> addAlert(String uid, PriceAlert alert) async {
    if (uid.isEmpty) return null;
    final ref = await _alertsRef(uid).add(alert.toMap());
    return ref.id;
  }

  /// Modification.
  Future<void> updateAlert(String uid, String alertId, PriceAlert alert) async {
    if (uid.isEmpty || alertId.isEmpty) return;
    await _alertsRef(uid).doc(alertId).update(alert.toMap());
  }

  /// Suppression.
  Future<void> deleteAlert(String uid, String alertId) async {
    if (uid.isEmpty || alertId.isEmpty) return;
    await _alertsRef(uid).doc(alertId).delete();
  }

  /// Lecture ponctuelle (optionnel).
  Future<List<PriceAlert>> getAlerts(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _alertsRef(uid).orderBy('createdAt', descending: true).get();
    return snap.docs.map((doc) => PriceAlert.fromMap(doc.id, doc.data())).toList();
  }
}
