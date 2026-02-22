import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:nice_share/core/services/send_session/send_session_cubit.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'custom_router.dart';

class CustomServer {
  int get port => _server.port;

  final HttpServer _server;
  final CustomRouter _router;

  void addSendHandler(int sessionId, SendHandler sendHandler) {
    _router.handlers[sessionId] = sendHandler;
  }

  void removeSendHandler(int sessionId) => _router.handlers.remove(sessionId);

  static Future<CustomServer> start() async {
    try {
      final router = CustomRouter();
      final handler = Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.router.call);
      final server = await serve(handler, InternetAddress.anyIPv4, 0);
      return CustomServer._(server, router);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> close() async {
    await _server.close();
  }

  CustomServer._(HttpServer server, CustomRouter router)
    : _server = server,
      _router = router;
}
