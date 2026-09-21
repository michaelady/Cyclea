import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/widgets/auth_actions.dart';
import 'package:cyclea/widgets/disclaimer_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Row(
                children: [
                  CycleaIcon(
                    CycleaGlyph.moon,
                    filled: true,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: CycleaIcon(
                          controller.isGuest ? CycleaGlyph.guest : CycleaGlyph.blossom,
                          filled: true,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        controller.user?.displayName ??
                            controller.user?.email ??
                            'Guest on this device',
                      ),
                      subtitle: Text(controller.syncLabel),
                    ),
                    if (controller.isGuest) ...[
                      Text(
                        controller.firebaseReady
                            ? 'Guest mode is fully usable. Google is optional and only syncs after you sign in.'
                            : 'Google Sign-In is available as an option once Firebase is configured. Guest mode remains fully usable.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      AuthChoiceColumn(
                        showGuest: true,
                        guestLabel: 'Continue as guest',
                        onGuest: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You are already using guest mode on this device.'),
                            ),
                          );
                        },
                        onGoogle: () => handleGoogleSignIn(context, controller),
                      ),
                    ] else ...[
                      Text(
                        'Signing out returns to guest on this device. Logs stay unless you delete them.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: controller.signOut,
                        icon: const CycleaIcon(CycleaGlyph.leaf, size: 18),
                        label: const Text('Sign out'),
                      ),
                    ],
                    if (controller.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: CycleaIcon(CycleaGlyph.spark, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: CycleaIcon(CycleaGlyph.sun, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: CycleaIcon(CycleaGlyph.moon, size: 16),
                        ),
                      ],
                      selected: {controller.themeMode},
                      onSelectionChanged: (value) => controller.setThemeMode(value.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CycleaIcon(
                          CycleaGlyph.seed,
                          filled: true,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text('Tester tools', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Loads about six months of realistic, slightly irregular cycles with symptoms so Insights is not empty.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () async {
                        await controller.seedDemoData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demo cycles added. Check Home and Insights.')),
                          );
                        }
                      },
                      child: const Text('Seed demo data'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CycleaIcon(
                          CycleaGlyph.heartLeaf,
                          filled: true,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text('Privacy', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(LegalCopy.privacySummary, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _openPrivacy(context),
                      child: const Text('Open privacy page'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _confirmDelete(context, controller),
                      child: const Text('Delete all Cyclea data'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disclaimer', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(LegalCopy.fullDisclaimer, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cyclea 1.0.0 · com.cyclea.app · no ads · no selling health data',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPrivacy(BuildContext context) async {
    final uri = privacyPageUri();
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open $uri if the browser blocked the link.')),
      );
    }
  }

  static Uri privacyPageUri() {
    if (!kIsWeb) {
      return Uri.parse('https://michaelady.github.io/Cyclea/privacy.html');
    }
    final base = Uri.base;
    if (base.path.contains('/Cyclea')) {
      return base.replace(path: '/Cyclea/privacy.html', query: '', fragment: '');
    }
    return base.replace(path: '/privacy.html', query: '', fragment: '');
  }

  Future<void> _confirmDelete(BuildContext context, CycleController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This removes every log from this device. If you are signed in, it also deletes your Cyclea documents in Cloud Firestore. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.deleteAllData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Cyclea logs deleted.')),
      );
    }
  }
}
