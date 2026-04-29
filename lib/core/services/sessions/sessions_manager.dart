import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/models/sessions_event.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:nice_share/core/services/send_session/send_session.dart';
import 'package:nice_share/core/services/web_session/web_session.dart';

class SessionsManager {
  final List<BaseSession> _sessions = [];

  List<WebSession> get webSessions =>
      _sessions.whereType<WebSession>().toList();

  List<SendSession> get sendSessions =>
      _sessions.whereType<SendSession>().toList();

  List<BaseSession> get sessions => List.unmodifiable(_sessions);

  int addEvent(SessionsEvent event) {
    switch (event) {
      case SessionAddedEvent():
        return _createSession(event);
      case SessionUpdatedEvent():
        // TODO: Handle this case.
        throw UnimplementedError();
      case SessionRemovedEvent():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  int _createSession(SessionAddedEvent event) {
    switch (event.session.type) {
      case SessionType.send:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SessionType.receive:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SessionType.webShare:
        final session = WebSession(
          fileHandlers: event.session.files
              .map((e) => FileHandler(file: e))
              .toList(),
          sessionId: DateTime.now().microsecondsSinceEpoch,
        );
        _sessions.add(session);
        return session.sessionId;
    }
  }
}
