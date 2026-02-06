import 'dart:io';

mixin BaseSession {
  int get sessionId;

  List<File> get files;

  Future<void> close();
}
