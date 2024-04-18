import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginStateScreen();
}

class _LoginStateScreen extends State<LoginScreen> {
  final _loginNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: TextFormField(
                controller: _loginNameController,
                decoration: const InputDecoration(
                  labelText: 'Login Name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: _validateLoginName,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onLogin,
              label: const Text('Login'),
              icon: const Icon(Icons.login),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateLoginName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your login name';
    }

    if (value.length < 5) {
      return 'Login name must be at least 5 characters';
    }

    // Only lowercase ascii letters, digits and underscore are allowed
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      return 'Only lowercase letters, digits and underscore are allowed';
    }

    return null;
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loginName = _loginNameController.text;
    await Preferences.instance.setLoginName(loginName);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
