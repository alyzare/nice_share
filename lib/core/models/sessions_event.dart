import 'package:nice_share/core/models/session_model.dart';

sealed class SessionsEvent {
  static SessionsEvent fromPayload({
    required RequestAction action,
    required Map<String, dynamic> payload,
  }) {
    assert(payload["action"] is int);
    final action = RequestAction.values[payload["action"]];
    switch (action) {
      case .add:
        return SessionAddedEvent(SessionModel.fromMap(payload));
      case .stop:
        return SessionRemovedEvent(payload["id"] as int?);
      case .update:
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

enum RequestAction { add, update, stop }
