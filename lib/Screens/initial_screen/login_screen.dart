import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';

import 'package:fittracker_source/Screens/initial_screen/register_screen.dart';
import 'package:fittracker_source/core/session/session_store.dart';
import 'package:fittracker_source/services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LoginScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prefillUsername() async {
    final username = await SessionStore.getUsername();
    if (!mounted || username == null || username.isEmpty) return;
    _usernameController.text = username;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess || result.userData == null || result.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Login failed')),
      );
      return;
    }

    final username = result.username!;
    final userId = result.userId!;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const JournalScreen(),
        settings: RouteSettings(arguments: {'username': username, 'userId': userId}),
      ),
    );
  }

  Future<void> _openRegister() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (!mounted || result == null) return;
    final username = result['username']?.toString();
    if (username != null && username.isNotEmpty) {
      _usernameController.text = username;
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a username'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.length < 8
                    ? 'Password must be at least 8 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log in'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _openRegister,
                child: const Text("Don't have an account? Sign up"),
              ),
              const Spacer(),
              TextButton(onPressed: widget.onBack, child: const Text('Back')),
            ],
          ),
        ),
      ),
    );
  }
}
