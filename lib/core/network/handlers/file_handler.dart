import 'dart:async';
import 'dart:io';

class FileHandler {
  final File _file;

  FileHandler({required File file}) : _file = file;

  late final fileLength = _file.lengthSync();

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
}
