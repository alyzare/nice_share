import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:nice_share/core/services/server_sessions/sessions_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'custom_router.dart';

class CustomServer {
  int get port => _server.port;

  final HttpServer _server;

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
              },
            ),
          )
          .addHandler(router.router.call);
      final server = await serve(handler, InternetAddress.anyIPv4, 8088);
      return CustomServer._(server, logController, sessionManager);
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
    this._logController,
    this.sessionsManager,
  );
}
