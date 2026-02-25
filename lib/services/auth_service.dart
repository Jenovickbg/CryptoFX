import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Authentification Firebase : Email/Mot de passe + Google.
/// La persistance est gérée par défaut par Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inscription email / mot de passe
  Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  /// Connexion email / mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  /// Connexion avec Google
  ///
  /// - Web : Firebase Auth + popup Google.
  /// - Mobile/Desktop : plugin google_sign_in.
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web : utilise directement le provider Google de Firebase Auth.
      final provider = GoogleAuthProvider();
      final cred = await _auth.signInWithPopup(provider);
      return cred.user;
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      return cred.user;
    }
  }

  /// Met à jour le nom d'affichage (Firebase Auth + Firestore).
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);
    await user.reload();

    await _firestore.collection('users').doc(user.uid).set(
          {'displayName': displayName},
          SetOptions(merge: true),
        );
  }

  /// Met à jour la photo de profil (galerie → Storage → Auth + Firestore).
  Future<void> updatePhotoFromBytes(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _storage.ref().child('users').child(user.uid).child('avatar.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await user.reload();

    await _firestore.collection('users').doc(user.uid).set(
          {'photoURL': url},
          SetOptions(merge: true),
        );
  }

  /// Change le mot de passe en vérifiant l'ancien mot de passe.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Utilisateur non connecté',
      );
    }

    final cred = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Ré-authentification requise pour les opérations sensibles.
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
    await user.reload();
  }

  /// Déconnexion (Firebase + Google si utilisé)
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
