import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

class WebSessionCubit extends Cubit<Object?> with BaseSession {
  @override
  final List<File> files;

  @override
  final int sessionId;

  final CustomServer server;

  WebSessionCubit({
    required this.files,
    required this.sessionId,
    required this.server,
  }) : super(null) {
    takenIds.add(sessionId);
    server.addWebHandler(
      sessionId,
      .new(
        files: Map.fromEntries(
          FileHandler.list(files).map((e) => MapEntry(e.fileName, e)),
        ),
      ),
    );
  }

  @override
  final isClosedNotifier = ValueNotifier(false);

  @override
  Future<void> close() {
    isClosedNotifier.value = true;
    isClosedNotifier.dispose();
    return super.close();
  }

  static final List<int> takenIds = [];

  static int get newId {
    int id = 0;
    while (takenIds.contains(id)) {
      id++;
    }
    return id;
  }
}
