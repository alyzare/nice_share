import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/services/server_foreground/windows_handler.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class ServerBridge {
  set sessionsCubit(SessionsCubit value) => _sessionsCubit = value;

  void handleMessage(Object data) {
    if (data is! Map<String, Object?>) return;

    final type = data["type"];

    return type is String && data.isNotEmpty
        ? _handleRequest(data)
        : (data["id"] is int)
        ? _completers[data["id"]]?.complete(data["data"])
        : null;
  }

  void _handleRequest(Map<String, dynamic> data) async {
    final String type = data["type"];

    final result = {"id": data["id"]};

    switch (type) {
      case "ask_permission":
        final answer = await _sessionsCubit?.askPermission(
          sessionId: data["payload"]["id"],
          peer: PeerModel.fromMap(data["payload"]["peer"]),
        );
        result["payload"] = answer;
      case "refresh":
        final List<Map<String, Object?>> sessionsData = data["payload"];
        return _sessionsCubit?.refresh(
          sessionsData
              .map((data) => SessionModel.fromMap(data))
              .toList(growable: false),
        );
    }

    sendDataToServer(result);
    debugPrint("DATA SENT TO FOREGROUND: $result");
  }

  void sendDataToServer(Object data) => Platform.isAndroid
      ? FlutterForegroundTask.sendDataToTask(data)
      : WindowsHandler.instance.onReceiveData(data);

  Future<SessionModel?> createSession(SessionModel sessionBlueprint) async {
    final map = sessionBlueprint.toMap();
    final result = await _request("session", action: "add", payload: map);
    final id = result["id"] as int? ?? -1;
    if (id > 0) {
      final peersMap = result["peers"] as Map<Uint8List, String?>?;
      return sessionBlueprint.upgrade(id, peersMap);
    }
    return null;
  }

  Future<void> stopSession(int sessionId) async {
    await _request("session", action: "remove", payload: {"id": sessionId});
  }

  Future<void> ensureServerRunning() async {
    _port = await _request("ensure_server_running");
    debugPrint(_port.toString());
  }

  Future<List<SessionModel>> getSessions() async {
    final List<Map<String, Object?>> sessionsData =
        await _request("get_all") ?? [];
    return sessionsData
        .map((data) => SessionModel.fromMap(data))
        .toList(growable: false);
  }

  late final int _port;

  final Map<int, Completer> _completers = {};

  SessionsCubit? _sessionsCubit;

  int get port => _port;

  Future<T?> _request<T>(
    String type, {
    String? action,
    Map<String, Object?> payload = const {},
  }) {
    final messageId = DateTime.now().microsecondsSinceEpoch;
    final completer = Completer<T?>();
    _completers[messageId] = completer;

    final response = {
      "type": type,
      "id": messageId,
      "action": ?action,
      "payload": payload,
    };

    sendDataToServer(response);
    return completer.future;
  }

  static ServerBridge get instance => _instance;

  static final ServerBridge _instance = ServerBridge._();

  ServerBridge._();
}
