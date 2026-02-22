import 'dart:convert';

import 'package:nice_share/core/services/send_session/file_handler.dart';
import 'package:nice_share/core/services/send_session/send_session_cubit.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class CustomRouter {
  final router = Router();

  CustomRouter() {
    router
      ..post('/session/<sessionId>', _sessionHandler)
      ..get('/session/<sessionId>/<fId>', _fileHandler);
  }

  final Map<int, SendHandler> handlers = {};

  Future<Response> _sessionHandler(Request request, String sessionId) async {
    final id = int.tryParse(sessionId);
    final infoHandler = handlers[id]?.infoHandler;

    if (infoHandler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    final info = await infoHandler.getInfo();

    if (info == null) {
      return Response.forbidden(jsonEncode({"message": "Permission Denied!"}));
    }

    return Response.ok(jsonEncode(info));
  }

  Response _fileHandler(Request request, String sessionId, String fId) {
    final id = int.tryParse(sessionId);
    final fileId = int.tryParse(fId);
    final token = request.headers['X-Token'];

    if (token == null) {
      return Response.forbidden(jsonEncode({"message": "Permission Denied!"}));
    }

    if (id == null || fileId == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session or file id'}),
      );
    }

    final handler = handlers[id];

    if (handler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    late final FileHandler fileHandler;
    try {
      fileHandler = handler.getFile(id: fileId, token: token);
    } catch (e) {
      if (e.toString() == "Wrong token") {
        return Response.unauthorized(
          jsonEncode({"message": "Permission Denied!"}),
        );
      }
      if (e is RangeError) {
        return Response.badRequest(
          body: jsonEncode({"message": "Invalid file id"}),
        );
      }
      return Response.internalServerError();
    }

    if (!fileHandler.fileExists) {
      return Response.notFound(jsonEncode({"message": "File not found"}));
    }

    final length = fileHandler.fileLength, range = request.headers['range'];

    int start = 0, end = length - 1;

    if (range != null && range.startsWith("bytes=")) {
      final parts = range.substring(6).split('-');
      start = int.parse(parts[0]);
      if (parts.length > 1 && parts[1].isNotEmpty) {
        end = int.parse(parts[1]);
      }
      if (end >= length) end = length - 1;
    }

    final stream = fileHandler(start, end + 1);

    return Response(
      range != null ? 206 : 200,
      body: stream,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Length': (end - start + 1).toString(),
        'Accept-Ranges': 'bytes',
        if (range != null) 'Content-Range': 'bytes $start-$end/$length',
        'Content-Disposition': 'attachment; filename="${fileHandler.fileName}"',
      },
    );
  }
}
