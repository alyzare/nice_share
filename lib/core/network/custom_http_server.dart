import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:nice_share/core/services/send_session/send_session_cubit.dart';

class CustomHttpServer {
  HttpServer? _server;

  StreamSubscription<HttpRequest>? _subscription;

  final List<BaseSession> _sessions = [];

  Future<void> addSession(BaseSession session) async {
    _sessions.add(session);
    await _ensureRunning();
    if (session is SendSessionCubit) {
      session.setHttpServerPort(port);
    }
  }

  void stopSession(BaseSession session) {
    _sessions.remove(session);
    if (_sessions.isEmpty) {
      _stopServer();
    }
  }

  Future<int> _ensureRunning() async {
    if (_server == null) {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      _subscription = _server!.listen(_handleRequest);
    }
    return _server!.port;
  }

  void _stopServer() async {
    await _subscription?.cancel();
    await _server?.close();
    _subscription = null;
    _server = null;
  }

  void _handleRequest(HttpRequest event) {
    switch (event.method) {
      case "GET":
        _handleGet(event);
    }
  }

  Future<void> _handleGet(HttpRequest event) async {
    final requestType = event.headers.value("X-Request-Type");

    if (requestType == null) {
      event.response
        ..statusCode = HttpStatus.forbidden
        ..write("Unauthorized")
        ..close();
      return;
    }

    final session =
        _sessions
                .where(
                  (s) =>
                      s.sessionId ==
                          int.tryParse(
                            event.headers.value("X-Session-Id") ?? "",
                          ) &&
                      s is SendSessionCubit,
                )
                .firstOrNull
            as SendSessionCubit?;

    if (session == null) {
      event.response
        ..statusCode = HttpStatus.badRequest
        ..write("Session not in header")
        ..close();
      return;
    }

    switch (requestType) {
      case "info":
        event.response
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode(session.toJson()))
          ..close();
        session.connect(event.connectionInfo?.remoteAddress.address ?? "NULL");
      case "file":
        final fileIndex = int.tryParse(
          event.headers.value("X-File-Index") ?? "",
        );
        if (fileIndex == null ||
            fileIndex < 0 ||
            fileIndex >= session.files.length) {
          event.response
            ..statusCode = HttpStatus.badRequest
            ..write("Invalid file index")
            ..close();
          return;
        }
        final file = session.files[fileIndex];
        event.response.statusCode = HttpStatus.ok;
        event.response.headers.contentLength = await file.length();
        int sentBytes = 0;
        final stream = file.openRead();
        stream.listen((chunk) {
          sentBytes += chunk.length;
          event.response.add(chunk);
        });
        await event.response.close();
      default:
        event.response
          ..statusCode = HttpStatus.badRequest
          ..write("Unknown request type")
          ..close();
    }
  }

  static CustomHttpServer get instance => _instance;

  int get port => _server?.port ?? -1;

  static final CustomHttpServer _instance = CustomHttpServer._();

  CustomHttpServer._();
}
