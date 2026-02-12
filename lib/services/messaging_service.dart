import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Notifications push (FCM) : permission, token, enregistrement Firestore.
/// Pour envoyer les alertes depuis un backend, utiliser le token stocké
/// dans users/{uid}/fcmToken.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Traitement en arrière-plan (optionnel)
}

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static void initBackground() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Demande la permission (iOS) et récupère le token.
  Future<String?> getToken() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          return null;
        }
      }
      final token = await _messaging.getToken();
      return token;
    } catch (_) {
      return null;
    }
  }

  /// Enregistre le token FCM dans Firestore (users/{uid}) pour les notifications.
  Future<void> saveTokenForUser(String uid) async {
    if (uid.isEmpty) return;
    final token = await getToken();
    if (token == null) return;
    try {
      await _firestore.collection('users').doc(uid).set(
            {'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  /// Supprime le token côté utilisateur (optionnel à la déconnexion).
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }

  /// Écoute les messages en premier plan (affichage in-app).
  void onForegroundMessage(void Function(RemoteMessage message) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }
}
