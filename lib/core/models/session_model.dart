import 'dart:io';
import 'dart:typed_data';

import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/send_session_model.dart';
import 'package:nice_share/core/models/web_session_model.dart';

import 'session_type.dart';

abstract class SessionModel {
  final int sessionId;
  final List<File> files;
  final SessionType type;

  SessionModel({
    required this.sessionId,
    required this.files,
    required this.type,
  });

  static SessionModel fromMap(Map<String, Object?> payload) {
    final sessionId = payload["id"] as int? ?? -1;
    final files =
        (payload["files"] as List?)?.map((e) => File(e)).toList() ?? [];
    final type = SessionType.values[payload["type"] as int];

    return switch (type) {
      .send => SendSessionModel(
        sessionId: sessionId,
        files: files,
        createPermissionCubit: true,
        peers: (payload["peers"] as List<Map<String, Object?>>?)
            ?.map((e) => PeerModel.fromMap(e))
            .toList(),
      ),
      // TODO: Handle this case.
      SessionType.receive => throw UnimplementedError(),
      .webShare => WebSessionModel(sessionId: sessionId, files: files),
    };
  }

  static SessionModel blueprint({
    List<File> files = const [],
    required SessionType type,
  }) {
    return switch (type) {
      .send => SendSessionModel(files: files, sessionId: -1),
      // TODO: Handle this case.
      .receive => throw UnimplementedError(),
      .webShare => WebSessionModel(sessionId: -1, files: files),
    };
  }

  SessionModel upgrade(int sessionId, [Map<Uint8List, String?>? peersMap]) =>
      switch (type) {
        SessionType.send => SendSessionModel(
          sessionId: sessionId,
          files: files,
          createPermissionCubit: true,
        ),
        SessionType.webShare => WebSessionModel(sessionId: sessionId, files: files),
        SessionType.receive => throw UnimplementedError(),
      };

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
