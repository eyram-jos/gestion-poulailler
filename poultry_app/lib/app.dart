import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wave_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/subscription_provider.dart';
import 'ui/theme.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/home/dashboard_screen.dart';
import 'ui/screens/subscription/upgrade_screen.dart';
import 'ui/screens/subscription/wave_payment_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WaveProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        title: 'OG PoultryPro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignupScreen.routeName: (_) => const SignupScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          UpgradeScreen.routeName: (_) => const UpgradeScreen(),
          WavePaymentScreen.routeName: (_) => const WavePaymentScreen(),
        },
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return FutureBuilder<void>(
      future: auth.tryAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isAuthenticated) return const DashboardScreen();
        return const LoginScreen();
      },
    );
  }
}
