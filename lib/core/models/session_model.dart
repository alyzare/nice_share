import 'dart:io';

import 'session_type.dart';

class SessionModel {
  final int sessionId;
  final List<File> files;
  final SessionType type;

  SessionModel.fromMap(Map<String, Object?> payload)
    : sessionId = payload["id"] as int? ?? -1,
      files =
          (payload["files"] as List?)
              ?.map((e) => File(e))
              .toList() ??
          [],
      type = SessionType.values[payload["type"] as int];

  SessionModel.blueprint({this.files = const [], required this.type})
    : sessionId = -1;

  SessionModel.fromBlueprint({
    required SessionModel blueprint,
    required this.sessionId,
  }) : files = blueprint.files,
       type = blueprint.type;

  @override
  String toString() {
    if (type == SessionType.webShare) {
      return "WEB: $sessionId";
    } else {
      return "SESSION: $sessionId";
    }
  }

  Map<String, Object?> toMap() => {
    "id": sessionId,
    "files": files.map((e) => e.path).toList(),
    "type": type.index,
  };
}
