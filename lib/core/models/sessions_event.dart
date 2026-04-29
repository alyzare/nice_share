import 'package:nice_share/core/models/session_model.dart';

sealed class SessionsEvent {
  static SessionsEvent byAction(String action, Map<String, Object?> payload) {
    switch (action) {
      case "add":
        return SessionAddedEvent(SessionModel.fromMap(payload));
      case "remove":
        return SessionRemovedEvent(payload["id"] as int?);
      case "update":
      default:
        throw UnimplementedError();
    }
  }
}

class SessionAddedEvent extends SessionsEvent {
  final SessionModel session;

  SessionAddedEvent(this.session);
}

class SessionUpdatedEvent extends SessionsEvent {
  final SessionModel session;

  SessionUpdatedEvent(this.session);
}

class SessionRemovedEvent extends SessionsEvent {
  final int? id;

  SessionRemovedEvent(this.id);
}
