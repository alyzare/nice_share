import 'dart:async';
import 'dart:io';

class FileHandler {
  final File _file;

  FileHandler({required File file}) : _file = file {
    fileLength = _file.lengthSync();
  }

  late final int fileLength;

  final _progressController = StreamController<double>.broadcast();

  int _bytesSent = 0;

  Stream<List<int>> call([int? start, int? end]) {
    return _file.openRead(start, end).map((chunk) {
      _bytesSent += chunk.length;
      _progressController.sink.add(_bytesSent / fileLength);
      return chunk;
    });
  }

  bool get fileExists => _file.existsSync();

  String get fileName => _file.uri.pathSegments.last;

  String get path => _file.path;

  static List<FileHandler> list(List<File> files) =>
      files.map((e) => FileHandler(file: e)).toList();

  Future<void> close() => _progressController.close();

  void deleteIfCached(Directory cacheDir) {
    if (_file.path.startsWith(cacheDir.path)) {
      _file.delete();
    }
  }
}
