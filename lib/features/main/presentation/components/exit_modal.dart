import 'package:flutter/material.dart';

class ExitModal extends StatelessWidget {
  const ExitModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      spacing: 20,
      children: [
        Icon(
          Icons.exit_to_app_rounded,
          size: 50,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: FittedBox(child: Text("Do you intend to exit all sessions?")),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: .center,
              spacing: 20,
              children: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Sure"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
