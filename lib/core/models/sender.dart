import 'dart:io';

class Sender {
  final InternetAddress address;
  final int port;
  final int sessionId;

  Sender({required this.address, required this.port, required this.sessionId});
}
