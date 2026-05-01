import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/subscription_repo.dart';

class WavePaymentScreen extends StatefulWidget {
  static const routeName = '/wave-payment';
  const WavePaymentScreen({super.key});

  @override
  State<WavePaymentScreen> createState() => _WavePaymentScreenState();
}

class _WavePaymentScreenState extends State<WavePaymentScreen> {
  bool loading = false;

  Future<void> confirmPayment() async {
    setState(() => loading = true);

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await SubscriptionRepo().setPlanDemo(user.id, pro: true);
    }

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement confirmé. PRO activé !')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement Wave')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Passe au plan PRO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Montant: 5 000 FCFA'),
                    SizedBox(height: 10),
                    Text('Numero Wave: 77 000 00 00'),
                    SizedBox(height: 10),
                    Text('Nom:OG PoultryPro'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : confirmPayment,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('J’ai payé'),
            ),
          ],
        ),
      ),
    );
  }
}