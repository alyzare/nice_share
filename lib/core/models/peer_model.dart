import 'dart:io';
import 'dart:typed_data';

class PeerModel {
  final InternetAddress ip;
  final String? name;

  PeerModel({required this.ip, this.name});

  @override
  bool operator ==(Object other) {
    return other is PeerModel && other.ip == ip && other.name == name;
  }

  @override
  int get hashCode => ip.hashCode ^ name.hashCode;

  PeerModel.fromMap(Map<String, Object?> map)
    : ip = InternetAddress.fromRawAddress(map["ip"] as Uint8List),
      name = map["name"] as String?;

  Map<String, Object?> get toMap => {"ip": ip.rawAddress, "name": name};
}
