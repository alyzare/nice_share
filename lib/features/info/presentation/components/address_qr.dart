import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddressQr extends StatelessWidget {
  final Uri uri;

  const AddressQr({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .65,
        decoration: BoxDecoration(
          border: .all(
            width: 5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: .circular(20),
        ),
        padding: .all(10),
        child: QrImageView(
          padding: .zero,
          data: uri.toString(),
          eyeStyle: QrEyeStyle(
            color: Theme.of(context).colorScheme.secondary,
            eyeShape: .circle,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
