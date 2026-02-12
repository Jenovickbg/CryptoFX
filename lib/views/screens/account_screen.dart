import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameController = TextEditingController();
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();
  final _picker = ImagePicker();

  final _pwdFormKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _photoLoading = false;

  @override
  void initState() {
    super.initState();
    _photoLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().user;
      _nameController.text = user?.displayName ?? user?.email?.split('@').first ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _saveName(AuthController auth) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom ne peut pas être vide'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.down,
        ),
      );
      return;
    }
    final msg = await auth.updateDisplayName(name);
    if (!mounted) return;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.down,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom mis à jour'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.up,
        ),
      );
    }
  }

  static const _photoTimeout = Duration(seconds: 25);

  Future<void> _pickAndUpdatePhoto(AuthController auth) async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    setState(() => _photoLoading = true);
    String? msg;
    try {
      final bytes = await xFile.readAsBytes();
      msg = await auth.updatePhotoFromBytes(bytes).timeout(
        _photoTimeout,
        onTimeout: () => throw TimeoutException('Délai dépassé. Vérifiez la connexion et Storage.'),
      );
    } on TimeoutException catch (e) {
      msg = e.message ?? 'Délai dépassé';
    } catch (e) {
      msg = e.toString();
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
    if (!mounted) return;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.down,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo mise à jour'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.up,
        ),
      );
    }
  }

  Future<void> _changePassword(AuthController auth) async {
    if (!_pwdFormKey.currentState!.validate()) return;
    final current = _currentPwdController.text;
    final newPwd = _newPwdController.text;

    final msg = await auth.changePassword(
      currentPassword: current,
      newPassword: newPwd,
    );
    if (!mounted) return;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.down,
        ),
      );
    } else {
      _currentPwdController.clear();
      _newPwdController.clear();
      _confirmPwdController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe mis à jour'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.up,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<AuthController>(
            builder: (context, auth, _) {
              final email = auth.user?.email ?? '';
              final photoUrl = auth.user?.photoURL;
              final initial = (auth.user?.displayName ?? auth.user?.email ?? '?')
                  .trim()
                  .isNotEmpty
                  ? (auth.user!.displayName ?? auth.user!.email ?? '?')
                      .trim()
                      .substring(0, 1)
                      .toUpperCase()
                  : '?';
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _photoLoading || auth.loading
                            ? null
                            : () => _pickAndUpdatePhoto(auth),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.surface,
                              backgroundImage:
                                  photoUrl != null ? NetworkImage(photoUrl) : null,
                              child: photoUrl == null
                                  ? Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: AppColors.textPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_photoLoading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Informations du profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: email,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.loading ? null : () => _saveName(auth),
                        child: auth.loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enregistrer le profil'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Modifier le mot de passe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _pwdFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _currentPwdController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: 'Ancien mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrent
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Entrez votre ancien mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _newPwdController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: 'Nouveau mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Entrez un nouveau mot de passe';
                              }
                              if (v.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPwdController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirmer le nouveau mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v != _newPwdController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.loading
                                  ? null
                                  : () => _changePassword(auth),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Mettre à jour le mot de passe'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

