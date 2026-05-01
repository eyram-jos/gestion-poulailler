import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class UpgradeScreen extends StatelessWidget {
  static const routeName = '/upgrade';

  const UpgradeScreen({super.key});

  static const String amount = '2 500 FCFA';
  static const String paymentNumber = '78 434 53 26';
  static const String whatsappNumber = '78 434 53 26';

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passer à PRO'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          const Text(
            '🚀 OG PoultryPro PRO',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _feature('📊 Dashboard avancé'),
          _feature('📄 Export PDF'),
          _feature('🐔 Vagues illimitées'),
          _feature('💰 Suivi complet business'),

         const SizedBox(height:15),

        const Text(
          'PoultryPro — Le copilote de votre élevage.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),

        const SizedBox(height:15),

        const Text(
          'Gérez votre élevage comme une vraie entreprise.\n'
          'Suivez vos dépenses, vos ventes, votre mortalité et vos bénéfices '
          'dans une seule application pensée pour les éleveurs africains.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:16,
            height:1.5,
          ),
        ),

        const SizedBox(height:15),

        const Text(
          '✔ Réduisez les pertes\n'
          '✔ Augmentez vos bénéfices\n'
          '✔ Prenez de meilleures décisions',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height:20),

          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paiement manuel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text('Montant :'),
                  const SelectableText(
                    amount,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Envoyez le paiement Wave / Orange Money au :'),
                  const SizedBox(height: 6),
                  const SelectableText(
                    paymentNumber,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Après paiement, envoyez la capture WhatsApp au :'),
                  const SizedBox(height: 6),
                  const SelectableText(
                    whatsappNumber,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (user != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        'ID utilisateur : ${user.id}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final message = '''
Bonjour, je veux activer OG PoultryPro PRO.

Montant payé : $amount
Paiement envoyé au : $paymentNumber
ID utilisateur : ${user?.id ?? 'Non connecté'}

Je vais envoyer la capture du paiement.
''';

                        await Clipboard.setData(
                          ClipboardData(text: message),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Message copié. Collez-le sur WhatsApp avec la capture.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copier le message WhatsApp'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.amber.shade50,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Après vérification du paiement, votre abonnement PRO sera activé pour 30 jours.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
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