import 'dart:async';

import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/models/sessions_event.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:nice_share/core/services/send_session/send_session.dart';
import 'package:nice_share/core/services/server_foreground/global_id_service.dart';
import 'package:nice_share/core/services/server_foreground/server_task_handler.dart';
import 'package:nice_share/core/services/web_session/web_session.dart';

class SessionsManager {
  final ServerTaskHandler taskHandler;
  final List<BaseSession> _sessions = [];

  final Map<int, StreamSubscription<PeerModel>> _permissionSubs = {};

  SessionsManager({required this.taskHandler});

  List<WebSession> get webSessions =>
      _sessions.whereType<WebSession>().toList();

  List<SendSession> get sendSessions =>
      _sessions.whereType<SendSession>().toList();

  List<BaseSession> get sessions => List.unmodifiable(_sessions);

  Future<int> addEvent(SessionsEvent event) async {
    switch (event) {
      case SessionAddedEvent():
        return await _createSession(event);
      case SessionUpdatedEvent():
        // TODO: Handle this case.
        throw UnimplementedError();
      case SessionRemovedEvent():
        return _removeSession(event);
    }
  }

  Future<int> _createSession(SessionAddedEvent event) async {
    switch (event.session.type) {
      case SessionType.send:
        final session = SendSession(
          sessionId: GlobalIdService.newId,
          fileHandlers: event.session.files
              .map((e) => FileHandler(file: e))
              .toList(),
          serverPort: await taskHandler.serverPort,
        );
        _permissionSubs[session.sessionId] = session.permissionEvents.listen((
          peer,
        ) async {
          final answer = await taskHandler.askPermission(
            sessionId: session.sessionId,
            peer: peer,
          );
          session.setPermissionResult(isGranted: answer, peer: peer);
        });
        _sessions.add(session);
        return session.sessionId;
      case SessionType.receive:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SessionType.webShare:
        final session = WebSession(
          fileHandlers: event.session.files
              .map((e) => FileHandler(file: e))
              .toList(),
          sessionId: GlobalIdService.newId,
        );
        _sessions.add(session);
        return session.sessionId;
    }
  }

  int _removeSession(SessionRemovedEvent event) {
    final session = _sessions
        .where((session) => event.id == session.sessionId)
        .firstOrNull;
    if (session == null) return -1;

    _sessions.remove(session);
    session.close();
    return 0;
  }
}
