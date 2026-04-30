import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/services/sessions/sessions_manager.dart';
import 'package:nice_share/core/services/web_session/web_session.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'custom_router.dart';

class CustomServer {
  int get port => _server.port;

  final HttpServer _server;
  final CustomRouter _router;

  final StreamController<String> _logController;

  final SessionsManager sessionsManager;

  Stream<String> get requestLogs => _logController.stream;

  static Future<CustomServer> start({
    required SessionsManager sessionManager,
  }) async {
    try {
      final router = CustomRouter(sessionsManager: sessionManager);
      final logController = StreamController<String>.broadcast();
      final handler = Pipeline()
          .addMiddleware(
            logRequests(
              logger: (msg, isError) {
                logController.add(msg);

                FlutterForegroundTask.sendDataToMain({
                  "type": "log",
                  "message": msg,
                  "error": isError,
                });
              },
            ),
          )
          .addHandler(router.router.call);
      final server = await serve(handler, InternetAddress.anyIPv4, 8088);
      return CustomServer._(server, router, logController, sessionManager);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> close() async {
    await _server.close();
    await _logController.close();
  }

  CustomServer._(
    this._server,
    this._router,
    this._logController,
    this.sessionsManager,
  );

  void addWebSession(WebSession session) => _router.webSessions.add(session);

  void removeWebSession(int sessionId) => _router.webSessions.removeWhere(
    (element) => element.sessionId == sessionId,
  );
}
