import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nice_share/core/models/file_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/services/send_session/send_session.dart';
import 'package:nice_share/core/services/sessions/sessions_manager.dart';
import 'package:nice_share/core/services/web_session/web_session.dart';
import 'package:nice_share/core/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

class CustomRouter {
  late final router = shelf.Router(notFoundHandler: _notFoundHandler);

  CustomRouter() {
    router
      ..get('/session/<sessionId>', _sessionHandler)..get(
        '/session/<sessionId>/<fId>', _fileHandler)..get(
        '/web/session/<sessionId>/<fName>', _webFileHandler)..get(
        '/web/session/<sessionId>', _webHandler)..get(
        '/static/<file>', _staticHandler)..get('/web/list', _webListHandler)
      ..post("/web/upload", _uploadHandler);
  }

  final sessionsManager = SessionsManager();

  List<WebSession> get webSessions => sessionsManager.webSessions;

  List<SendSession> get sendSessions => sessionsManager.sendSessions;

  Future<Response> _sessionHandler(Request request, String sessionId) async {
    final id = int.tryParse(sessionId);
    final session = sessionsManager.sendSessions
        .where((element) => element.sessionId == id)
        .firstOrNull;

    if (session == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }
    final peerName = request.headers['X-Peer-Name'];

    final info = await session.infoHandler.getInfo(peerName ?? "No Name");

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

    final session = sendSessions.where((element) => element.sessionId ==id,).firstOrNull;

    if (session == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    late final FileHandler fileHandler;
    try {
      fileHandler = session.getFile(id: fileId, token: token);
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

    final length = fileHandler.fileLength,
        range = request.headers['range'];

    int start = 0,
        end = length - 1;

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

    final session = webSessions
        .where((element) => element.sessionId == id)
        .firstOrNull;

    if (session == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }
    late final FileHandler fileHandler;
    try {
      fileHandler = session.getFile(fileName)!;
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

    final length = fileHandler.fileLength,
        range = request.headers['range'];

    int start = 0,
        end = length - 1;

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

    final session = webSessions
        .where((element) => element.sessionId == id)
        .firstOrNull;

    if (session == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid session id'}),
      );
    }

    final content = await rootBundle.loadString("assets/static/index.html");
    final stringBuilder = StringBuffer()
      ..write('<ul>');

    for (final fileHandler in session.fileHandlers) {
      final fileName = fileHandler.fileName;
      final fileSize = formattedSize(fileHandler.fileLength);

      final encodedName = Uri.encodeComponent(fileName);
      stringBuilder.write(
        '<li><a href="/web/session/$sessionId/$encodedName"><span class="name">📄 $fileName</span><span class="meta">$fileSize</span></a></li>',
      );
    }
    stringBuilder.write('</ul>');
    final listHtml = stringBuilder.toString();
    final finalContent = content
        .replaceFirst("<dart_title />", "<h2>Nice Share</h2>")
        .replaceAll(
      "<dart_form />",
      '<form id="uploadForm"><input type="file" name="file" multiple required /><button>Upload</button></form>',
    )
        .replaceFirst("<dart />", listHtml)
        .replaceFirst(
      "<dart_script />",
      '<script src="/static/upload.js" defer></script>',
    );

    return Response.ok(finalContent, headers: {'Content-Type': 'text/html'});
  }

  Future<Response> _webListHandler(Request request) async {
    final content = await rootBundle.loadString("assets/static/index.html");

    final stringBuilder = StringBuffer()
      ..write('<ul>');

    for (final key in webSessions.map((e) => e.sessionId)) {
      stringBuilder.write(
        '<li><a href="/web/session/$key"><span class="name">Session: $key</span></a></li>',
      );
    }
    stringBuilder.write('</ul>');
    final listHtml = stringBuilder.toString();
    final finalContent = content
        .replaceFirst("<dart_title />", "<h2>Sessions</h2>")
        .replaceFirst("<dart />", listHtml)
        .replaceFirst(
      "<dart_script />",
      '<script src="/static/upload.js" defer></script>',
    )
        .replaceAll(
      "<dart_form />",
      '<form id="uploadForm"><input type="file" name="file" multiple required /><button>Upload</button></form>',
    );

    return Response.ok(finalContent, headers: {'Content-Type': 'text/html'});
  }

  Future<Response> _uploadHandler(Request request) async {
    final fileNameEncoded = request.headers['x-file-name'];
    if (fileNameEncoded == null) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Missing X-File-Name header'}),
      );
    }

    final fileName = Uri.decodeComponent(fileNameEncoded);

    final downloadsDir = await _getDownloadDirectory();
    if (downloadsDir == null) {
      return Response.internalServerError(
        body: jsonEncode({'message': 'Cannot find downloads directory'}),
      );
    }

    final saveDir = Directory(
      path.join(
        downloadsDir.path,
        'Nice Share',
        MyFileType
            .fromExtension(fileName
            .split(".")
            .last)
            .dirName,
      ),
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

  Future<Response> _staticHandler(Request request, String file) async {
    if (file.contains('/') || file.contains(r'\') || file.contains('..')) {
      return Response.forbidden('Invalid path');
    }

    final String content;
    try {
      content = await rootBundle.loadString('assets/static/$file');
    } catch (_) {
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
    final bytes = utf8.encode(content);
    return Response.ok(
      bytes,
      headers: {
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      },
    );
  }

  Future<Response> _notFoundHandler(Request request) async {
    if (request.method == "GET" &&
        (request.url.path.isEmpty || request.url.path == "web")) {
      return webSessions.length == 1
          ? Response.found("web/session/${webSessions.first.sessionId}")
          : Response.found("web/list");
    }
    try {
      final content = await rootBundle.loadString(
        'assets/static/notfound.html',
      );
      final bytes = utf8.encode(content);
      return Response.notFound(
        bytes,
        headers: {
          'Content-Type': 'text/html',
          'Content-Length': bytes.length.toString(),
        },
      );
    } catch (_) {
      return Response.notFound('Not found');
    }
  }

  Future<Directory?> _getDownloadDirectory() async =>
      Platform.isAndroid
          ? Directory("/storage/emulated/0")
          : await path_provider.getDownloadsDirectory();
}
