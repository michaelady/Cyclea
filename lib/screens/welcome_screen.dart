import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_decor.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/widgets/auth_actions.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: PetalWash(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CycleaWordmark(),
                    const SizedBox(height: 10),
                    Text(
                      'A warm, private cycle companion with personal statistics — not a clinic, and not contraception.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SoftCard(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CycleaIcon(
                                  CycleaGlyph.heartLeaf,
                                  filled: true,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text('Before you begin', style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  LegalCopy.fullDisclaimer,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthChoiceColumn(
                      onGuest: controller.acceptDisclaimer,
                      onGoogle: () => _continueWithGoogle(context, controller),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AuthCopy.guestHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LegalCopy.privacySummary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueWithGoogle(BuildContext context, CycleController controller) async {
    final signedIn = await handleGoogleSignIn(context, controller);
    if (signedIn) await controller.acceptDisclaimer();
  }
}

/// Kept so older imports and tests can still refer to the first-run gate.
typedef DisclaimerGate = WelcomeScreen;
