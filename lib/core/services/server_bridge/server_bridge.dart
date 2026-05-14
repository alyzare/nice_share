import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/message.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/services/server_handlers/base_handler.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class ServerBridge {
  set sessionsCubit(SessionsCubit value) => _sessionsCubit = value;

  void handleMessage(dynamic data) {
    if (data is! Map<String, dynamic> && data is! Message) return;

    final message = data is Message
        ? data
        : Message.fromMap(data as Map<String, dynamic>);

    switch (message.type) {
      case MessageType.request:
        _handleRequest(message as RequestMessage);
      case MessageType.response:
        _completers[message.id]?.complete(message as ResponseMessage);
      case MessageType.idle:
        _handleIdleMessage(message as IdleMessage);
    }
  }

  void _handleRequest(RequestMessage message) async {
    final Map<String, dynamic> payload = {};

    switch (message.action) {
      case .askPermission:
        if (message.payload == null) return;
        final answer = await _sessionsCubit?.askPermission(
          sessionId: message.payload!["id"] as int,
          peer: PeerModel.fromMap(
            message.payload!["peer"] as Map<String, dynamic>,
          ),
        );
        payload.addAll({"answer": answer ?? false});

      case _:
    }
    final response = ResponseMessage.ofRequest(message, payload: payload);
    sendDataToServer(response);
  }

  void _handleIdleMessage(IdleMessage message) {
    switch (message.action) {
      case .refresh:
        if (message.payload == null) return;
        final sessionsData =
            message.payload!["sessions"] as List<Map<String, dynamic>>;
        _sessionsCubit?.refresh(
          sessionsData
              .map((data) => SessionModel.fromMap(data))
              .toList(growable: false),
        );
      case _:
    }
  }

  void sendDataToServer(Message message) => Platform.isAndroid
      ? FlutterForegroundTask.sendDataToTask(message.toMap)
      : WindowsHandler.instance.onReceiveData(message.toMap);

  Future<SessionModel?> createSession(SessionModel sessionBlueprint) async {
    final message = RequestMessage(
      action: .addSession,
      payload: sessionBlueprint.toMap,
    );
    final response = await _request(message);

    if ((response?.payload!["id"] as int? ?? -1) > 0) {
      final peersMap = response!.payload!["peers"] as Map<Uint8List, String?>?;
      return sessionBlueprint.upgrade(response.payload!["id"] as int, peersMap);
    }
    return null;
  }

  Future<void> stopSession(int sessionId) async {
    await _request(
      RequestMessage(action: .stopSession, payload: {"id": sessionId}),
    );
  }

  Future<void> ensureServerRunning() async {
    final result = await _request(RequestMessage(action: .ensureServerRunning));
    _port = result!.payload!["port"] as int;
    debugPrint(_port.toString());
  }

  Future<List<SessionModel>> getSessions() async {
    final result = await _request(RequestMessage(action: .getAll));

    final List<Map<String, dynamic>> sessionsData =
        (result?.payload!["sessions"] as List<Map<String, dynamic>>?) ?? [];

    return sessionsData
        .map((data) => SessionModel.fromMap(data))
        .toList(growable: false);
  }

  late final int _port;

  final Map<int, Completer<ResponseMessage>> _completers = {};

  SessionsCubit? _sessionsCubit;

  int get port => _port;

  Future<ResponseMessage?> _request(RequestMessage message) {
    final completer = Completer<ResponseMessage>();
    _completers[message.id] = completer;

    sendDataToServer(message);
    return completer.future;
  }

  static ServerBridge get instance => _instance;

  static final ServerBridge _instance = ServerBridge._();

  ServerBridge._();
}
