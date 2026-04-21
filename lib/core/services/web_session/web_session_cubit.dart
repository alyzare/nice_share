import 'dart:io';
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
    _takenIds.add(sessionId);
    server.addWebHandler(
      sessionId,
      .new(
        files: Map.fromEntries(
          FileHandler.list(files).map((e) => MapEntry(e.fileName, e)),
        ),
      ),
    );
  }

  static final List<int> _takenIds = [];

  static int get newId {
    int id = 0;
    while (_takenIds.contains(id)) {
      id++;
    }
    return id;
  }
}
