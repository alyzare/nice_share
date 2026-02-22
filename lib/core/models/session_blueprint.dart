import 'dart:io';

import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:nice_share/core/services/send_session/send_session_cubit.dart';

class SessionBlueprint {
  final int sessionId;
  final List<File>? files;
  final SessionType type;

  SessionBlueprint({required this.sessionId, this.files, required this.type})
    : assert(
        !(type == SessionType.receive || type == SessionType.webReceive) ||
            files == null,
        'For receive types, files must be null',
      );

  BaseSession createSession(CustomServer server) {
    return switch (type) {
      SessionType.send => SendSessionCubit(
        files: files ?? [],
        server: server,
        sessionId: sessionId,
      ),
      // TODO: Handle this case.
      SessionType.receive => throw UnimplementedError(),
      // TODO: Handle this case.
      SessionType.webShare => throw UnimplementedError(),
      // TODO: Handle this case.
      SessionType.webReceive => throw UnimplementedError(),
    };
  }
}

enum SessionType { send, receive, webShare, webReceive }
