import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _username.text.trim();
    final password = _password.text;
    String message;

    if (_isRegister) {
      final created = await DatabaseService.instance.register(username, password);
      message = created
          ? 'Registrasi berhasil. Silakan login.'
          : 'Username sudah digunakan atau registrasi gagal.';
      if (created && mounted) {
        setState(() {
          _isRegister = false;
          _password.clear();
        });
      }
    } else {
      final valid = await DatabaseService.instance.login(username, password);
      if (valid) {
        await PreferencesService().saveSession(username);
        if (mounted) widget.onAuthenticated();
        return;
      }
      message = 'Username atau password salah.';
    }

    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegister ? 'Buat Akun' : 'Selamat Datang';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101B2D), Color(0xFF173D43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.travel_explore, size: 54, color: Color(0xFF168B83)),
                          const SizedBox(height: 12),
                          Text('Rick & Morty Explorer',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(height: 8),
                          Text(title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _username,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 3
                                    ? 'Username minimal 3 karakter'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                    ? 'Password minimal 6 karakter'
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(_isRegister ? 'Register' : 'Login'),
                            ),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() => _isRegister = !_isRegister),
                            child: Text(_isRegister
                                ? 'Sudah punya akun? Login'
                                : 'Belum punya akun? Register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
