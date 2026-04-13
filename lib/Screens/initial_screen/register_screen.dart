import 'package:flutter/material.dart';

import 'package:fittracker_source/services/auth_service.dart';
import 'package:fittracker_source/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  /// When used inside StepProgressForm (onboarding flow)
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const RegisterScreen({super.key, this.onNext, this.onBack});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  /// Whether this screen is embedded in the onboarding flow
  bool get _isEmbedded => widget.onNext != null;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final rawInfo = await UserService.getUserInfo();
    final localProfile = <String, dynamic>{...?rawInfo};
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final result = await AuthService.register(
      username: username,
      password: password,
      localProfile: localProfile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Registration failed')),
      );
      return;
    }

    if (_isEmbedded) {
      // Continue onboarding flow (step5 health goal)
      widget.onNext!();
    } else {
      // Standalone mode: pop back with result
      Navigator.of(context).pop({
        'username': result.username ?? username,
        'userId': result.userId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isEmbedded ? null : AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEmbedded) ...[
                const SizedBox(height: 20),
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to save your personalized plan',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a username';
                  if (v.trim().length < 3) return 'Username too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'At least 8 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                validator: (v) {
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create account', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (_isEmbedded) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Back'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
