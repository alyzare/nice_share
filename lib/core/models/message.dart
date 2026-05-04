class Message {
  final MessageType type;
  final int? id;
  final RequestAction? action;
  final Map<String, Object> payload;

  Message({required this.type, this.id, this.payload = const {}, this.action});

  Map<String, Object> get toMap => {
    "id": ?id,
    "type": type.index,
    if (action != null) "action": action!.index,
    "payload": payload,
  };

  static Message fromMap(Map<String, Object?> data) {
    final type = MessageType.values[data["type"] as int? ?? 0];
    final id = data["id"] as int?;
    final payload = data["payload"] as Map<String, Object>?;
    final actionIndex = data["action"] as int?;
    return Message(
      id: id,
      type: type,
      payload: payload ?? {},
      action: actionIndex == null ? null : RequestAction.values[actionIndex],
    );
  }

  @override
  String toString() => toMap.toString();
}

enum MessageType {
  unknown,
  askPermission,
  refresh,
  session,
  ensureServerRunning,
  getAll,
  serverStopped,
}

enum RequestAction { add, remove, update }
