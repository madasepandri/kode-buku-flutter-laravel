import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'task_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final Widget page = switch (auth.state) {
      AuthState.checking =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthState.signedOut => const LoginScreen(),
      AuthState.signedIn => TaskHomePage(key: ValueKey(auth.user!.id)),
      AuthState.retryableError => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(auth.errorMessage ?? 'Sesi belum dapat diperiksa.'),
                TextButton(
                  onPressed: auth.restore,
                  child: const Text('Coba lagi'),
                ),
                TextButton(
                  onPressed: auth.clearDeviceSession,
                  child: const Text('Hapus sesi di perangkat'),
                ),
              ],
            ),
          ),
        ),
    };

    return Navigator(
      key: ValueKey('${auth.state}-${auth.user?.id}'),
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
