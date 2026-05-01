import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils.dart';
import '../../../models/expense.dart';
import '../../../models/mortality.dart';
import '../../../models/sale.dart';
import '../../../models/wave.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/wave_provider.dart';
import '../../../repositories/expense_repo.dart';
import '../../../repositories/mortality_repo.dart';
import '../../../repositories/sale_repo.dart';
import '../auth/login_screen.dart';
import '../subscription/upgrade_screen.dart';
import '../../../services/pdf_service.dart';
import '../../widgets/chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  bool _started = false;
  bool _expiredDialogShown = false;

  final _expenseRepo = ExpenseRepo();
  final _saleRepo = SaleRepo();
  final _mortalityRepo = MortalityRepo();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<WaveProvider>().watch(user.id);
      context.read<DashboardProvider>().watchAll(user.id);
      context.read<SubscriptionProvider>().watch(user.id);
    }

    _started = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final waves = context.watch<WaveProvider>().waves;
    final dashboard = context.watch<DashboardProvider>();
    final subscription = context.watch<SubscriptionProvider>();


    if (subscription.trialExpired && !subscription.isPro) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        UpgradeScreen.routeName,
      );
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    }


    if (subscription.isExpired && !_expiredDialogShown) {
      _expiredDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showExpiredDialog(context);
      });
    }

    final activeWave = waves.where((w) => w.isActive).isNotEmpty
        ? waves.firstWhere((w) => w.isActive)
        : null;

    final pages = [
      _OverviewTab(activeWave: activeWave, waves: waves),
      _WavesTab(userId: user.id, waves: waves, isPro: subscription.isPro),
      _ExpensesTab(userId: user.id, waves: waves, repo: _expenseRepo),
      _SalesTab(userId: user.id, waves: waves, repo: _saleRepo),
      _MortalityTab(userId: user.id, waves: waves, repo: _mortalityRepo),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('OG PoultryPro'),
            const SizedBox(width: 10),
            _PlanBadge(subscription: subscription),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (v) => setState(() => _tab = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Vue'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Vagues'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Dépenses'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Ventes'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Mortalité'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showQuickAddDialog(context, user.id, waves, dashboard),
              icon: const Icon(Icons.add),
              label: const Text('Ajout rapide'),
            )
          : null,
    );
  }

  void _showExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Abonnement PRO expiré'),
          content: const Text(
            'Votre accès PRO a expiré. Renouvelez votre abonnement pour récupérer les rapports avancés, l’export PDF et les vagues illimitées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(UpgradeScreen.routeName);
              },
              child: const Text('Renouveler'),
            ),
          ],
        );
      },
    );
  }

  void _showQuickAddDialog(
    BuildContext context,
    String userId,
    List<Wave> waves,
    DashboardProvider dashboard,
  ) {
    final isPro = context.read<SubscriptionProvider>().isPro;

    if (!isPro) {
      Navigator.of(context).pushNamed(UpgradeScreen.routeName);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Ajouter dépense'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showExpenseSheet(context, userId, waves);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('Ajouter vente'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSaleSheet(context, userId, waves);
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Ajouter mortalité'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMortalitySheet(context, userId, waves);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExpenseSheet(BuildContext context, String userId, List<Wave> waves) {
    _ExpensesTab(userId: userId, waves: waves, repo: _expenseRepo)
        .openSheet(context);
  }

  void _showSaleSheet(BuildContext context, String userId, List<Wave> waves) {
    _SalesTab(userId: userId, waves: waves, repo: _saleRepo).openSheet(context);
  }

  void _showMortalitySheet(
      BuildContext context, String userId, List<Wave> waves) {
    _MortalityTab(userId: userId, waves: waves, repo: _mortalityRepo)
        .openSheet(context);
  }
}

class _PlanBadge extends StatelessWidget {
  final SubscriptionProvider subscription;
  const _PlanBadge({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final label = subscription.isPro ? 'PRO PREMIUM' : 'FREE';
    final color = subscription.isPro ? Colors.amber.shade700 : Colors.grey;

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Wave? activeWave;
  final List<Wave> waves;

  const _OverviewTab({
    required this.activeWave,
    required this.waves,
  });

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    final totalExpenses = dashboard.totalExpenses();
    final totalRevenue = dashboard.totalRevenue();
    final profit = dashboard.profit();
    final mortality = dashboard.totalMortality();
    final totalChicks = waves.fold<int>(0, (p, w) => p + w.chicks);
    final activeChicks = activeWave?.chicks ?? 0;
    final reminders = _buildReminders(activeWave);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PremiumHeader(subscription: subscription),


        if (!subscription.isPro &&
            !subscription.trialExpired)
        Text(
        'Essai gratuit : ${subscription.trialDaysRemaining} jours restants',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        ),



        if (subscription.shouldRenewWarn) ...[
          const SizedBox(height: 12),
          _RenewWarningCard(subscription: subscription),
        ],

        if (subscription.isExpired) ...[
          const SizedBox(height: 12),
          _ExpiredCard(),
        ],

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpi(
              'Cheptel total',
              '$totalChicks',
              Icons.pets,
              [Colors.green.shade700, Colors.green.shade400],
            ),
            _kpi(
              'Vague active',
              '$activeChicks',
              Icons.layers,
              [Colors.blue.shade700, Colors.blue.shade400],
            ),
            _kpi(
              'Dépenses',
              '${round2(totalExpenses)} FCFA',
              Icons.receipt_long,
              [Colors.deepOrange.shade700, Colors.orange.shade400],
            ),
            _kpi(
              'Revenus',
              '${round2(totalRevenue)} FCFA',
              Icons.payments,
              [Colors.teal.shade700, Colors.teal.shade400],
            ),
            _kpi(
              'Profit net',
              '${round2(profit)} FCFA',
              Icons.trending_up,
              profit >= 0
                  ? [Colors.purple.shade700, Colors.purple.shade400]
                  : [Colors.red.shade700, Colors.red.shade400],
            ),
            _kpi(
              'Mortalité',
              '$mortality poulets',
              Icons.warning_amber,
              [Colors.red.shade700, Colors.red.shade400],
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'Analyse financière',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ProfitChart(
              expenses: totalExpenses,
              revenue: totalRevenue,
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (!subscription.isPro)
          _FreeVsProCard(),

        if (subscription.isPro)
          ElevatedButton.icon(
            onPressed: () async {
              await PdfService.generateReport(
                totalExpenses: totalExpenses,
                totalRevenue: totalRevenue,
                profit: profit,
                mortality: mortality,
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Exporter le rapport PDF'),
          ),

        if (!subscription.isPro)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(UpgradeScreen.routeName);
            },
            icon: const Icon(Icons.lock_open),
            label: const Text('Débloquer les fonctions PRO'),
          ),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rappels élevage',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...reminders.map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(r)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpi(
    String label,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildReminders(Wave? activeWave) {
    if (activeWave == null) {
      return const ['Aucune vague active. Crée une vague pour voir les rappels.'];
    }

    final day = DateTime.now().difference(activeWave.startDate).inDays + 1;

    return [
      'Jour actuel de la vague : J$day',
      'J1 : eau + sucre + aliment démarrage',
      'J2 à J4 : antistress',
      'J11 à J15 : vaccin gumboro',
      'J15+ : transition vers aliment croissance',
      'Après croissance : anticoccidien',
      'Fin de cycle : préparation vente et bilan financier',
    ];
  }
}

class _PremiumHeader extends StatelessWidget {
  final SubscriptionProvider subscription;

  const _PremiumHeader({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final expireText = _expireText(subscription);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: subscription.isPro
              ? [Colors.green.shade800, Colors.green.shade500]
              : [Colors.black87, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subscription.isPro
                ? 'Compte PRO actif'
                : 'Plan Free actif',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subscription.isPro
                ? 'Vous gérez votre élevage avec les outils premium.'
                : 'Passez PRO pour gérer votre élevage comme une vraie entreprise.',
            style: const TextStyle(color: Colors.white70),
          ),
          if (expireText != null) ...[
            const SizedBox(height: 10),
            Text(
              expireText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _expireText(SubscriptionProvider sub) {
    final expireAt = sub.expireAt;
    if (expireAt == null) return null;

    if (sub.isExpired) {
      return 'Abonnement expiré';
    }

    return 'Expire dans ${sub.daysRemaining} jour(s)';
  }
}

class _RenewWarningCard extends StatelessWidget {
  final SubscriptionProvider subscription;

  const _RenewWarningCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.notifications_active, color: Colors.orange),
        title: Text(
          'Votre abonnement expire dans ${subscription.daysRemaining} jour(s)',
        ),
        subtitle: const Text('Renouvelez maintenant pour éviter la coupure PRO.'),
        trailing: TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(UpgradeScreen.routeName);
          },
          child: const Text('Renouveler'),
        ),
      ),
    );
  }
}

class _ExpiredCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.lock, color: Colors.red),
        title: const Text('Abonnement PRO expiré'),
        subtitle: const Text(
          'Renouvelez votre abonnement pour récupérer les fonctions premium.',
        ),
        trailing: TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(UpgradeScreen.routeName);
          },
          child: const Text('Renouveler'),
        ),
      ),
    );
  }
}

class _FreeVsProCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Free vs PRO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _comparisonRow('Vagues', '1 seule', 'Illimitées'),
            _comparisonRow('Export PDF', 'Bloqué', 'Disponible'),
            _comparisonRow('Ajout rapide', 'Bloqué', 'Disponible'),
            _comparisonRow('Rapports avancés', 'Limité', 'Complet'),
            const SizedBox(height: 12),
            const Text(
              'PRO vous aide à suivre vos dépenses, ventes, mortalités et bénéfices avec une vision claire.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(String feature, String free, String pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              free,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          Expanded(
            child: Text(
              pro,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavesTab extends StatelessWidget {
  final String userId;
  final List<Wave> waves;
  final bool isPro;

  const _WavesTab({
    required this.userId,
    required this.waves,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: waves.isEmpty
          ? const Center(child: Text('Aucune vague enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: waves.length,
              itemBuilder: (_, i) {
                final w = waves[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.layers),
                    title: Text(w.name),
                    subtitle: Text(
                      '${w.chicks} poussins - début ${formatDate(w.startDate)}',
                    ),
                    trailing: Chip(
                      label: Text(w.isActive ? 'Actif' : 'Terminé'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!isPro && waves.length >= 1) {
            Navigator.of(context).pushNamed(UpgradeScreen.routeName);
            return;
          }
          _showCreateWave(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle vague'),
      ),
    );
  }

  void _showCreateWave(BuildContext context) {
    final nameCtrl = TextEditingController();
    final chicksCtrl = TextEditingController(text: '200');
    DateTime start = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom vague'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chicksCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Nombre de poussins'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Date début : ${formatDate(start)}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: start,
                      );
                      if (picked != null) start = picked;
                    },
                    child: const Text('Changer'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim().isEmpty
                      ? 'Vague ${waves.length + 1}'
                      : nameCtrl.text.trim();
                  final chicks = int.tryParse(chicksCtrl.text.trim()) ?? 0;
                  if (chicks <= 0) return;

                  await context
                      .read<WaveProvider>()
                      .createWave(userId, name, chicks, start);

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final String userId;
  final List<Wave> waves;
  final ExpenseRepo repo;

  const _ExpensesTab({
    required this.userId,
    required this.waves,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().expenses;

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Aucune dépense enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    title: Text(e.label),
                    subtitle: Text('${e.type} - ${formatDate(e.date)}'),
                    trailing: Text('${round2(e.amount)} FCFA'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Dépense'),
      ),
    );
  }

  void openSheet(BuildContext context) {
    String? waveId = waves.isNotEmpty ? waves.first.id : null;
    final amountCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'aliment');
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: waveId,
                items: waves
                    .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Libellé'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date : ${formatDate(date)}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) date = picked;
                    },
                    child: const Text('Changer'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (waveId == null || amount <= 0) return;

                  final expense = Expense(
                    id: '',
                    userId: userId,
                    waveId: waveId!,
                    type: typeCtrl.text.trim().isEmpty
                        ? 'autre'
                        : typeCtrl.text.trim(),
                    label: labelCtrl.text.trim().isEmpty
                        ? 'Dépense'
                        : labelCtrl.text.trim(),
                    amount: amount,
                    date: date,
                  );

                  await repo.addExpense(expense);

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SalesTab extends StatelessWidget {
  final String userId;
  final List<Wave> waves;
  final SaleRepo repo;

  const _SalesTab({
    required this.userId,
    required this.waves,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().sales;

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Aucune vente enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final s = items[i];
                return Card(
                  child: ListTile(
                    title: Text('${s.quantity} poulets'),
                    subtitle: Text(
                      'Prix unitaire ${round2(s.priceUnit)} - ${formatDate(s.date)}',
                    ),
                    trailing: Text('${round2(s.total)} FCFA'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Vente'),
      ),
    );
  }

  void openSheet(BuildContext context) {
    String? waveId = waves.isNotEmpty ? waves.first.id : null;
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '3500');
    final deliveryCtrl = TextEditingController(text: '0');
    final defeatherCtrl = TextEditingController(text: '0');
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: waveId,
                items: waves
                    .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix unitaire'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deliveryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Livraison'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: defeatherCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Déplumage total'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date : ${formatDate(date)}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) date = picked;
                    },
                    child: const Text('Changer'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                  final unit = double.tryParse(priceCtrl.text.trim()) ?? 0;
                  final delivery =
                      double.tryParse(deliveryCtrl.text.trim()) ?? 0;
                  final defeather =
                      double.tryParse(defeatherCtrl.text.trim()) ?? 0;

                  if (waveId == null || qty <= 0 || unit <= 0) return;

                  final total = (qty * unit) + delivery + defeather;

                  final sale = Sale(
                    id: '',
                    userId: userId,
                    waveId: waveId!,
                    quantity: qty,
                    priceUnit: unit,
                    total: total,
                    date: date,
                  );

                  await repo.addSale(sale);

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MortalityTab extends StatelessWidget {
  final String userId;
  final List<Wave> waves;
  final MortalityRepo repo;

  const _MortalityTab({
    required this.userId,
    required this.waves,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().mortalities;

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Aucune mortalité enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final m = items[i];
                return Card(
                  child: ListTile(
                    title: Text('${m.count} morts'),
                    subtitle: Text('${formatDate(m.date)} - ${m.notes}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Mortalité'),
      ),
    );
  }

  void openSheet(BuildContext context) {
    String? waveId = waves.isNotEmpty ? waves.first.id : null;
    final countCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: waveId,
                items: waves
                    .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date : ${formatDate(date)}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) date = picked;
                    },
                    child: const Text('Changer'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final count = int.tryParse(countCtrl.text.trim()) ?? 0;
                  if (waveId == null || count <= 0) return;

                  final m = Mortality(
                    id: '',
                    userId: userId,
                    waveId: waveId!,
                    date: date,
                    count: count,
                    notes: notesCtrl.text.trim(),
                  );

                  await repo.addMortality(m);

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}