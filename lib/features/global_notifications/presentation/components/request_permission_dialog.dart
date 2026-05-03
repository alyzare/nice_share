import 'package:flutter/material.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class RequestPermissionDialog extends StatefulWidget {
  final PermissionRequest request;

  const RequestPermissionDialog._(this.request);

  @override
  State<RequestPermissionDialog> createState() =>
      _RequestPermissionDialogState();

  static Future<bool?> show(
    BuildContext context,
    PermissionRequest request,
  ) async => showDialog(
    context: context,
    builder: (context) => RequestPermissionDialog._(request),
  );
}

class _RequestPermissionDialogState extends State<RequestPermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: .min,
          spacing: 10,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "Device Name: "),
                  TextSpan(
                    text: widget.request.peer.name,
                    style: TextStyle(fontWeight: .bold),
                  ),
                ],
              ),
            ),
            Text("Asking for session: ${widget.request.sessionId}"),

            Row(
              mainAxisSize: .min,
              children: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text("Refuse"),
                ),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
