import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/validators.dart';
import '../home/dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez votre email d’abord.')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email de réinitialisation envoyé. Vérifiez votre boîte mail.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade800,
                          Colors.green.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 52,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'OG PoultryPro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Le copilote de votre élevage',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Suivez vos dépenses, ventes, mortalités et bénéfices depuis votre téléphone.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
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
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Connectez-vous pour gérer votre élevage.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),

                            const SizedBox(height: 18),

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

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        setState(() => _loading = true);

                                        try {
                                          await context
                                              .read<AuthProvider>()
                                              .login(
                                                _emailController.text.trim(),
                                                _passwordController.text.trim(),
                                              );

                                          if (!context.mounted) return;

                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                            DashboardScreen.routeName,
                                          );
                                        } catch (e) {
                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() => _loading = false);
                                          }
                                        }
                                      },
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Se connecter'),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  SignupScreen.routeName,
                                );
                              },
                              child: const Text(
                                'Pas de compte ? Créer un compte',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '14 jours d’essai gratuit • PRO à 2500 FCFA/mois',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
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