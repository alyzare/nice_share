import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/network/handlers/info_handler.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';

part 'send_session_state.dart';

class SendSessionCubit extends Cubit<SendSessionState> {
  final List<File> files;
  final int sessionId;

  final ServerBridge server;

  SendSessionCubit({
    required this.files,
    required this.sessionId,
    required this.server,
  }) : super(SendSessionBroadcasting()) {
    _udpTimer = Timer.periodic(Duration(milliseconds: 500), _broadcastAddress);
    server.addSendHandler(
      sessionId,
      .new(
        fileHandlers: FileHandler.list(files),
        infoHandler: InfoHandler(
          info: getInfo(),
          askPermission: _askPermission,
        ),
        tokenNotifier: _tokenNotifier,
      ),
    );
  }

  Map<String, Object> getInfo() => {
    "sessionId": sessionId,
    "files": files.map((f) => f.path).toList(),
  };

  void connect(String peerName) {
    emit(SendSessionConnected(peerName: peerName));
  }

  void progressing(int index, double progress) {
    if (state is! SendSessionConnected) return;
    if (state is! SendSessionProgressing) {
      emit(
        (state as SendSessionConnected).toProgressing(
          List.generate(files.length, (i) {
            return i == index ? progress : 0.0;
          }),
        ),
      );
    }
  }

  late final _permissionCompleter = Completer<bool>();

  late final Timer _udpTimer;

  final _tokenNotifier = ValueNotifier<String?>(null);

  late final _broadcastMessage = Uint8List.fromList([
    ..."NSS".codeUnits,
    ...(ByteData(8)..setInt64(0, sessionId)).buffer.asUint8List(),
    ...(ByteData(4)..setInt32(0, server.port)).buffer.asUint8List(),
  ]);

  Future<void> _broadcastAddress(Timer timer) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    socket.send(_broadcastMessage, InternetAddress('255.255.255.255'), 12459);
    socket.close();
  }

  Future<String?> _askPermission(String name) async {
    if (_tokenNotifier.value != null) return null;
    emit(SendSessionAskingPermission());
    try {
      final isGranted = await _permissionCompleter.future.timeout(
        Duration(seconds: 20),
      );
      if (!isGranted) {
        emit(SendSessionBroadcasting());
        return null;
      }
      _tokenNotifier.value = _generateToken();
      emit(SendSessionConnected(peerName: "TEST"));
      return _tokenNotifier.value;
    } on TimeoutException catch (_) {
      emit(SendSessionBroadcasting());
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

  @override
  Future<void> close() {
    _udpTimer.cancel();
    server.removeSendHandler(sessionId);
    _tokenNotifier.dispose();

    return super.close();
  }
}
