sealed class Message {
  final MessageAction action;
  final int id;
  final Map<String, dynamic>? payload;

  Message({required this.action, required this.id, this.payload});

  MessageType get type;

  Map<String, dynamic> get toMap => {
    "id": id,
    "type": type.index,
    "action": action.index,
    "payload": payload,
  };

  factory Message.fromMap(Map<String, dynamic> data) {
    final type = MessageType.values[data["type"] as int];
    final action = MessageAction.values[data["action"] as int];
    final id = data["id"] as int;
    final payload = data["payload"] as Map<String, dynamic>?;

    switch (type) {
      case MessageType.request:
        return RequestMessage(action: action, id: id, payload: payload);
      case MessageType.response:
        return ResponseMessage(action: action, id: id, payload: payload);
      case MessageType.idle:
        return IdleMessage(action: action, payload: payload);
    }
  }

  @override
  String toString() =>
      (toMap
            ..update("type", (value) => MessageType.values[value].name)
            ..update("action", (value) => MessageAction.values[value].name))
          .toString();

  static int _messageId = 0;

  static int get newId => _messageId++;
}

class RequestMessage extends Message {
  RequestMessage({required super.action, super.payload, int? id})
    : super(id: id ?? Message.newId);

  @override
  MessageType get type => .request;
}

class ResponseMessage extends Message {
  ResponseMessage.ofRequest(RequestMessage request, {super.payload})
    : super(action: request.action, id: request.id);

  ResponseMessage({required super.action, required super.id, super.payload});

  @override
  MessageType get type => .response;
}

class IdleMessage extends Message {
  IdleMessage({required super.action, super.payload}) : super(id: -1);

  @override
  MessageType get type => .idle;
}

enum MessageAction {
  unknown,
  askPermission,
  refresh,
  addSession,
  stopSession,
  updateSession,
  ensureServerRunning,
  getAll,
  serverStopped,
  style,
  askUploadPermission,
}

enum MessageType { request, response, idle }
