import 'package:nice_share/core/models/session_model.dart';

sealed class SessionsEvent {
  final SessionModel session;

  SessionsEvent(this.session);

  static SessionsEvent byAction(String action, Map<String, Object?> payload) {
    switch (action) {
      case "add":
        return SessionAddedEvent(SessionModel.fromMap(payload));
      case "remove":
      case "update":
      default:
        throw UnimplementedError();
    }
  }
}

class SessionAddedEvent extends SessionsEvent {
  SessionAddedEvent(super.session);
}

class SessionUpdatedEvent extends SessionsEvent {
  SessionUpdatedEvent(super.session);
}

class SessionRemovedEvent extends SessionsEvent {
  SessionRemovedEvent(super.session);
}
