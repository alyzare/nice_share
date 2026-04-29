import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

class WebSession with BaseSession {
  @override
  final List<FileHandler> fileHandlers;

  @override
  final int sessionId;

  WebSession({required this.fileHandlers, required this.sessionId});

  FileHandler? getFile(String fileName) {
    final file = fileHandlers.where((f) => f.fileName == fileName).firstOrNull;
    return file;
  }

  @override
  SessionType get type => .webShare;
}
