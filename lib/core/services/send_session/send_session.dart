import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/network/handlers/info_handler.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

class SendSession with BaseSession {
  @override
  final int sessionId;

  @override
  final List<FileHandler> fileHandlers;

  final int serverPort;

  SendSession({
    required this.sessionId,
    required this.fileHandlers,
    required this.serverPort,
  }) {
    _udpTimer = Timer.periodic(Duration(milliseconds: 500), _broadcastAddress);
  }

  InfoHandler get infoHandler => InfoHandler(
    info: {
      "sessionId": sessionId,
      "files": fileHandlers.map((e) => e.fileName),
    },
    askPermission: _askPermission,
  );

  @override
  close() async {
    _udpTimer.cancel();
    _tokenNotifier.dispose();
    super.close();
  }

  late final _permissionCompleter = Completer<bool>();

  late final Timer _udpTimer;

  final _tokenNotifier = ValueNotifier<String?>(null);

  late final _broadcastMessage = Uint8List.fromList([
    ..."NSS".codeUnits,
    ...(ByteData(8)..setInt64(0, sessionId)).buffer.asUint8List(),
    ...(ByteData(4)..setInt32(0, serverPort)).buffer.asUint8List(),
  ]);

  Future<void> _broadcastAddress(Timer timer) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    socket.send(_broadcastMessage, InternetAddress('255.255.255.255'), 12459);
    socket.close();
  }

  Future<String?> _askPermission(String name) async {
    if (_tokenNotifier.value != null) return null;
    // emit(SendSessionAskingPermission());
    try {
      final isGranted = await _permissionCompleter.future.timeout(
        Duration(seconds: 20),
      );
      if (!isGranted) {
        // emit(SendSessionBroadcasting());
        return null;
      }
      _tokenNotifier.value = _generateToken();
      // emit(SendSessionConnected(peerName: "TEST"));
      return _tokenNotifier.value;
    } on TimeoutException catch (_) {
      // emit(SendSessionBroadcasting());
      return null;
    }
  }

  String _generateToken() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(256),
    ).map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  FileHandler getFile({required int id, required String token}) {
    // TODO
    throw UnimplementedError();
  }

  @override
  SessionType get type => .send;
}
