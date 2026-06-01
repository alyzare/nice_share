import 'package:flutter/material.dart';
import 'package:nice_share/core/models/upload_permission_request.dart';

class RequestUploadPermissionModal extends StatelessWidget {
  final UploadPermissionRequest request;

  const RequestUploadPermissionModal({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 10,
      children: [
        Text(
          "Upload request from Web",
          style: TextStyle(fontWeight: .bold, fontSize: 25),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final file = request.files[index];
              return ListTile(
                title: Text(file.name),
                subtitle: Text(file.formattedSize),
              );
            },
            itemCount: request.files.length,
          ),
        ),
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
