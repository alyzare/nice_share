import 'package:flutter/cupertino.dart';
import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:path_provider/path_provider.dart';

mixin BaseSession {
  SessionType get type;

  int get sessionId;

  List<FileHandler> get fileHandlers;

  final isClosedNotifier = ValueNotifier(false);

  @mustCallSuper
  Future<void> close() async {
    isClosedNotifier.value = true;
    isClosedNotifier.dispose();
    for (final handler in fileHandlers) {
      handler.close();
    }
    _deleteCachedFiles();
  }

  void _deleteCachedFiles() async {
    final cacheDir = await getApplicationCacheDirectory();

    for (final file in fileHandlers) {
      file.deleteIfCached(cacheDir);
      // if (file.path.startsWith(cacheDir.path)) {
      //   file.delete();
      // }
    }
  }

  Map<String, Object?> toMap() => {
    "sessionId": sessionId,
    "files": fileHandlers.map((e) => e.fileName).toList(),
    "type": type.index,
  };
}
