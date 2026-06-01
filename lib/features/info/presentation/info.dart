import 'package:flutter/material.dart';
import 'package:nice_share/core/services/server_bridge/server_bridge.dart';
import 'package:nice_share/features/info/presentation/components/address_qr.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final ips = <String>[];

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri(
      scheme: "http",
      host: ServerBridge.instance.address.address,
      port: ServerBridge.instance.port,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 25,
        mainAxisSize: .min,
        children: [
          Center(
            child: Text(
              "Network Info",
              style: TextStyle(fontWeight: .bold, fontSize: 40),
            ),
          ),
          AddressQr(uri: uri),
          Center(
            child: Text(
              uri.toString(),
              style: TextStyle(fontWeight: .bold, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _init() async {
  }
}
