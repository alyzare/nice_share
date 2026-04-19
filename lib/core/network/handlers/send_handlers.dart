import 'package:flutter/foundation.dart';

import 'file_handler.dart';
import 'info_handler.dart';

class SendHandler {
  final List<FileHandler> _fileHandlers;
  final InfoHandler infoHandler;
  final ValueNotifier<String?> _tokenNotifier;

  SendHandler({
    required List<FileHandler> fileHandlers,
    required this.infoHandler,
    required ValueNotifier<String?> tokenNotifier,
  }) : _fileHandlers = fileHandlers,
       _tokenNotifier = tokenNotifier;

  FileHandler getFile({required int id, required String token}) {
    if (_tokenNotifier.value != token) throw "Wrong token";
    return _fileHandlers[id];
  }
}
