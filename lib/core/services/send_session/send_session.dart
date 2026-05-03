import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nice_share/core/models/peer_model.dart';
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
      "files": fileHandlers.map((e) => e.fileName).toList(),
    },
    askPermission: _askPermission,
  );

  @override
  close() async {
    _udpTimer.cancel();
    _permissionController.close();
    super.close();
  }

  final _permissionController = StreamController<PeerModel>.broadcast();

  Stream<PeerModel> get permissionEvents => _permissionController.stream;

  final _permissionTokenCompleters = <PeerModel, Completer<String>>{};

  late final Timer _udpTimer;

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

  Future<String?> _askPermission(PeerModel peer) async {
    final completer = _permissionTokenCompleters[peer];
    if (completer != null && completer.isCompleted) return completer.future;
    if (completer == null) _permissionTokenCompleters[peer] = Completer();

    _permissionController.add(peer);
    try {
      final token = await _permissionTokenCompleters[peer]!.future;
      return token;
    } catch (_) {
      _permissionTokenCompleters.remove(peer);
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

  void setPermissionResult({required PeerModel peer, required bool isGranted}) {
    if (isGranted) {
      _permissionTokenCompleters[peer]?.complete(_generateToken());
    } else {
      _permissionTokenCompleters[peer]?.completeError("permission denied");
    }
  }

  @override
  SessionType get type => .send;
}
