import 'dart:async';
import 'dart:io';

import 'package:nice_share/core/models/file_type.dart';
import 'package:nice_share/core/utils.dart';
import 'package:path/path.dart';

class FileHandler {
  final File _file;

  FileHandler({required File file, int? fileLength}) : _file = file {
    this.fileLength = fileLength ?? _file.lengthSync();
  }

  final _progressController = StreamController<double>.broadcast();

  late final int fileLength;

  int _bytesProceeded = 0;

  Stream<List<int>> send([int? start, int? end]) {
    return _file.openRead(start, end).map((chunk) {
      _bytesProceeded += chunk.length;
      _progressController.sink.add(_bytesProceeded / fileLength);
      return chunk;
    });
  }

  Future<void> receive(Stream<List<int>> bytes) {
    final sink = _file.openWrite();
    return sink.addStream(bytes);
  }

  bool get fileExists => _file.existsSync();

  String get fileName => _file.uri.pathSegments.last;

  String get path => _file.path;

  static List<FileHandler> list(List<File> files) =>
      files.map((e) => FileHandler(file: e)).toList();

  static Future<List<FileHandler>> listToReceive(
    List<Map<String, dynamic>> data,
  ) async {
    final downloadsDir = await getDownloadDirectory();
    if (downloadsDir == null) throw "No Directory";
    final future = data.map((e) async {
      final saveDir = Directory(
        join(
          downloadsDir.path,
          'Nice Share',
          MyFileType.fromExtension(
            (e["name"] as String).split(".").last,
          ).dirName,
        ),
      );
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
      return FileHandler(
        file: File(join(saveDir.path, e["name"] as String)),
        fileLength: e["length"] as int,
      );
    }).toList();

    return Future.wait(future);
  }

  Future<void> close() => _progressController.close();

  void deleteIfCached(Directory cacheDir) {
    if (_file.path.startsWith(cacheDir.path)) {
      _file.delete();
    }
  }
}
