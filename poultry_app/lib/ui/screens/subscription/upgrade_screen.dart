import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/payment_service.dart';

class UpgradeScreen extends StatelessWidget {
  static const routeName = '/upgrade';

  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passer à PRO'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              '🚀 PoultryPro PRO',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _feature('📊 Dashboard avancé'),
            _feature('📄 Export PDF'),
            _feature('🐔 Vagues illimitées'),
            _feature('💰 Suivi complet business'),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                if (user == null) return;

                print("CLICK PAYMENT");

                final url =
                    await PaymentService.createPayment(user.id);

                print("URL paiement: $url");

                if (url != null) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  print("ERREUR: URL NULL");
                }
              },
              child: const Text(
                'Payer avec Wave / Orange Money',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return ListTile(
      leading: const Icon(Icons.check, color: Colors.green),
      title: Text(text),
    );
  }
}