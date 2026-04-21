import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CachedFilesCount extends StatefulWidget {
  const CachedFilesCount({super.key});

  @override
  State<CachedFilesCount> createState() => _CachedFilesCountState();
}

class _CachedFilesCountState extends State<CachedFilesCount> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: _cachedFiles(),
        builder: (context, snapshot) {
          final files = snapshot.data ?? [];
          return Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "Cached Files: "),
                  TextSpan(
                    text: files.length.toString(),
                    style: TextStyle(fontWeight: .bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Stream<List<File>> _cachedFiles() async* {
    final cacheDir = await getApplicationCacheDirectory();
    await for (final _ in cacheDir.watch(recursive: true)) {
      yield cacheDir.listSync().whereType<File>().toList();
    }
  }
}
