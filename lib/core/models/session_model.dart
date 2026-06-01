import 'dart:io';
import 'dart:typed_data';

import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/receive_session_model.dart';
import 'package:nice_share/core/models/send_session_model.dart';
import 'package:nice_share/core/models/web_session_model.dart';

import 'sender.dart';
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

  static SessionModel fromMap(Map<String, dynamic> payload) {
    final sessionId = payload["sessionId"] as int? ?? -1;
    final files =
        (payload["files"] as List?)?.map((e) => File(e)).toList() ?? [];
    final type = SessionType.values[payload["type"] as int];

    return switch (type) {
      .send => SendSessionModel(
        sessionId: sessionId,
        files: files,
        createPermissionCubit: true,
        peers: (payload["peers"] as List<Map<String, dynamic>>?)
            ?.map((e) => PeerModel.fromMap(e))
            .toList(),
      ),
      SessionType.receive => ReceiveSessionModel(
        sender: Sender.fromMap(payload["sender"] as Map<String, dynamic>),
        files: files,
        sessionId: sessionId,
      ),
      .webShare => WebSessionModel(sessionId: sessionId, files: files),
      .webReceive => throw UnimplementedError(),
    };
  }

  static SessionModel blueprint({
    List<File> files = const [],
    required SessionType type,
    Sender? sender,
  }) {
    assert(type != .receive || sender != null);
    return switch (type) {
      .send => SendSessionModel(files: files),
      .receive => ReceiveSessionModel(sender: sender!),
      .webShare => WebSessionModel(files: files),
      .webReceive => throw UnsupportedError(
        "WebReceiveSession doesn't need blueprint on UI side!",
      ),
    };
  }

  SessionModel upgrade(int sessionId, [Map<Uint8List, String?>? peersMap]) =>
      switch (type) {
        SessionType.send => SendSessionModel(
          sessionId: sessionId,
          files: files,
          createPermissionCubit: true,
        ),
        SessionType.webShare => WebSessionModel(
          sessionId: sessionId,
          files: files,
        ),
        SessionType.receive => ReceiveSessionModel(
          sessionId: sessionId,
          sender: (this as ReceiveSessionModel).sender,
          files: files,
        ),
        SessionType.webReceive => throw UnsupportedError(
          "WebReceiveSession doesn't need upgrade on UI side!",
        ),
      };

  @override
  String toString() {
    if (type == SessionType.webShare) {
      return "WEB: $sessionId";
    } else {
      return "SESSION: $sessionId";
    }
  }

  Map<String, dynamic> get toMap => {
    "sessionId": sessionId,
    "files": files.map((e) => e.path).toList(),
    "type": type.index,
  };
}
