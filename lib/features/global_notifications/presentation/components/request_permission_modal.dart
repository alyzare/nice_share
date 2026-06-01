import 'package:flutter/material.dart';
import 'package:nice_share/core/models/permission_request.dart';

class RequestPermissionModal extends StatelessWidget {
  final PermissionRequest request;

  const RequestPermissionModal({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 10,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "Device Name: "),
              TextSpan(
                text: request.peer.name,
                style: TextStyle(fontWeight: .bold),
              ),
            ],
          ),
        ),
        Text("Asking for session: ${request.sessionId}"),
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
    );
  }
}
