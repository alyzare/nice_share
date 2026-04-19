import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/network/handlers/web_handler.dart';
import 'package:nice_share/core/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'handlers/send_handlers.dart';

class CustomRouter {
  final router = shelf.Router();
  CustomRouter() {
    router
      ..get('/session/<sessionId>', _sessionHandler)
      ..get('/session/<sessionId>/<fId>', _fileHandler)
      ..get('/web/<sessionId>/<fName>', _webFileHandler)
      ..get('/web/<sessionId>', _webHandler)
      ..post("/web/<sessionId>", _uploadHandler)
      ..get('/static/<file>', _staticHandler);
  }

  final Map<int, SendHandler> handlers = {};
  final Map<int, WebHandler> webHandlers = {};

  Future<Response> _sessionHandler(Request request, String sessionId) async {
    final id = int.tryParse(sessionId);
    final infoHandler = handlers[id]?.infoHandler;

    if (infoHandler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }
    final peerName = request.headers['X-Peer-Name'];

    final info = await infoHandler.getInfo(peerName ?? "No Name");

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

  Response _webFileHandler(Request request, String sessionId, String fileName) {
    final id = int.tryParse(sessionId);

    if (id == null || fileName.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session or file id'}),
      );
    }

    final handler = webHandlers[id];

    if (handler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }
    late final FileHandler fileHandler;
    try {
      fileHandler = handler.getFile(fileName)!;
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

  Future<Response> _webHandler(Request request, String sessionId) async {
    final id = int.tryParse(sessionId);

    if (id == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    final handler = webHandlers[id];

    if (handler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    //load index.html
    final file = File("static/index.html");
    if (!file.existsSync()) {
      return Response.notFound(jsonEncode({"message": "File not found"}));
    }

    final content = file.readAsStringSync();
    final stringBuilder = StringBuffer()..write('<ul>');

    for (final fileHandler in handler.files.values) {
      final fileName = fileHandler.fileName;
      final fileSize = formattedSize(fileHandler.fileLength);

      stringBuilder.write(
        '<li><a href="${null /*todo*/}"><span class="name">📄 $fileName</span><span class="meta">$fileSize</span></a></li>',
      );
    }
    stringBuilder.write('</ul>');
    final listHtml = stringBuilder.toString();
    final finalContent = content.replaceFirst("<dart/>", listHtml);

    return Response.ok(finalContent, headers: {'Content-Type': 'text/html'});
  }

  Future<Response> _uploadHandler(Request request, String sessionId) async {
    final id = int.tryParse(sessionId);

    if (id == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    final handler = webHandlers[id];

    if (handler == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    final fileNameEncoded = request.headers['x-file-name'];
    if (fileNameEncoded == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Missing X-File-Name header'}),
      );
    }

    final fileName = Uri.decodeComponent(fileNameEncoded);

    final downloadsDir = await path_provider.getDownloadsDirectory();
    if (downloadsDir == null) {
      return Response.internalServerError(
        body: jsonEncode({'message': 'Cannot find downloads directory'}),
      );
    }

    final saveDir = Directory(
      path.join(downloadsDir.path, 'nice_share', 'web_$sessionId'),
    );
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final saveFile = File(path.join(saveDir.path, fileName));
    debugPrint("Saving file: ${saveFile.path}");
    final sink = saveFile.openWrite();

    try {
      await request.read().cast<List<int>>().pipe(sink);

      return Response.ok(jsonEncode({'message': 'Uploaded successfully'}));
    } catch (e) {
      debugPrint(e.toString());
      return Response.internalServerError(
        body: jsonEncode({'message': 'Failed to save file'}),
      );
    } finally {
      await sink.close();
    }
  }

  Response _staticHandler(Request request, String file) {
    if (file.contains('/') || file.contains(r'\') || file.contains('..')) {
      return Response.forbidden('Invalid path');
    }

    final f = File('static/$file');
    if (!f.existsSync()) {
      return Response.notFound('Not found');
    }

    String contentType = 'text/plain';
    if (file.endsWith('.css')) {
      contentType = 'text/css';
    } else if (file.endsWith('.js') || file.endsWith('.js')) {
      contentType = 'application/javascript';
    } else if (file.endsWith('.html')) {
      contentType = 'text/html';
    }
    return Response.ok(
      f.openRead(),
      headers: {
        'Content-Type': contentType,
        'Content-Length': f.lengthSync().toString(),
      },
    );
  }
}
