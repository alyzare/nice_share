import 'dart:io';
import 'dart:typed_data';

class Sender {
  final InternetAddress address;
  final int port;
  final int sessionId;

  Sender({required this.address, required this.port, required this.sessionId});

  static Sender fromMap(Map<String, Object> payload) {
    return Sender(
      address: InternetAddress.fromRawAddress(payload["ip"] as Uint8List),
      port: payload['port'] as int,
      sessionId: payload["sender_id"] as int,
    );
  }

  Map<String, Object> get toMap => {
    "ip": address.rawAddress,
    "port": port,
    "sender_id": sessionId,
  };

  @override
  bool operator ==(Object other) {
    if (other is! Sender) return false;

    return
        other.address == address &&
        other.sessionId == sessionId &&
        other.port == port;
  }

  @override
  int get hashCode =>
      address.rawAddress[0] ^
      address.rawAddress[1] ^
      address.rawAddress[2] ^
      address.rawAddress[3] ^
      sessionId ^
      port;
}
