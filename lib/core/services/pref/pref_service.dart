import 'package:hive_flutter/hive_flutter.dart';
import 'package:nice_share/core/utils.dart';

class PrefService {
  static late Box<String> _prefBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefBox = await Hive.openBox("pref");
    _peerName = _prefBox.get("peerName");
    if (_peerName == null || _peerName!.isEmpty) {
      _peerName = await getDeviceName();
      await _prefBox.put('name', _peerName!);
    }
  }

  static String get peerName => _peerName ?? "No Name";
  static String? _peerName;

  PrefService._();
}
