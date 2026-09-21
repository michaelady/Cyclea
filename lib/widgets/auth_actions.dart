import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class AuthCopy {
  static const firebaseNeededTitle = 'Google Sign-In needs Firebase';

  static const firebaseNeededBody =
      'This build still has placeholder Firebase keys, so Google Sign-In cannot complete yet. Guest mode stays fully usable on this device.\n\n'
      'To enable it, add a Firebase project with Google Auth, real values in lib/firebase_options.dart, '
      'google-services.json for Android, OAuth client IDs, and authorized domains for localhost and michaelady.github.io. See the README.';

  static const guestHint = 'Guest mode works fully on this device. You can sign in later from Settings.';
}

class ContinueAsGuestButton extends StatelessWidget {
  const ContinueAsGuestButton({super.key, required this.onPressed, this.label = 'Continue as guest'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const CycleaIcon(CycleaGlyph.leaf, filled: true, size: 18, color: Colors.white),
      label: Text(label),
    );
  }
}

class ContinueWithGoogleButton extends StatelessWidget {
  const ContinueWithGoogleButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2524)
            : Colors.white,
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GoogleGMark(size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class AuthChoiceColumn extends StatelessWidget {
  const AuthChoiceColumn({
    super.key,
    required this.onGuest,
    required this.onGoogle,
    this.showGuest = true,
    this.guestLabel = 'Continue as guest',
    this.googleLabel = 'Continue with Google',
  });

  final VoidCallback onGuest;
  final VoidCallback onGoogle;
  final bool showGuest;
  final String guestLabel;
  final String googleLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showGuest) ...[
          ContinueAsGuestButton(onPressed: onGuest, label: guestLabel),
          const SizedBox(height: 10),
        ],
        ContinueWithGoogleButton(onPressed: onGoogle, label: googleLabel),
      ],
    );
  }
}

Future<void> showFirebaseNeededDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          CycleaIcon(CycleaGlyph.cloudLeaf, filled: true, size: 22, color: CycleaColors.sage),
          SizedBox(width: 10),
          Expanded(child: Text(AuthCopy.firebaseNeededTitle)),
        ],
      ),
      content: const Text(AuthCopy.firebaseNeededBody),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep using guest'),
        ),
      ],
    ),
  );
}

Future<bool> handleGoogleSignIn(BuildContext context, CycleController controller) async {
  if (!controller.firebaseReady) {
    await showFirebaseNeededDialog(context);
    return false;
  }
  try {
    final user = await controller.signIn();
    return user != null;
  } on FirebaseNotConfiguredException {
    if (context.mounted) await showFirebaseNeededDialog(context);
    return false;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $error')),
      );
    }
    return false;
  }
}
