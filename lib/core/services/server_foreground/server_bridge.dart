import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/network/handlers/send_handlers.dart';

class ServerBridge {
  static final ServerBridge _instance = ServerBridge._();

  static ServerBridge get instance => _instance;

  ServerBridge._();

  void handleMessage(Object data) {
    if (data is! Map<String, dynamic> || data["id"] is! int) return;

    _completers[data["id"]]?.complete(data["data"]);
  }

  Future<SessionModel?> createSession(SessionModel sessionBlueprint) async {
    final int id = await _request(
      "session",
      action: "add",
      payload: sessionBlueprint.toMap(),
    );
    if (id > 0) {
      return SessionModel.fromBlueprint(
        blueprint: sessionBlueprint,
        sessionId: id,
      );
    }
    return null;
  }

  late final int _port;

  int get port => _port;

  Future<void> ensureServerRunning() async {
    _port = await _request("ensure_server_running");
    debugPrint(_port.toString());
  }

  void addSendHandler(int sessionId, SendHandler sendHandler) {
    //TODO: remove
  }

  void removeSendHandler(int sessionId) {
    //TODO: remove
  }

  void removeWebHandler(int sessionId) {
    //TODO: remove
  }

  Future<T?> _request<T>(
    String type, {
    String? action,
    Map<String, Object?> payload = const {},
  }) {
    final id = DateTime.now().microsecondsSinceEpoch;
    final completer = Completer<T?>();
    _completers[id] = completer;

    FlutterForegroundTask.sendDataToTask({
      "type": type,
      "id": id,
      "data": payload,
    });
    debugPrint(
      "DATA SENT TO FOREGROUND: ${{"type": type, "id": id, "data": payload}}",
    );
    return completer.future;
  }

  final Map<int, Completer> _completers = {};
}
