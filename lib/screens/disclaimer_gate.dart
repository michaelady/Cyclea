import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:flutter/material.dart';

class DisclaimerGate extends StatelessWidget {
  const DisclaimerGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to Cyclea', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'A calm cycle tracker with personal statistics — not a clinic, and not contraception.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        LegalCopy.fullDisclaimer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.acceptDisclaimer,
                    child: const Text('I understand — continue'),
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
    );
  }
}
