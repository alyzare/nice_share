

import 'package:nice_share/core/network/handlers/file_handler.dart';

class WebHandler {
  final Map<String, FileHandler> files;

  WebHandler({required this.files});

  FileHandler? getFile(String fileName) => files[fileName];
}
