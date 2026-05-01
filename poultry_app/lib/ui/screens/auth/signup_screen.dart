import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/validators.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthProvider>().signup(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 48,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bienvenue sur OG PoultryPro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Créez votre compte et commencez à suivre votre élevage gratuitement pendant 14 jours.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Inscription',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: validateNotEmpty,
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: validateEmail,
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: validateNotEmpty,
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Créer mon compte'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Suivez vos dépenses, ventes, mortalités et bénéfices en un seul endroit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}