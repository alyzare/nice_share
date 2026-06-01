import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

class PrefService {
  static late Box<String> _prefBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefBox = await Hive.openBox("pref");
    _peerName = _prefBox.get("peerName");
    if (_peerName == null || _peerName!.isEmpty) {
      _peerName = String.fromCharCodes(
        List.generate(5, (index) {
          final code = Random().nextInt(36);
          if (code < 10) {
            return code + 48;
          }
          return code + 55;
        }),
      );
      await _prefBox.put('name', _peerName!);
    }
  }

  static String get peerName => _peerName ?? "No Name";
  static String? _peerName;

  PrefService._();
}
