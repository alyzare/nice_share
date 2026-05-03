import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class ServerBridge {
  static final ServerBridge _instance = ServerBridge._();

  static ServerBridge get instance => _instance;

  ServerBridge._();

  SessionsCubit? _sessionsCubit;

  set sessionsCubit(SessionsCubit value) => _sessionsCubit = value;

  void handleMessage(Object data) {
    if (data is! Map<String, dynamic> || data["id"] is! int) return;

    final type = data["type"];

    return type is String && data.isNotEmpty
        ? _handleRequest(data)
        : _completers[data["id"]]?.complete(data["data"]);
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
    }

    FlutterForegroundTask.sendDataToTask(result);
    debugPrint("DATA SENT TO FOREGROUND: $result");
  }

  Future<SessionModel?> createSession(SessionModel sessionBlueprint) async {
    final result = await _request(
      "session",
      action: "add",
      payload: sessionBlueprint.toMap(),
    );
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

  Future<List<SessionModel>> getSessions() async {
    final List<Map<String, Object?>> sessionsData =
        await _request("get_all") ?? [];
    return sessionsData
        .map((data) => SessionModel.fromMap(data))
        .toList(growable: false);
  }

  late final int _port;

  int get port => _port;

  Future<void> ensureServerRunning() async {
    _port = await _request("ensure_server_running");
    debugPrint(_port.toString());
  }

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

    FlutterForegroundTask.sendDataToTask(response);
    debugPrint("DATA SENT TO FOREGROUND: $response");
    return completer.future;
  }

  final Map<int, Completer> _completers = {};
}
