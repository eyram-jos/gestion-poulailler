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
    final activeWave = waves.where((w) => w.isActive).isNotEmpty
        ? waves.firstWhere((w) => w.isActive)
        : null;

    final pages = [
      _OverviewTab(activeWave: activeWave),
      _WavesTab(userId: user.id, waves: waves, isPro: subscription.isPro),
      _ExpensesTab(userId: user.id, waves: waves, repo: _expenseRepo),
      _SalesTab(userId: user.id, waves: waves, repo: _saleRepo),
      _MortalityTab(userId: user.id, waves: waves, repo: _mortalityRepo),
    ];

    return Scaffold(
      appBar: AppBar(
  title: Row(
    children: [
      const Text('PoultryPro'),
      const SizedBox(width: 10),
      Consumer<SubscriptionProvider>(
        builder: (_, sub, __) {
          return Chip(
            label: Text(
              sub.isPro ? 'PRO' : 'FREE',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                sub.isPro ? Colors.green : Colors.grey,
          );
        },
      ),
    ],
  ),
  actions: [
    IconButton(
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
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Depenses'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Ventes'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Mortalite'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showQuickAddDialog(context, user.id, waves, dashboard),
              icon: const Icon(Icons.add),
              label: const Text('Ajout rapide'),
            )
          : null,
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
              title: const Text('Ajouter depense'),
              onTap: () {
                Navigator.pop(ctx);
                _showExpenseSheet(context, userId, waves);
              },
            ),
            ListTile(
              title: const Text('Ajouter vente'),
              onTap: () {
                Navigator.pop(ctx);
                _showSaleSheet(context, userId, waves);
              },
            ),
            ListTile(
              title: const Text('Ajouter mortalite'),
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
    _ExpensesTab(userId: userId, waves: waves, repo: _expenseRepo).openSheet(context);
  }

  void _showSaleSheet(BuildContext context, String userId, List<Wave> waves) {
    _SalesTab(userId: userId, waves: waves, repo: _saleRepo).openSheet(context);
  }

  void _showMortalitySheet(BuildContext context, String userId, List<Wave> waves) {
    _MortalityTab(userId: userId, waves: waves, repo: _mortalityRepo).openSheet(context);
  }
}

class _OverviewTab extends StatelessWidget {
  final Wave? activeWave;
  const _OverviewTab({required this.activeWave});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final totalExpenses = dashboard.totalExpenses();
    final totalRevenue = dashboard.totalRevenue();
    final profit = dashboard.profit();
    final mortality = dashboard.totalMortality();
    final reminders = _buildReminders(activeWave);
    final isPro = context.watch<SubscriptionProvider>().isPro;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _kpi('Depenses', '${round2(totalExpenses)} FCFA'),
            _kpi('Ventes', '${round2(totalRevenue)} FCFA'),
            _kpi('Benefice net', '${round2(profit)} FCFA'),
            _kpi('Mortalite', '$mortality poulets'),
          ],
        ),

        const SizedBox(height: 20),

          const Text(
            'Analyse financière',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ProfitChart(
            expenses: totalExpenses,
            revenue: totalRevenue,
          ),

        // 🔴 BLOQUAGE PRO
        if (!isPro)
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              title: const Text('Fonctions limitées'),
              subtitle: const Text('Passe Pro pour exporter, rapports avancés...'),
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(UpgradeScreen.routeName);
                },
                child: const Text('Passer PRO'),
              ),
            ),
          ),


        if (isPro)
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
            label: const Text('Exporter PDF'),
          ),

        if (!isPro)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(UpgradeScreen.routeName);
            },
            child: const Text('Débloquer Export PDF (PRO)'),
          ),


        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rappels elevage', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...reminders.map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('- $r'),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpi(String label, String value) {
  return Container(
    width: 170,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange, Colors.deepOrange],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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
      return const ['Aucune vague active. Cree une vague pour voir les rappels.'];
    }
    final day = DateTime.now().difference(activeWave.startDate).inDays + 1;
    return [
      'Jour 1: eau + sucre + aliment demarrage',
      'Jour 2-4: antistress',
      'Jour 11-15: gumboro',
      'Transition croissance',
      'Anticoccidien',
      'Fin de cycle',
      'Jour actuel: J$day',
    ];
  }
}

class _WavesTab extends StatelessWidget {
  final String userId;
  final List<Wave> waves;
  final bool isPro;
  const _WavesTab({required this.userId, required this.waves, required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: waves.length,
        itemBuilder: (_, i) {
          final w = waves[i];
          return Card(
            child: ListTile(
              title: Text(w.name),
              subtitle: Text('${w.chicks} poussins - debut ${formatDate(w.startDate)}'),
              trailing: Chip(label: Text(w.isActive ? 'Actif' : 'Termine')),
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
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom vague')),
              const SizedBox(height: 12),
              TextField(
                controller: chicksCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nombre de poussins'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Date debut: ${formatDate(start)}')),
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
                  final name = nameCtrl.text.trim().isEmpty ? 'Vague ${waves.length + 1}' : nameCtrl.text.trim();
                  final chicks = int.tryParse(chicksCtrl.text.trim()) ?? 0;
                  if (chicks <= 0) return;
                  await context.read<WaveProvider>().createWave(userId, name, chicks, start);
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
  const _ExpensesTab({required this.userId, required this.waves, required this.repo});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().expenses;
    return Scaffold(
      body: ListView.builder(
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
        label: const Text('Depense'),
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
                items: waves.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type')),
              const SizedBox(height: 8),
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Libelle')),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date: ${formatDate(date)}')),
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
                    type: typeCtrl.text.trim().isEmpty ? 'autre' : typeCtrl.text.trim(),
                    label: labelCtrl.text.trim().isEmpty ? 'Depense' : labelCtrl.text.trim(),
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
  const _SalesTab({required this.userId, required this.waves, required this.repo});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().sales;
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final s = items[i];
          return Card(
            child: ListTile(
              title: Text('${s.quantity} poulets'),
              subtitle: Text('Prix unitaire ${round2(s.priceUnit)} - ${formatDate(s.date)}'),
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
                items: waves.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantite')),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix unitaire')),
              const SizedBox(height: 8),
              TextField(controller: deliveryCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Livraison')),
              const SizedBox(height: 8),
              TextField(controller: defeatherCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Deplumage total')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date: ${formatDate(date)}')),
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
                  final delivery = double.tryParse(deliveryCtrl.text.trim()) ?? 0;
                  final defeather = double.tryParse(defeatherCtrl.text.trim()) ?? 0;
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
  const _MortalityTab({required this.userId, required this.waves, required this.repo});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<DashboardProvider>().mortalities;
    return Scaffold(
      body: ListView.builder(
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
        label: const Text('Mortalite'),
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
                items: waves.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                onChanged: (v) => waveId = v,
                decoration: const InputDecoration(labelText: 'Vague'),
              ),
              const SizedBox(height: 8),
              TextField(controller: countCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date: ${formatDate(date)}')),
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
