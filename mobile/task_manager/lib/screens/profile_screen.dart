import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) { return const SizedBox.shrink(); }
    return ListView(padding: const EdgeInsets.all(24), children: [
      Center(child: UserAvatar(url: user.avatarUrl)),
      const SizedBox(height: 16),
      Text(user.name, textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall),
      Text(user.email, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: auth.busy ? null : () => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const EditProfileScreen())),
        icon: const Icon(Icons.edit_outlined), label: const Text('Edit profil')),
    ]);
  }
}
