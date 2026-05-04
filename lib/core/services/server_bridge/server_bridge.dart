import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/message.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/services/server_handlers/base_handler.dart';
import 'package:nice_share/core/utils.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class ServerBridge {
  set sessionsCubit(SessionsCubit value) => _sessionsCubit = value;

  void handleMessage(Object data) {
    if (data is! Map<String, Object> && data is! Message) return;

    final message = data is Message
        ? data
        : Message.fromMap(data as Map<String, Object>);
    if (message.type != .unknown) {
      return _handleRequest(message);
    } else if (message.id != null) {
      _completers[message.id]?.complete(message);
    }
  }

  void _handleRequest(Message message) async {
    final Map<String, Object> payload = {};

    switch (message.type) {
      case .askPermission:
        final answer = await _sessionsCubit?.askPermission(
          sessionId: message.payload["id"] as int,
          peer: PeerModel.fromMap(
            message.payload["peer"] as Map<String, Object?>,
          ),
        );
        payload.addAll({"answer": answer ?? false});
      case .refresh:
        final sessionsData =
            message.payload["sessions"] as List<Map<String, Object?>>;
        _sessionsCubit?.refresh(
          sessionsData
              .map((data) => SessionModel.fromMap(data))
              .toList(growable: false),
        );
      case _:
    }
    final resultMessage = Message(
      type: .unknown,
      id: message.id,
      payload: payload,
    );
    if (resultMessage.id != null) sendDataToServer(resultMessage);
  }

  void sendDataToServer(Message message) => Platform.isAndroid
      ? FlutterForegroundTask.sendDataToTask(message.toMap)
      : WindowsHandler.instance.onReceiveData(message.toMap);

  Future<SessionModel?> createSession(SessionModel sessionBlueprint) async {
    final message = Message(
      id: newGlobalId,
      type: .session,
      action: .add,
      payload: sessionBlueprint.toMap,
    );
    final resultMessage = await _request(message);

    if ((resultMessage?.id ?? -1) > 0) {
      final peersMap =
          resultMessage!.payload["peers"] as Map<Uint8List, String?>?;
      return sessionBlueprint.upgrade(resultMessage.payload["id"] as int, peersMap);
    }
    return null;
  }

  Future<void> stopSession(int sessionId) async {
    await _request(
      Message(
        id: newGlobalId,
        type: .session,
        action: .remove,
        payload: {"id": sessionId},
      ),
    );
  }

  Future<void> ensureServerRunning() async {
    final result = await _request(
      Message(id: newGlobalId, type: .ensureServerRunning),
    );
    _port = result!.payload["port"] as int;
    debugPrint(_port.toString());
  }

  Future<List<SessionModel>> getSessions() async {
    final result = await _request(Message(id: newGlobalId, type: .getAll));

    final List<Map<String, Object?>> sessionsData =
        (result?.payload["sessions"] as List<Map<String, Object?>>?) ?? [];

    return sessionsData
        .map((data) => SessionModel.fromMap(data))
        .toList(growable: false);
  }

  late final int _port;

  final Map<int, Completer<Message?>> _completers = {};

  SessionsCubit? _sessionsCubit;

  int get port => _port;

  Future<Message?> _request(Message message) {
    final completer = Completer<Message?>();
    _completers[message.id!] = completer;

    sendDataToServer(message);
    return completer.future;
  }

  static ServerBridge get instance => _instance;

  static final ServerBridge _instance = ServerBridge._();

  ServerBridge._();
}
