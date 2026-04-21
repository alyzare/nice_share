import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

mixin BaseSession {
  int get sessionId;

  List<File> get files;

  final isClosedNotifier = ValueNotifier(false);

  @mustCallSuper
  Future<void> close() async {
    isClosedNotifier.value = true;
    isClosedNotifier.dispose();
    _deleteCachedFiles();
  }

  void _deleteCachedFiles() async {
    final cacheDir = await getApplicationCacheDirectory();

    for (final file in files) {
      if (file.path.startsWith(cacheDir.path)) {
        file.delete();
      }
    }
  }
}
