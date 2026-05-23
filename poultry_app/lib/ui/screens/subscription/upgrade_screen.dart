import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';

class UpgradeScreen extends StatelessWidget {
  static const routeName = '/upgrade';

  const UpgradeScreen({super.key});

  static const String amount = '2 500 FCFA';
  static const String paymentNumber = '78 434 53 26';
  static const String whatsappNumber = '78 434 53 26';

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final auth = context.watch<AuthProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    final bool trialExpired = subscription.trialExpired && !subscription.isPro;
    final bool proExpired = subscription.isExpired && !subscription.isPro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passer à PRO'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          Text(
            'Bonjour ${auth.displayName} 👋',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '🚀 OG PoultryPro PRO',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          if (trialExpired)
            _importantInfoCard(
              title: 'Votre essai gratuit est terminé',
              message:
                  'Vous avez bénéficié de 14 jours pour tester OG PoultryPro, découvrir la plateforme et voir comment elle peut vous aider à mieux gérer votre élevage. '
                  'Pour continuer à utiliser l’application, vous devez maintenant passer à l’abonnement mensuel de 2 500 FCFA.',
              color: Colors.orange,
              icon: Icons.timer_off,
            )
          else if (proExpired)
            _importantInfoCard(
              title: 'Votre abonnement PRO a expiré',
              message:
                  'Votre accès PRO est terminé. Pour continuer à utiliser les fonctionnalités avancées, veuillez renouveler votre abonnement mensuel de 2 500 FCFA.',
              color: Colors.red,
              icon: Icons.lock,
            )
          else if (subscription.isPro)
            _importantInfoCard(
              title: 'Compte PRO actif',
              message:
                  'Votre abonnement est actif. Il vous reste ${subscription.daysRemaining} jour(s) avant expiration.',
              color: Colors.green,
              icon: Icons.verified,
            )
          else
            _importantInfoCard(
              title: 'Essai gratuit en cours',
              message:
                  'Il vous reste ${subscription.trialDaysRemaining} jour(s) d’essai gratuit. Profitez-en pour tester la plateforme avant de passer à l’abonnement PRO.',
              color: Colors.green,
              icon: Icons.hourglass_bottom,
            ),

          const SizedBox(height: 18),

          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.green.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'PoultryPro — Le copilote de votre élevage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gérez votre élevage comme une vraie entreprise. '
                    'Suivez vos dépenses, vos ventes, votre mortalité et vos bénéfices dans une seule application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          _feature('📊 Dashboard avancé'),
          _feature('📄 Export PDF professionnel'),
          _feature('🐔 Vagues illimitées'),
          _feature('💰 Suivi complet des dépenses, ventes et bénéfices'),
          _feature('📈 Vision claire de la rentabilité'),

          const SizedBox(height: 20),

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
                    'Comment payer votre abonnement ?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _step(
                    '1',
                    'Envoyez 2 500 FCFA par Wave ou Orange Money au numéro indiqué.',
                  ),

                  _step(
                    '2',
                    'Après la transaction, faites une capture d’écran du paiement.',
                  ),

                  _step(
                    '3',
                    'Cliquez sur le bouton “Copier le message WhatsApp”.',
                  ),

                  _step(
                    '4',
                    'Envoyez le message copié + la capture de paiement sur WhatsApp au même numéro.',
                  ),

                  _step(
                    '5',
                    'Après vérification, votre compte PRO sera activé pour 30 jours.',
                  ),

                  const SizedBox(height: 18),

                  const Text('Montant à payer :'),
                  const SelectableText(
                    amount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Numéro Wave / Orange Money :'),
                  const SizedBox(height: 6),
                  const SelectableText(
                    paymentNumber,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Envoyer la capture WhatsApp au :'),
                  const SizedBox(height: 6),
                  const SelectableText(
                    whatsappNumber,
                    style: TextStyle(
                      fontSize: 22,
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

Nom : ${auth.displayName}
Montant payé : $amount
Paiement envoyé au : $paymentNumber
ID utilisateur : ${user?.id ?? 'Non connecté'}

J’envoie la capture de la transaction avec ce message.
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
                'Important : votre abonnement PRO sera activé manuellement après vérification du paiement. La durée est de 30 jours.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _importantInfoCard({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color.withOpacity(0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
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

  static Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: Colors.green,
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}