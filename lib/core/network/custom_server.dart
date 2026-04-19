import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nice_share/core/network/handlers/web_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'custom_router.dart';
import 'handlers/send_handlers.dart';

class CustomServer {
  int get port => _server.port;

  final HttpServer _server;
  final CustomRouter _router;

  final StreamController<String> _logController;
  Stream<String> get requestLogs => _logController.stream;

  void addSendHandler(int sessionId, SendHandler sendHandler) {
    _router.handlers[sessionId] = sendHandler;
  }

  void removeSendHandler(int sessionId) => _router.handlers.remove(sessionId);

  static Future<CustomServer> start() async {
    try {
      final router = CustomRouter();
      final logController = StreamController<String>.broadcast();
      final handler = Pipeline()
          .addMiddleware(
            logRequests(logger: (msg, isError) => logController.add(msg)),
          )
          .addHandler(router.router.call);
      final server = await serve(handler, InternetAddress.anyIPv4, 8088);
      debugPrint("Server is running on port ${server.port}");
      return CustomServer._(server, router, logController);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> close() async {
    await _server.close();
    await _logController.close();
  }

  CustomServer._(this._server, this._router, this._logController);

  void addWebHandler(int sessionId, WebHandler handler) {
    _router.webHandlers[sessionId] = handler;
  }

  void removeWebHandler(int sessionId) => _router.webHandlers.remove(sessionId);
}
