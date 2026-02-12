import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// État d'auth + persistance via authStateChanges.
class AuthController extends ChangeNotifier {
  final AuthService _auth = AuthService();

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool _loading = false;
  bool get loading => _loading;

  StreamSubscription<User?>? _sub;

  AuthController() {
    _user = _auth.currentUser;
    _sub = _auth.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<String?> signUpWithEmail(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.signUpWithEmail(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageForCode(e.code);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmail(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageForCode(e.code);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    _loading = true;
    notifyListeners();
    try {
      final u = await _auth.signInWithGoogle();
      return u == null ? 'Connexion annulée' : null;
    } on FirebaseAuthException catch (e) {
      return _messageForCode(e.code);
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> updateDisplayName(String name) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.updateDisplayName(name.trim());
      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Erreur lors de la mise à jour du nom';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Met à jour la photo de profil (bytes issus de la galerie).
  /// N'utilise pas _loading pour éviter les spinners sur les boutons.
  Future<String?> updatePhotoFromBytes(Uint8List bytes) async {
    try {
      await _auth.updatePhotoFromBytes(bytes);
      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Erreur photo';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Mot de passe trop faible';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Ancien mot de passe incorrect';
        case 'requires-recent-login':
          return 'Veuillez vous reconnecter puis réessayer.';
        default:
          return e.message ?? 'Erreur lors du changement de mot de passe';
      }
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String? _messageForCode(String code) {
    switch (code) {
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Compte désactivé';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email ou mot de passe incorrect';
      case 'invalid-credential':
        return 'Identifiants incorrects';
      case 'network-request-failed':
        return 'Vérifiez votre connexion';
      default:
        return 'Erreur de connexion';
    }
  }
}
